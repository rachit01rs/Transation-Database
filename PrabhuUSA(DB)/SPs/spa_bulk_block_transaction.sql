/****** Object:  StoredProcedure [dbo].[spa_bulk_block_transaction]    Script Date: 06/17/2014 13:31:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_bulk_block_transaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_bulk_block_transaction]
GO

/****** Object:  StoredProcedure [dbo].[spa_bulk_block_transaction]    Script Date: 06/17/2014 13:31:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
** Database : Prabhu_Usa
** Object : 
** Purpose : ------------- 
**
** Author: Paribesh Jung Karki	
** Date:    05/18/2014
**
** Modifications:
** Purpose     : added selection option Payout Agent list. 
** Author      : Sunita Shrestha
** Date        : 18th July 2014  
**			
** Execute Examples :
** 	spa_bulk_block_transaction @flag='s', @cmbAgentName='20100031', @receiveCountry='Nepal', @confirmBlock='U' 
*/

CREATE PROCEDURE [dbo].[spa_bulk_block_transaction]
@flag CHAR(1),
@cmbAgentName varchar (50)=NULL,
@receiveCountry VARCHAR(50)=NULL,
@payment_type VARCHAR(50)=NULL,
@confirmBlock VARCHAR(50),
@Username VARCHAR(50),
@PayoutAgent VARCHAR(50)=NULL,
@senderCountry VARCHAR(50)=NULL
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @datetime DATETIME
	SET @datetime=dbo.getDateHO(GETUTCDATE()) 
		IF @flag='s' -- summary report
			BEGIN
					
				SELECT ReceiverCountry,COUNT(ReceiverCountry) AS [No. of transaction] FROM dbo.moneySend WITH (NOLOCK)
				WHERE CASE WHEN @cmbAgentName IS NOT NULL THEN agentid ELSE '1' END = ISNULL(@cmbAgentName,'1') 
				AND CASE WHEN @senderCountry IS NOT NULL THEN SenderCountry ELSE '1' END = ISNULL(@senderCountry,'1') 
				AND CASE WHEN @receiveCountry IS NOT NULL THEN ReceiverCountry ELSE '1' END = ISNULL(@receiveCountry,'1') 
				
				AND CASE WHEN @payment_type IS NOT NULL THEN PaymentType ELSE '1' END = ISNULL(@payment_type,'1') 
				AND CASE WHEN @confirmBlock = 'U' THEN TransStatus ELSE '1' END =  CASE WHEN @confirmBlock = 'U' THEN  'Block' ELSE '1' END 
				AND CASE WHEN @confirmBlock = 'B' THEN TransStatus ELSE '1' END <> CASE WHEN @confirmBlock = 'B' THEN  'Block' ELSE '2' END 
				AND CASE WHEN @PayoutAgent IS NOT NULL THEN expected_payoutagentid ELSE '1' END = ISNULL(@PayoutAgent,'1')  
				AND TransStatus NOT IN ('Cancel') AND status IN ('Un-Paid')
				GROUP BY ReceiverCountry	 
			END
		
		IF @flag='u' -- update report
		BEGIN
			BEGIN TRY
			BEGIN TRANSACTION trans
						CREATE TABLE #temp 
						(	tranno BIGINT,
							refno VARCHAR(50)
						)
						IF @confirmBlock='B'
						BEGIN
							INSERT INTO #temp (tranno,refno)
							SELECT Tranno,refno FROM dbo.moneySend WITH (NOLOCK)
							WHERE CASE WHEN @cmbAgentName IS NOT NULL THEN agentid ELSE '1' END = ISNULL(@cmbAgentName,'1') 
							AND CASE WHEN @senderCountry IS NOT NULL THEN SenderCountry ELSE '1' END = ISNULL(@senderCountry,'1') 
							AND CASE WHEN @receiveCountry IS NOT NULL THEN ReceiverCountry ELSE '1' END = ISNULL(@receiveCountry,'1') 
							AND CASE WHEN @payment_type IS NOT NULL THEN PaymentType ELSE '1' END = ISNULL(@payment_type,'1') 
							AND CASE WHEN @PayoutAgent IS NOT NULL THEN expected_payoutagentid ELSE '1' END = ISNULL(@PayoutAgent,'1')  
							AND TransStatus NOT IN ('Block','Cancel') AND status IN ('Un-Paid')
							
							update Moneysend set transStatus='Block',transStatusPrevious=TransStatus,
							lock_dot=getdate(),lock_by= 'HO:'+@Username	 FROM dbo.moneySend m
							JOIN #temp t ON m.Tranno=t.Tranno
							
							
							insert into TransactionNotes(RefNo,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)
							select t.refno,'This Transaction is Block by HO:'+@Username,@datetime,'HO:'+@Username,'A',2,t.tranno 
							from #temp t 		
							
						END
						ELSE
						BEGIN
							INSERT INTO #temp (tranno,refno)
							SELECT Tranno,refno FROM dbo.moneySend WITH (NOLOCK)
							WHERE CASE WHEN @cmbAgentName IS NOT NULL THEN agentid ELSE '1' END = ISNULL(@cmbAgentName,'1')  
							AND CASE WHEN @senderCountry IS NOT NULL THEN SenderCountry ELSE '1' END = ISNULL(@senderCountry,'1') 
							AND CASE WHEN @receiveCountry IS NOT NULL THEN ReceiverCountry ELSE '1' END = ISNULL(@receiveCountry,'1') 
							AND CASE WHEN @payment_type IS NOT NULL THEN PaymentType ELSE '1' END = ISNULL(@payment_type,'1') 
							AND CASE WHEN @PayoutAgent IS NOT NULL THEN expected_payoutagentid ELSE '1' END = ISNULL(@PayoutAgent,'1')  
							AND TransStatus IN ('Block') AND status IN ('Un-Paid')
							
							update Moneysend set transStatus=ISNULL(transStatusPrevious,'Payment'),lock_dot=@datetime,lock_by= 'HO:'+@Username	
							FROM dbo.moneySend m JOIN #temp t1 ON m.Tranno=t1.Tranno
							
							
							
							insert into TransactionNotes(RefNo,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)
							select t1.refno,'This Transaction is Unblock by HO:'+@Username,@datetime,'HO:'+@Username,'A',2,t1.tranno
							from #temp t1 
							
							
						END		
			
						SELECT 'Success' STATUS, 'You have Successfully updated' msg
				
			COMMIT TRANSACTION trans
			
			--**** Thrid party Status Update (Prabhu Cash)           
			DECLARE @refno VARCHAR(50),@flag_block VARCHAR(50),@remarks VARCHAR(100)
			
			IF @confirmBlock='B'
				BEGIN
					SET @confirmBlock='Block'
					SET @flag_block='b'
					SET @remarks='This Transaction is block by HO:'+@Username
				END
				
			ELSE
				BEGIN
					SET @confirmBlock='Un-Block'
					SET @flag_block='u'
					SET @remarks='This Transaction is Unblock by HO:'+@Username
				END
				
				
			DECLARE db_cursor CURSOR
			FOR
				SELECT  refno
				FROM    #temp WITH ( NOLOCK ) 
	         

			OPEN db_cursor   
			FETCH NEXT FROM db_cursor INTO @refno

			WHILE @@FETCH_STATUS = 0 
				BEGIN 
					EXEC spa_integration_partner_cancel_ticket @flag_block, NULL, @refno,
						@confirmBlock, NULL, NULL, @Username, NULL,@remarks , NULL,
						NULL   
					FETCH NEXT FROM db_cursor INTO @refno
				END   

			CLOSE db_cursor   
			DEALLOCATE db_cursor
	            
			DROP TABLE #temp
       	
		END TRY
		BEGIN CATCH            
		          
		  if @@trancount>0           
				rollback TRANSACTION  trans        
		          
		 declare @desc varchar(1000)            
		 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'            
		 INSERT INTO [error_info]            
				   ([ErrorNumber]            
				   ,[ErrorDesc]            
				   ,[Script]            
				   ,[ErrorScript]            
				   ,[QueryString]            
				   ,[ErrorCategory]            
				   ,[ErrorSource]            
				   ,[error_date])            
		 select -1,@desc,'spa_bulk_block_transaction','SQL',@desc,'SQL','spa_bulk_block_transaction',getdate()            

		 select 'ERROR' STATUS,'Please try again: '+CAST(@@IDENTITY as varchar(10)) msg
		          
		END CATCH
	END 
END
GO


/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 2/23/2013 7:43:44 PM
 ************************************************************/

--USE [TML_Remit_Msia_db]
IF OBJECT_ID('[spa_ExportTransaction_UttaraBank]', 'P') IS NOT NULL
    DROP PROCEDURE spa_ExportTransaction_UttaraBank
GO

/****** Object:  StoredProcedure [dbo].[spa_ExportTransactionPayoutWise]    Script Date: 02/20/2013 16:49:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*  
** Database : prabhuUsa  
** Object  : spa_ExportTransaction_UttaraBank  
**  
**  
**  
** Purpose  : export Transaction to excel format after batch processing  
** Author :  Kanchan Dahal 
** Date  :  18 March 2013, SUN  
**  
** Modifications:  
    
** Execute Examples :  
**   */
CREATE PROCEDURE [dbo].[spa_ExportTransaction_UttaraBank]
    @paymentType VARCHAR(50) = NULL ,  
    @login_user_id VARCHAR(50) ,  
    @branch_id VARCHAR(50) ,  
    @digital_id VARCHAR(200) = NULL ,  
    @process_id VARCHAR(150) ,  
    @batch_Id VARCHAR(100) = NULL,  
 @fromdate varchar(100)=NULL,  
 @todate varchar(100)=NULL,  
 @check CHAR(1)=NULL  
AS
	  SET XACT_ABORT ON ;    
    BEGIN TRY    
        IF @todate IS NOT NULL 
            SET @todate = @todate + ' 23:59:59:998'  
     
        DECLARE @desc VARCHAR(1000) ,
            @agent_id VARCHAR(50)    
        DECLARE @ledger_tabl VARCHAR(100) ,
            @sql VARCHAR(MAX)    
  -------------------------------------------------------------------------------  
        SET @agent_id = '20100019'  
  --20100003
  -------------------------------------------------------------------------------  
        DECLARE @expected_payoutagentid VARCHAR(50) ,
            @rBankID VARCHAR(50) ,
            @rBankName VARCHAR(200) ,
            @rBankBranch VARCHAR(200) ,
            @GMT_Date DATETIME ,
            @cover_fund MONEY ,
            @payout_fund_limit CHAR(1) ,
            @total_row INT 
   ---------------------------------------------------------------------------------------- 
   ------------ For Auto Paid txn----------------------------------------------------------    
        IF @branch_id IS NULL 
            SELECT TOP 1
                    @branch_Id = agent_branch_Code
            FROM    agentdetail a WITH ( NOLOCK )
                    JOIN agentbranchdetail b WITH ( NOLOCK ) ON a.agentcode = b.agentcode
            WHERE   a.agentCode = @agent_id
                    AND b.isHeadOffice = 'y'  
        IF @branch_id IS NULL 
            SELECT TOP 1
                    @branch_Id = agent_branch_Code
            FROM    agentdetail a WITH ( NOLOCK )
                    JOIN agentbranchdetail b WITH ( NOLOCK ) ON a.agentcode = b.agentcode
            WHERE   a.agentCode = @agent_id   
          
        SELECT  @expected_payoutagentid = a.agentcode ,
                @rBankID = b.agent_branch_code ,
                @rBankName = a.companyName ,
                @rBankBranch = b.Branch ,
                @GMT_Date = dbo.getDateHO(GETUTCDATE()) 
                --,@cover_fund = a.currentBalance - ISNULL(Account_No_IB, 0)
        FROM    agentdetail a WITH ( NOLOCK )
                JOIN agentbranchdetail b WITH ( NOLOCK ) ON a.agentcode = b.agentcode
        WHERE   agent_branch_code = @branch_id    
   ------------------------------------------------------------------------------------------------- 
        BEGIN TRANSACTION trans  
         
    
        SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @login_user_id,
                                             @process_id)   
                                               
  IF @paymentType='Cash Pay'
  SET @sql='select '''' [SL. NO.],dbo.decryptdb(refno) as [TT/INVOICE/REFERENCE NO.],
		convert(varchar,cast(confirmDate as datetime),103) as [Tran. Date],
		totalRoundAmt [Amount],
		ReceiverName as [BENEFICIARY],
		ReceiverID as [ID],
		rBankName [BANK],
		replace(isNULL(rBankBranch,'''')+''-''+ isNULL(b.address,''''),'','','' '') as [BRANCH WITH DISTRICT],
		senderName as [REMITTER],
		receiver_mobile as [CELL NO. OF BENEFICIARY],
		sender_mobile as [CELL NO. OF REMITTER],
		ag.currencyType '
  ELSE
  SET @sql='select '''' [SL. NO.],dbo.decryptdb(refno) as [TT/INVOICE/REFERENCE NO.],
		convert(varchar,cast(confirmDate as datetime),103) as [Tran. Date],
		totalRoundAmt [Amount],
		ReceiverName as [BENEFICIARY],
		rBankACNo as [A/C NO.],
		case when paymentType=''Bank Transfer'' then rBankName else ben_bank_name end as [BANK],
		case when paymentType =''Bank Transfer'' then replace(isNULL(rBankBranch,'''')+''-''+ isNULL(b.address,''''),'','','' '') else rBankAcType end as [BRANCH WITH DISTRICT],
		senderName as [REMITTER],
		totalRoundAmt as [AMOUNT IN WORD],
		''Tel:''+replace(ReceiverPhone,'','',''\'') as [CONTACT NO. OF BENEFICIARY],
		receiver_mobile as [CELL NO. OF BENEFICIARY],
		sender_mobile as [CELL NO. OF REMITTER],
		ag.currencyType '	 
		                                          
  SET @sql=@sql +' INTO '+ @ledger_tabl +'   
  from moneysend m WITH(NOLOCK)   
   left outer join agentbranchdetail b WITH(NOLOCK) on m.rBankID=b.agent_branch_code 
   left outer join agentdetail ag on ag.agentCode=b.agentCode   
   JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  
   WHERE ISNULL(a.disable_payout,''n'')<>''y'' AND (expected_payoutagentid='''+@agent_id+''' or paid_agent_id='''+@agent_id+''')         
   and Transstatus = ''Payment'' and paymentType='''++@paymentType+''''   
  if @check='1'   
   SET @sql=@sql +' and status=''Paid'' and confirmDate between '''+@fromDate+''' and '''+ @toDate +''''  
  else  
   SET @sql=@sql +' and status=''Un-Paid'' and is_downloaded is null'  
    
   SET @sql = @sql + ' order by confirmDate '   
            
        PRINT ( @sql )    
        EXEC(@sql)    
    
        SET @total_row = @@rowcount    
    
        DECLARE @total_amount MONEY    
        CREATE TABLE #temp_total_amount ( total_amount MONEY ) 
        IF @check IS NULL
        BEGIN
			SET @sql = '
						UPDATE moneysend set is_downloaded=''y'',
											 downloaded_by='''+ @login_user_id + ''',
											 downloaded_ts=dbo.getDateHO(GETUTCDATE())
						FROM moneysend m with(nolock) 
						JOIN ' + @ledger_tabl+ ' t on dbo.encryptdb(t.[TT/INVOICE/REFERENCE NO.])=m.refno JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  WHERE ISNULL(a.disable_payout,''n'')<>''y'''
			EXEC (@sql)
		END
    
        SET @sql = '    
				insert #temp_total_amount(total_amount)    
				select sum([Amount]) from ' + @ledger_tabl+ ''    
        EXEC(@sql)    
    
        SELECT  @total_amount = total_amount
        FROM    #temp_total_amount   
        DECLARE @total_row_pending INT ,
            @total_amount_pending MONEY     
    ----------------------------------------------------------------------------------------------------------------------  
    --------------- Bulk pay section--------------------------------------------------------------------------------------  
    if @check IS NULL  
    BEGIN  
   DELETE  [temp_trn_csv_pay]  
   WHERE   digital_id_payout = @digital_id    
     
   SET @sql = 'INSERT INTO [temp_trn_csv_pay]    
  ([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],    
  [rBankID],[rBankName],[rBankBranch],[digital_id_payout])    
  select   
   tranno,refno,receiverName,totalRoundAmt,'''+ CONVERT(VARCHAR, @GMT_Date, 120) + ''',''' + @login_user_id+ ''',    
 ''' + @agent_id + ''',''' + @rBankID + ''',''' + @rBankName + ''','''+ @rBankBranch + ''',''' + @digital_id + '''     
   from ' + @ledger_tabl+ ' t   
   JOIN moneysend m with (nolock) on dbo.encryptDB(t.[Transaction No.])=m.refno JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  where m.paymenttype<>''Cash Pay'' AND ISNULL(a.disable_payout,''n'')<>''y'''    
   PRINT @sql    
   EXEC(@sql)    
     
   PRINT ( 'spa_make_bulk_payment_csv ''' + @digital_id + ''',NULL,''y''' )    
   EXEC ('spa_make_bulk_payment_csv '''+@digital_id+''',NULL,''y''')  
    END  
        ----------------------------------------------------------------------------------------------------------------------     
    
        DECLARE @url_desc VARCHAR(MAX)    
        SET @url_desc = 'paymentType=' + ISNULL(@paymentType, '')    
        SET @desc = 'Uttara Bank  Download <strong><u>' + ISNULL(@paymentType,
                                                             'ALL')
            + '</u></strong> is completed.  TXN Found:'
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '  Total Amount: '
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)   
        IF @check = '1' 
            SET @desc = @desc + ' from Time:' + @fromdate + ' To ' + @todate
                + ' (Re-Downloaded)'  
        ELSE 
            SET @desc = @desc + ' Local Time:' + CONVERT(VARCHAR, @GMT_Date, 120)    
    
        IF @total_row_pending IS NOT NULL
            AND @total_amount_pending IS NOT NULL 
            SET @desc = @desc + '<br><i>Cover fund not enough(Pending:'
                + CAST(@total_row_pending AS VARCHAR) + ' AMT:'
                + CAST(@total_amount_pending AS VARCHAR) + ')</i>'    
    
        PRINT @desc    
        EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc,
            'c', @process_id, NULL, @url_desc    
    
        COMMIT TRANSACTION  trans  
    END TRY    
    BEGIN CATCH    
    
        IF @@trancount > 0 
            ROLLBACK TRANSACTION  trans  
    
     
        SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'    
     
     
        INSERT  INTO [error_info]
                ( [ErrorNumber] ,
                  [ErrorDesc] ,
                  [Script] ,
                  [ErrorScript] ,
                  [QueryString] ,
                  [ErrorCategory] ,
                  [ErrorSource] ,
                  [IP] ,
                  [error_date]  
                )
                SELECT  -1 ,
                        @desc ,
                        @batch_Id ,
                        'SQL' ,
                        @desc ,
                        'SQL' ,
                        'SP' ,
                        LEFT(@digital_id, 20) ,
                        GETDATE()    
        SELECT  'ERROR' ,
                '1050' ,
                'Error Please try again'    
    
    END CATCH    

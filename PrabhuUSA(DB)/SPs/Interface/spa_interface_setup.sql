IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_interface_setup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_interface_setup]
GO

/****** Object:  StoredProcedure [dbo].[spa_interface_setup]    Script Date: 02/11/2014 16:11:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_interface_setup]
@flag VARCHAR(10),
@sno INT = NULL,
@isEnable VARCHAR(10)= NULL,
@agentcode INT=NULL,
@updateTS DATETIME =NULL,
@createdBY VARCHAR(50) =NULL,
@updateBY VARCHAR(50) =NULL



AS 
BEGIN
	DECLARE @timeDate DATETIME
	SET @timeDate =dbo.getDateHO(GETUTCDATE())

	IF @flag='i'
	BEGIN
		IF NOT EXISTS (SELECT 'X' FROM tbl_interface_setup std WITH(nolock) WHERE std.mode='send')      
		BEGIN
			SELECT 'Error' STATUS, 'Contact Support Team for initial setup' [MESSAGE]
			RETURN
		END
		else IF EXISTS (SELECT 'X' FROM tbl_interface_setup std WITH(nolock) WHERE std.agentcode=@agentcode)              
		BEGIN              
			SELECT 'Error' STATUS, 'Agent already exists' [MESSAGE]               
		RETURN             
		END 
		ELSE    
		BEGIN TRY
			INSERT INTO [dbo].[tbl_interface_setup]
				([agentcode]
				,[mode]
				,[enable_update_remote_DB]
				,[remote_db]
				,[external_agent_id]
				,[external_branch_id]
				,[Remarks]
				,[external_agent_name]
				,[external_branch_name]
				,[PartnerAgentCode]
				,[PayoutCountry]
				,[createdTS]
				,[createdBY]
						)
			SELECT TOP 1 @agentcode
				,[mode]
				,@isEnable
				,[remote_db]
				,[external_agent_id]
				,[external_branch_id]
				,UPPER(a.CompanyName) [Remarks]
				,[external_agent_name]
				,[external_branch_name]
				,[PartnerAgentCode]
				,[PayoutCountry]
				,@timeDate
				,@createdBY
				 FROM dbo.tbl_interface_setup t WITH(NOLOCK) JOIN 
				dbo.agentDetail a WITH(NOLOCK) ON a.agentCode=@agentcode WHERE
				mode='send' AND enable_update_remote_DB='y' ORDER BY sno DESC
			
		SELECT 'Success' STATUS, 'Agent successfully listed.' [MESSAGE]      
		END TRY

		BEGIN CATCH
			DECLARE @descc VARCHAR(1000)              
			SET @descc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'              
			INSERT INTO [error_info]        
			(        
				[ErrorNumber],        
				[ErrorDesc],        
				[Script],        
				[ErrorScript],        
				[QueryString],        
				[ErrorCategory],        
				[ErrorSource],        
				[IP],        
				[error_date]        
			)        
			SELECT 
				-1,        
				@descc,        
				'spa_interface_setup',        
				'SQL',        
				@descc,        
				'SQL',        
				'SP',        
				'',        
				GETDATE()        

				SELECT 'ERROR' STATUS,        
				'('+cast(SCOPE_IDENTITY() AS VARCHAR(50))+') Error Please try again' [MESSAGE]    
		END CATCH
								
	END
	IF @flag='u'
	BEGIN TRY
		UPDATE tbl_interface_setup SET
		enable_update_remote_DB= @isEnable,
		updateTS=@timeDate,
		updateBY=@updateBY
		WHERE sno=@sno
		SELECT 'Success' STATUS, 'Agent successfully updated.' [MESSAGE]  
	END TRY
	BEGIN CATCH
			DECLARE @desc VARCHAR(1000)              
			SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'              
			INSERT INTO [error_info]        
			(        
				[ErrorNumber],        
				[ErrorDesc],        
				[Script],        
				[ErrorScript],        
				[QueryString],        
				[ErrorCategory],        
				[ErrorSource],        
				[IP],        
				[error_date]        
			)        
			SELECT 
				-1,        
				@desc,        
				'spa_interface_setup',        
				'SQL',        
				@desc,        
				'SQL',        
				'SP',        
				'',        
				GETDATE()        

				SELECT 'ERROR' STATUS,        
				'('+cast(SCOPE_IDENTITY() AS VARCHAR(50))+') Error Please try again'  [MESSAGE] 
		END CATCH
	
IF @flag='s'
	BEGIN
		SELECT Sno,Remarks [Agent],external_agent_name [external_agent],enable_update_remote_DB [isEnable],mode,updateTS,updateBY,createdTS,createdby
		FROM tbl_interface_setup WITH (NOLOCK) 
		WHERE CASE WHEN   @Sno IS NOT  NULL THEN  sno ELSE 1 END = isnull(@Sno,1)
		 AND mode='send'
	END
	
	 if @flag='d' --delete agent
	 BEGIN
	 	IF NOT EXISTS (SELECT 'X' FROM tbl_interface_setup std WITH(nolock) WHERE sno not in (@sno) and std.mode='send')      
		BEGIN
			SELECT 'Error' STATUS, 'There must be at least one row' [MESSAGE]
			RETURN
		END
	 		BEGIN TRY  
			  DELETE FROM tbl_interface_setup WHERE sno=@sno  
			    
				 SELECT 'Success' STATUS, 'Agent deleted successfully.'[MESSAGE]  
			 END TRY  
			 BEGIN CATCH  
				 SELECT 'ERROR' STATUS, 'Sorry,agent not deleted!!' [MESSAGE] 
			 END CATCH  	 	
	 END
			 
END 	
	
GO


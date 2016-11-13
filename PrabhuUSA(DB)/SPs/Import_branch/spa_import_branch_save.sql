DROP PROC [dbo].[spa_import_branch_save] 
GO
/*  
SELECT * FROM [agentbranchdetail]  
*/  
CREATE PROC [dbo].[spa_import_branch_save]
    @processid VARCHAR(200) ,
    @agentid VARCHAR(50) ,
    @agent_user_id VARCHAR(50) = NULL ,
    @autouser VARCHAR(50) = NULL,        
	@userRole VARCHAR(50)=NULL  
AS 
    DECLARE @agent_branch_code VARCHAR(50) ,
        @SQL VARCHAR(200)      
    BEGIN TRY      
       
        BEGIN TRANSACTION      
         
        DECLARE @branch_id VARCHAR(50) ,
            @country VARCHAR(100)      
        SELECT TOP 1
                @branch_id = agent_branch_code
        FROM    agentbranchDetail
        ORDER BY agent_branch_code DESC      
        SELECT TOP 1
                @country = country
        FROM    agentDetail
        WHERE   agentcode = @agentid      
      
        INSERT  INTO [agentbranchdetail]
                ( [agent_branch_Code] ,
                  [agentCode] ,
                  [Branch] ,
                  [Address] ,
                  [City] ,
                  [Country] ,
                  [Telephone] ,
                  [email] ,
                  [contactPerson] ,
                  [TransferType] ,
                  [branchCodeChar] ,
                  [letter_head] ,
                  [currentBalance] ,
                  [created_by] ,
                  [created_ts] ,
                  [agent_code_id] ,
                  Fax ,
                  Branch_type ,
                  --state_branch ,
                  ext_branch_code,approve_by,approve_ts
                )
                SELECT  ROW_NUMBER() OVER ( ORDER BY branch ASC ) + @branch_id ,
                        agentcode ,
                        RTRIM(LTRIM(t.branch)) ,
                        t.address ,
                        t.City ,
                        @country ,
                        t.telephone ,
                        emailid ,
                        contactPerson ,
                        'Deposit' ,
                        branchcode ,
                        RTRIM(LTRIM(branch)) + '[n]' + [address] + '[n]'
                        + telephone ,
                        0.00 ,
                        'system' ,
                        GETDATE() ,
                        @agentid ,
                        fax ,
                        branchtype ,
                        --state ,
                        ExtBranchCode,'system',GETDATE()
                FROM    temp_import_branchdetail t
                WHERE   agentCode = @agentid
                        AND process_id = @processid
                ORDER BY branch      
        
        IF @autouser IS NOT NULL 
            BEGIN    
                SELECT  @agent_user_id = ISNULL(MAX(agent_user_id), 10010000)
                FROM    agentsub      
          
				IF @autouser='a'
				BEGIN
					INSERT  INTO agentsub
							( agent_user_id ,
							  User_login_Id ,
							  User_pwd ,
							  user_name ,
							  user_post ,
							  user_address ,
							  user_email ,
							  agentCode ,
							  agent_branch_code ,
							  create_date ,
							  upload ,
							  rights ,
							  limited_date ,
							  lock_days ,
							  create_by ,
							  approve_by ,
							  approve_ts ,
							  user_remarks
							)
							SELECT  ROW_NUMBER() OVER ( ORDER BY branch ASC )
									+ @agent_user_id ,
									ROW_NUMBER() OVER ( ORDER BY branch ASC )
									+ @agent_user_id ,
									dbo.encryptdb(LTRIM(RTRIM(User_pwd))) ,
									ROW_NUMBER() OVER ( ORDER BY branch ASC )
									+ @agent_user_id ,
									user_post ,
									user_address ,
									user_email ,
									agentCode ,
									ROW_NUMBER() OVER ( ORDER BY branch ASC )
									+ @branch_id ,
									GETDATE() ,
									upload ,
									CAST(rights AS INT) ,
									CAST(limited_date AS INT) ,
									CAST(lock_days AS INT) ,
									'system' ,
									approve_by ,
									approve_ts ,
									user_remarks
							FROM    temp_import_branchdetail
							WHERE   process_id = @processid 
						END
						
				IF @autouser='m'
				BEGIN
					INSERT  INTO agentsub
							( agent_user_id ,
							  User_login_Id ,
							  User_pwd ,
							  user_name ,
							  user_post ,
							  user_address ,
							  user_email ,
							  agentCode ,
							  agent_branch_code ,
							  create_date ,
							  upload ,
							  rights ,
							  limited_date ,
							  lock_days ,
							  create_by ,
							  approve_by ,
							  approve_ts ,
							  user_remarks
							)
							SELECT  ROW_NUMBER() OVER ( ORDER BY branch ASC )
									+ @agent_user_id ,
									User_login_Id ,
									dbo.encryptdb(LTRIM(RTRIM(User_login_Id))) ,
									User_login_Id,
									user_post ,
									user_address ,
									user_email ,
									agentCode ,
									ROW_NUMBER() OVER ( ORDER BY branch ASC )
									+ @branch_id ,
									GETDATE() ,
									upload ,
									CAST(rights AS INT) ,
									CAST(limited_date AS INT) ,
									CAST(lock_days AS INT) ,
									'system' ,
									approve_by ,
									approve_ts ,
									user_remarks
							FROM    temp_import_branchdetail
							WHERE   process_id = @processid AND User_login_Id IS NOT NULL
						END
						      
        
            END    
            
            IF @userRole IS NOT NULL
            BEGIN
				insert application_role_agent_user(role_id,user_id)
				SELECT @userRole,a.User_login_Id FROM temp_import_branchdetail t 
				JOIN agentsub a ON a.user_login_id=t.User_login_Id
				WHERE   t.process_id = @processid            	
            END
      
      
        COMMIT TRANSACTION      
        SELECT  'SUCCESS'      
      
    END TRY      
    BEGIN CATCH      
        IF @@trancount > 0 
            ROLLBACK TRANSACTION            
             
        DECLARE @desc VARCHAR(1000)            
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
                SELECT  '100' ,
                        @desc ,
                        'spa_import_branch_save' ,
                        'SQL' ,
                        @desc ,
                        'SQL' ,
                        'SP' ,
                        '' ,
                        GETDATE()            
    END CATCH      
      
      
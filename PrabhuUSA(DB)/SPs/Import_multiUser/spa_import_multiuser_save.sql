DROP PROC [dbo].[spa_import_multiuser_save]          
go         
--spa_import_multiuser_save @processid='admin_0262F441_EC10_4235_AFC0_33BE94DC591B'  
--select * from [error_info]          
--select * from agentbranchdetail          
--select * from temp_import_multiuser          
--SELECT TOP 1 agent_branch_code FROM agentbranchDetail ORDER BY agent_branch_code DESC          
--selectmax([agent_user_id]) from agentsub          
-- DELETE FROM agentsub where agent_user_id>10010050          
--select * from agentsub          
CREATE PROC [dbo].[spa_import_multiuser_save]
    @processid VARCHAR(200) ,
    @agentid VARCHAR(50) = NULL
AS     
    BEGIN TRY          
           
        BEGIN TRANSACTION tran1      
             
        DECLARE @agent_code VARCHAR(100) ,
            @agent_user_id VARCHAR(100) ,
            @txt_role VARCHAR(1000) ,
            @txt_del VARCHAR(1000)--,   @branch_id varchar(50), @country VARCHAR(100) ,      
   
            
        SELECT  @agent_code = agentcode
        FROM    agentbranchDetail
        WHERE   agent_branch_code IN ( SELECT TOP 1
                                                agent_branch_code
                                       FROM     temp_import_multiuser
                                       WHERE    process_id = @processid )    
        SELECT  @agent_user_id = ISNULL(MAX(agent_user_id), 40000000)
        FROM    agentsub     
     
              
              
        INSERT  INTO agentsub
                ( agent_user_id ,
                  agentCode ,
                  User_login_Id ,
                  User_pwd ,
                  [user_name] ,
                  user_post ,
                  user_address ,
                  user_email ,
                  agent_branch_code ,
                  upload ,
                  rights ,
                  limited_date ,
                  lock_days ,
                  create_by ,
                  approve_by ,
                  approve_ts ,
                  user_remarks ,
                  allow_integration_user
                )
                SELECT  ROW_NUMBER() OVER ( ORDER BY agent_branch_code ASC )
                        + @agent_user_id ,
                        @agent_code ,
                        User_login_Id ,
                        dbo.encryptdb(User_pwd) ,
                        [user_name] ,
                        user_post ,
                        user_address ,
                        user_email ,
                        agent_branch_code ,
                        upload ,
                        CAST(rights AS INT) ,
                        CAST(limited_date AS INT) ,
                        CAST(lock_days AS INT) ,
                        create_by ,
                        approve_by ,
                        GETDATE() ,
                        user_remarks ,
                        allow_integration_user
                FROM    temp_import_multiuser
                WHERE   process_id = @processid     
     
     
   ------------------------------------------------------------------
   ------------------------- ROLE GIVEN------------------------------
   
        INSERT  application_role_agent_user
                ( role_id ,
                  user_id
                )
                SELECT  roles ,
                        User_login_id
                FROM    temp_import_multiuser
                WHERE   process_id = @processid  
   
   
   ------------------------------------------------------------------
  
    
          
        COMMIT TRANSACTION  tran1        
        SELECT  'SUCCESS'          
          
    END TRY          
    BEGIN CATCH          
        IF @@trancount > 0 
            ROLLBACK TRANSACTION  tran1              
                 
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
                        'spa_import_multiuser_save' ,
                        'SQL' ,
                        @desc ,
                        'SQL' ,
                        'SP' ,
                        '' ,
                        GETDATE()                
    END CATCH          
          
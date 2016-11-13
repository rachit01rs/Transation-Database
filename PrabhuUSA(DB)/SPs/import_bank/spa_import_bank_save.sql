 DROP PROC [dbo].[spa_import_bank_save]        
go       
        
--spa_import_branch_save @processid='admin_C7874A98_7344_44DC_8193_0494534E352E', @agentid='20100043'        
--spa_import_branch_save @processid='admin_5FCEF864_D0A0_4BF8_A422_B0BEEF81540B', @agentid='20100045'        
--spa_import_branch_save @processid='admin_E0EC6FAA_9228_4F3C_ABF9_365D3CD10461', @agentid='20100038'        
--select * from [error_info]        
--select * from agentbranchdetail        
--select * from temp_import_branchdetail        
--SELECT TOP 1 agent_branch_code FROM agentbranchDetail ORDER BY agent_branch_code DESC        
--selectmax([agent_user_id]) from agentsub        
-- DELETE FROM agentsub where agent_user_id>10010050        
--select * from agentsub        
 CREATE PROC [dbo].[spa_import_bank_save]
    @processid VARCHAR(200) ,
    @agent_country VARCHAR(50) = NULL ,
    @payingOutAgent VARCHAR(50) = NULL
 AS 
    BEGIN TRY        
         
        BEGIN TRANSACTION     
        INSERT  INTO Commercial_bank
                ( Bank_name ,
                  external_bank_id ,
                  country ,
                  payout_agent_id 
                )
                SELECT  Bank ,
                        ExtBankID ,
                        agent_country ,
                        payingOutAgent
                FROM    temp_import_bankDetail
                WHERE   process_id = @processid
                ORDER BY Bank 
        DELETE  temp_import_bankDetail
        WHERE   process_id = @processid     
        
        
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
                        'spa_import_bank_save' ,
                        'SQL' ,
                        @desc ,
                        'SQL' ,
                        'SP' ,
                        '' ,
                        GETDATE()              
    END CATCH        
        
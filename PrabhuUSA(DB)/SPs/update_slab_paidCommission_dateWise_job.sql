IF OBJECT_ID('update_slab_paidCommission_dateWise_job','P') IS NOT NULL
	DROP PROCEDURE [dbo].update_slab_paidCommission_dateWise_job
GO
--spa_Export_JanataBank_job '20100004','Cash Pay','ranesh','30101265',NULL,'a','JBBLCashPay','09/12/2010','09/30/2011'  
CREATE PROCEDURE [dbo].update_slab_paidCommission_dateWise_job
    @expected_payoutAgentId VARCHAR(50),
    @country VARCHAR(40),
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @run_by CHAR(1) = NULL , --a as agent , b as branch, NULL or H as HeadOffice  
    @batch_Id VARCHAR(100) = NULL 
AS 
    DECLARE @spa VARCHAR(max)  
    DECLARE @job_name VARCHAR(100)  
    DECLARE @process_id VARCHAR(100) ,
        @desc VARCHAR(200)  
    SET @process_id = REPLACE(NEWID(), '-', '_')  
  
    SET @job_name = 'update_slab_paidCommission_dateWise' + @process_id  
    SET @spa = 'update_slab_paidCommission_dateWise ' 
         + CASE WHEN @expected_payoutAgentId IS NULL THEN 'NULL'
               ELSE '''' + @expected_payoutAgentId + ''''
          END + ',' 
        + CASE WHEN @country IS NULL THEN 'NULL'
               ELSE '''' + @country + ''''
          END + ',' 
          + CASE WHEN @fromdate IS NULL THEN 'NULL'
               ELSE '''' + @fromdate + ''''
          END + ',' 
          + CASE WHEN @todate IS NULL THEN 'NULL'
               ELSE '''' + @todate + ''''
          END + ',' 
           + CASE WHEN @login_user_id IS NULL THEN 'NULL'
               ELSE '''' + @login_user_id + ''''
         END + ',' 
          + CASE WHEN @batch_Id IS NULL THEN 'NULL'
               ELSE '''' + @batch_Id + ''''
          END + ',' 
          + CASE WHEN @process_id IS NULL THEN 'NULL'
               ELSE '''' + @process_id + ''''
          END 
  
  
    PRINT @spa  
    EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id, @login_user_id  
  
    SET @desc = '<font color=red>Download processing. Please wait !!</font>'        
  
    EXEC spa_message_board 'i', @login_user_id, NULL, @batch_id, @desc, 'p',
        @process_id, NULL, NULL, NULL, NULL, @run_by  
    SELECT  0 ,
            @batch_Id ,
            'process run' ,
            'Status' ,
            'Batch process has been run and will complete shortly.' ,
            'Please check/refresh your message board.'  


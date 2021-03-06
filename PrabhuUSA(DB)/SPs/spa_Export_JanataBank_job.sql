IF OBJECT_ID('spa_Export_JanataBank_job','P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Export_JanataBank_job]
GO
--spa_Export_JanataBank_job '20100004','Cash Pay','ranesh','30101265',NULL,'a','JBBLCashPay','09/12/2010','09/30/2011'  
CREATE PROCEDURE [dbo].[spa_Export_JanataBank_job]
    @agent_id VARCHAR(50) ,
    @paymentType VARCHAR(50) = NULL ,
    @login_user_id VARCHAR(50) ,
    @branch_id VARCHAR(50) ,
    @ditital_id VARCHAR(200) = NULL ,
    @run_by CHAR(1) = NULL , --a as agent , b as branch, NULL or H as HeadOffice  
    @batch_Id VARCHAR(100) = NULL ,
    @fromDate VARCHAR(100) = NULL ,
    @toDate VARCHAR(100) = NULL
AS 
    DECLARE @spa VARCHAR(500)  
    DECLARE @job_name VARCHAR(100)  
    DECLARE @process_id VARCHAR(150) ,
        @desc VARCHAR(1000)  
    SET @process_id = REPLACE(NEWID(), '-', '_')  
    IF @ditital_id IS NULL 
        SET @ditital_id = @process_id  
  
    SET @job_name = 'spa_Export_JanataBank' + @process_id  
    SET @spa = 'spa_Export_JanataBank ''' + @agent_id + ''','
        + CASE WHEN @paymentType IS NULL THEN 'NULL'
               ELSE '''' + @paymentType + ''''
          END + ',''' + @login_user_id + ''',''' + @branch_id + ''','''
        + @ditital_id + ''',''' + @process_id + ''',''' + @batch_Id + ''','
        + CASE WHEN @fromDate IS NULL THEN 'NULL'
               ELSE '''' +@fromDate + ''''
          END + ',' 
        + CASE WHEN @toDate IS NULL THEN 'NULL'
               ELSE ''''+ @toDate + ''''
          END 
  
    PRINT @spa  
    EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id, @login_user_id  
  
    SET @desc = '<font color=red>Download processing. Please wait !!</font>'        
  
    EXEC spa_message_board 'i', @login_user_id, NULL, @batch_id, @desc, 'p',
        @process_id, NULL, NULL, @agent_id, NULL, @run_by  
    SELECT  0 ,
            @batch_Id ,
            'process run' ,
            'Status' ,
            'Batch process has been run and will complete shortly.' ,
            'Please check/refresh your message board.'  


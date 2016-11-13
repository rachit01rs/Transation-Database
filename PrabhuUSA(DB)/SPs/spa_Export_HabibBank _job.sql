IF OBJECT_ID('spa_Export_HabibBank_job','P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Export_HabibBank_job]
GO
--spa_Export_JanataBank_job '20100004','Cash Pay','ranesh','30101265',NULL,'a','JBBLCashPay','09/12/2010','09/30/2011'  
CREATE PROCEDURE [dbo].[spa_Export_HabibBank_job]
    @trn_type VARCHAR(50) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @check CHAR(1) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @ditital_id VARCHAR(200) = NULL ,
    @run_by CHAR(1) = NULL , --a as agent , b as branch, NULL or H as HeadOffice  
    @batch_Id VARCHAR(100) = NULL ,
	@url_desc VARCHAR(100) = NULL,
	@agentId VARCHAR(50) = NULL
AS 
    DECLARE @spa VARCHAR(500)  
    DECLARE @job_name VARCHAR(100)  
    DECLARE @process_id VARCHAR(150) ,
        @desc VARCHAR(1000)  
    SET @process_id = REPLACE(NEWID(), '-', '_')  
    IF @ditital_id IS NULL 
        SET @ditital_id = @process_id  
  
    SET @job_name = 'spa_Export_HabibBank' + @process_id  
    SET @spa = 'spa_Export_HabibBank ' 
         + CASE WHEN @trn_type IS NULL THEN 'NULL'
               ELSE '''' + @trn_type + ''''
          END + ',' 
        + CASE WHEN @fromDate IS NULL THEN 'NULL'
               ELSE '''' + @fromDate + ''''
          END + ',' 
          + CASE WHEN @toDate IS NULL THEN 'NULL'
               ELSE '''' + @toDate + ''''
          END + ',' 
          + CASE WHEN @check IS NULL THEN 'NULL'
               ELSE '''' + @check + ''''
          END + ',' 
          + CASE WHEN @login_user_id IS NULL THEN 'NULL'
               ELSE '''' + @login_user_id + ''''
          END + ',' 
          + CASE WHEN @process_id IS NULL THEN 'NULL'
               ELSE '''' + @process_id + ''''
          END + ',' 
          + CASE WHEN @batch_id IS NULL THEN 'NULL'
               ELSE '''' + @batch_id + ''''
          END  + ',' 
          + CASE WHEN @url_desc IS NULL THEN 'NULL'
               ELSE '''' + @url_desc + ''''
          END 

  
    PRINT @spa  
    EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id, @login_user_id  
  
    SET @desc = '<font color=red>Download processing. Please wait !!</font>'        
  
    EXEC spa_message_board 'i', @login_user_id, NULL, @batch_id, @desc, 'p',
        @process_id, NULL, @url_desc, @agentId, NULL, @run_by  
    SELECT  0 ,
            @batch_Id ,
            'process run' ,
            'Status' ,
            'Batch process has been run and will complete shortly.' ,
            'Please check/refresh your message board.'  


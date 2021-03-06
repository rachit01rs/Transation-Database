IF OBJECT_ID('spa_Batch_FileGeneration_HNB_job', 'P') IS NOT NULL 
    DROP PROCEDURE [dbo].[spa_Batch_FileGeneration_HNB_job]
go

--spa_Batch_FileGeneration_HNB_job '20100004','Cash Pay','ranesh',NULL,'a','JBBLCashPay'
CREATE PROCEDURE [dbo].[spa_Batch_FileGeneration_HNB_job]
	@destination_agent VARCHAR(50),
    @paymentType VARCHAR(50) = NULL ,
    @login_user_id VARCHAR(50) ,
    @ditital_id VARCHAR(200) = NULL ,
    @run_by CHAR(1) = NULL , --a as agent , b as branch, NULL or H as HeadOffice  
    @batch_Id VARCHAR(100) = NULL 
--    ,@fromDate VARCHAR(100) = NULL ,
--    @toDate VARCHAR(100) = NULL
AS 
    DECLARE @spa VARCHAR(500)  
    DECLARE @job_name VARCHAR(100)  
    DECLARE @process_id VARCHAR(150) ,
        @desc VARCHAR(1000)  
    SET @process_id = REPLACE(NEWID(), '-', '_')  
    IF @ditital_id IS NULL 
        SET @ditital_id = @process_id  
  
    SET @job_name = 'spa_Batch_FileGeneration_HNB' + @process_id  
    SET @spa = 'spa_Batch_FileGeneration_HNB '''+@destination_agent+''','
        + CASE WHEN @paymentType IS NULL THEN 'NULL'
               ELSE '''' + @paymentType + ''''
          END + ',''' + @login_user_id + ''',''' + @ditital_id + ''','''
        + @process_id + ''',''' + @batch_Id + ''''
--        + CASE WHEN @fromDate IS NULL THEN 'NULL'
--               ELSE '''' +@fromDate + ''''
--          END + ',' 
--        + CASE WHEN @toDate IS NULL THEN 'NULL'
--               ELSE ''''+ @toDate + ''''
--          END 
  
    PRINT @spa 
    --RETURN 
    EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id, @login_user_id  
  
    SET @desc = '<font color=red>Download processing. Please wait !!</font>'        
  
    EXEC spa_message_board 'i', @login_user_id, NULL, @batch_id, @desc, 'p',
        @process_id, NULL, NULL, @destination_agent, NULL, @run_by  
    SELECT  0 ,
            @process_id ,
            'process run' ,
            'Status' ,
            'Batch process has been run and will complete shortly.' ,
            'Please check/refresh your message board.'  



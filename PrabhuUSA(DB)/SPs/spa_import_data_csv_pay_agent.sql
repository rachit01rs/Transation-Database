IF OBJECT_ID('spa_import_data_csv_pay_agent', 'P') IS NOT NULL 
    DROP PROCEDURE [dbo].[spa_import_data_csv_pay_agent]   
GO
CREATE PROCEDURE [dbo].[spa_import_data_csv_pay_agent]
    @PathFileName VARCHAR(500) ,
    @tablename VARCHAR(100) ,
    @user_login_id VARCHAR(50) ,
    @branch_id VARCHAR(20) ,
    @ip_address VARCHAR(50) = NULL ,
    @digital_id_sender VARCHAR(200) = NULL
AS 
    DECLARE @spa VARCHAR(500)  
    DECLARE @job_name VARCHAR(100)  
    DECLARE @process_id VARCHAR(50)  
    SET @process_id = REPLACE(NEWID(), '-', '_')  
  
    SET @job_name = 'spa_import_data_csv_pay_agent_job' + @process_id  
    SET @spa = 'spa_import_data_csv_pay_agent_data_job ''' + @PathFileName
		+ ''',''' + @tablename + ''', ''' + @job_name + ''', ''' + @process_id 
        + ''',''' + @user_login_id + ''',''' + @branch_id + ''','''
        + @ip_address + ''', ''' + @digital_id_sender + ''''  
  
    PRINT @spa 
    EXEC spa_run_sp_as_job @job_name, @spa, 'ImportData', @user_login_id  
  
    SELECT  0 ,
            'ImportData' ,
            'process run' ,
            'Status' ,
            'Import process has been run and will complete shortly.' ,
            'Plese check/refresh your message board.'  
  
  
  

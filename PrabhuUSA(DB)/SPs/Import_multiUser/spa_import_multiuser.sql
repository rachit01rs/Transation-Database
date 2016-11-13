DROP PROCEDURE [dbo].[spa_import_multiuser]                  
GO            
CREATE PROCEDURE [dbo].[spa_import_multiuser]                  
@PathFileName VARCHAR(500),                  
@user_login_id VARCHAR(50),                  
@ip_address VARCHAR(50)=NULL,                  
@digital_id_sENDer VARCHAR(200)=NULL,              
@process_id VARCHAR(200)=NULL,            
@branch_id varchar(100)=NULL      
as                  
DECLARE @spa VARCHAR(500)                  
DECLARE @job_name VARCHAR(100)                   
DECLARE @tablename VARCHAR(50)                
SET @tablename='temp_multiuser'               
IF @process_id IS NULL                 
SET @process_id = REPLACE(newid(),'-','_')                  
        
SET @job_name = 'spa_import_multiuser_job' + @process_id                  
SET @spa = 'spa_import_multiuser_job  ''' + @PathFileName  +''',''' + @tablename  +  ''', ''' +                   
 @job_name + ''', ''' +@process_id+''','''+ @user_login_id + ''','''+                  
 @ip_address  + ''', ''' +@digital_id_sENDer+''', '''+isnull(@branch_id,'')+''''             
                  
print @spa                  
EXEC spa_run_sp_as_job @job_name, @spa, 'ImportData', @user_login_id                  
                  
SELECT 0, 'ImportData', 'process run', 'Status', 'Import process has been run and will complete shortly.',                  
'Please check/refresh your message board.' 
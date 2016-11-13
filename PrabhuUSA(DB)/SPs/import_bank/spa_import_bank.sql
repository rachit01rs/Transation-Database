DROP PROCEDURE [dbo].[spa_import_bank]                 
go          
CREATE PROCEDURE [dbo].[spa_import_bank]                 
@PathFileName VARCHAR(500),                
@user_login_id VARCHAR(50),                
@ip_address VARCHAR(50)=NULL,                
@digital_id_sENDer VARCHAR(200)=NULL,            
@process_id VARCHAR(200)=NULL,          
@agent_country varchar(100)=NULL,          
@user varchar(100)=NULL,        
@payingOutAgent VARCHAR(50)=NULL           
as                
DECLARE @spa VARCHAR(500)                
DECLARE @job_name VARCHAR(100)                 
DECLARE @tablename VARCHAR(50)              
SET @tablename='temp_bank_book'             
IF @process_id IS NULL               
SET @process_id = REPLACE(newid(),'-','_')                
      
SET @job_name = 'spa_import_bank_job' + @process_id                
SET @spa = 'spa_import_bank_job  ''' + @PathFileName  +''',''' + @tablename  +  ''', ''' +                 
 @job_name + ''', ''' +@process_id+''','''+ @user_login_id + ''','''+                
 @ip_address  + ''', ''' +@digital_id_sENDer+''', '''+isnull(@agent_country,'')+''', '''+isnull(@user,'')+''', '''+isnull(@payingOutAgent,'')+''''             
                
print @spa                
EXEC spa_run_sp_as_job @job_name, @spa, 'ImportData', @user_login_id                
                
SELECT 0, 'ImportData', 'process run', 'Status', 'Import process has been run and will complete shortly.',                
'Please check/refresh your message board.' 
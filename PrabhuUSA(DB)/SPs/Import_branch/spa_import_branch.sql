DROP PROCEDURE [dbo].[spa_import_branch]               
GO        
CREATE PROCEDURE [dbo].[spa_import_branch]               
@PathFileName VARCHAR(500),              
@user_login_id VARCHAR(50),              
@ip_address VARCHAR(50)=NULL,              
@digital_id_sENDer VARCHAR(200)=NULL,          
@process_id VARCHAR(200)=NULL,        
@agentid varchar(100)=NULL,        
@user varchar(100)=NULL,      
@autouser VARCHAR(50)=NULL,      
@BranchType VARCHAR(50)=NULL,      
@userRole VARCHAR(50)=NULL         
as              
DECLARE @spa VARCHAR(500)              
DECLARE @job_name VARCHAR(100)               
DECLARE @tablename VARCHAR(50)            
SET @tablename='temp_branch_import'           
IF @process_id IS NULL             
SET @process_id = REPLACE(newid(),'-','_')              
    
SET @job_name = 'spa_import_branch_job' + @process_id              
SET @spa = 'spa_import_branch_job  ''' + @PathFileName  +''',''' + @tablename  +  ''', ''' +               
 @job_name + ''', ''' +@process_id+''','''+ @user_login_id + ''','''+
 @ip_address  + ''', ''' +@digital_id_sENDer+''', '''+@agentid+''', '''+@user+''', '''+isNull(@autouser, 'n')+''', '''+@BranchType+''', '''+isNull(@userRole, '0')+''''           
              
print @spa              
EXEC spa_run_sp_as_job @job_name, @spa, 'ImportData', @user_login_id              
              
SELECT 0, 'ImportData', 'process run', 'Status', 'Import process has been run and will complete shortly.',              
'Please check/refresh your message board.' 
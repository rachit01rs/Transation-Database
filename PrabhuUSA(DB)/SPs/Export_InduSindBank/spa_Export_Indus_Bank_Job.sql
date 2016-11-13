IF OBJECT_ID('spa_Export_Indus_Bank_Job','P') IS NOT NULL
DROP PROCEDURE	spa_Export_Indus_Bank_Job
GO

/*    
** Database    : PrabhuUSA    
** Object      : spa_Export_Indus_Bank_Job    
** Purpose     : Job to Run for Export To Indusind Bank    
** Author      : Hari Saran Manandhar    
** Date     : 25 May 2013    
** Modifications  :     
*/     
    
CREATE PROCEDURE [dbo].[spa_Export_Indus_Bank_Job]     
@checkbox CHAR(1)=NULL,    
@status VARCHAR(50)=NULL,    
@paymentType varchar(50)=NULL,    
@login_user_id varchar(50),    
@branch_id varchar(50)=NULL,    
@fromdate VARCHAR(50),    
@todate VARCHAR(50),    
@ddDate VARCHAR(50),    
@digital_id varchar(200)=NULL,    
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice    
@batch_Id varchar(100)=null,    
@agent_id varchar(50)=NULL    
as    
DECLARE @spa varchar(500)    
DECLARE @job_name varchar(100)    
DECLARE @process_id varchar(150),@desc varchar(1000)    
SET @process_id = REPLACE(newid(),'-','_')    
    
  IF RTRIM(LTRIM(REPLACE(@digital_id,':','')))='' OR @digital_id IS NULL    
    SET @digital_id=@login_user_id+'_'+@process_id    
    
 SET @job_name = 'spa_Export_Indus_Bank' + @process_id    
     
 SET @spa = 'spa_Export_Indus_Bank ' + case when @checkbox is null then 'Null'  else     
 ''''+ @checkbox+'''' end +','''+ @login_user_id  + ''','+case when @branch_id IS NULL THEN 'NULL' ELSE     
 ''''+@branch_id+'''' END +','''+@fromdate +''','''+@todate +''',''' +@ddDate +''','''+ @digital_id+''',''' + @process_id+''','''+@batch_Id +''','    
 + case when @agent_id IS NULL THEN 'NULL' ELSE ''''+@agent_id+'''' END +','    
 + case when @status IS NULL THEN 'NULL' ELSE ''''+@status+'''' END +','    
 + case when @paymentType IS NULL THEN 'NULL' ELSE ''''+@paymentType+'''' END       
    
print @spa    
    
    
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id    
--return    
    
    
set @desc ='<font color=red>Download processing. Please wait !!</font>'          
    
 EXEC  spa_message_board 'i', @login_user_id,    
  NULL, @batch_id,    
  @desc, 'p', @process_id,null,null,    
  @agent_id ,    
  NULL,    
  @run_by    
select 0, @batch_Id,    
    'process run', 'Status',     
   'Batch process has been run and will complete shortly.',    
    'Please check/refresh your message board.'    
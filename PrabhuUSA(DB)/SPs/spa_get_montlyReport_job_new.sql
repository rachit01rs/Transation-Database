DROP PROC [dbo].[spa_get_montlyReport_job_new]  
GO
--spa_get_montlyReport_job_new NULL,NULL,'2012','confirmDate','d',NULL,'admin','monthly_rept_new',NULL,'United States','AL'    
    
--spa_get_montlyReport_job '85700000',NULL,'2009','local_dot','l',NULL,'anoopkl','monthly_rept','a'    
CREATE PROC [dbo].[spa_get_montlyReport_job_new]    
@agent_id varchar(50)=NULL,    
@sel_month int=NULL,    
@sel_year int=NULL,    
@date_type varchar(200)=NULL,    
@curr_type char(1)='l',    
@payout_country varchar(50)=null,    
@login_user_id varchar(100),    
@batch_Id varchar(100),    
@run_by char(1)=null,    
@SenderCountry varchar(100)=NUll,    
@pay_agent varchar(50)=NULL,   
@sender_state VARCHAR(100)=NULL   
as    
    
DECLARE @spa varchar(500)    
DECLARE @job_name varchar(100)    
DECLARE @process_id varchar(150),@desc varchar(1000)    
SET @process_id = REPLACE(newid(),'-','_')    
    
    
 SET @job_name = 'spa_get_montlyReport_new_job_' + @process_id    
 SET @spa = 'spa_get_montly_report_new '+    
 isNull(''''+@agent_id+'''','NULL') +','+    
 isNull(''''+cast(@sel_month AS varchar)+'''','NULL') +','+    
 isNull(''''+cast(@sel_year AS varchar)+'''','NULL') +','+    
 isNull(''''+ @date_type +'''','NULL') +','+    
 isNull(''''+@curr_type+'''','NULL') +','+    
 isNull(''''+@payout_country+'''','NULL') +','''+@process_id +''','''+@login_user_id +''',    
 '''+@batch_Id +''','+isNull(''''+@SenderCountry+'''','NULL')    
 +','+isNull(''''+@pay_agent+'''','NULL')    
 +','+isNull(''''+@sender_state+'''','NULL')   
    
    
    
print @spa    
    
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id    
    
set @desc ='<font color=red>'+ upper(@batch_id)+' <b>Summary</b> is processing for as of date:. Please wait !!</font>'          
 EXEC  spa_message_board 'i', @login_user_id,    
    NULL, @batch_id,@desc, 'p', @process_id,null,null,    
  @agent_id ,    
  NULL,    
  @run_by    
    
select 0, @batch_Id,    
    'process run', 'Status',     
   'Batch process has been run and will complete shortly.',    
    'Plese check/refresh your message board.' 
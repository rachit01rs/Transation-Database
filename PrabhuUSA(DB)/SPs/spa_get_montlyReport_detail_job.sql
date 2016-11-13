DROP PROC [dbo].[spa_get_montlyReport_detail_job]  
GO
CREATE PROC [dbo].[spa_get_montlyReport_detail_job]    
@send_agent_id varchar(50)=NULL,    
@payout_agent_id varchar(50)=NULL,    
@payout_country varchar(100)=NULL,    
@year int,    
@month int=null,    
@login_user_id varchar(100),    
@batch_Id varchar(100) ,  
@sendercountry VARCHAR(50)=NULL,  
@sender_state VARCHAR(50)=NULL    
as    
    
DECLARE @spa varchar(500)    
DECLARE @job_name varchar(100)    
DECLARE @process_id varchar(150),@desc varchar(1000)    
SET @process_id = REPLACE(newid(),'-','_')    
    
    
 SET @job_name = 'spa_get_montlyReport_detail_job_' + @process_id    
 SET @spa = 'spa_get_montlyReport_detail '+    
 isNull(''''+@send_agent_id+'''','NULL') +','+    
 isNull(''''+@payout_agent_id+'''','NULL') +','+    
 isNull(''''+@payout_country+'''','NULL') +','+    
 isNull(''''+ cast(@year AS varchar) +'''','NULL') +','+    
 isNull(''''+cast(@month AS varchar)+'''','NULL') +','''+    
 @process_id +''','''+@login_user_id +''','''+@batch_Id +''''    
 +','+isNull(''''+@sendercountry+'''','NULL')+','+isNull(''''+@sender_state+'''','NULL')    
    
    
    
print @spa    
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id    
    
set @desc ='<font color=red>'+ upper(@batch_id)+' is processing for as of date:. Please wait !!</font>'          
 EXEC  spa_message_board 'i', @login_user_id,    
    NULL, @batch_id,    
    @desc, 'p', @process_id    
    
select 0, @batch_Id,    
    'process run', 'Status',     
   'Batch process has been run and will complete shortly.',    
    'Plese check/refresh your message board.'   
  
  
DROP PROCEDURE get_all_agentbalance_process_job
GO  
create PROCEDURE [dbo].[get_all_agentbalance_process_job]   
@date_type char(1), -- c Current Balance, d Date wise  
@agent_type char(1), -- a MAIN AGent, b Branch Wise, d Bank/District Wise, f FUND TRANSFER IN EXCEL, l Ledger Report  
@country varchar(100)=null,  
@hide_nil char(1)=null,  
@as_of_date varchar(20)=null,  
@login_user_id varchar(50)=NULL,  
@batch_Id varchar(100)=NULL,
@state varchar(50)=null   

as  
DECLARE @spa varchar(500)  
DECLARE @job_name varchar(100)  
DECLARE @process_id varchar(150),@desc varchar(1000)  
SET @process_id = REPLACE(newid(),'-','_')  
    
  IF @state IS NOT NULL 
		SET @state='''' +@state +''''
		
 SET @job_name = 'get_all_agentbalance_process_job_' + @process_id  
 SET @spa = 'get_all_agentbalance_process  ''' + @date_type  +''',''' + @agent_type  +  ''', ''' +   
   isNull(@country,'-') + ''', '''+isNUll(@hide_nil,'-') +''','''+ @as_of_date + ''','''+@process_id +''','''+  
   @login_user_id  + ''', ''' +@batch_Id +''',' +ISNULL(@state,'Null') 
  
--print @spa  
--   return

EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id  
  
set @desc ='<font color=red>'+ upper(@batch_id)+' is processing for as of date:' + @as_of_date +'. Please wait !!</font>'        
 EXEC  spa_message_board 'i', @login_user_id,  
    NULL, @batch_id,  
    @desc, 'p', @process_id
  
select 0, @batch_Id,  
    'process run', 'Status',   
   'Batch process has been run and will complete shortly.',  
    'Plese check/refresh your message board.'  
  
  
  
  
  
  
  
  
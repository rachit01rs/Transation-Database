ALTER PROCEDURE [dbo].spa_ip_trace_report_job         
    @agentCode VARCHAR(50) = NULL,  
    @senderCountry VARCHAR(40) = NULL,  
    @fromDate VARCHAR(50) = NULL ,  
    @toDate VARCHAR(50) = NULL ,  
    @dateType VARCHAR(50)= NULL,        
 @login_user_id varchar(50)=NULL,  
 @batch_Id varchar(50)=NULL,  
 @runby CHAR(1)=NULL  
as        
DECLARE @spa varchar(500),@job_name varchar(100),@process_id varchar(150),@desc varchar(1000)
    
SET @process_id = REPLACE(newid(),'-','_')        
     
        
 SET @job_name = 'spa_ip_trace_report_job' + @process_id        
 SET @spa = 'spa_ip_trace_report '   
         + CASE WHEN @agentCode IS NULL THEN 'NULL'  
               ELSE '''' + @agentCode + ''''  
          END + ','   
        + CASE WHEN @senderCountry IS NULL THEN 'NULL'  
               ELSE '''' + @senderCountry + ''''  
          END + ','   
          + CASE WHEN @fromDate IS NULL THEN 'NULL'  
               ELSE '''' + @fromDate + ''''  
          END + ','   
          + CASE WHEN @toDate IS NULL THEN 'NULL'  
               ELSE '''' + @toDate + ''''  
          END + ','   
          + CASE WHEN @dateType IS NULL THEN 'NULL'  
               ELSE '''' + @dateType + ''''  
          END + ','   
           + CASE WHEN @login_user_id IS NULL THEN 'NULL'  
               ELSE '''' + @login_user_id + ''''  
         END + ','   
          + CASE WHEN @batch_Id IS NULL THEN 'NULL'  
               ELSE '''' + @batch_Id + ''''  
          END + ','   
          + CASE WHEN @process_id IS NULL THEN 'NULL'  
               ELSE '''' + @process_id + ''''  
          END  
 print(@spa)        
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id        
     
  set @desc ='<font color=red>IP Trace Report is in processing of date:' +@toDate+'. Please wait... !!!</font>'    
 EXEC  spa_message_board 'i', @login_user_id,NULL, @batch_Id,@desc, 'p', @process_id,NULL,@toDate,NULL,NULL,NULL,@runby        
   
select 0, 'IP Trace Report',        
    'process run', 'Status',         
    'Batch process has been running and will complete shortly.',        
    'Please check/refresh your message board.'    
        
        
        
        
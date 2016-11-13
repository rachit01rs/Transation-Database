IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_reconcile_transaction_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE spa_reconcile_transaction_job
GO
create PROCEDURE [dbo].spa_reconcile_transaction_job       
 @reconsileBy varchar(50)=NULL,  
 @dateType varchar(50)=NULL,  
 @toDate varchar(50) =NULL,
 @login_user_id varchar(50)=NULL     
as      
DECLARE @spa varchar(500)      
DECLARE @job_name varchar(100)      
DECLARE @process_id varchar(150),@processName VARCHAR(200)  
DECLARE @desc varchar(1000)      
DECLARE @summary_batch_Id varchar(100) 
DECLARE @detail_batch_Id varchar(100)  
  
SET @process_id = REPLACE(newid(),'-','_')      
SET @summary_batch_Id='ReconcileTransaction_Summary'    
 SET @detail_batch_Id='ReconcileTransaction_Detail'  

   IF @reconsileBy IS NULL
		SET @reconsileBy='a'
      
 SET @job_name = 'spa_reconcile_transaction_job' + @process_id      
 SET @spa = 'spa_reconsile_transaction_new '''+@reconsileBy+''','''+@dateType+''','''+@toDate+''','''+@login_user_id+''','''+@process_id+''','''+@summary_batch_Id+''','''+@detail_batch_Id+''''  
 print(@spa)      
EXEC spa_run_sp_as_job @job_name, @spa, @detail_batch_Id , @login_user_id      
   

 set @desc ='<font color=red>'+ upper(@detail_batch_Id)+' is processing of date:' +@toDate+'. Please wait... !!!</font>'  
 EXEC  spa_message_board 'i', @login_user_id,NULL, @detail_batch_Id,@desc, 'p', @process_id,NULL,@toDate      
 set @desc ='<font color=red>'+ upper(@summary_batch_Id)+' is processing of date:' +@toDate+'. Please wait... !!!</font>'            
 EXEC  spa_message_board 'i', @login_user_id,NULL, @summary_batch_Id,@desc, 'p', @process_id ,NULL,@toDate 

select 0, @summary_batch_Id,      
    'process run', 'Status',       
    'Batch process has been running and will complete shortly.',      
    'Please check/refresh your message board.'      
      
UNION ALL  
select 0, @detail_batch_Id,      
    'process run', 'Status',       
    'Batch process has been running and will complete shortly.',      
    'Please check/refresh your message board.'  
      
      
      
      
      
drop PROC [dbo].[spa_txn_report_job]

/****** Object:  StoredProcedure [dbo].[spa_txn_report_job]    Script Date: 06/26/2011 18:15:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_txn_report_job]  
@flag char(1)=null,  
@agent varchar(50)=null,  
@country varchar(50)=null,  
@branch varchar(50)=null,   
@fromdate varchar(50)=null,  
@todate varchar(50)=null,  
@order varchar(50)=null,  
@minamt varchar(50)=null,  
@maxamt varchar(50)=null,  
@curr varchar(50)=null,  
@user varchar(50)=null,  
@country1 varchar(50)=null,  
@agent1 varchar(50)=null,  
@group_by varchar(50)=null  
as  
  
DECLARE @spa varchar(500),@job_name varchar(100),@process_id varchar(150),@desc varchar(1000),@batch varchar(100)  
SET @process_id = REPLACE(newid(),'-','_')  
set @batch='txn_analysis'  
  
 SET @job_name = 'spa_txn_report_job_' + @process_id  
 SET @spa = 'spa_txn_report '''+@flag+''','''+@agent+''','''+@country+''','''+@branch+''','''+@fromdate+''',  
 '''+@todate+''','''+@order+''','''+@minamt+''','''+@maxamt+''','''+@curr+''','''+@user+''',  
 '''+@agent1+''','''+@country1+''','''+@process_id+''','''+@batch+''','+  
 CASE WHEN @group_by IS NULL THEN 'NULL' ELSE ''''+@group_by+'''' END   
print @spa  
EXEC spa_run_sp_as_job @job_name, @spa, @batch , @user  
  
set @desc ='<font color=red>'+replace(upper(@batch),'_',' ')+' is processing for as of date:. Please wait !!</font>'        
 EXEC  spa_message_board 'i', @user,NULL, @batch,@desc,   
 'p', @process_id,null,null, @agent , NULL,'a'  
  
select 0, replace(upper(@batch),'_',' '),  
    'process run', 'Status',   
   'Batch process has been run and will complete shortly.',  
    'Please check/refresh your message board.'  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  























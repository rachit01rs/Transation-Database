set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--spa_ComplianceCheck_job 12313,'Hold'
ALTER  PROCEDURE [dbo].[spa_ComplianceCheck_job]       
@tranno varchar(20)     ,
@transStatus VARCHAR(50)=NULL
as      
      
DECLARE @spa varchar(500)      
DECLARE @job_name varchar(100),@batch_Id varchar(50)      
DECLARE @process_id varchar(150),@desc varchar(1000)      
      
SET @process_id = REPLACE(newid(),'-','_')      
set @batch_Id='ComplianceJob'      
      
 SET @job_name = 'spa_ComplianceCheck' + @process_id      
 SET @spa = 'spa_ComplianceCheck ''c'',''' + @tranno  +''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'+CASE WHEN @transStatus is NULL THEN ' NULL ' ELSE ''''+ @transStatus +'''' END 
       
print @spa      
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , 'system'      
      
      


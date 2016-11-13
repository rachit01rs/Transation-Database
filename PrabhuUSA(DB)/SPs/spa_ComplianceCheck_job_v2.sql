
/****** Object:  StoredProcedure [dbo].[spa_ComplianceCheck_job_v2]    Script Date: 09/16/2013 02:06:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_ComplianceCheck_job 12313,'Hold'
create  PROCEDURE [dbo].[spa_ComplianceCheck_job_v2]       
@tranno varchar(20)     ,
@transStatus VARCHAR(50)=NULL
as      
      
DECLARE @spa varchar(500)      
DECLARE @job_name varchar(100),@batch_Id varchar(50)      
DECLARE @process_id varchar(150),@desc varchar(1000)      
      
SET @process_id = REPLACE(newid(),'-','_')      
set @batch_Id='ComplianceJob'      

 INSERT INTO moneysend_staging
 (
 
 	Tranno,
 	TransStatus,
 	create_ts
 )
 VALUES
 (
 	@tranno,@transStatus,GETDATE()
 )
--
-- SET @job_name = 'spa_ComplianceCheckv2' + @process_id      
-- SET @spa = 'spa_ComplianceCheck_v2 ''c'',''' + @tranno  +''',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'+CASE WHEN @transStatus is NULL THEN ' NULL ' ELSE ''''+ @transStatus +'''' END 
--       
--print @spa      
--EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , 'system'      
      
      
      

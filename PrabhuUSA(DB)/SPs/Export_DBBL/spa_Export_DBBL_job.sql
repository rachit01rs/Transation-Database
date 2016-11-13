IF OBJECT_ID('spa_Export_DBBL_job','P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Export_DBBL_job] 
go
--spa_Export_DBBL_job '20100072',NULL,'NBLADMIN01','30108381','moin','a','NationalBank'  
CREATE PROCEDURE [dbo].[spa_Export_DBBL_job]  
@agentid VARCHAR(50) =NULL,  
@paymentType varchar(50)=NULL,  
@login_user_id varchar(50),  
@branch_id VARCHAR(50)=NULL ,  
@digital_id varchar(200)=NULL,  
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice  
@batch_Id varchar(100),  
@fromdate varchar(100)=NULL,  
@todate varchar(100)=NULL,  
@check CHAR(1)=NULL  
as  
DECLARE @spa varchar(500)  
DECLARE @job_name varchar(100)  
DECLARE @process_id varchar(150),@desc varchar(1000)  
SET @process_id = REPLACE(newid(),'-','_')  
  
  IF RTRIM(LTRIM(REPLACE(@digital_id,':','')))='' OR @digital_id IS NULL  
    SET @digital_id=@login_user_id+'_'+@process_id  
  
 SET @job_name = 'spa_Export_DBBL' + @process_id  
 SET @spa = 'spa_Export_DBBL  '+  
 CASE WHEN @paymentType is null then ' Null '  else  '''' + @paymentType  +  ''''  end +',''' + @login_user_id  +  ''',  
 '+CASE WHEN @branch_id is null THEN ' Null '  ELSE  '''' + @branch_id  +  ''''  END  
 +','+CASE WHEN @digital_id is null THEN ' Null '  ELSE  '''' + @digital_id  +  ''''  end  
 +','+CASE WHEN @process_id is null THEN ' Null '  ELSE  '''' + @process_id  +  ''''  END  
 +','+CASE WHEN @batch_Id is null THEN ' Null '  ELSE  '''' + @batch_Id  +  ''''  END  
 +','+CASE WHEN @fromdate is null THEN ' Null '  ELSE  '''' + @fromdate  +  ''''  END  
 +','+CASE WHEN @todate is null THEN ' Null '  ELSE  '''' + @todate  +  ''''  END  
 +','+CASE WHEN @check is null THEN ' Null '  ELSE  '''' + @check  +  ''''  end  
   
  
print @spa  
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id  
  
set @desc ='<font color=red>Download processing. Please wait !!</font>'        
  
 EXEC  spa_message_board 'i', @login_user_id,  
  NULL, @batch_id,  
  @desc, 'p', @process_id,null,null,  
  @agentid ,  
  NULL,  
  @run_by  
select 0, @batch_Id,  
    'process run', 'Status',   
   'Batch process has been run and will complete shortly.',  
    'Please check/refresh your message board.'  
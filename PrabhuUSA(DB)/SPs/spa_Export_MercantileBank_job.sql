IF OBJECT_ID('spa_Export_MercantileBank_job','P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Export_MercantileBank_job] 
go
--spa_Export_MercantileBank_job '20100072',NULL,'NBLADMIN01','30108381','moin','a','NationalBank'
CREATE PROCEDURE [dbo].[spa_Export_MercantileBank_job] 
@agent_id varchar(50),
@paymentType varchar(50)=NULL,
@login_user_id varchar(50),
@branch_id varchar(50),
@digital_id varchar(200)=NULL,
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice
@batch_Id varchar(100)
as
DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(150),@desc varchar(1000)
SET @process_id = REPLACE(newid(),'-','_')

	 IF RTRIM(LTRIM(REPLACE(@digital_id,':','')))='' OR @digital_id IS NULL
	   SET @digital_id=@login_user_id+'_'+@process_id

	SET @job_name = 'spa_Export_MercantileBank' + @process_id
	SET @spa = 'spa_Export_MercantileBank  ''' + @agent_id  +''','+
	case when @paymentType is null then ' Null '  else  '''' + @paymentType  +  ''''  end +',''' + @login_user_id  +  ''',
	'''+@branch_id+''','''+ @digital_id +''',''' + @process_id  +  ''',''' +@batch_Id +''''

print @spa
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id 

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


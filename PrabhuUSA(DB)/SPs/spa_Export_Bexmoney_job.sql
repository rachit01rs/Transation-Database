IF OBJECT_ID('spa_Export_Bexmoney_job','P') IS NOT NULL
DROP PROCEDURE	spa_Export_Bexmoney_job
GO
/*
** Database				:	prabhuUSA
** Object 				:	spa_Export_Bexmoney_job
** Purpose 				:	Transaction report generation for prabhuUSA
** Author				:	Anonymous
** MODIFIED Author		:	Rajan Gauchan
** Date					:	24 JAN 2013, THURS
** Modifications:
** object_id name changed with the corresponding field	
** Execute Examples :

--spa_Export_Bexmoney_job '20100072',NULL,'NBLADMIN01','30108381','moin','a','NationalBank'
spa_Export_Bexmoney_job '20100013',NULL,NULL,'PMT018','20100002','01/28/2013 00:00:00:000','01/28/2013 23:59:59.999','ConfirmDate',NULL,'a','Export_Bexmoney'
spa_Export_Bexmoney  '20100013', Null , Null ,'PMT018','20100002','01/28/2013 00:00:00:000','01/28/2013 23:59:59.999','ConfirmDate','PMT018_2730F5C8_74C4_49FD_9EE8_5B21C0A450C1','2730F5C8_74C4_49FD_9EE8_5B21C0A450C1','Export_Bexmoney'

*/ 

CREATE PROCEDURE [dbo].[spa_Export_Bexmoney_job] 
@agent_id varchar(50),
@status VARCHAR(50),
@paymentType varchar(50)=NULL,
@login_user_id varchar(50),
@branch_id varchar(50),
@fromdate VARCHAR(50),
@todate VARCHAR(50),
@ddDate VARCHAR(50),
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

	SET @job_name = 'spa_Export_Bexmoney' + @process_id
	SET @spa = 'spa_Export_Bexmoney  ''' + @agent_id  +''','+
	case when @status is null then ' Null '  else  '''' + @status  +  ''''  end +',' +
	case when @paymentType is null then ' Null '  else  '''' + @paymentType  +  ''''  end +',''' 
	+ @login_user_id  +  ''','''+@branch_id+''','''+@fromdate +''',''' +@todate +''',''' +@ddDate +''','''
	+ @digital_id +''',''' + @process_id  +  ''',''' +@batch_Id +''''

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


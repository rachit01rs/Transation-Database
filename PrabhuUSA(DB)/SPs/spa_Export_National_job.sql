/****** Object:  StoredProcedure [dbo].[spa_Export_National_job]    Script Date: 07/25/2014 12:19:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Export_National_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Export_National_job]
GO
/****** Object:  StoredProcedure [dbo].[spa_Export_National_job]    Script Date: 07/25/2014 12:19:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--spa_Export_National_job '20100072',NULL,'NBLADMIN01','30108381','moin','a','NationalBank'
CREATE PROCEDURE [dbo].[spa_Export_National_job] 
@agent_id varchar(50),
@paymentType varchar(50)=NULL,
@login_user_id varchar(50),
@branch_id varchar(50),
@ditital_id varchar(200)=NULL,
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice
@batch_Id varchar(100)=null
as
DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(150),@desc varchar(1000)
SET @process_id = REPLACE(newid(),'-','_')
if @ditital_id is null
	set @ditital_id=@process_id

	SET @job_name = 'spa_Export_National' + @process_id
	SET @spa = 'spa_Export_National  ''' + @agent_id  +''','+
	case when @paymentType is null then ' Null '  else  '''' + @paymentType  +  ''''  end +',''' + @login_user_id  +  ''',
	'''+@branch_id+''','''+ @ditital_id +''',''' + @process_id  +  ''',''' +@batch_Id +''''

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




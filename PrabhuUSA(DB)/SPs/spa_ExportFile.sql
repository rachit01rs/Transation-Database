
/****** Object:  StoredProcedure [dbo].[spa_ExportFile]    Script Date: 06/11/2013 21:45:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ExportFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ExportFile]
GO

/****** Object:  StoredProcedure [dbo].[spa_ExportFile]    Script Date: 06/11/2013 21:45:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_ExportFile 'cc12333','support','Export_File','2012-05-01','2012-05-02'
CREATE proc [dbo].[spa_ExportFile]
@process_id varchar(150),
@login_user_id varchar(50),
@batch_id varchar(50),
@from_date varchar(20) ,
@to_date varchar(20) ,
@date_type varchar(20)=null,
@send_agent_id varchar(50)=null,
@payout_agent_id varchar(50)=null,
@payout_country varchar(50) =null
as 

--SET @process_id = dbo.FNAGetNewID()
--set @from_date ='2012-05-01'
--set @to_date ='2012-05-01'

declare @cmd varchar(5000)
declare @ssispath varchar(1000)
declare @Output_Path varchar(500),@Output_file VARCHAR(500)

set @Output_Path='C:\Project\SSIS\ExportExcel\Output'
set @ssispath = 'C:\Project\SSIS\ExportExcel\ExportExcel\ExportExcel\bin\Package1.dtsx'
SET @Output_file=@Output_Path +'\'+@process_id

set @date_type=isNULL(@date_type,'confirmDate')
DECLARE @SQL_Export VARCHAR(500)
SET @SQL_Export='spa_SSIS_ExportFile ''2011-05-01'',''2012-05-01'''

set @cmd = '/F "' + @ssispath + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::Process_ID].Properties[Value];"' + @process_id + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::SQL_Export].Properties[Value];"' + @SQL_Export + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::Output_Path].Properties[Value];"' + @Output_Path + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::Output_FileName].Properties[Value];"' + @Output_file + '"' 

print @cmd
--exec master..xp_cmdshell @cmd
declare @job_name varchar(200),@user_id varchar(50)
set @job_name='SSIS_'+@process_id
set @user_id=SYSTEM_USER
exec [spa_SSIS_Job]
	@run_job_name=@job_name
	, @spa=@cmd
	, @proc_desc='SSIS Job'
	, @user_login_id=@user_id
	, @job_subsystem = 'SSIS'
	, @process_id =@process_id
	, @proxy_name='SSIS_Proxy'


declare @desc varchar(500)
set @desc='Export file completed as of date '+ @from_date +' and '+ @to_date 

	EXEC  spa_message_board 'u', @login_user_id,
				NULL, @batch_id,
				@desc, 'c', @process_id,null,null

GO



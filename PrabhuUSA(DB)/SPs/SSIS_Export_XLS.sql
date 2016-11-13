

/****** Object:  StoredProcedure [dbo].[spa_SSIS_ExportFile]    Script Date: 04/12/2013 01:56:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
    
--spa_SSIS_ExportFile '2012-05-01','2012-05-01'    
CREATE PROC [dbo].[spa_SSIS_ExportFile]    
@from_date VARCHAR(20),    
@to_date VARCHAR(20),    
@date_type varchar(20)='ConfirmDate',    
@agent_id VARCHAR(50)=NULL,    
@payout_country VARCHAR(100)=NULL,    
@payout_agent_id varchar(50)=NULL     
as    
select Tranno,dbo.decryptDB(refno) PINNO,AgentName,Branch,    
SenderName,SenderPassport,SenderCountry,senderNativeCountry SenderNativeCountry,    
ReceiverName BeneficiayName,receiver_mobile BeneficiayMobile,     
ReceiverCountry,ReceiverRelation BeneficiayRelation,    
Paidamt CollectedAMT,ms.SCharge ServiceCharge,    
today_dollar_rate CustomerRate,    
TotalRoundAMT PayoutAMT,ReceiveCType PayoutCCY,PaymentType,    
convert(varchar,confirmDate,106) ApproveDate,    
convert(varchar,confirmDate,108) ApproveTime,    
rBankName PayoutAgent,CustomerID,    
case when ms.TransStatus='Cancel' THEN 'Cancel' ELSE ms.[status] END STATUS,    
ms.ExchangeRate SendCCYUSDRate,    
ms.ho_dollar_rate PayoutCCyUSDRate,    
ms.agent_settlement_rate CustomerRateCost,    
convert(varchar,ms.paidDate ,106)   PaidDate,convert(varchar,ms.paidDate ,108)   PaidTime,    
ms.agent_receiverSCommission PayoutCommissionSendCCY,    
ms.agent_receiverCommission PayoutCommission,    
ms.agent_receiverComm_Currency PayoutCommissionCCY,    
ms.paid_date_usd_rate PaidDateUSDRatePayoutCCY,    
--ms.PaidDate_CustRate PaidDate_CustRate,  
ms.reason_for_remittance PurposeOfRemittance    
from moneysend ms where case when @date_type='PaidDate' then PaidDate else ConfirmDate end    
between @from_date and @to_date+ ' 23:59:59.990'      
and case when @agent_id is null then '1' else ms.agentid end = isNUll(@agent_id,'1')    
and case when @payout_country is null then '1' else ms.receiverCountry end = isNUll(@payout_country,'1')    
and case when @payout_agent_id is null then '1' else ms.expected_payoutagentid end = isNUll(@payout_agent_id,'1')    
    
    
GO

/****** Object:  StoredProcedure [dbo].[spa_ExportFile_Job]    Script Date: 04/12/2013 01:56:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--set ANSI_NULLS ON
--set QUOTED_IDENTIFIER ON
--go
--spa_ExportFile_Job 'system','2012-05-01','2012-05-02'
------- ##########NEW SYSTEM ################
create proc.[dbo].[spa_ExportFile_Job]
@login_user_id varchar(50),
@from_date varchar(20) ,
@to_date varchar(20) ,
@date_type varchar(20)=null,
@send_agent_id varchar(50)=null,
@payout_agent_id varchar(50)=null,
@payout_country varchar(50) =NULL

as

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100),@batch_id varchar(100)
DECLARE @process_id varchar(150),@desc varchar(1000)

SET @process_id = REPLACE(newid(),'-','_')

set @batch_id='Export_File'
	
	SET @job_name = 'spa_ExportFile_Job_' + @process_id

	SET @spa = 'spa_ExportFile  ''' + @process_id  +''',''' + @login_user_id  +''',''' + @batch_Id  +''','''+@from_date+''','''+@to_date+''','+ 
	case when @date_type is null then ' Null '  else  '''' + @date_type  +  ''''  end +','+
	case when @send_agent_id is null then ' Null ' else  '''' + @send_agent_id  +  '''' end +','+
 	case when @payout_agent_id is null then ' Null '  else  '''' + @payout_agent_id  +  ''''  end +','+
	case when @payout_country is null then ' Null '  else  '''' + @payout_country  +  ''''  end 

print @spa

EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id

set @desc ='<font color=red>Export File is processing for from:' + @from_date +' and to:'+ @to_date +'. Please wait !!</font>'  			 
EXEC  spa_message_board 'i', @login_user_id,
		NULL, @batch_id,
		@desc, 'p', @process_id,null,null,
		NULL ,
		NULL


select 0, @batch_Id,
 			'process run', 'Status', 
			'Batch process has been run and will complete shortly.',
 			'Please check/refresh your message board.'














GO

/****** Object:  StoredProcedure [dbo].[spa_SSIS_Job]    Script Date: 04/12/2013 01:56:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[spa_SSIS_Job]
	@run_job_name VARCHAR(100)
	, @spa VARCHAR(5000)
	, @proc_desc VARCHAR (100)
	, @user_login_id VARCHAR(50)
	, @job_subsystem VARCHAR(100) = 'SSIS'
	, @process_id VARCHAR(120) = NULL
	, @proxy_name VARCHAR(100)=NULL
	, @active_start_date INT = NULL
	, @active_start_time INT = NULL
	, @freq_type INT = NULL
	, @freq_interval INT = NULL
	, @freq_subday_type INT = NULL
	, @freq_subday_interval INT = NULL
	, @freq_relative_interval INT = NULL
	, @freq_recurrence_factor INT = NULL
	, @active_end_date INT = NULL
	, @active_end_time INT = NULL
as


	DECLARE @db_name VARCHAR(50)
			, @user_name VARCHAR(50)
			, @spa_failed VARCHAR(500)
			, @spa_success VARCHAR(500)
			, @desc VARCHAR(500)
			, @msg VARCHAR(500)
			, @job_ID BINARY(16)
			, @sch_name VARCHAR(100)
			, @source VARCHAR(1000)
			, @step_name_1 VARCHAR(1000)
			, @step_name_2 VARCHAR(1000)
			, @step_name_3 VARCHAR(1000)
			
		SET @db_name = DB_NAME()
 
		EXECUTE msdb.dbo.sp_add_job @job_id = @job_ID OUTPUT 
					, @job_name = @run_job_name
					, @owner_login_name = @user_login_id
					, @description = @proc_desc
					, @category_name = N'[Uncategorized (Local)]'
					, @enabled = 1
					, @delete_level= 1
			
		--	set @proxy_name = 'SSIS_Proxy'
			SET @source='SSIS'
			SET @step_name_1 = '1 - SSIS start'
			SET @step_name_2 = '2 - SSIS success' 
			SET @step_name_3 = '3 - SSIS failure'	
			
		PRINT 'step1'
			EXEC msdb.dbo.sp_add_jobstep 
				@job_name = @run_job_name
				, @step_id = 1
				, @step_name = @step_name_1
				, @subsystem = @job_subsystem
				,@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0
				, @command = @spa
				, @database_name = @db_name
				, @proxy_name = @proxy_name
			PRINT 'update job'
			EXECUTE msdb.dbo.sp_update_job @job_id = @job_ID, @start_step_id = 1 
			
--			SET @sch_name = 'schedule_' + @run_job_name
--			
--			if @active_start_date is null 
--			set @active_start_date=CONVERT(VARCHAR(10), GETDATE(), 112)
--			if @active_start_time is null 
--				set @active_start_time=replace(CONVERT(VARCHAR(10), dateadd(s,5,GETDATE()), 108),':','')
--
--			SELECT @freq_type = ISNULL(@freq_type, 1)
--					, @freq_interval = ISNULL(@freq_interval, 0) 
--					, @freq_subday_type = ISNULL(@freq_subday_type, 0)
--					, @freq_subday_interval =ISNULL(@freq_subday_interval, 0)
--					, @freq_relative_interval =ISNULL(@freq_relative_interval, 0)
--					, @freq_recurrence_factor = ISNULL(@freq_recurrence_factor, 0)
--					, @active_start_date = ISNULL(@active_start_date, 19900101)
--					, @active_end_date = ISNULL(@active_end_date, 99991231)
--					, @active_start_time = ISNULL(@active_start_time, 000000)
--					, @active_end_time =ISNULL(@active_end_time, 235959)
--			
--declare @schedule_id  int
--			-- Add the job schedules
--			PRINT 'add schedule'
--			EXEC msdb.dbo.sp_add_schedule 
--				@schedule_name = @sch_name
--				, @enabled = 1 
--				, @freq_type = @freq_type
--				, @freq_interval = @freq_interval
--				, @freq_subday_type = @freq_subday_type
--				, @freq_subday_interval = @freq_subday_interval
--				, @freq_relative_interval = @freq_relative_interval
--				, @freq_recurrence_factor = @freq_recurrence_factor
--				, @active_start_date = @active_start_date
--				, @active_end_date = @active_end_date
--				, @active_start_time = @active_start_time
--				, @active_end_time = @active_end_time
--				,@schedule_id  =@schedule_id  output
--			
--			PRINT 'attach schedule'
--			EXEC msdb.dbo.sp_attach_schedule @job_name = @run_job_name, @schedule_name = @sch_name
--			
--		EXEC msdb.dbo.sp_update_schedule @schedule_id=@schedule_id, 
--			@enabled=1

			PRINT 'add jobserver'
			EXECUTE msdb.dbo.sp_add_jobserver @job_id = @job_ID, @server_name = N'(local)' 

	EXEC msdb.dbo.sp_start_job @job_name = @run_job_name

GO

/****** Object:  StoredProcedure [dbo].[spa_ExportFile]    Script Date: 04/12/2013 01:56:46 ******/
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



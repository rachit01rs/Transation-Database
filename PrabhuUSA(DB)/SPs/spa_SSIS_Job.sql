
/****** Object:  StoredProcedure [dbo].[spa_SSIS_Job]    Script Date: 06/11/2013 21:46:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_SSIS_Job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_SSIS_Job]
GO


/****** Object:  StoredProcedure [dbo].[spa_SSIS_Job]    Script Date: 06/11/2013 21:46:00 ******/
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



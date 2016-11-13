
/****** Object:  StoredProcedure [dbo].[spa_ExportFile_Job]    Script Date: 06/11/2013 21:45:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ExportFile_Job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ExportFile_Job]
GO



/****** Object:  StoredProcedure [dbo].[spa_ExportFile_Job]    Script Date: 06/11/2013 21:45:04 ******/
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




GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_yearly_ofac_job]') AND TYPE in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_yearly_ofac_job]
GO
/****** Object:  StoredProcedure [dbo].[spa_get_yearly_ofac_job]    Script Date: 08/24/2014 16:45:44 ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[spa_get_yearly_ofac_job]    Script Date: 08/24/2014 12:58:12 ******/
/*
** Database :		PrabhuUSA
** Object :			spa_get_yearly_ofac_job
** Purpose :		Yearly report generation
** Author:			Sudaman Shrestha
** Date:			08/24/2014
** Flag:			'a' for processing batch, 'b' for displaying table
** Modification:	made stored procedure capable of generating report based on different report type(ofac,compliance,total transaction,total cancelled)
** Date:			09/05/2014
** Report type:		'tt' = total transaction, 'ct' = total cancelled transaction, 'ofac' = ofac, 'cpl' = compliance
** Note:			pass @batch_Id as shorter as possible. There is a maximum limit defined for naming table name = 50. In my case 'YR' = Yearly Report
** Execute Examples :	
		select * from message_board
		spa_get_yearly_ofac_job 'a',NULL, NULL, NULL, '2014',NULL,NULL,NULL,'admin','YR',NULL,NULL,NULL,NULL,'cpl'
		spa_get_yearly_ofac_job 'b',2992, NULL, NULL, '2014',NULL,NULL,NULL,'admin','YR',NULL,NULL,NULL,NULL,'cpl'
*/

CREATE PROC [dbo].[spa_get_yearly_ofac_job]    
@flag CHAR(1),
@message_id INT = NULL,
@agent_id VARCHAR(50)=NULL,    
@sel_month INT=NULL,    
@sel_year INT=NULL,    
@date_type VARCHAR(200)=NULL,    
@curr_type CHAR(1)='l',    
@payout_country VARCHAR(50)=null,    
@login_user_id VARCHAR(100),    
@batch_Id VARCHAR(100),    
@run_by CHAR(1)=null,    
@SenderCountry VARCHAR(100)=NUll,    
@pay_agent VARCHAR(50)=NULL,   
@sender_state VARCHAR(100)=NULL,
@report_type VARCHAR(10) 

AS    
    
DECLARE @spa VARCHAR(500)    
DECLARE @job_name_all VARCHAR(500) 
DECLARE @process_id VARCHAR(150)
DECLARE @desc VARCHAR(1000)
DECLARE @sql1 VARCHAR(5000)
DECLARE @sql2 VARCHAR(5000)
DECLARE @sql3 VARCHAR(5000)
DECLARE @user_login_id VARCHAR(100)
DECLARE @job_name VARCHAR(500)
DECLARE @full_batch_id_name VARCHAR(200)

IF @report_type = 'cpl' SET @full_batch_id_name = 'compliance'
IF @report_type = 'ct' SET @full_batch_id_name = 'cancelled transaction'
IF @report_type = 'tt' SET @full_batch_id_name = 'Total Transaction'
IF @report_type = 'ofac' SET @full_batch_id_name = @report_type

SET @process_id = REPLACE(NEWID(),'-','_')
   
IF @flag = 'a'
	BEGIN  
		SET @job_name_all = 'spa_get_yearly_ofac_job_' +@process_id 
		SET @spa = 'spa_get_yearly_ofac '+    
		isNull(''''+@agent_id+'''','NULL') +','+    
		isNull(''''+cast(@sel_month AS varchar)+'''','NULL') +','+    
		isNull(''''+cast(@sel_year AS varchar)+'''','NULL') +','+    
		isNull(''''+ @date_type +'''','NULL') +','+		 
		isNull(''''+@payout_country+'''','NULL') +','''+@process_id+''','''+@login_user_id +''',    
		'''+@batch_Id +''','+isNull(''''+@SenderCountry+'''','NULL')    
		+','+isNull(''''+@pay_agent+'''','NULL')    
		+','+isNull(''''+@sender_state+'''','NULL')
		+','+isNull(''''+@report_type+'''','NULL')  
		
		PRINT(@spa)  
   
		EXEC spa_run_sp_as_job @job_name_all, @spa, @batch_Id , @login_user_id  

		SET @desc ='<font color=red>'+ UPPER(@full_batch_id_name)+' <b>Report</b> is processing. Please wait !!</font>'          
 
		EXEC spa_message_board 'i',@login_user_id,NULL, @batch_id,@desc,'p',@process_id,null,null,
			@agent_id,NULL,@run_by 
  
		SELECT 0,@batch_Id,'process run','Status','Batch process has been run and will complete shortly.',    
			'Plese check/refresh your message board.'    
	END

IF @flag = 'b'
	BEGIN	
		SELECT @user_login_id=user_login_id,@job_name=job_name 
		FROM message_board 
		WHERE message_id=@message_id AND source=@batch_Id
		
		IF @user_login_id IS NULL AND @job_name IS NULL
			BEGIN
				SELECT 'ERROR' [Status],2001,'No record in message_board table' [Message]
				RETURN
			END
		ELSE
							
		BEGIN TRY
			IF @report_type <> 'ofac' and @report_type <> 'cpl' 
				BEGIN
					SET @sql1='SELECT * FROM iremit_process.dbo.'+@batch_Id+'_'+ @user_login_id+'_'+@report_type+@job_name 
					EXEC(@sql1)
				END
			IF @report_type='ofac' or @report_type = 'cpl'
				BEGIN
					SET @sql1='SELECT * FROM iremit_process.dbo.'+@batch_Id+'_'+ @user_login_id+'_all'+@report_type+@job_name 
					SET @sql2='SELECT * FROM iremit_process.dbo.'+@batch_Id+'_'+ @user_login_id+'_hold'+@report_type+@job_name 
					SET @sql3='SELECT * FROM iremit_process.dbo.'+@batch_Id+'_'+ @user_login_id+'_cancel'+@report_type+@job_name							
					EXEC(@sql1)
					EXEC(@sql2)
					EXEC(@sql3)
				END
		END TRY
		BEGIN CATCH
			SELECT 'ERROR' [status],'Record does not exist' [message]
		END CATCH 
	END
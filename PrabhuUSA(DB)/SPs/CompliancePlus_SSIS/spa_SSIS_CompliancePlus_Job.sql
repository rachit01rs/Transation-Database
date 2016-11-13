IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_SSIS_CompliancePlus_Job]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].spa_SSIS_CompliancePlus_Job
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_SSIS_CompliancePlus_Job  
** Purpose     : 
** Author      : Kanchan Dahal
** Date        : 24rd August 2013  
  
*/
--spa_SSIS_CompliancePlus_Job NULL,'2012-01-01','2013-12-31',NULL,'admin',':','h'
-----spa_SSIS_CompliancePlus_Job @batch_id='Export_CompliancePlusSSIS',@trn_type=NULL,@fromDate='2012-01-01 ',@toDate='2014-05-12 ',@check=NULL,@login_user_id='admin',@run_by='h',@url_desc='action_form=txtReportPay_CompliancePlusSSIS.asp&batch_id=Export_CompliancePlusSSIS',@file_name='PGI'

CREATE PROCEDURE.[dbo].spa_SSIS_CompliancePlus_Job
    @trn_type VARCHAR(50) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @check CHAR(1) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @ditital_id VARCHAR(200) = NULL ,
    @run_by CHAR(1) = NULL , --a as agent , b as branch, NULL or H as HeadOffice  
    @batch_Id VARCHAR(100) = NULL ,
	@url_desc VARCHAR(5000) = NULL,
	@agentId VARCHAR(50) = NULL,
	@file_name VARCHAR(50) = NULL

AS 

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100) --,@batch_id varchar(100)
DECLARE @process_id varchar(150),@desc varchar(1000),@Output_file VARCHAR(200)

SET @process_id = REPLACE(newid(),'-','_')
IF @batch_id IS NULL
	set @batch_id='Export_CompliancePlusSSIS'

IF @file_name IS NULL
	set @file_name=@batch_id

SET @Output_file=@file_name+'_'+@process_id+'.txt'

---------------------------------------Setup------------------------------------------------------------------------------
DECLARE @path VARCHAR(500),@servername VARCHAR(50),@databasename VARCHAR(50),@ssispath varchar(200)
set @ssispath = 'D:\SVN\Prabhu_USA\Other_Files\ExportCompliancePlus\CompliancePlus\CompliancePlus\bin\Deployment\Package.dtsx'
SET @path='D:\SVN\Prabhu_USA\Other_Files\ExportCompliancePlus\CompliancePlus\Output\'
SET @databasename='prabhuusa'
SET @servername='(local)'
--------------------------------------------------------------------------------------------------------------------------

SET @url_desc = @Output_file
	
	SET @job_name = 'spa_SSIS_CompliancePlus_' + @process_id

	SET @spa = 'spa_SSIS_CompliancePlus ' 
         + CASE WHEN @trn_type IS NULL THEN 'NULL'
               ELSE '''' + @trn_type + ''''
          END + ',' 
        + CASE WHEN @fromDate IS NULL THEN 'NULL'
               ELSE '''' + @fromDate + ''''
          END + ',' 
          + CASE WHEN @toDate IS NULL THEN 'NULL'
               ELSE '''' + @toDate + ''''
          END + ',' 
          + CASE WHEN @check IS NULL THEN 'NULL'
               ELSE '''' + @check + ''''
          END + ',' 
          + CASE WHEN @login_user_id IS NULL THEN 'NULL'
               ELSE '''' + @login_user_id + ''''
          END + ',' 
          + CASE WHEN @process_id IS NULL THEN 'NULL'
               ELSE '''' + @process_id + ''''
          END + ',' 
          + CASE WHEN @batch_id IS NULL THEN 'NULL'
               ELSE '''' + @batch_id + ''''
          END  + ',' 
          + CASE WHEN @url_desc IS NULL THEN 'NULL'
               ELSE '''' + @url_desc + ''''
          END 
 

print @spa

-----------------------------------------------------------------------------------------------------------------------
----------------------------- Creating a job for ssis package----------------------------------------------------------
declare @cmd varchar(8000)
declare @Final_Path varchar(200) ,@template VARCHAR(200) ,@Working_Path VARCHAR(200),@del_file VARCHAR (250)


set @Final_Path='D:\SVN\Prabhu_USA\iRemit\BB645F9F_D0E2_4739_BABE_04E56BCD1605\\'
SET @template=@path+'template\templateFile.txt'
SET @Working_Path=@path+'working\'+@Output_file
SET @del_file='spa_message_board @flag=''c'',@source='''+@batch_id+''''

set @cmd = '/F "' + @ssispath + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::strSQLScript].Properties[Value];"' + @spa + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::strFinalPath].Properties[Value];"' + @Final_Path + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::strWorkingPath].Properties[Value];"' + @Working_Path + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::strTemplate].Properties[Value];"' + @template + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::strDelFile].Properties[Value];"' + @del_file + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::DBserverName].Properties[Value];"' + @ServerName + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::DBname].Properties[Value];"' + @DatabaseName + '"' 


print @cmd

--exec master..xp_cmdshell @cmd
declare @user_id varchar(50)
set @user_id=SYSTEM_USER
exec [spa_SSIS_Job]
	@run_job_name=@job_name
	, @spa=@cmd
	, @proc_desc='SSIS Job'
	, @user_login_id=@user_id
	, @job_subsystem = 'SSIS'
	, @process_id =@process_id
	, @proxy_name='SSIS_proxy'


-----------------------------------------------------------------------------------------------------------------------

--EXEC spa_run_sp_as_job @job_name, @spa, @batch_id , @login_user_id

set @desc ='<font color=red>Export File is processing for from:' + @fromDate +' and to:'+ @toDate +'. Please wait !!</font>'  			 
EXEC  spa_message_board 'i', @login_user_id,
		NULL, @batch_id,
		@desc, 'p',  @process_id,null,null,
		@agentId ,
		NULL,
		@run_by


select 0, @batch_id,
 			'process run', 'Status', 
			'Batch process has been run and will complete shortly.',
 			'Please check/refresh your message board.'



GO
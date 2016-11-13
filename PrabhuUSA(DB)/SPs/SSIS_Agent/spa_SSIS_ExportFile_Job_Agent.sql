IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_SSIS_ExportFile_Job_Agent]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_SSIS_ExportFile_Job_Agent]
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_SSIS_ExportFile_Job_Agent  
** Purpose     : 
** Author      : Bikash Giri 
** Date        : 24rd August 2013  
  
*/
--spa_SSIS_ExportFile_Job_Agent '20100031','bandana','2013-08-05','2013-08-25','PaidDate',NULL,'Nepal','30106331','Paid',NULL,'a','Export_File'


CREATE PROCEDURE.[dbo].[spa_SSIS_ExportFile_Job_Agent]
@agent_id varchar(50),
@login_user_id varchar(50),
@from_date varchar(20) ,
@to_date varchar(20) ,
@date_type varchar(20)=null,
@payout_agent_id varchar(50)=null,
@payout_country varchar(50) =NULL,
@branch_code VARCHAR (50) = NULL,
@trn_status VARCHAR (50) =NULL,
@trn_type VARCHAR (50) =NULL,
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice
@batch_id varchar(100)

AS 

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100) --,@batch_id varchar(100)
DECLARE @process_id varchar(150),@desc varchar(1000),@url_desc VARCHAR(1000),@Output_file VARCHAR(200)

SET @process_id = REPLACE(newid(),'-','_')
IF @batch_id IS NULL
	set @batch_id='Export_File'

SET @Output_file=@batch_id+'_'+@process_id+'.xls'

---------------------------------------Setup------------------------------------------------------------------------------
DECLARE @path VARCHAR(500),@servername VARCHAR(50),@databasename VARCHAR(50),@ssispath varchar(200)
set @ssispath = 'D:\SVN\Prabhu_USA\Database\SSISPackage\Export_File_SSIS_Agent\bin\Deployment\Export_File_SSIS.dtsx'
SET @path='D:\SVN\Prabhu_USA\Database\SSISPackage\Export_File_SSIS_Agent\output\'
SET @databasename='prabhuusa'
SET @servername='(local)'
--------------------------------------------------------------------------------------------------------------------------

SET @url_desc = 'path='+@path+'final\'+@Output_file
	
	SET @job_name = 'spa_SSIS_ExportFile_Job_Agent_' + @process_id

	SET @spa = 'spa_SSIS_ExportFile_Agent  ''' + @process_id  +''',''' + @agent_id  +''','''+ @login_user_id  +''',''' + @batch_id  +''','''+@from_date+''','''+@to_date+''','+ 
	case when @date_type is null then ' Null '  else  '''' + @date_type  +  ''''  END +','+
 	case when @payout_agent_id is null then ' Null '  else  '''' + @payout_agent_id  +  ''''  END +','+
	case when @payout_country is null then ' Null '  else  '''' + @payout_country  +  ''''  END +','+
	case when @branch_code is null then ' Null ' else  '''' + @branch_code  +  '''' END +','+
	case when @trn_status is null then ' Null ' else  '''' + @trn_status  +  '''' END +','+
	case when @trn_type is null then ' Null ' else  '''' + @trn_type  +  '''' END +','+
	case when @url_desc is null then ' Null ' else  '''' + @url_desc  +  '''' END


 
 
 

print @spa

-----------------------------------------------------------------------------------------------------------------------
----------------------------- Creating a job for ssis package----------------------------------------------------------
declare @cmd varchar(8000)
declare @Final_Path varchar(200) ,@template VARCHAR(200) ,@Working_Path VARCHAR(200),@del_file VARCHAR (250)


set @Final_Path=@path+'final\\'
SET @template=@path+'template\template.xls'
SET @Working_Path=@path+'working\'+@Output_file
SET @del_file='spa_message_board @flag=''c'',@source='+@batch_id

set @cmd = '/F "' + @ssispath + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::Sql_Script].Properties[Value];"' + @spa + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::Final_Path].Properties[Value];"' + @Final_Path + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::Working_Path].Properties[Value];"' + @Working_Path + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::template].Properties[Value];"' + @template + '"'
set @cmd = @cmd + ' /SET \Package.Variables[User::del_file].Properties[Value];"' + @del_file + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::ServerName].Properties[Value];"' + @ServerName + '"' 
set @cmd = @cmd + ' /SET \Package.Variables[User::DatabaseName].Properties[Value];"' + @DatabaseName + '"' 


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
	, @proxy_name='SSIS_Proxy'


-----------------------------------------------------------------------------------------------------------------------

--EXEC spa_run_sp_as_job @job_name, @spa, @batch_id , @login_user_id

set @desc ='<font color=red>Export File is processing for from:' + @from_date +' and to:'+ @to_date +'. Please wait !!</font>'  			 
EXEC  spa_message_board 'i', @login_user_id,
		NULL, @batch_id,
		@desc, 'p',  @process_id,null,null,
		@agent_id ,
		NULL,
		@run_by


select 0, @batch_id,
 			'process run', 'Status', 
			'Batch process has been run and will complete shortly.',
 			'Please check/refresh your message board.'



GO
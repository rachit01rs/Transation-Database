IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_SSIS_ExportFile_Job_Api_Detail]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_SSIS_ExportFile_Job_Api_Detail]
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_SSIS_ExportFile_Job_Api_Detail  
** Purpose     : 
** Author      : Bikash Giri 
** Date        : 10th september 2013  
  
*/
--spa_SSIS_ExportFile_Job_Api_Detail 'admin','Nepal','Cash_Payment',null,'Export_Api_Detail'


CREATE PROCEDURE [dbo].[spa_SSIS_ExportFile_Job_Api_Detail]
@admin varchar(50),
@payout_country varchar(50) =NULL,
@PAYMENTTYPE VARCHAR (50) =NULL,
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice
@batch_id varchar(100),
@agentCode varchar(50)=null
--
AS 

DECLARE @spa varchar(500)
DECLARE @job_name varchar(100) --,@batch_id varchar(100)
DECLARE @process_id varchar(150),@desc varchar(1000),@url_desc VARCHAR(1000),@Output_file VARCHAR(200)

SET @process_id = REPLACE(newid(),'-','_')
IF @batch_id IS NULL
	set @batch_id='Export_Api_Detail'


SET @Output_file=@batch_id+'_'+@PAYMENTTYPE+'_'+@process_id+'.txt'

---------------------------------------Setup------------------------------------------------------------------------------
DECLARE @path VARCHAR(500),@servername VARCHAR(50),@databasename VARCHAR(50),@ssispath varchar(200)
set @ssispath = 'D:\SVN\Prabhu_USA\Database\SSISPackage\Export_File_SSIS_Api_Detail\bin\Deployment\Export_File_SSIS.dtsx'
SET @path='D:\SVN\Prabhu_USA\Database\SSISPackage\Export_File_SSIS_Api_Detail\output\'
SET @databasename='prabhuusa'
SET @servername='(local)'
--------------------------------------------------------------------------------------------------------------------------
 


SET @url_desc = 'path='+@path+'final\'+@Output_file
	
	SET @job_name = 'spa_SSIS_ExportFile_Job_Api_Detail_' + @process_id

	SET @spa = 'spa_SSIS_ExportFile_Api_Detail  ''' + @process_id  +''',''' + @admin +''','''+ @batch_id  +''','+ 
	case when @payout_country is null then ' Null '  else  '''' + @payout_country  +  ''''  END +','+
	case when @PAYMENTTYPE is null then ' Null ' else  '''' + @PAYMENTTYPE  +  '''' END +','+
	case when @url_desc is null then ' Null ' else  '''' + @url_desc  +  '''' END+','+
	case when @agentCode is null then ' Null ' else  '''' + @agentCode  +  '''' END



 
 

print @spa

-----------------------------------------------------------------------------------------------------------------------
----------------------------- Creating a job for ssis package----------------------------------------------------------
declare @cmd varchar(8000)
declare @Final_Path varchar(200) ,@template VARCHAR(200) ,@Working_Path VARCHAR(200),@del_file VARCHAR (250)


set @Final_Path=@path+'final\\'
SET @template=@path+'template\template.txt'
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

set @desc ='<font color=red>Export File is processing. Please wait !!</font>'  			 
EXEC  spa_message_board 'i', @admin,
		NULL, @batch_id,
		@desc, 'p',  @process_id,null,null,
		@admin ,
		NULL,
		@run_by


select 0, @batch_id,
 			'process run', 'Status', 
			'Batch process has been run and will complete shortly.',
 			'Please check/refresh your message board.'



GO
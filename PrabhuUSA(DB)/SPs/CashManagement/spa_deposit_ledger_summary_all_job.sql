--set ANSI_NULLS ON      
--set QUOTED_IDENTIFIER ON      
--go      
--spa_deposit_ledger_job 's','10100000','8004','8/26/2008','10/26/2008','10100500',NULL,NULL,'klanoop',null      
------- ##########NEW SYSTEM ################      
DROP PROC spa_deposit_ledger_summary_all_job
Go
--set ANSI_NULLS ON  
--set QUOTED_IDENTIFIER ON  
--go  
--spa_deposit_ledger_job 's','10100000','8004','8/26/2008','10/26/2008','10100500',NULL,NULL,'klanoop',null  
------- ##########NEW SYSTEM ################  
create proc.[dbo].[spa_deposit_ledger_summary_all_job]  
@agent_id varchar(50),  
@deposit_id varchar(50),  
@from_date varchar(20),  
@branch_code varchar(50)=NULL,  
@login_user_id varchar(50)=NULL,  
@deposit_type varchar(10)=NULL,  
@to_date varchar(20)=NULL   
as  
  
DECLARE @spa varchar(500)  
DECLARE @job_name varchar(100),@batch_id varchar(100)  
DECLARE @process_id varchar(150),@desc varchar(1000)  
  
SET @process_id = REPLACE(newid(),'-','_')  
  
set @batch_id='deposit_summary'  
 SET @job_name = 'spa_deposit_ledger_summary_all_job_' + @process_id  
  
 DECLARE @vault_ledger_id VARCHAR(50)  
   
 SELECT  @vault_ledger_id=af.cash_vault  
   FROM agent_function af WHERE af.agent_Id=@agent_id  
IF @deposit_id=@vault_ledger_id  
BEGIN   
 SET @batch_id='cash_vault'  
SET @spa = 'spa_deposit_ledger_summary_vault '+   
 case when @agent_id is null then ' Null '  else  '''' + @agent_id  +  ''''  end +','+  
 case when @deposit_id is null then ' Null ' else  '''' + @deposit_id  +  '''' end +',  
 '''+ @from_date + ''','+  
  case when @branch_code is null then ' Null '  else  '''' + @branch_code  +  ''''  end +',  
 '''+ @login_user_id  + ''','''+@process_id +''','+  
 case when @deposit_type is null then ' Null '  else  '''' + @deposit_type  +  ''''  END +','''+ @to_date + ''''  
END   
ELSE   
BEGIN   
   
 SET @spa = 'spa_deposit_ledger_summary_all '+   
 case when @agent_id is null then ' Null '  else  '''' + @agent_id  +  ''''  end +','+  
 case when @deposit_id is null then ' Null ' else  '''' + @deposit_id  +  '''' end +',  
 '''+ @from_date + ''','+  
  case when @branch_code is null then ' Null '  else  '''' + @branch_code  +  ''''  end +',  
 '''+ @login_user_id  + ''','''+@process_id +''','+  
 case when @deposit_type is null then ' Null '  else  '''' + @deposit_type  +  ''''  end  
END   
print @spa  
  
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id  
  
set @desc ='<font color=red>Ledger Summary is processing for as of date:' + @from_date +' . Please wait !!</font>'        
EXEC  spa_message_board 'i', @login_user_id,  
  NULL, @batch_id,  
  @desc, 'p', @process_id,null,null,  
  @agent_id ,  
  @branch_code  
  
  
select 0, @batch_Id,  
    'process run', 'Status',   
   'Batch process has been run and will complete shortly.',  
    'Please check/refresh your message board.'      
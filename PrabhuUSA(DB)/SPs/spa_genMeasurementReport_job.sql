DROP PROCEDURE [dbo].[spa_genMeasurementReport_job]   
Go
--spa_genMeasurementReport_job 's','10100000',NULL,'7/1/2008','8/12/2008','-1','y','a','l',1,'y','anoop'  
CREATE PROCEDURE [dbo].[spa_genMeasurementReport_job]   
@flag char(1),  
@agent_id varchar(50),  
@branch_id varchar(50),  
@from_date varchar(20),  
@to_date varchar(20),  
@settlement_agent_id varchar(50)=null,  
@calc_opening_balance char(1)=null,  
@agent_type char(1)=null, -- NULL/a MAIN AGENT TYPE , b= Branch Type , d Bank or Deposit type  
@calc_currency char(1)=null, -- l = Local CUrrency , d - USD  
@usd_rate money=null,  
@calc_commission char(1)=null,  
@login_user_id varchar(50)=null,  
@run_by char(1)=NULL, --a as agent , b as branch, NULL or H as HeadOffice  
@batch_id varchar(100)=NULL --- for filtering batch type 'soa_ledger_local  
as  
DECLARE @spa varchar(500)  
DECLARE @job_name varchar(100)  
DECLARE @process_id varchar(150),@desc varchar(1000)  
SET @process_id = REPLACE(newid(),'-','_')  
--PRINT (@batch_id)  
  
IF @batch_id IS NULL  
set @batch_id='soa_ledger'  
 SET @job_name = 'spa_LedgerReport_job_' + @process_id  
--  
declare @pmt_date varchar(50)  
set @pmt_date='04/30/2011 23:59:59:999'  
print CONVERT(VARCHAR(26), @pmt_date, 109)  
print CONVERT(VARCHAR(26), @from_date, 109)  
print CONVERT(VARCHAR(26), @to_date, 109)  
if CONVERT(VARCHAR(26), @pmt_date, 109)>CONVERT(VARCHAR(26), @to_date, 109)  
print 'test'  
else if CONVERT(VARCHAR(26), @pmt_date, 109)<CONVERT(VARCHAR(26), @to_date, 109)  
print 'test2'  
else  
print 'test3'  
 print datediff(d,@pmt_date,@from_date)  
print datediff(d,@pmt_date,@to_date)  
if @agent_id='20100003'  
begin  
if datediff(d,@pmt_date,@from_date)<0 and datediff(d,@pmt_date,@to_date)<0  
begin  
 SET @spa = 'spa_LedgerReport_PMTNepal_job  ''' + @flag  +''','+   
 case when @agent_id is null then ' Null '  else  '''' + @agent_id  +  ''''  end +','+  
 case when @branch_id is null then ' Null ' else  '''' + @branch_id  +  '''' end +',  
 '''+ @from_date + ''','''+ @to_date + ''','+  
  case when @settlement_agent_id is null then ' Null '  else  '''' + @settlement_agent_id  +  ''''  end +','+  
 case when @calc_opening_balance is null then ' Null '  else  '''' + @calc_opening_balance  +  ''''  end +','+  
 case when @agent_type is null then ' Null '  else  '''' + @agent_type  +  ''''  end +','+  
 case when @calc_currency is null then ' Null '  else  '''' + @calc_currency  +  ''''  end +','+  
 case when @usd_rate is null then ' Null '  else  '' + cast(@usd_rate as varchar)  +  ''  end +','+  
 case when @calc_commission is null then ' Null '  else  '''' + @calc_commission  +  ''''  end +',  
 '''+ @login_user_id  + ''','''+@process_id +''''  
end  
else if datediff(d,@pmt_date,@from_date)>=0 and datediff(d,@pmt_date,@to_date)>=0  
  
begin  
 SET @spa = 'spa_LedgerReport_PMT_Paid_job  ''' + @flag  +''','+   
 case when @agent_id is null then ' Null '  else  '''' + @agent_id  +  ''''  end +','+  
 case when @branch_id is null then ' Null ' else  '''' + @branch_id  +  '''' end +',  
 '''+ @from_date + ''','''+ @to_date + ''','+  
  case when @settlement_agent_id is null then ' Null '  else  '''' + @settlement_agent_id  +  ''''  end +','+  
 case when @calc_opening_balance is null then ' Null '  else  '''' + @calc_opening_balance  +  ''''  end +','+  
 case when @agent_type is null then ' Null '  else  '''' + @agent_type  +  ''''  end +','+  
 case when @calc_currency is null then ' Null '  else  '''' + @calc_currency  +  ''''  end +','+  
 case when @usd_rate is null then ' Null '  else  '' + cast(@usd_rate as varchar)  +  ''  end +','+  
 case when @calc_commission is null then ' Null '  else  '''' + @calc_commission  +  ''''  end +',  
 '''+ @login_user_id  + ''','''+@process_id +''''  
end  
else if  datediff(d,@pmt_date,@from_date)<0 and datediff(d,@pmt_date,@to_date)>0  
  
begin  
 select 'Error' status,'Please select the date range before or after '+@pmt_date+'' msg  
 return  
end  
end  
else  
begin  
 SET @spa = 'spa_LedgerReport_job  ''' + @flag  +''','+   
 case when @agent_id is null then ' Null '  else  '''' + @agent_id  +  ''''  end +','+  
 case when @branch_id is null then ' Null ' else  '''' + @branch_id  +  '''' end +',  
 '''+ @from_date + ''','''+ @to_date + ''','+  
  case when @settlement_agent_id is null then ' Null '  else  '''' + @settlement_agent_id  +  ''''  end +','+  
 case when @calc_opening_balance is null then ' Null '  else  '''' + @calc_opening_balance  +  ''''  end +','+  
 case when @agent_type is null then ' Null '  else  '''' + @agent_type  +  ''''  end +','+  
 case when @calc_currency is null then ' Null '  else  '''' + @calc_currency  +  ''''  end +','+  
 case when @usd_rate is null then ' Null '  else  '' + cast(@usd_rate as varchar)  +  ''  end +','+  
 case when @calc_commission is null then ' Null '  else  '''' + @calc_commission  +  ''''  end +',  
 '''+ @login_user_id  + ''','''+@process_id +''''  
end  
print @spa  
  
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @login_user_id  
  
set @desc ='<font color=red>SOA is processing for from:' + @from_date +' and to:'+ @to_date +'. Please wait !!</font>'        
 EXEC  spa_message_board 'i', @login_user_id,  
  NULL, @batch_id,  
  @desc, 'p', @process_id,null,null,  
  @agent_id ,  
  @branch_id,  
  @run_by  
  
  
select 0, @batch_Id,  
    'process run', 'Status',   
   'Batch process has been run and will complete shortly.',  
    'Please check/refresh your message board.'  
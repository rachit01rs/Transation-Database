DROP procedure [dbo].[spa_monthly_credit_soa_job]  
go  
CREATE procedure [dbo].[spa_monthly_credit_soa_job]  
@flag char(1)=Null,  
@agentId varchar(50)=Null,  
@agentName varchar(150)=Null,  
@fromDate varchar(50)=Null,  
@toDate varchar(50)=Null,  
@dateType varchar(50)=Null,  
@month varchar(50)=Null,  
@year varchar(50)=Null,  
@user_id varchar(50)=Null,  
@curr char(1)=Null  
  
as  
  
DECLARE @spa varchar(500)  
DECLARE @job_name varchar(100)  
DECLARE @process_id varchar(150),@desc varchar(1000),@batch_Id varchar(100)  
declare @lblDate varchar(50)  
SET @process_id = REPLACE(newid(),'-','_')  
  
set @lblDate=DATENAME(month,''+@month+'/1/'+@year+'')+' '+DATENAME(year,''+@month+'/1/'+@year+'')  
if @flag='l'  
begin  
 set @batch_Id='MonthlyCreditNote'  
 SET @job_name = 'PRABHU_spa_monthly_credit_note_' + @process_id  
 SET @spa = 'spa_monthly_credit_note '+  
 isNull(''''+@agentId+'''','NULL') +','+  
 isNull(''''+@agentName+'''','NULL') +','+  
 isNull(''''+@dateType+'''','NULL') +','+  
 isNull(''''+@fromDate+'''','NULL') +','+  
 isNull(''''+@toDate+'''','NULL') +','+  
 isNull(''''+@user_id+'''','NULL') +','+  
 isNull(''''+@process_id+'''','NULL') +','''+@batch_Id +''''  
 set @desc ='<font color=red>'+ upper(@batch_id)+' is processing from '+@fromDate+' to '+@toDate+':. Please wait !</font>'    
end  
else  
begin  
if @flag='s'  
SET @agentName='Sending: '+@agentName  
if @flag='p'  
SET @agentName='Super: '+@agentName  
if @flag='r'  
SET @agentName='Payout: '+@agentName      
  
 set @batch_Id='MonthlySOA'  
 SET @job_name = 'PRABHU_spa_monthly_soa_' + @process_id  
 SET @spa = 'spa_monthly_soa '+  
 isNull(''''+@flag+'''','NULL') +','+  
 isNull(''''+@agentId+'''','NULL') +','+  
 isNull(''''+@agentName+'''','NULL') +','+  
 isNull(''''+@dateType+'''','NULL') +','+  
 isNull(''''+@month+'''','NULL') +','+  
 isNull(''''+@year+'''','NULL') +','+  
 isNull(''''+@user_id+'''','NULL') +','+  
 isNull(''''+@process_id+'''','NULL') +','''+@batch_Id +''','''+isnull(@curr,'l') +''''  
 set @desc ='<font color=red>'+ upper(@batch_id)+' is processing Month of '+@lblDate+':. Please wait !</font>'  
end  
  
print @spa  
  
set @desc = @desc +'<BR><b>('+@agentName+')</b>'  
EXEC spa_run_sp_as_job @job_name, @spa, @batch_Id , @user_id  
  
EXEC  spa_message_board 'i', @user_id,NULL, @batch_id, @desc, 'p', @process_id  
  
select 0, @batch_Id,'process run', 'Status',   
'Batch process has been run and will complete shortly.',  
'Plese check/refresh your message board.'   
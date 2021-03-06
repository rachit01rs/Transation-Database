    
drop procedure [dbo].[spa_show_sending_reports]    
    go
--exec spa_show_receiving_reports 's','confirmDate','11/12/2007','11/13/2007','','','','','','','Payment'      
CREATE procedure [dbo].[spa_show_sending_reports]      
@report_flag varchar(1),      
@dateType varchar(50),      
@fromDate varchar(50),      
@toDate varchar(50)=NULL,      
@stats varchar(50)=NULL,      
@senderAgentId varchar(50)=NULL,      
@receiveCountry varchar(50)= NULL,      
@receiveAgentName varchar(50)= NULL,      
@rBankId varchar(50)= NULL,      
@paymentType varchar(50)= NULL,      
@tranStatus varchar(50)= NULL,    
@sendCountry varchar(50)= NULL,
@agent_state VARCHAR(100)=NULL       
as      
if @tranStatus='Payment'      
 set @tranStatus='''Payment'',''Block'''      
      
Declare @txt_sql varchar(5000),      
 @txt_condition varchar(5000)      
 set @txt_condition=''      
      
 if @stats is not null  --check the status paid or Un-Paid or both      
 begin      
  set @txt_condition=@txt_condition +' and status='''+ @stats +''''      
 end      
 if @senderAgentId is not null      
  begin      
  set @txt_condition=@txt_condition + ' and agentid='''+ @senderAgentId+''''      
  end      
 if @receiveCountry is not null      
 begin      
  set @txt_condition=@txt_condition + ' and receiverCountry='''+ @receiveCountry+''''      
 end      
 if @receiveAgentName is not null      
 begin        
  set @txt_condition=@txt_condition  + ' and paid_agent_id='''+ @receiveAgentName+''''      
 end      
 if @rBankId is not null      
 begin       
  set @txt_condition=@txt_condition + ' and rBankId='''+ @rBankId +''''      
 end      
 if @paymentType is not null      
 begin       
  set @txt_condition=@txt_condition + ' and paymentType='''+ @paymentType+''''      
 end      
       
 if @tranStatus is not null      
 begin      
  set @txt_condition=@txt_condition + ' and  transStatus in ('+@tranStatus+')'      
 end      
 if @sendCountry is not null      
 begin      
  set @txt_condition=@txt_condition + ' and  sendercountry='''+@sendCountry+''' '     
 end     
 if @agent_state is not null      
 begin      
  set @txt_condition=@txt_condition + ' and  a.state='''+@agent_state+''' '     
 end  
declare @table_name varchar(5000)      
      
if @report_flag='d' --Detail Reports      
begin      
 set @txt_sql='Select * from (select tranno,refno,agentid,a.companyname agentname,branch_code,branch,customerid,senderName,      
   senderCountry,paidcType,ReceiverName,paidAmt,rBankid,rBankBranch,local_dot,      
  paidDate,totalRoundAmt,receiveAmt,status,transStatus, receivecType from moneysend m with (nolock) 
  join agentdetail a with (nolock) on a.agentcode=m.agentid      
  where  '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59 '''      
  set @txt_sql=@txt_sql + @txt_condition      
 if exists(select top 1 table_name from close_transaction where close_date >= @fromDate)      
 begin      
 set @txt_sql=@txt_sql +' union '      
 set @txt_sql=@txt_sql + 'select tranno,refno,agentid,a.companyname agentname,branch_code,branch,customerid,senderName,      
   senderCountry,paidcType,ReceiverName,paidAmt,rBankid,rBankBranch,local_dot,      
  paidDate,totalRoundAmt,receiveAmt,status,transStatus, receivecType from moneysend_arch1 m with (nolock)
  join agentdetail a with (nolock) on a.agentcode=m.agentid     
  where  '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59 '''      
  set @txt_sql=@txt_sql + @txt_condition      
 end      
 set @txt_sql=@txt_sql + ' ) l order by agentname,receivecType,branch'      
 --print @txt_sql      
 exec(@txt_sql)      
      
end      
if @report_flag='s' -- Summary Reports      
begin      
       
 set @txt_sql='select agentname,senderCountry,paidcType,receiveCType  as currencyType,count(*) as No_of_Tran,sum(paidAmt)as       
  paidAmt,receiverCountry,receivectype,rBankName,sum(totalRoundAmt)as TotalRoundAmt from (       
 select a.companyname  agentname,senderCountry,paidcType,paidAmt,      
 receiverCountry,receivectype,a.companyname rBankName, TotalRoundAmt       
 from moneysend m with (nolock)
 join agentdetail a with (nolock) on a.agentcode=m.agentid   
 where '+ @dateType +' between '''+@fromDate +''' and '''+ @toDate +' 23:59:59'''      
 set @txt_sql=@txt_sql + @txt_condition       
 if exists(select top 1 table_name from close_transaction where close_date >= @fromDate)      
 begin      
 set @txt_sql=@txt_sql +' union all       
 select a.companyname agentname,senderCountry,paidcType,paidAmt,      
 receiverCountry,receivectype,rBankName, TotalRoundAmt       
 from moneysend_arch1 m with (nolock)
 join agentdetail a with (nolock) on a.agentcode=m.agentid   
 where '+ @dateType +' between '''+@fromDate +''' and '''+ @toDate +' 23:59:59'''      
 set @txt_sql=@txt_sql + @txt_condition       
 end      
 set @txt_sql=@txt_sql+ ')l group by  agentname,rBankName,receiveCType,paidcType,senderCountry,receiverCountry'      
       
--print(@txt_sql)      
 exec(@txt_sql)      
end    
    
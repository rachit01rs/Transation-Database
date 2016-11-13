drop procedure [dbo].[spa_show_receiving_reports]     
GO    
--exec spa_show_receiving_reports 'd','confirmDate','11/12/2007','11/13/2007',NULL,NULL,NULL,NULL,NULL,NULL,'Payment'       
CREATE procedure [dbo].[spa_show_receiving_reports]      
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
@sendCountry varchar(50)= NULL      
as      
Declare @txt_sql varchar(5000),      
 @txt_condition varchar(5000)      
 set @txt_condition=''      
      
      
 if @stats is not null  --check the status paid or Un-Paid or both      
 begin      
  set @txt_condition=@txt_condition +'  and status='''+ @stats +''''      
 end      
 if @senderAgentId is not null      
  begin      
  set @txt_condition=@txt_condition + '  and agentid='''+ @senderAgentId+''''      
  end      
 if @receiveCountry is not null      
 begin      
  set @txt_condition=@txt_condition + '  and receiverCountry='''+ @receiveCountry+''''      
 end      
 if @receiveAgentName is not null      
 begin        
  set @txt_condition=@txt_condition  + '  and (paid_agent_id='''+ @receiveAgentName+''' or expected_payoutagentid='''+@receiveAgentName+''')'      
 end      
 if @rBankId is not null      
 begin       
  set @txt_condition=@txt_condition + '  and rBankId='''+ @rBankId +''''      
 end      
 if @paymentType is not null      
 begin       
  set @txt_condition=@txt_condition + '  and paymentType='''+ @paymentType+''''      
 end      
       
 if @tranStatus is not null      
 begin      
  set @txt_condition=@txt_condition + ' and  transStatus='''+@tranStatus+''''      
 end      
 if @sendCountry is not null      
 begin      
  set @txt_condition=@txt_condition + ' and  sendercountry='''+@sendCountry+''' '     
 end      
if @report_flag='d' --Detail Reports      
begin      
 set @txt_sql='select tranno,refno,agentid,agentname,branch_code,branch,customerid,senderName,sCharge,      
    senderCountry,paidcType,ReceiverName,paidAmt,rBankid,rBankBranch,rBankName,local_dot,      
   paidDate,paidDate,totalRoundAmt,receiveAmt,status,transStatus, receivecType,r.companyName       
   from moneysend m with(nolock) join agentdetail r with(nolock) on r.agentcode=m.expected_payoutagentid       
   where ' + @dateType +' between '''+ @fromDate +''' and ''' + @toDate +' 23:59:59'''      
      
 set @txt_sql=@txt_sql + @txt_condition + ' order by agentname,receivecType,r.companyName'      
 exec(@txt_sql)      
end      
if @report_flag='s' -- Summary Reports      
begin      
 set @txt_sql='select r.CompanyName,rBankName,agentname,senderCountry,paidcType as currencyType,count(*) as No_of_Tran,sum(paidAmt)as       
  paidAmt,receiverCountry,receivectype,sum(totalRoundAmt)as TotalRoundAmt,expected_payoutagentid from moneysend        
 m with(nolock) join agentdetail r with(nolock) on r.agentcode=m.expected_payoutagentid       
  where m.transStatus<>''Cancel'' and '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59 '''      
      
 set @txt_sql=@txt_sql + @txt_condition       
 set @txt_sql=@txt_sql+ 'group by   r.CompanyName,rBankName,senderCountry,receiverCountry,paidcType,      
  agentname,receivectype,expected_payoutagentid '      
 print @txt_sql      
 exec(@txt_sql)      
end      
  
if @report_flag='t'       
begin  
set @txt_sql='select convert(varchar,'+@dateType+',101) dot,count(*) as No_of_Tran, r.CompanyName,receivectype,  
sum(totalRoundAmt)as TotalRoundAmt from moneysend m with(nolock) join agentdetail r with(nolock) on r.agentcode=m.expected_payoutagentid   
where m.transStatus<>''Cancel'' and '+ @dateType +' between '''+ @fromDate +''' and '''+ @toDate +' 23:59:59 '''        
 set @txt_sql=@txt_sql + @txt_condition         
 set @txt_sql=@txt_sql+ ' group by convert(varchar,'+@dateType+',101),r.CompanyName,receivectype '    
 set @txt_sql=@txt_sql+ ' order by convert(varchar,'+@dateType+',101),r.CompanyName '       
 --print @txt_sql        
 exec(@txt_sql)        
end  
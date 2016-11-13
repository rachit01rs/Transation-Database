drop proc [dbo].[spa_txn_report]  
go
CREATE proc [dbo].[spa_txn_report]    
@flag char(1)=null,    
@agent varchar(50)=null,    
@country varchar(50)=null,  
@branch varchar(50)=null,     
@fromdate varchar(50)=null,    
@todate varchar(50)=null,    
@order varchar(50)=null,    
@minamt varchar(50)=null,    
@maxamt varchar(50)=null,    
@curr varchar(50)=null,    
@user varchar(50)=null,    
@agent1 varchar(50)=null,    
@country1 varchar(50)=null,  
@process varchar(50)=null,    
@batch varchar(50)=null ,    
@group_by varchar(50)=null     
    
as    
DECLARE @temptablename varchar(200),@sql varchar(5000),@msg varchar(500)    
declare @clm varchar(500),@grp varchar(500)    
set @temptablename=dbo.FNAProcessTBl(@batch, @user,@process)    
if @flag='a'    
begin    
 IF @group_by='i'  
 BEGIN  
  set @sql='select customerId,senderPassport,senderName,totalroundamt,paidamt,dollar_amt dollar_amt,paidCType,receiveCType,Tranno,     
  ReceiverCountry,receiverName,senderAddress,paymentType,confirmDate,SEmpid,ssn_card_id into '+@temptablename+' from moneysend with (nolock)     
  where transStatus not in (''Hold'',''Cancel'') and confirmDate between '''+@fromdate+''' and '''+@todate+' 23:59:59''  
  and case when '''+@curr+'''=''d'' then dollar_amt when '''+@curr+'''=''p'' then totalroundamt else paidamt end  
  between '+@minamt+' and '+@maxamt+''    
  if @country is not null  and @country<>''    
   set @sql=@sql+' and receivercountry='''+@country+''''     
  if @agent is not null  and @agent<>''    
   set @sql=@sql+' and expected_payoutagentid='''+@agent+''''    
  if @country1 is not null  and @country1<>''    
   set @sql=@sql+' and sendercountry='''+@country1+''''     
  if @agent1 is not null  and @agent1<>''    
   set @sql=@sql+' and agentid='''+@agent1+''''    
  if @branch is not null  and @branch<>''    
   set @sql=@sql+' and branch_code='''+@branch+''''    
  if @order='senderName'     
   set @order='totalroundamt desc,sendername'    
  else    
   set @order='totalroundamt desc'    
      
  set @sql=@sql+' order by '+@order    
  set @msg='Report-1 (individual)'    
 END  
 ELSE  
 BEGIN  
    
   
  set @sql='select customerId,senderPassport,senderName,sum(totalroundamt) payoutamt,sum(paidamt) totalroundamt,     
  sum(dollar_amt) dollar_amt,paidCType,receiveCType, count(*) noOfTrns,ssn_card_id into '+@temptablename+' from moneysend with (nolock)     
  where transStatus=''Payment'' and confirmDate between '''+@fromdate+''' and '''+@todate+' 23:59:59'''    
  if @country is not null  and @country<>''    
  set @sql=@sql+' and receivercountry='''+@country+''''     
  if @agent is not null  and @agent<>''    
  set @sql=@sql+' and expected_payoutagentid='''+@agent+''''    
  if @country1 is not null  and @country1<>''    
  set @sql=@sql+' and sendercountry='''+@country1+''''     
  if @agent1 is not null  and @agent1<>''    
  set @sql=@sql+' and agentid='''+@agent1+''''    
  if @branch is not null  and @branch<>''    
   set @sql=@sql+' and branch_code='''+@branch+''' '  
  if @order='senderName'     
  set @order='totalroundamt desc,sendername'    
  else    
  set @order='totalroundamt desc'    
      
  set @sql=@sql+' group by customerId,senderPassport,senderName,ssn_card_id,paidCType,receiveCType having sum(    
  case when '''+@curr+'''=''d'' then dollar_amt when '''+@curr+'''=''p'' then totalroundamt else paidamt end)     
  between '+@minamt+' and '+@maxamt+' order by '+@order    
  set @msg='Report-1 (Groupwise)'    
  END  
  PRINT @sql  
  
end    
if @flag='b'    
begin    
if @order='r'    
begin    
set @flag='r'    
set @clm='receivername'    
set @sql='select top '+@minamt+' count(tranno) totaltrn,max(SenderName) SenderName,max(paidCType) paidCType,max(SenderCompany) SenderCompany,sum(paidamt) totalamt,max(ReceiverAddress) ReceiverAddress,    
max(ReceiverCity) ReceiverCity ,sum(dollar_amt) dollar_amt,ReceiverName,max(SenderNativeCountry) SenderNativeCountry,max(SenderCountry) SenderCountry,max(ReceiverCountry) ReceiverCountry,max(ssn_card_id) ssn_card_id     
into '+@temptablename+' FROM moneysend with (nolock) where Transstatus not in(''Cancel'')     
and local_DOT between '''+@fromdate+''' and '''+@todate+' 23:59:59'''     
end    
else    
begin    
set @clm='senderpassport,sendername'    
set @sql='select top '+@minamt+' count(tranno) totaltrn,sendername,max(paidCType) paidCType,senderpassport,sum(paidamt) totalamt, sum(dollar_amt) dollar_amt,max(SenderCompany) SenderCompany,    
sum(totalroundamt) totalroundamt,max(receiveCType) receiveCType,max(SenderNativeCountry) SenderNativeCountry,max(SenderCountry) SenderCountry,max(ReceiverCountry) ReceiverCountry,max(ssn_card_id) ssn_card_id     
into '+@temptablename+' FROM moneysend with (nolock) where Transstatus not in(''Cancel'')     
and local_DOT between '''+@fromdate+''' and '''+@todate+' 23:59:59'''     
end    
if @country is not null  and @country<>''    
set @sql=@sql+' and receivercountry='''+@country+''''     
if @agent is not null  and @agent<>''    
set @sql=@sql+' and expected_payoutagentid='''+@agent+''''     
if @agent1 is not null and @agent1<>''    
set @sql=@sql+' and agentid='''+@agent1+''''  
if @branch is not null  and @branch<>''    
set @sql=@sql+' and branch_code='''+@branch+''''    
if @country1 is not null  and @country1<>''    
set @sql=@sql+' and sendercountry='''+@country1+''''     
set @sql=@sql+'  group by '+@clm    
if @maxamt='t'    
set @sql=@sql+' order by totaltrn desc '    
else    
set @sql=@sql+' order by dollar_amt desc '    
set @msg='Report-2'    
end    
if @flag='c'    
begin    
if @order='s'     
begin    
set @clm='SenderName'    
set @grp=@clm +',senderPassport,SenderNativecountry,ReceiverCountry'    
end    
else if @order='r'     
begin    
set @clm='ReceiverName'    
set @grp=@clm+',SenderNativecountry,ReceiverCountry'    
end    
else if @order='b'    
begin    
set @clm='SenderName'    
set @grp=@clm +',senderPassport,ReceiverName,SenderNativecountry,ReceiverCountry'    
end    
else if @order='n'    
begin    
set @clm='SenderNativecountry'    
set @grp=@clm +',ReceiverCountry,senderName,senderPassport,ReceiverName'    
end    
set @curr=@order    
set @sql='select isnull(SenderPhoneno,'''') SenderPhoneno, isnull(sender_mobile,'''') SenderMobile,isnull(receiver_mobile,'''') ReceiverMobile,isnull(ReceiverPhone,'''') ReceiverPhone, tranno,senderName,senderPassport,ReceiverName,rBankName,convert(varchar,confirmDate,101) confirmDate,PaidAmt,    
TotalRoundAmt,SEmpId,receiveCtype,paidCType,SenderNativecountry,ReceiverCountry,ssn_card_id into '+@temptablename+' FROM moneysend with (nolock)     
where Transstatus not in(''Cancel'') and confirmDate between '''+@fromdate+''' and '''+@todate+' 23:59:59'''    
if @country is not null  and @country<>''    
set @sql=@sql+' and receivercountry='''+@country+''''     
if @agent is not null  and @agent<>''    
set @sql=@sql+' and expected_payoutagentid='''+@agent+''''    
if @agent1 is not null and @agent1<>''    
set @sql=@sql+' and agentid='''+@agent1+''''   
if @branch is not null  and @branch<>''    
set @sql=@sql+' and branch_code='''+@branch+''''   
if @country1 is not null  and @country1<>''    
set @sql=@sql+' and sendercountry='''+@country1+''''     
set @sql=@sql+' and '+@clm+' in (select '+@clm+' from moneysend with(nolock)  where confirmDate between '''+@fromdate+''' and '''+@todate+' 23:59:59'''     
if @country is not null  and @country<>''    
set @sql=@sql+' and receivercountry='''+@country+''''     
if @agent is not null  and @agent<>''    
set @sql=@sql+' and expected_payoutagentid='''+@agent+''''    
if @agent1 is not null and @agent1<>''    
set @sql=@sql+' and agentid='''+@agent1+''''  
if @branch is not null  and @branch<>''    
set @sql=@sql+' and branch_code='''+@branch+''''      
if @country1 is not null  and @country1<>''    
set @sql=@sql+' and sendercountry='''+@country1+''''   
if @order='b'    
set @sql=@sql+' and senderName=receiverName'    
if @order='n'    
set @sql=@sql+' and sendernativecountry<>receivercountry'    
set @sql=@sql+' and Transstatus not in(''Cancel'') group by ssn_card_id,'+@grp+' having count(*) > 1) order by '+@grp+',local_dot'     
set @msg='Report-3'    
end    
if @flag='d'    
begin    
declare @sql1 varchar(500)    
set @curr=@order    
create table #temp(    
fromdate varchar(50),    
todate varchar(50),    
my varchar(50),    
totaltrn varchar(50),    
customer_id varchar(50),    
paidCType varchar(50),    
senderpassport varchar(50),    
totalamt varchar(50),    
receiver varchar(50),    
receiverid varchar(50)    
)    
if @agent1=''    
set @sql='spa_Cust_Detail null,null,'    
else if @branch is not null and @branch<>''    
set @sql='spa_Cust_Detail '''+@agent1+''', '''+@branch+''','  
else  
set @sql='spa_Cust_Detail '''+@agent1+''',null,'  
  
if @fromdate=''    
set @sql=@sql+'null,'    
else    
set @sql=@sql+''''+@fromdate+''','    
if @todate=''    
set @sql=@sql+'null,'    
else    
set @sql=@sql+''''+@todate+''','    
if @order=''    
set @sql=@sql+'null,null'    
else    
set @sql=@sql+'null,'''+@order+''''    
    
insert into #temp exec(@sql)    
set @sql='select * into '+@temptablename+' FROM #temp'    
set @msg='Report-4'    
    
end    
print @sql    
exec(@sql)    
    
declare @msg_agenttype varchar(500),@url_desc varchar(2000),@desc varchar(1000)    
set @url_desc='flag='+@flag+'&agent_id='+@agent+'&txtcountry='+@country+'&fromDate='+@fromdate+    
'&toDate='+@todate+'&txtAmount='+@minamt+'&maxAmount='+@maxamt+'&curr='+@curr+'&senderagent='+@agent1+  
'&sendcountry='+@country1+'&group_by=' +@group_by  
set @msg_agenttype=''  
if @flag='d'    
SET @msg_agenttype='<b>'+@msg+'</b> ' --('+@fromdate+'/'+@todate+')'    
else    
SET @msg_agenttype='<b>'+@msg+'</b> from '+@fromdate+' to '+@todate  
if @url_desc is null  
set @url_desc='flag='+@flag  
if @flag='c'  
set @url_desc=@url_desc+'&type='+@order  
  
set @url_desc=@url_desc+'&msg='+@msg_agenttype    
  
  
print @url_desc  
    
set @desc=replace(upper(@batch),'_',' ')+' report by '+@msg_agenttype +' is completed. '    
EXEC  spa_message_board 'u', @user, NULL, @batch, @desc, 'c', @process,null,@url_desc    
 
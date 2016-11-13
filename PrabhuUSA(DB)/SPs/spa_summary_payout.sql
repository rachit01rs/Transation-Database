DROP proc [dbo].[spa_summary_payout]
go 
CREATE proc [dbo].[spa_summary_payout]    
@flag char(1),    
@senderAgent varchar(50)=NULL,    
@receiveCountry varchar(100)=NULL,    
@payoutAgent varchar(50)=NULL,    
@payoutBranch varchar(50)=NULL,    
@statusType varchar(100)=NULL,    
@paymentType varchar(100)=NULL,    
@dateType varchar(50)=NULL,    
@fromDate varchar(50)=NULL,    
@toDate varchar(50)=NULL,    
@senderAgentName varchar(200)=NULL,    
@senderBranch varchar(200)=NULL,  
@sendCountry varchar(50)= NULL ,
@senderAgent_state  varchar(50)=NULL,
@payoutAgent_state  varchar(50)=NULL
    
AS    
DECLARE @sql varchar(8000)    
if @dateType is NULL     
set @dateType='PaidDate'    
    
    
if @flag='r'    
begin    
set @sql='SELECT m.receivercountry,count(m.tranno) totnos,m.receivectype,sum(m.totalroundamt) totamt    
FROM moneysend m with (nolock) 
JOIN agentdetail s with (nolock) on m.agentid=s.agentcode 
JOIN agentdetail p with (nolock) on m.expected_payoutagentid=p.agentcode 
WHERE transStatus in (''Payment'',''Block'')     
and m.'+@dateType+' between '''+@fromDate+''' and '''+@toDate+' 23:59:59'' '     
 if @sendCountry IS NOT NULL    
 SET @sql= @sql+' and  m.sendercountry='''+ @sendCountry +''''    
if @senderAgent IS NOT NULL    
 SET @sql= @sql+' and m.agentid='''+ @senderAgent +''''    
if @receiveCountry IS NOT NULL    
 SET @sql= @sql+' and  m.receivercountry='''+ @receiveCountry +''''    
if @payoutAgent IS NOT NULL    
 SET @sql= @sql+' and m.expected_payoutagentid='''+ @payoutAgent +''''    
if @paymentType IS NOT NULL    
 SET @sql= @sql+' and m.paymentType='''+ @paymentType +''''    
if @statusType IS NOT NULL    
 SET @sql= @sql+' and m.status='''+ @statusType +''''   
if @senderAgent_state IS NOT NULL    
 SET @sql= @sql+' and s.state='''+ @senderAgent_state +'''' 
if @payoutAgent_state IS NOT NULL    
 SET @sql= @sql+' and p.state='''+ @payoutAgent_state +''''  
    
SET @sql= @sql+' group by m.receivercountry,m.receivectype    
order by m.receivercountry,m.receivectype'    
end    
    
if @flag='s'    
begin    
set @sql='SELECT sendercountry receivercountry,count(tranno) totnos,receivectype,sum(totalroundamt) totamt    
from moneysend with (nolock) where transStatus in (''Payment'',''Block'')     
and '+@dateType+' between '''+@fromDate+''' and '''+@toDate+' 23:59:59'' '     
  
 if @sendCountry IS NOT NULL    
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''    
if @senderAgent IS NOT NULL    
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''    
if @receiveCountry IS NOT NULL    
 SET @sql= @sql+' and  receivercountry='''+ @receiveCountry +''''    
if @payoutAgent IS NOT NULL    
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''    
if @paymentType IS NOT NULL    
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''    
if @statusType IS NOT NULL    
 SET @sql= @sql+' and status='''+ @statusType +''''    
    
SET @sql= @sql+' group by sendercountry,receivectype    
order by sendercountry,receivectype'    
end    
    
if @flag='a'    
begin    
set @sql='SELECT companyname receivercountry,count(tranno) totnos,    
receivectype,sum(totalroundamt) totamt    
from moneysend  with (nolock) join agentdetail with (nolock) on agentid=agentcode    
where transStatus in (''Payment'',''Block'')     
and receivectype=currencytype    
and '+@dateType+' between '''+@fromDate+''' and '''+@toDate+' 23:59:59'' '     
if @sendCountry IS NOT NULL    
 SET @sql= @sql+' and  sendercountry='''+ @sendCountry +''''     
if @senderAgent IS NOT NULL    
 SET @sql= @sql+' and agentid='''+ @senderAgent +''''    
if @receiveCountry IS NOT NULL    
 SET @sql= @sql+' and  sendercountry='''+ @receiveCountry +''''    
if @payoutAgent IS NOT NULL    
 SET @sql= @sql+' and expected_payoutagentid='''+ @payoutAgent +''''    
if @paymentType IS NOT NULL    
 SET @sql= @sql+' and paymentType='''+ @paymentType +''''    
if @statusType IS NOT NULL    
 SET @sql= @sql+' and status='''+ @statusType +''''    
    
SET @sql= @sql+' group by companyname,receivectype    
order by companyname,receivectype'    
end    
    
exec(@sql) 
IF OBJECT_ID('spa_exRate', 'P') IS NOT NULL 
    DROP PROCEDURE spa_exRate
GO  
  
--exec spa_exRate NULL,'add','Malaysia'  
create PROC [dbo].[spa_exRate]  
@agent_id varchar(50)=null,  
@user_admin varchar(50)=Null,  
@country varchar(150)=Null  
as  
DECLARE @sql varchar(5000)  
  
IF @user_admin IS NOT NULL and @country is null  
 SELECT @country=country FROM admintable WITH(NOLOCK) WHERE cUser=@user_admin  
  
IF @country ='Nepal'  
 SET @country=NULL  
  
  
SET @sql='select * from (  
SELECT a.country,'''' PayoutAgent,'''' Branch,isNULL(a.agent_short_code,a.CompanyName) agent_short_code,r.CurrencyType,  
ReceiveCountry,a.CompanyName CompanyName,r.ReceiveCType,ExchangeRate,NPRRate SettlementRate,DollarRate ,  
r.Customer_Rate,update_by,update_ts,isNull(agent_premium_payout,0) agent_premium_payout,isNull(agent_premium_send,0) agent_premium_send  
,DollarRate+isNull(agent_premium_payout,0)  [PAIDCost],ExchangeRate+isNull(agent_premium_send,0) SENDCOST  
 FROM agentcurrencyRate r WITH(NOLOCK) JOIN agentDetail a WITH(NOLOCK) 
ON r.agentid=a.agentcode where 1=1'  
IF @country IS NOT NULL  
SET @sql=@sql+' and a.country='''+@country+''''  
IF @agent_id IS NOT NULL  
SET @sql=@sql+' and r.agentid='''+@agent_id+''''  
SET @sql=@sql+' Union ALL  
SELECT a.country,'''' PayoutAgent,b.branch Branch,isNULL(a.agent_short_code,a.CompanyName) agent_short_code,r.CurrencyType,ReceiveCountry,a.CompanyName CompanyName,r.ReceiveCType,ExchangeRate,NPRRate SettlementRate,DollarRate ,  
r.Customer_Rate,update_by,update_ts,isNull(agent_premium_payout,0) agent_premium_payout,isNull(agent_premium_send,0) agent_premium_send  
,DollarRate+isNull(agent_premium_payout,0)  [PAIDCost],ExchangeRate+isNull(agent_premium_send,0) SENDCOST  
 FROM agent_branch_rate r WITH(NOLOCK) JOIN agentDetail a WITH(NOLOCK) 
ON r.agentid=a.agentcode join agentbranchdetail b WITH(NOLOCK) on r.agent_branch_code=b.agent_branch_code where 1=1'  
IF @country IS NOT NULL  
SET @sql=@sql+' and a.country='''+@country+''''  
IF @agent_id IS NOT NULL  
SET @sql=@sql+' and r.agentid='''+@agent_id+''''  
SET @sql=@sql+' Union ALL  
SELECT a.country,p.companyName PayoutAgent,'''' Branch,isNULL(a.agent_short_code,a.CompanyName) agent_short_code,a.CurrencyType,p.CompanyName ReceiveCountry,a.CompanyName CompanyName,r.ReceiveCType,ExchangeRate,NPRRate SettlementRate,DollarRate ,  
r.Customer_Rate,update_by,update_ts,isNull(agent_premium_payout,0) agent_premium_payout,isNull(agent_premium_send,0) agent_premium_send  
,DollarRate+isNull(agent_premium_payout,0)  [PAIDCost],ExchangeRate+isNull(agent_premium_send,0) SENDCOST  
 FROM agentpayout_CurrencyRate r WITH(NOLOCK) JOIN agentDetail a WITH(NOLOCK)  
ON r.agentid=a.agentcode JOIN agentdetail p WITH(NOLOCK) ON p.agentCode=r.payout_agent_id  where 1=1'  
IF @country IS NOT NULL  
SET @sql=@sql+' and a.country='''+@country+''''  
IF @agent_id IS NOT NULL  
SET @sql=@sql+' and r.agentid='''+@agent_id+''''  
SET @sql=@sql+' Union ALL  
SELECT a.country,p.companyName PayoutAgent,b.branch Branch,isNULL(a.agent_short_code,a.CompanyName) agent_short_code,a.CurrencyType,p.CompanyName ReceiveCountry,a.CompanyName CompanyName,r.ReceiveCType,ExchangeRate,NPRRate SettlementRate,DollarRate ,  
r.Customer_Rate,update_by,update_ts,isNull(agent_premium_payout,0) agent_premium_payout,isNull(agent_premium_send,0) agent_premium_send  
,DollarRate+isNull(agent_premium_payout,0)  [PAIDCost],ExchangeRate+isNull(agent_premium_send,0) SENDCOST  
 FROM agentpayout_CurrencyRate_branch r WITH(NOLOCK) JOIN agentDetail a WITH(NOLOCK)  
ON r.agentid=a.agentcode JOIN agentdetail p WITH(NOLOCK) ON p.agentCode=r.payout_agent_id 
join agentbranchdetail b WITH(NOLOCK) on r.agent_branch_code=b.agent_branch_code  where 1=1'  
IF @country IS NOT NULL  
SET @sql=@sql+' and a.country='''+@country+''''  
IF @agent_id IS NOT NULL  
SET @sql=@sql+' and r.agentid='''+@agent_id+''''  
SET @sql=@sql+')l order by l.country,l.receiveCTYpe,l.agent_short_code,l.PayoutAgent,Branch'  
print @sql  
EXEC (@sql)  
  
  
  
  
  
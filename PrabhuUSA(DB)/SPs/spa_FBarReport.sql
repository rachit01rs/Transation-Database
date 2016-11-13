create proc spa_FBar_Report
@fromDate varchar(20),
@toDate varchar(20)
as
--set @fromDate='2013-01-01'
--set @toDate='2013-12-31'
--drop table #openbalance
--drop table #CurrentYear
--drop table #FBAR_Report

create table #CurrentYear(
sno int identity(1,1),
PayoutAgentID varchar(20),
PaidMonth varchar(10),
SettleAmount Money
)

select expected_payoutagentid PayoutAgentID,Sum(PaidAmount) OpenBalance 
into #OpenBalance 
from (
select expected_payoutagentid,
(TotalRoundAmt + isNUll((case when isNull(agent_receiverComm_Currency,'l')='l' 
								then agent_receiverCommission 
								else agent_receiverCommission * isNull(payout_settle_usd,exchangeRate * agent_settlement_rate) 
								end  + agent_receiverSCommission*agent_settlement_rate),0))/isNull(payout_settle_usd,isNull(ho_dollar_rate,exchangeRate *  agent_settlement_rate)) *-1
								 PaidAmount 
from moneySend m 
where status in('Paid','Post')  and paidDate < @fromDate 
union all
select b.agentCode,
case when mode='dr' then dollar_rate else dollar_rate * -1 end Amount from agentbalance b join agentDetail a
on b.agentCode=a.agentCode
where a.AgentType='ExtAgent' and DOT < @fromDate 
) l
group by expected_payoutagentid


insert #CurrentYear(PayoutAgentID,PaidMonth,SettleAmount)
select expected_payoutagentid PayoutAgentID,PaidMonth,Sum(PaidAmount) SettleAmount 
from (
select expected_payoutagentid,right(CONVERT(varchar,paidDate,106),8) PaidMonth,
(TotalRoundAmt + isNUll((case when isNull(agent_receiverComm_Currency,'l')='l' 
								then agent_receiverCommission 
								else agent_receiverCommission * isNull(payout_settle_usd,exchangeRate * agent_settlement_rate) 
								end  + agent_receiverSCommission*agent_settlement_rate),0))/isNull(payout_settle_usd,isNull(ho_dollar_rate,exchangeRate *  agent_settlement_rate)) *-1 PaidAmount 
from moneySend m 
where status in('Paid','Post')  and paidDate between @fromDate and @toDate +' 23:59:59'
union all
select b.agentCode,right(CONVERT(varchar,DOT,106),8) FundDate,
case when mode='dr' then dollar_rate else dollar_rate * -1 end Amount from agentbalance b join agentDetail a
on b.agentCode=a.agentCode
where a.AgentType='ExtAgent' and DOT between @fromDate and @toDate +' 23:59:59'
) l
group by expected_payoutagentid,PaidMonth
order by expected_payoutagentid,CAST('1 '+ PaidMonth as datetime)

select a.CompanyName PartnerName,PaidMonth,
(select sum(SettleAmount) from #CurrentYear y where payoutagentid=c.payoutagentid
and y.sno<=c.sno
)+o.OpenBalance CloseBalance
into #FBAR_Report
 from #CurrentYear c join #openBalance o
 on c.payoutagentid=o.payoutagentid
 join agentDetail a on a.agentCode=c.PayoutAgentID
order by c.PayoutAgentid, CAST('1 '+ PaidMonth as datetime)

--drop table #TempResult
--create table #TempResult(
--sno int identity(1,1)
--)

exec sys_CrossTab '#FBAR_Report','PaidMonth','PaidMonth','CAST(''1 ''+ PaidMonth as datetime)','CloseBalance','PartnerName',
	null,'Sum',0,NULL,1,null,null,'PartnerName','money'
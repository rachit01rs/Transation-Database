/****** Object:  StoredProcedure [dbo].[spa_FBar_Report]    Script Date: 02/18/2014 09:46:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spa_FBar_Report]
@fromDate varchar(20),
@toDate varchar(20)
as
--declare @fromDate varchar(20),@toDate varchar(20)
--
--set @fromDate='2013-01-01'
--set @toDate='2013-12-31'
--drop table #openbalance
--drop table #CurrentYear
--drop table #FBAR_Report
--drop table #AsOfMonth
--drop table #BankID
--drop table #FullMonth
--drop table #PartnerBankID
--drop table #FullMonthPartner

create table #CurrentYear(
sno int identity(1,1),
PayoutAgentID varchar(20),
PaidMonth varchar(10),
SettleAmount Money,
BranchID Varchar(20)
)

select expected_payoutagentid PayoutAgentID,Sum(PaidAmount) OpenBalance,BranchID
into #OpenBalance 
from (
select expected_payoutagentid,
(TotalRoundAmt + isNUll((case when isNull(agent_receiverComm_Currency,'l')='l' 
								then agent_receiverCommission 
								else agent_receiverCommission * isNull(payout_settle_usd,exchangeRate * agent_settlement_rate) 
								end  + agent_receiverSCommission*agent_settlement_rate),0))/isNull(payout_settle_usd,isNull(ho_dollar_rate,exchangeRate *  agent_settlement_rate)) *-1
								 PaidAmount,
	Null BranchID 
from moneySend m 
where status in('Paid','Post')  and paidDate < @fromDate 
union all
select b.agentCode,
case when mode='dr' then dollar_rate else dollar_rate * -1 end Amount,
case when a.agentCan='Fund Account' then Branch_Code else Null End
from agentbalance b join agentDetail a
on b.agentCode=a.agentCode
where a.agentCan in ('Both','Fund Account','None','Receiver') and DOT < @fromDate 
) l
group by expected_payoutagentid,BranchID


insert #CurrentYear(PayoutAgentID,PaidMonth,SettleAmount,BranchID)
select expected_payoutagentid PayoutAgentID,PaidMonth,Sum(PaidAmount) SettleAmount,BranchID 
from (
select expected_payoutagentid,right(CONVERT(varchar,paidDate,106),8) PaidMonth,
(TotalRoundAmt + isNUll((case when isNull(agent_receiverComm_Currency,'l')='l' 
								then agent_receiverCommission 
								else agent_receiverCommission * isNull(payout_settle_usd,exchangeRate * agent_settlement_rate) 
								end  + agent_receiverSCommission*agent_settlement_rate),0))/isNull(payout_settle_usd,isNull(ho_dollar_rate,exchangeRate *  agent_settlement_rate)) *-1 PaidAmount ,
	Null BranchID
from moneySend m 
where status in('Paid','Post')  and paidDate between @fromDate and @toDate +' 23:59:59'
union all
select b.agentCode,right(CONVERT(varchar,DOT,106),8) FundDate,
case when mode='dr' then dollar_rate else dollar_rate * -1 end Amount,
case when a.agentCan='Fund Account' then Branch_Code else Null End BranchID
 from agentbalance b join agentDetail a
on b.agentCode=a.agentCode
where a.agentCan in ('Both','Fund Account','None','Receiver') and DOT between @fromDate and @toDate +' 23:59:59'
) l
group by expected_payoutagentid,BranchID,PaidMonth
order by expected_payoutagentid,CAST('1 '+ PaidMonth as datetime)



select PaidMonth into #AsOfMonth from #CurrentYear 
group by PaidMonth
order by CAST('1 '+ PaidMonth as datetime)

select distinct payoutagentid into #PartnerBankID from #CurrentYear 
where BranchID is null

select * into #FullMonthPartner from #PartnerBankID , #AsOfMonth

insert #CurrentYear(PaidMonth,settleAmount,payoutagentid)
select f.PaidMonth,0,f.payoutagentid from #FullMonthPartner f left outer join #CurrentYear c 
on f.payoutagentid=c.payoutagentid and f.PaidMonth=c.PAidMOnth
where c.payoutagentid is null


select a.CompanyName PartnerName,PaidMonth,
(select sum(SettleAmount) from #CurrentYear y where payoutagentid=c.payoutagentid
and CAST('1 '+ y.PaidMonth as datetime)<=CAST('1 '+ c.PaidMonth as datetime)
)+isNull(o.OpenBalance,0) CloseBalance
into #FBAR_Report
 from #CurrentYear c left outer join #openBalance o
 on c.payoutagentid=o.payoutagentid
 join agentDetail a on a.agentCode=c.PayoutAgentID
where (a.agentCan in ('Both','None') and a.accessed='Granted' 
and a.agent_short_code not in ('PRABHUNP','UNITED','XPRESS','PMTRANGLO','FUSINDO')) or a.agent_short_code in ('EXIXBANK')
order by c.PayoutAgentid, CAST('1 '+ PaidMonth as datetime)

select distinct BranchID into #BankID from #CurrentYear 
where BranchID in ('39319258','96832933','39327297','39327364','39323419')

select * into #FullMonth from #BankID , #AsOfMonth



insert #CurrentYear(PaidMonth,settleAmount,branchID)
select f.PaidMonth,0,f.BranchID from #FullMonth f left outer join #CurrentYear c 
on f.BranchID=c.BranchID and f.PaidMonth=c.PAidMOnth
where c.branchid is null

insert #FBAR_Report(PartnerName,PaidMonth,CloseBalance)
select '[FBank] - '+b.Branch PartnerName,c.PaidMonth,
(select sum(isNull(SettleAmount,0)) from #CurrentYear y 
where BranchID=c.BranchID
and CAST('1 '+ y.PaidMonth as datetime)<=CAST('1 '+ c.PaidMonth as datetime)
)+isNull(o.OpenBalance,0) CloseBalance
--into #FBAR_Report
 from #CurrentYear c join agentbranchdetail b on b.agent_branch_code=c.BranchID left outer join #openBalance o
 on c.BranchID=o.BranchID
where b.agent_branch_code in ('39319258','96832933','39327297','39327364','39323419')
order by b.Branch, CAST('1 '+ c.PaidMonth as datetime)--select * from #openBalance where BranchID='39327364'

exec sys_CrossTab '#FBAR_Report','PaidMonth','PaidMonth','CAST(''1 ''+ PaidMonth as datetime)','CloseBalance','PartnerName',
	null,'Sum',0,NULL,1,null,null,'PartnerName','money'
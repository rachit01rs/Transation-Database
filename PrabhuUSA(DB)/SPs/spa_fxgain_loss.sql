    
    
    
--spa_fxgain_loss Null,'20100031','1/01/2010','1/30/2011','admin','s'     
    
ALTER proc [dbo].[spa_fxgain_loss]    
@agentid varchar(50)=null,    
@ragentid varchar(50)=null,    
@sagentid varchar(50)=null,    
@country varchar(50)=null,    
@payout varchar(50)=null,    
@fromdate varchar(50)=null,    
@todate varchar(50)=null,    
@empid varchar(50)=null,    
@flag char(1)=null    
    
as    
    
select @agentid=headoffice_agent_id from tbl_setup    
declare @sdate varchar(50), @sql varchar(5000)    
select @sdate=isNull(agent_settlement_date,'confirmdate') from agentdetail where agentcode=@ragentid    
declare @fund money,@companyname varchar(50),@agent_id varchar(1000)    
set @agent_id=''    
    
if @flag='p'    
begin    
select @agent_id=agentCode +','+ @agent_id  from agentdetail where super_agent_id=@ragentId    
set @agent_id=left(@agent_id,len(@agent_id)-1)    
set @agent_id=@ragentId+','+@agent_id    
--select @agent_id=sub_agent_id +','+ @agent_id  from agent_sub_agent where agentcode=@ragentId    
--set @agent_id=left(@agent_id,len(@agent_id)-1)    
--set @agent_id=@ragentId+','+@agent_id    
    
select @fund=sum(case when mode='dr' then isnull(amount,0)* -1 else isnull(amount,0) end),    
@companyname=a.companyname from agentbalance b join agentdetail a on b.agentcode=a.agentcode     
where mode in('dr','cr') and b.approved_by is not null and b.agentcode in(@agent_id)    
and b.approved_ts between @fromdate and @todate+' 23:59:59'    
group by a.companyname     
if @fund is null    
set @fund=0    
    
--set @sdate='confirmdate'    
set @sql='select * from (    
select cast('''+@fromdate+' 00:00:00'' as datetime)-1 confirmdate,count(*) tottrn,    
0 camt,0 scharge,0 scom,0 hcom,0 sendAmt,0 crate,    
sum(case when mode=''dr'' then isnull(amount,0)* -1 else isnull(amount,0) end) totamt,avg(xrate) srate,    
0 samt_usd,0 paybleamt,0 need2fund,    
sum(case when mode=''dr'' then isnull(amount,0)* -1 else isnull(amount,0) end) fxgl,''y'' pfund    
from agentbalance b join agentdetail a on b.agentcode=a.agentcode     
where mode in(''dr'',''cr'') and b.approved_ts between '''+@fromdate+''' and '''+@todate+' 23:59:59''     
and b.agentcode in('+ @agent_id +') group by a.companyname '    
    
set @sql=@sql+'union all    
select convert(varchar,'+@sdate+',101) confirmdate,count(*) tottrn,sum(paidamt/exchangerate) camt,sum(scharge/exchangerate) scharge,    
sum(senderCommission/exchangerate) scom,sum((scharge-senderCommission)/exchangerate) hcom,sum((paidamt-scharge)/exchangerate) sendAmt,    
avg(today_dollar_rate*exchangerate) crate,sum(totalroundamt) totamt,avg(isnull(payout_settle_usd,today_dollar_rate)*exchangerate) srate,    
sum(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) samt_usd,round(sum(totalroundamt),2) paybleamt,    
round(sum(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)),2) need2fund,sum(paidamt-scharge)-    
sum(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) fxgl,Null    
from moneysend m with (nolock) join agentdetail a on m.expected_payoutagentid=a.agentcode    
where '+@sdate+' between '''+@fromdate+''' and '''+@todate+' 23:59:59''     
and transstatus in(''Payment'',''Block'') --and status=''paid''    
and (agentid in('+ @agent_id +') or expected_payoutagentid in('+@agent_id+'))'    
if @sagentid is not null    
set @sql=@sql+' and (agentid='''+@sagentid+''' or expected_payoutagentid='''+@sagentid+''') '    
if @country is not null and @payout is NULL    
set @sql=@sql+' and receivercountry='''+@country+''' '    
if @payout is not null    
set @sql=@sql+' and expected_payoutagentid='''+@payout+''' '    
    
set @sql=@sql+'     
group by convert(varchar,'+@sdate+',101)    
) s order by confirmdate'    
    
end     
else if @flag='s'    
begin    
select @fund=sum(isnull(amount,0)),@companyname=a.companyname from agentbalance b     
join agentdetail a on b.agentcode=a.agentcode     
where mode='cr' and b.approved_by is not null and b.agentcode=@ragentid    
and b.approved_ts between @fromdate and @todate+' 23:59:59'   
group by a.companyname     
if @fund is null    
set @fund=0    
    
set @sdate='confirmdate'    
set @sql='select * from (    
select '''+@fromdate+''' confirmdate,count(*) tottrn,    
0 camt,0 scharge,0 scom,0 hcom,0 sendAmt,0 crate,sum(amount) totamt,avg(xrate) srate,    
0 samt_usd,0 paybleamt,0 need2fund,sum(amount) fxgl,''y'' pfund    
from agentbalance b join agentdetail a on b.agentcode=a.agentcode     
where mode=''cr'' and b.dot between '''+@fromdate+''' and '''+@todate+' 23:59:59''     
and b.agentcode='''+@ragentid+''' group by a.companyname '    
    
set @sql=@sql+'union all    
select isNUll(a.agent_short_code,a.companyName) confirmdate,count(*) tottrn,      SUM(  
                     CASE WHEN ISNULL(p.settlement_calc_by, ''s'') = ''s'' then  
      paidamt / exchangerate  
                    ELSE   
      (totalroundamt / ISNULL(payout_settle_usd,ho_dollar_rate) + (scharge / exchangerate))  
     END                       
                    ) camt ,  
                    SUM(scharge / exchangerate) scharge ,  
                    SUM(senderCommission / exchangerate) scom ,  
                    SUM(( ( scharge - senderCommission ) / exchangerate )) hcom ,  
                    SUM(  
                    CASE WHEN ISNULL(p.settlement_calc_by, ''s'') = ''s'' then  
                    ( paidamt - scharge ) / exchangerate  
                    ELSE   
     totalroundamt / ISNULL(payout_settle_usd,ho_dollar_rate)  
                    END ) sendAmt ,  
                    AVG(agent_payout_agent_cust_rate) crate ,  
                    SUM(totalroundamt) totamt ,  
                    AVG( ISNULL(payout_settle_usd, ho_dollar_rate)) srate ,  
                    SUM(totalroundamt / ISNULL(payout_settle_usd,  
                                               ho_dollar_rate)) samt_usd ,  
                    ROUND(SUM(totalroundamt), 2) paybleamt ,  
                    ROUND(SUM(totalroundamt / ISNULL(payout_settle_usd,  
                                                     ho_dollar_rate)), 2) need2fund ,  
                    SUM(  
                    CASE WHEN ISNULL(p.settlement_calc_by, ''s'') = ''s'' then  
                    ( paidamt - scharge ) / exchangerate  
                    ELSE   
     totalroundamt / ISNULL(payout_settle_usd,ho_dollar_rate)  
                    END )  
                    - SUM(totalroundamt/  ISNULL(payout_settle_usd,ho_dollar_rate)) fxgl,a.agentCode    
from moneysend m with (nolock) join agentdetail a with (nolock) on m.expected_payoutagentid=a.agentcode    
JOIN agentdetail p ON m.agentid = p.agentcode  
where '+@sdate+' between '''+@fromdate+''' and '''+@todate+' 23:59:59''     
and transstatus in(''Payment'',''Block'') --and status=''paid''    
and agentid='''+@ragentid+''' '    
if @country is not null and @payout is NULL    
set @sql=@sql+' and receivercountry='''+@country+''' '     
if @payout is not null    
set @sql=@sql+' and expected_payoutagentid='''+@payout+''' '    
set @sql=@sql+'    
group by isNUll(a.agent_short_code,a.companyName),a.agentCode    
) s order by confirmdate'    
    
end     
--else    
--begin    
--select @fund=sum(isnull(amount,0)),@companyname=a.companyname from agentbalance b     
--join agentdetail a on b.agentcode=a.agentcode     
--where mode='dr' and b.approved_by is not null and b.agentcode=@ragentid    
--and b.approved_ts between @fromdate and @todate+' 23:59:59'    
--group by a.companyname     
--if @fund is null    
--set @fund=0    
--set @sdate='paiddate'    
--set @sql='select * from (    
--select cast('''+@fromdate+' 00:00:00'' as datetime)-1 confirmdate,count(*) tottrn,    
--0 camt,0 scharge,0 scom,0 hcom,0 sendAmt,0 crate,sum(amount) totamt,avg(xrate) srate,    
--0 samt_usd,0 paybleamt,0 need2fund,sum(amount) fxgl,''y'' pfund    
--from agentbalance b join agentdetail a on b.agentcode=a.agentcode     
--where mode=''dr'' and b.approved_ts between '''+@fromdate+''' and '''+@todate+' 23:59:59''     
--and b.agentcode='''+@ragentid+''' group by a.companyname '    
--    
--set @sql=@sql+'union all    
--select convert(varchar,'+@sdate+',101) confirmdate,count(*) tottrn,sum(paidamt) camt,sum(scharge) scharge,    
--sum(scharge/2) scom,sum(scharge-(scharge/2)) hcom,sum(paidamt-scharge) sendAmt,    
--avg(today_dollar_rate) crate,sum(totalroundamt) totamt,avg(isnull(payout_settle_usd,today_dollar_rate)) srate,    
--sum(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) samt_usd,round(sum(totalroundamt),2) paybleamt,    
--round(sum(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)),2) need2fund,sum(paidamt-scharge)-    
--sum(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) fxgl,Null    
--from moneysend join agentdetail on expected_payoutagentid=agentcode    
--where '+@sdate+' between '''+@fromdate+''' and '''+@todate+' 23:59:59''     
--and status=''paid'' and transstatus=''Payment''    
--and expected_payoutagentid='''+@ragentid+'''     
--and agentid='''+@agentid+'''    
--group by convert(varchar,'+@sdate+',101)    
--) s order by confirmdate'    
--end    
--print(@sql)    
exec(@sql)    
    
    
    
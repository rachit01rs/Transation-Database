--spa_fxgain_loss_drill 20100031,'20100003','1/01/2010','1/30/2011','admin','s'   
--spa_fxgain_loss_drill '20100046','20100004','01/01/2010','1/30/2011','admin','s'   
  
alter proc [dbo].[spa_fxgain_loss_drill]  
@agentid varchar(50)=null,  
@ragentid varchar(50)=null,  
@fromdate varchar(50)=null,  
@todate varchar(50)=null,  
@empid varchar(50)=null,  
@flag char(1)=null  
as  
--select @agentid=headoffice_agent_id from tbl_setup  
declare @sdate varchar(50), @sql varchar(5000)  
select @sdate=isNull(agent_settlement_date,'confirmdate') from agentdetail where agentcode=@ragentid  
declare @fund money,@companyname varchar(50),@agent_id varchar(1000)  
set @agent_id=''  
  
if @flag='p'  
begin  
select @agent_id=agentCode +','+ @agent_id  from agentdetail where super_agent_id=@ragentId  
set @agent_id=left(@agent_id,len(@agent_id)-1)  
set @agent_id=@ragentId+','+@agent_id  
  
  
--set @sdate='confirmdate'  
set @sql='select * from ('  
  
set @sql=@sql+'  
select convert(varchar,'+@sdate+',101) confirmdate,count(*) tottrn,(paidamt/exchangerate) camt,(scharge) scharge,  
(scharge/2) scom,(scharge-(scharge/2)) hcom,(paidamt-scharge) sendAmt,  
(today_dollar_rate*exchangerate) crate,(totalroundamt) totamt,(isnull(payout_settle_usd,today_dollar_rate)*exchangerate) srate,  
(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) samt_usd,round((totalroundamt),2) paybleamt,  
round((totalroundamt/isnull(payout_settle_usd,today_dollar_rate)),2) need2fund,(paidamt-scharge)-  
(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) fxgl  
from moneysend m with (nolock) join agentdetail a on m.expected_payoutagentid=a.agentcode  
where '+@sdate+' between '''+@fromdate+''' and '''+@todate+' 23:59:59''   
and transstatus in(''Payment'',''Block'') --and status=''paid''  
and (agentid in('+ @agent_id +') or expected_payoutagentid in('+@agent_id+'))  
group by convert(varchar,'+@sdate+',101)  
) s order by confirmdate'  
  
end   
else if @flag='s'  
begin  
  
set @sdate='confirmdate'  
set @sql='select * from ('  
set @sql=@sql+'  
select isNUll(a.agent_short_code,a.companyName) companyName,confirmdate,tranno,
(CASE WHEN ISNULL(p.settlement_calc_by, ''s'') = ''s'' then  
      paidamt / exchangerate  
                    ELSE   
      (totalroundamt / ISNULL(payout_settle_usd,ho_dollar_rate) + (scharge / exchangerate))  
     END          ) camt,
(scharge/exchangerate) scharge,  
(senderCommission/exchangerate) scom,((scharge-senderCommission)/exchangerate) hcom,
(CASE WHEN ISNULL(p.settlement_calc_by, ''s'') = ''s'' then  
                    ( paidamt - scharge ) / exchangerate  
                    ELSE   
     totalroundamt / ISNULL(payout_settle_usd,ho_dollar_rate)  
                    END ) sendAmt,  
(agent_payout_agent_cust_rate) crate,(totalroundamt) totamt,(isnull(payout_settle_usd,ho_dollar_rate)) srate,  
(totalroundamt/isnull(payout_settle_usd,ho_dollar_rate)) samt_usd,round((totalroundamt),2) paybleamt,  
round((totalroundamt/isnull(payout_settle_usd,ho_dollar_rate)),2) need2fund,(
 CASE WHEN ISNULL(p.settlement_calc_by, ''s'') = ''s'' then  
                    ( paidamt - scharge ) / exchangerate  
                    ELSE   
     totalroundamt / ISNULL(payout_settle_usd,ho_dollar_rate)  
                    END)-  
(totalroundamt/isnull(payout_settle_usd,ho_dollar_rate)) fxgl  
from moneysend m with (nolock) join agentdetail a on m.expected_payoutagentid=a.agentcode  
JOIN agentdetail p ON m.agentid = p.agentcode 
where '+@sdate+' between '''+@fromdate+''' and '''+@todate+' 23:59:59''   
and transstatus in(''Payment'',''Block'') --and status=''paid''  
and agentid='''+@agentid+'''  
and expected_payoutagentid='''+ @ragentid  +'''  
) s order by confirmdate'  
end   
else  
begin  
  
set @sdate='paiddate'  
set @sql='select * from ( '  
set @sql=@sql+'  
select convert(varchar,'+@sdate+',101) confirmdate,count(*) tottrn,(paidamt) camt,(scharge) scharge,  
(scharge/2) scom,(scharge-(scharge/2)) hcom,(paidamt-scharge) sendAmt,  
(today_dollar_rate) crate,(totalroundamt) totamt,(isnull(payout_settle_usd,today_dollar_rate)) srate,  
(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) samt_usd,round((totalroundamt),2) paybleamt,  
round((totalroundamt/isnull(payout_settle_usd,today_dollar_rate)),2) need2fund,(paidamt-scharge)-  
(totalroundamt/isnull(payout_settle_usd,today_dollar_rate)) fxgl  
from moneysend with (nolock) join agentdetail with (nolock) on expected_payoutagentid=agentcode  
where '+@sdate+' between '''+@fromdate+''' and '''+@todate+' 23:59:59''   
and status=''paid'' and transstatus=''Payment''  
and expected_payoutagentid='''+@ragentid+'''   
and agentid='''+@agentid+'''  
group by convert(varchar,'+@sdate+',101)  
) s order by confirmdate'  
end  
print(@sql)  
exec(@sql)  
  
  
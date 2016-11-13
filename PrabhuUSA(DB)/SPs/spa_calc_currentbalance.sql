  
ALTER proc [dbo].[spa_calc_currentbalance]  
as  
declare @sql varchar(5000),@currentdate varchar(20),@process_id varchar(150),@tName varchar(200)  
SET @process_id = REPLACE(newid(),'-','_')  
set @currentdate=convert(varchar,dbo.getDateHO(getutcdate()),101)  
set @sql='get_all_agentbalance_process  ''d'',''a'', ''-'', ''y'','''+@currentdate+''',  
'''+@process_id+''',''system'', ''SummaryBalance_Auto'''  
exec(@sql)  
  
set @tName='iremit_process.dbo.SummaryBalance_Auto_system_'+@process_id  
  
update agentdetail set currentbalance=0.00  
  
set @sql='  
update agentdetail set currentbalance=case when t.dr>0 then t.dr else t.cr end  
from agentdetail a, '+ @tName +' t  
where a.agentcode=t.agent_Id'  
exec(@sql)  
  
select agentid,sum(paidAmt-(senderCommission+isNUll(agent_ex_gain,0))) total_hold into #temp_hold from moneysend
where transStatus in ('Hold','OFAC','Compliance')
group by agentid

update agentdetail set currentbalance=isNULL(currentbalance,0)+t.total_hold
from agentdetail a, #temp_hold t
where a.agentcode=t.agentid

select agentcode,sum(case when mode='dr' then amount else amount*-1 end) Total_bal into #temp_unapproved
from agentbalance where approved_ts is null
and mode in ('cr','dr')
group by agentcode

update agentdetail set currentbalance=isNULL(currentbalance,0)+t.Total_bal
from agentdetail a, #temp_unapproved t
where a.agentcode=t.agentcode

  
DELETE customer_trans_limit  
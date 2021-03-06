DROP proc [dbo].[spa_ComplianceIDCheck]   
gO 
--select * from agentdetail where country='Nepal'  
--spa_ComplianceIDCheck 1000.4928,'2145248130','United States','Cash Pay','20100016'  
CREATE proc [dbo].[spa_ComplianceIDCheck]   
@amount money,  
@customer_mobile varchar(20),  
@send_country varchar(50)=NULL,  
@payment_type varchar(50)=NULL,  
@payout_agent_id varchar(50)=NULL  
as  
--declare @amount money ,@customer_mobile varchar(20),@send_country varchar(50),@payment_type varchar(50),@payout_agent_id varchar(50)  
--set @amount=20000  
--set @customer_mobile='60125029188'  
--set @send_country='United States'  
----drop table #temp_sno  
--drop table #temp   
--declare @sql varchar(max)  
  
create table #temp ( sno int,amount_if_more money,nos_of_days int ,fromDate datetime,sender_mobile varchar(50))  
----select sno,amount_if_more,nos_of_days,getdate() fromDate,  
----191 sender_mobile into #temp  from PaymentRule_Setup where 1=2  
--insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
--select cast(sno as varchar),amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
--@customer_mobile sender_mobile from PaymentRule_Setup p  
--where send_agent_country=@send_country and paymentType is NULL and agentType is null  
--select * from #temp  
if exists (select sno from PaymentRule_Setup where send_agent_country=@send_country and paymentType=@payment_type and agentType=@payout_agent_id)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country=@send_country and paymentType=@payment_type and agentType=@payout_agent_id  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country=@send_country and paymentType=@payment_type and agentType is NULL)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country=@send_country and paymentType=@payment_type and agentType is null  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country=@send_country and paymentType is NULL and agentType=@payout_agent_id)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country=@send_country and paymentType is null and agentType=@payout_agent_id  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country=@send_country and paymentType is null and agentType is null)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country=@send_country and paymentType is null and agentType is null  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country is null and paymentType=@payment_type and agentType=@payout_agent_id)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country is null and paymentType=@payment_type and agentType=@payout_agent_id  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country is null and paymentType is null and agentType=@payout_agent_id)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country is null and paymentType is NULL and agentType=@payout_agent_id  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country is null and paymentType=@payment_type and agentType is null)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country is null and paymentType=@payment_type and agentType is null  
end  
else if exists (select sno from PaymentRule_Setup where send_agent_country is null and paymentType is null and agentType is null)  
begin  
insert into #temp(sno,amount_if_more,nos_of_days,fromDate,sender_mobile)  
select sno,amount_if_more,nos_of_days,dateadd(d,nos_of_days*-1,getdate()) fromDate,  
@customer_mobile sender_mobile from PaymentRule_Setup p  
where send_agent_country is null and paymentType is NULL and agentType is null  
end  
--else  
--set @sql=@sql+' and send_agent_country is NULL'  
--if exists (select sno from PaymentRule_Setup where paymentType=@payment_type)  
--set @sql=@sql+' and paymentType='''+@payment_type+''''  
--else  
--set @sql=@sql+' and paymentType is NULL'  
--if exists (select sno from PaymentRule_Setup where agentType=@payout_agent_id)  
--set @sql=@sql+' and agentType='''+@payout_agent_id+''''  
--else  
--set @sql=@sql+' and agentType is NULL'  
--print (@sql)  
--exec (@sql)  
  
  
--and paymentType=@payment_type and agentType=@payout_agent_id  
select t.sno into #temp_sno from #temp t outer apply (  
select sum(paidAmt) totalAmt from moneysend m   
where m.sender_mobile=t.sender_mobile  and m.transstatus<>'Cancel'  
and m.Local_Dot between t.fromDate and getdate()) p  
where amount_if_more <=(@amount+isNULL(totalAmt,0))  
declare @validation_msg varchar(max)  
set @validation_msg=''  
select @validation_msg=@validation_msg + validation_msg +'<br>' from PaymentRule_Setup p join #temp_sno s  
on p.sno=s.sno  
  
select requiredfield1,@validation_msg validation_msg from PaymentRule_Setup p join #temp_sno s  
on p.sno=s.sno  
where requiredField1 is not null  
group by requiredfield1  
union  
select requiredfield2,@validation_msg validation_msg from PaymentRule_Setup p join #temp_sno s  
on p.sno=s.sno  
where requiredField2 is not null  
group by requiredField2  
union  
select requiredfield3,@validation_msg validation_msg from PaymentRule_Setup p join #temp_sno s  
on p.sno=s.sno  
where requiredField3 is not null  
group by requiredField3  
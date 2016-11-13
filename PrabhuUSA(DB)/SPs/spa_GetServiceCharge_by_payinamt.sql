--spa_GetServiceCharge_by_payinamt '10000004','10000001',1000,'Cash Pay','NULL','10000001'    
CREATE PROCEDURE [dbo].[spa_GetServiceCharge_by_payinamt]    
@send_agent_id varchar(50),    
@payout_agent_id varchar(50),    
@pay_in_amt varchar (50),    
@payment_type varchar(100),    
@country varchar(100)=NULL,    
@send_branch_id varchar(50)=null    
as    
DECLARE @branch_slab_id int    
IF @send_branch_id IS NOT NULL    
BEGIN     
 create table #temp_branchcharge(    
 slab_id int,    
 min_amount money,    
 max_amount money,    
 deposit_amt money,    
 Service_Charge money    
 )    
     
-- insert into #temp_branchcharge(slab_id,min_amount,max_amount,service_charge,send_commission,paid_commission)    
 exec spa_GetServiceCharge_Branch_by_payinamt @send_agent_id,@payout_agent_id,@pay_in_amt,@payment_type,@country,@send_branch_id,'#temp_branchcharge'    
    
 select @branch_slab_id=slab_id from #temp_branchcharge    
END    
ELSE    
BEGIN     
 SET @branch_slab_id=-1    
END     
    
IF @branch_slab_id > 0     
BEGIN    
 -- RETURN BRANCH WISE Service Charge    
 SELECT * FROM #temp_branchcharge    
 RETURN     
END     
ELSE    
BEGIN    
CREATE TABLE #temp_scharge(    
 [slab_id] [int],    
 [payment_type] [varchar] (50),    
 [agent_id] [varchar](50),    
 [Rec_Country] [varchar](100),    
 [payout_agent_id] [varchar](50),    
 [min_amount] [money],    
 [max_amount] [money],    
 [service_charge_mode] [char](1),    
 [service_charge_flat] [money],    
 [service_charge_per] [float],    
 send_commission money,    
 send_commission_type char(1),    
 paid_commission money,    
 paid_commission_type char(1)    
    
)    
insert into #temp_scharge(slab_id,payment_type,agent_id,Rec_Country,payout_agent_id,min_amount,max_amount,    
service_charge_mode,service_charge_flat,service_charge_per,send_commission,send_commission_type,paid_commission,paid_commission_type)    
select slab_id,payment_type,agent_id,Rec_Country,payout_agent_id,case when service_charge_mode='f' then min_amount-service_charge_flat    
else min_amount-min_amount*service_charge_per/100 end min_amount,case when service_charge_mode='f' then max_amount-service_charge_flat    
else max_amount-max_amount*service_charge_per/100 end max_amount,service_charge_mode,service_charge_flat, service_charge_per ,    
send_commission,send_commission_type,paid_commission,paid_commission_type    
from service_charge_setup where agent_id=@send_agent_id    
    
DECLARE @payout_country varchar(100),@FLAT_Charge Money,@sql_clm varchar(5000),@sql varchar(5000),@mode varchar(50)    
    
-----------Column STATEMENT ------------------------    
SET @sql_clm=' slab_id,min_amount, max_amount,      
   case when service_charge_mode=''f'' then ('+cast(@pay_in_amt AS varchar)+') +service_charge_flat    
   else ('+cast(@pay_in_amt AS varchar)+')*100/(100-service_charge_per)  end deposit_amt,case when service_charge_mode=''f'' then service_charge_flat    
   else (('+cast(@pay_in_amt AS varchar)+')*100/(100-service_charge_per))-('+cast(@pay_in_amt AS varchar)+')  end Service_Charge,    
   case when send_commission_type=''f'' then send_commission    
   when  service_charge_mode=''f'' then service_charge_flat * (send_commission/100)     
   when  service_charge_mode=''p'' then service_charge_per * (send_commission/100)     
   else 0 end send_commission,    
   case when paid_commission_type=''f'' then paid_commission    
   when  service_charge_mode=''f'' then service_charge_flat * (paid_commission/100)     
   when  service_charge_mode=''p'' then service_charge_per * (paid_commission/100)     
   else 0 end paid_commission    
 '    
---------------Column END ---------------    
--SELECT * FROM service_charge_setup     
    
IF @payout_agent_id IS null    
SET @payout_country=@country     
else    
SELECT @payout_country=country FROM agentdetail WHERE agentcode=@payout_agent_id    
    
    
IF exists(SELECT slab_id FROM service_charge_setup     
WHERE agent_id=@send_agent_id AND payout_agent_id=@payout_agent_id AND payment_type=@payment_type)    
SET @mode='agent_payment'    
    
if @mode IS null    
BEGIN     
 IF exists(SELECT slab_id FROM service_charge_setup     
 WHERE agent_id=@send_agent_id AND payout_agent_id=@payout_agent_id AND payment_type IS null)    
 SET @mode='agent_NULL'    
END     
if @mode IS null    
BEGIN     
IF exists(SELECT slab_id FROM service_charge_setup     
WHERE agent_id=@send_agent_id AND rec_Country=@payout_country AND payment_type=@payment_type)    
SET @mode='country_payment'    
END     
if @mode IS null    
BEGIN     
IF exists(SELECT slab_id FROM service_charge_setup     
WHERE agent_id=@send_agent_id AND rec_Country=@payout_country AND payment_type IS null)    
SET @mode='country_NULL'    
END     
    
IF @mode IS null    
SELECT 'Error' Status,'Service Charge not define, Contact headoffice' Message    
PRINT '#########  '+@mode +'   ####'    
    
--##############Agent wise Rate and Payment Type MATCHED ###################    
IF @mode='agent_payment'    
begin    
PRINT 'inside  agent_payment'    
 if exists(select * from #temp_scharge where @pay_in_amt <=max_amount    
 and agent_id=@send_agent_id and payout_agent_id=@payout_agent_id and payment_type=@payment_type)    
 begin    
   SET @sql='select   top 1 '+@sql_clm +'    
    from #temp_scharge where '+ cast(@pay_in_amt AS varchar) +' <= max_amount    
    and agent_id='''+ @send_agent_id +''' and payout_agent_id='''+ @payout_agent_id +''' and payment_type='''+ @payment_type +'''    
       order by max_amount desc'    
 end    
 ELSE     
 begin    
   SET @sql='select   '+@sql_clm +'    
    from #temp_scharge where max_amount=(select max(max_amount) from service_charge_setup    
    where agent_id='''+ @send_agent_id +''' and payout_agent_id='''+ @payout_agent_id +''' and payment_type='''+ @payment_type +''')    
    AND agent_id='''+ @send_agent_id +''' and payout_agent_id='''+ @payout_agent_id +''' and payment_type='''+ @payment_type +''''    
 end    
END     
--##############Agent wise Rate and Payment NOT MATCHED ###################    
IF @mode='agent_NULL'    
begin    
PRINT 'inside  agent_null'    
 if exists(select * from #temp_scharge where @pay_in_amt <=max_amount    
 and agent_id=@send_agent_id and payout_agent_id=@payout_agent_id and payment_type IS null)    
 begin    
   SET @sql='select top 1 '+@sql_clm +'    
    from #temp_scharge where '+ cast(@pay_in_amt AS varchar) +' <= max_amount    
    and agent_id='''+ @send_agent_id +''' and payout_agent_id='''+ @payout_agent_id +''' and payment_type IS null    
             order by max_amount desc'    
 end    
 ELSE     
 begin    
   SET @sql='select   '+@sql_clm +'    
    from #temp_scharge where max_amount=(select max(max_amount) from service_charge_setup    
    where agent_id='''+ @send_agent_id +''' and payout_agent_id='''+ @payout_agent_id +''' and payment_type IS null)    
    AND agent_id='''+ @send_agent_id +''' and payout_agent_id='''+ @payout_agent_id +''' and payment_type IS null'    
 end    
END     
    
    
--##############Country wise Rate and Payment Type MATCHED ###################    
IF @mode='country_payment'    
begin    
PRINT 'inside  country_payment'    
 if exists(select * from #temp_scharge where @pay_in_amt <= max_amount    
 and agent_id=@send_agent_id and rec_Country=@payout_country and payment_type=@payment_type)    
 begin    
   SET @sql='select top 1  '+@sql_clm +'    
    from #temp_scharge where '+ cast(@pay_in_amt AS varchar) +' <=max_amount    
    and agent_id='''+ @send_agent_id +''' and rec_Country='''+ @payout_country +''' and payment_type='''+ @payment_type +'''    
             order by max_amount desc'    
 end    
 ELSE     
 begin    
   SET @sql='select   '+@sql_clm +'    
    from #temp_scharge where max_amount=(select max(max_amount) from service_charge_setup    
    where agent_id='''+ @send_agent_id +''' and rec_Country='''+ @payout_country +''' and payment_type='''+ @payment_type +''')    
    AND agent_id='''+ @send_agent_id +''' and rec_Country='''+ @payout_country +''' and payment_type='''+ @payment_type +''''    
 end    
END     
--##############Country wise Rate and Payment NOT MATCHED ###################    
IF @mode='country_Null'    
begin    
--PRINT 'inside country Null'    
 if exists(select * from #temp_scharge where @pay_in_amt <=max_amount    
 and agent_id=@send_agent_id and rec_Country=@payout_country and payment_type IS null)    
 begin    
   SET @sql='select top 1  '+@sql_clm +'    
    from #temp_scharge where '+ cast(@pay_in_amt AS varchar) +' <= max_amount    
    and agent_id='''+ @send_agent_id +''' and rec_Country='''+ @payout_country +''' and payment_type IS null    
             order by max_amount desc'    
 end    
 ELSE     
 begin    
   SET @sql='select   '+@sql_clm +'    
    from #temp_scharge where max_amount=(select max(max_amount) from service_charge_setup    
    where agent_id='''+ @send_agent_id +''' and rec_Country='''+ @payout_country +''' and payment_type IS null)    
    AND agent_id='''+ @send_agent_id +''' and rec_Country='''+ @payout_country +''' and payment_type IS null'    
 end    
END     
PRINT @sql    
exec(@sql)    
drop table #temp_scharge    
END    
    
    
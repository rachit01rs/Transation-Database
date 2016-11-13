DROP proc [dbo].[spa_make_payment]        
Go  
CREATE proc [dbo].[spa_make_payment]          
@branch_id varchar(50),          
@tranno int,          
@user_id varchar(50),          
@DIG_INFO varchar(250),          
@new_account varchar(100)=null,          
@call_from char(1)=NULL,          
@beneficiary_ID_type varchar(100)=NULL,          
@beneficiary_ID_number varchar(100)=NULL,          
@table_name varchar(50)=NULL,          
@rBankName varchar(200)=NULL,                    
@rBankBranch varchar(200)=NULL,      
@is_own_branch char(1)=Null   ----- For PFCL Branches             
AS          
          
BEGIN TRY          
          
 --Check Remote for pay transaction       
--if exists(select tranno FROM moneySend with (nolock) WHERE tranno=@tranno AND (TransStatus in ('Payment','Pay Processing') and status = 'Un-Paid'))        
--begin    
-- declare @refno_check varchar(50)    
-- select @refno_check=refno from moneysend with (nolock) where tranno=@tranno    
-- --exec spa_PartnerCheck_for_pay @refno_check    
-- ---if not exists (select tranno from moneysend with (nolock) WHERE tranno=@tranno AND TransStatus IN ('Pay Processing'))        
-- -begin    
--  --select 'ERROR' status,'1002' id,'ERROR OCCUR <br> Please contact headoffice!!' Message          
---- return     
---- end    
----update moneysend set TransStatus='Payment' where tranno=@tranno AND TransStatus IN ('Pay Processing')    
--end     
-- ###test          
-- declare @branch_id varchar(50),          
-- @tranno int,          
-- @user_id varchar(50),          
-- @DIG_INFO varchar(250),          
-- @new_account varchar(100)          
-- set @tranno=100047          
-- set @branch_id='70400300'          
-- set @user_id='HO:admin'          
-- drop table #temp_rate_ho          
-- ### Test End          
declare @expected_payoutagentid varchar(50),@agent_country varchar(100),@payoutagentid varchar(50),          
@GMT_Date datetime,          
@receiveAgentID varchar(50),@transferType varchar(50),@MAIN_LEDGER_ID varchar(50),@agent_comm money, @agent_comm_type varchar(20),          
@agent_receiverSCommission money ,@isApiTXN VARCHAR(50),@payout_settle_usd money        
          
select @payoutagentid=agent_code_id,@agent_country=a.country ,          
@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@receiveAgentID=a.agentcode,@transferType=transferType,          
@agent_comm=a.commission,@agent_comm_type=a.cType          
from agentbranchdetail b with (nolock) join agentdetail a with (nolock)           
on b.agentcode=a.agentcode where agent_branch_code=@branch_id          
          
if (@rBankName is null or @rBankBranch is null)                    
select @rBankName=a.companyName,@rBankBranch=b.branch from agentbranchdetail b join agentdetail a  on b.agentcode=a.agentcode where agent_branch_code=@branch_id               
          
select @MAIN_LEDGER_ID=headoffice_agent_id from tbl_setup with (nolock)         
          
if not exists (select tranno from moneysend  with (nolock)         
where tranno=@tranno  and receiverCountry=@agent_country           
and transStatus='Payment' and status='Un-Paid'          
and lock_status='locked' and lock_by=@user_id and test_trn is null)          
BEGIN          
 IF @table_name IS NOT NULL           
  exec ('insert into '+@table_name+' (status,Confirm_ID,Message)            
  select ''ERROR'',''1001'',''Transaction detail does not  match for payment criteria''')           
 ELSE           
  select 'ERROR' status,'1001' id,'Transaction detail does not match for payment criteria' MESSAGE          
          
 return          
end           
          
declare @send_agent_id varchar(50),@agent_receiveingComm money,@agent_receiverComm_Currency char(1),@receivingComm money,@sending_country varchar(100),          
@totalroundamt money,@old_acno varchar(100),@refno varchar(50),          
@payment_type varchar(50),@Scharge money,@paid_date_usd_rate money,          
@isIRH_trn char(1),@paidamt money,@send_branch_id varchar(50) ,@refno_decrypt VARCHAR(50) ,@diable_payout CHAR(1)        
          
select @send_agent_id=m.agentid,@refno=m.refno,@sending_country=m.senderCountry,@totalroundamt=m.totalroundamt,        
@old_acno=m.rBankACNo,@payment_type=m.paymenttype,@expected_payoutagentid=m.expected_payoutagentid,        
@agent_receiverSCommission=m.agent_receiverSCommission,@Scharge=m.SCharge,@isIRH_trn=m.isIRH_trn,@paidamt=m.paidamt,@send_branch_id=m.branch_code        
,@isApiTXN=SenderBankName  ,@diable_payout=ISNULL(a.disable_payout,'n'),@payout_settle_usd=m.payout_settle_usd
from moneysend m  WITH (NOLOCK) JOIN agentDetail a  WITH (NOLOCK) ON a.agentCode=m.agentid 
where tranno=@tranno          
  SET @refno_decrypt= dbo.decryptDB(@refno)  
         
IF LOWER(@diable_payout)='y'  
BEGIN  
 SELECT 'ERROR' StatusMsg,'1002' id,'This Transaction is blocked.Please contact the remitter.' MESSAGE  
 RETURN   
END    


if @payment_type='Bank Transfer' and @payoutagentid <> @expected_payoutagentid          
BEGIN          
          
 IF @table_name IS NOT NULL           
  EXEC ('insert into '+@table_name+'(status,Confirm_ID,Message)            
  select ''ERROR'',''1002'',''Payout agent not matched''')           
 ELSE           
  select 'ERROR' status,'1002' id,'Payout agent not matched!!' Message          
          
 RETURN          
          
end          
          
select @paid_date_usd_rate=DollarRate          
from agentCurrencyRate with (nolock) where agentid=@send_agent_id and receiveCountry=@agent_country          
          
IF exists(select Currencyid FROM agentpayout_CurrencyRate with (nolock) WHERE agentid=@send_agent_id AND payout_agent_id=@payoutagentid)          
begin          
PRINT 'insert agent wise'          
select @paid_date_usd_rate=x.DollarRate          
 from agentpayout_CurrencyRate x with (nolock)          
 where x.agentId=@send_agent_id  and payout_agent_id=@payoutagentid          
end          
          
IF exists(select sno FROM roster with (nolock) WHERE payoutagentid=@payoutagentid)          
begin          
PRINT 'insert agent wise'          
select @paid_date_usd_rate=x.buyRate          
 from roster x with (nolock)           
 where payoutagentid=@payoutagentid          
end          
      
     
          
--if @agent_comm is not NULL and @agent_comm>0           
--begin          
-- set @agent_receiverSCommission=case when @agent_comm_type='By Percentage' then (@Scharge * (@agent_comm/100)) else @agent_comm end          
--end          
          
--           
-- if @payment_type='Cash Payment' and @expected_payoutagentid <> @payoutagentid           
-- begin          
--  select 'ERROR','1002','Payout agent not matached!!'          
--  return          
-- end          
          
          
if @call_from is NULL          
begin          
create table #temp_charge(slab_id int,          
min_amount money,          
max_amount money,          
service_charge money,          
send_commission money,paid_commission money          
)          
insert into #temp_charge(slab_id,min_amount,max_amount,service_charge,send_commission,paid_commission)          
exec spa_GetServiceCharge @send_agent_id,@payoutagentid,@paidamt,@payment_type,@send_branch_id          
select @agent_receiverSCommission=paid_commission from #temp_charge          
end          
 -- MAIN AGENT COMMISSION SLAB  
select top 1 @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission 
where agent_code=@payoutagentid   
and case when country='all' then @sending_country else country end=@sending_country   
and case when payment_mode='default' then @payment_type else payment_mode end=@payment_type   
and case when paidValueCCY='d' then (@totalroundamt/@payout_settle_usd) else @totalroundamt end between min_amount and max_amount 
order by case when country='all' then 'a' else country end desc,
case when payment_mode='default' then 'a' else payment_mode end desc 

-- BRANCH AGENT COMMISSION  
select top 1 @receivingComm=commission_value from agent_branch_commission  with (nolock)   
where agent_branch_code=@branch_id  and case when country='all' then @sending_country else country end=@sending_country   
and case when payment_mode='default' then @payment_type else payment_mode end=@payment_type   
and case when paidValueCCY='d' then (@totalroundamt/@payout_settle_usd) else @totalroundamt end between min_amount and max_amount 
order by case when country='all' then 'a' else country end desc,
case when payment_mode='default' then 'a' else payment_mode end desc 
            
-- MAIN AGENT COMMISSION          
--select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission with (nolock)           
--where agent_code=@payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount          
--and payment_mode=@payment_type and case when paidValueCCY='d' then (@totalroundamt/@payout_settle_usd) else @totalroundamt end between min_amount and max_amount 
--order by case when country='all' then 'a' else country end desc,
--case when payment_mode='default' then 'a' else payment_mode end desc          
          
--if @agent_receiveingComm is null          
-- begin          
--  select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission with (nolock)           
--  where agent_code=@payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount          
--  and payment_mode='Default'          
-- end          
--if @agent_receiveingComm is null          
-- begin          
-- select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission with (nolock)          
-- where agent_code=@payoutagentid and country='All' and @totalroundamt between min_amount and max_amount          
-- and payment_mode=@payment_type          
-- end          
--if @agent_receiveingComm is null          
-- begin          
--  select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission with (nolock)           
--  where agent_code=@payoutagentid and country='All' and @totalroundamt between min_amount and max_amount          
--  and payment_mode='Default'          
-- end          
---- BRANCH AGENT COMMISSION          
--select @receivingComm=commission_value from agent_branch_commission with (nolock)          
-- where agent_branch_code=@branch_id  and country=@sending_country          
          
          
if @agent_receiveingComm is null          
 set @agent_receiveingComm=0          
  
if @is_own_branch='y' and @payment_type='Bank Transfer'  
begin  
 set @agent_receiveingComm=0  
 set @agent_receiverSCommission=0.00    
end    
          
if @receivingComm is null or (@transferType='Deposit' and @payment_type='Bank Transfer')           
 set @receivingComm=0          
begin TRANSACTION          
if @payment_type='Cash Payment'          
 Update MoneySend set rBankId=@branch_id,          
 rBankName=@rBankName ,          
 rBankBranch=@rBankBranch,paidBy=@user_id,          
 paidDate=@GMT_Date,podDate=@GMT_Date,paidTime=convert(varchar,dbo.getDateHO(getutcdate()),108),          
 HO_paidDate=dbo.getDateHO(getutcdate()),          
 status='Paid', receiverCommission=@receivingComm,          
 receiveAgentID=@receiveAgentID,          
 digital_id_payout=@DIG_INFO ,          
 agent_receiverCommission=@agent_receiveingComm,          
 agent_receiverComm_Currency=@agent_receiverComm_Currency,          
 lock_status='unlocked',          
 agent_receiverSCommission=@agent_receiverSCommission,          
 expected_payoutagentid=@payoutagentid,          
 paid_agent_id=@payoutagentid,          
 paid_date_usd_rate=@paid_date_usd_rate,          
 paid_beneficiary_ID_type=@beneficiary_ID_type,          
 paid_beneficiary_ID_number=@beneficiary_ID_number          
 where Tranno=@tranno and transStatus='Payment' and Status='Un-Paid'           
 --and paid_agent_id=@expected_payoutagentid          
else          
 Update MoneySend set rBankId=case when paymentType='Bank Transfer' then rBankId else @branch_id end,          
 rBankName=@rBankName ,          
 rBankBranch= case when paymentType='Bank Transfer' then rBankBranch else @rBankBranch end,paidBy=@user_id,          
 paidDate=@GMT_Date,podDate=@GMT_Date,paidTime=convert(varchar,dbo.getDateHO(getutcdate()),108),          
 HO_paidDate=dbo.getDateHO(getutcdate()),          
 status='Paid', receiverCommission=@receivingComm,          
 receiveAgentID=@receiveAgentID,          
 digital_id_payout=@DIG_INFO ,          
 agent_receiverCommission=@agent_receiveingComm,          
 agent_receiverComm_Currency=@agent_receiverComm_Currency,          
 lock_status='unlocked',          
 agent_receiverSCommission=@agent_receiverSCommission,          
 expected_payoutagentid=@payoutagentid,          
 paid_agent_id=@payoutagentid,          
 paid_date_usd_rate=@paid_date_usd_rate,          
 paid_beneficiary_ID_type=@beneficiary_ID_type,          
 paid_beneficiary_ID_number=@beneficiary_ID_number          
 where Tranno=@tranno and transStatus='Payment' and Status='Un-Paid'           
          
if @new_account is not null and @payment_type='Bank Transfer' and @new_account  <> @old_acno          
begin          
 Update MoneySend set rBankACNo=@new_account          
  where Tranno=@tranno          
 insert transactionNotes(refno,comments,DatePosted,postedBy,uploadBy,noteType,tranno)          
 values(@refno,'Account no changed while payment:'+cast(@old_acno as varchar) +' to '+ cast(@new_account as varchar),@GMT_Date,          
 @user_id,'A',2,@tranno)          
          
end           
Update agentDetail set currentBalance=isNull(currentBalance,0)-(@totalroundamt+           
case when @agent_receiverComm_Currency='l' then @agent_receiveingComm else @agent_receiveingComm*@paid_date_usd_rate end),          
currentCommission=isNull(currentCommission,0)+case when @agent_receiverComm_Currency='l' then @agent_receiveingComm else @agent_receiveingComm*@paid_date_usd_rate end          
where agentcode=@payoutagentid          
          
declare @invoice_no int,@roweffect int,@check_comm_branch varchar (50)          
--select @invoice_no=max(cast(invoiceNo as int)) from agentbalance where isNumeric(invoiceNo)=1          
set @invoice_no=ident_current('agentbalance') + 1          
--############# Payout Branch Commission           
          
select avg(usdRRate) usdRRate,receivecountry into #temp_rate_ho from(          
  select avg(ExchangeRate) usdRRate,a.country receivecountry from  agentcurrencyRate r with (nolock)          
  join agentdetail a with (nolock) on r.agentid=a.agentcode           
  group by a.country          
  union           
  select avg(DollarRate) usdRRate,receivecountry from  agentcurrencyRate           
  group by receivecountry ) j          
  group by receivecountry          
          
-- select @receivingComm,@agent_receiverSCommission          
          
if @receivingComm>0           
begin          
           
          
 set @invoice_no=ident_current('agentbalance') + 1          
          
 insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,          
 Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)          
 select @invoice_no,a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),@receivingComm,a.CurrencyType,          
 @paid_date_usd_rate,'cr','Commission Gain:'+ dbo.decryptDB(@refno),@user_id, cast(@receivingComm/@paid_date_usd_rate as money),          
 b.agent_branch_code,          
 dbo.getDateHO(getutcdate()),@user_id,dbo.getDateHO(getutcdate())          
 from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode           
 where b.comm_main_branch_id=@branch_id          
           
 set @roweffect=@@rowcount          
 if @roweffect > 0           
 begin           
  insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,          
  Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)          
  select @invoice_no,a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),cast(@receivingComm/c.usdRRate as money),a.CurrencyType,          
  c.usdRRate,'dr','Commission Gain:'+ dbo.decryptDB(@refno),@user_id, cast(@receivingComm/c.usdRRate as money),NULL,          
  dbo.getDateHO(getutcdate()),@user_id,dbo.getDateHO(getutcdate())          
  from agentdetail a with (nolock) join #temp_rate_ho c          
  on c.receivecountry=a.country where           
  a.agentcode=@MAIN_LEDGER_ID          
           
  Update agentDetail set currentBalance=isNull(a.currentBalance,0)+cast(@receivingComm/c.usdRRate as money)          
  from agentDetail a with (nolock), #temp_rate_ho c          
  where c.receivecountry=a.country and a.agentcode=@MAIN_LEDGER_ID          
             
  Update agentBranchDetail set currentBalance=isNull(currentBalance,0)-@receivingComm          
  where comm_main_branch_id=@branch_id          
           
  Update agentDetail set currentBalance=isNull(a.currentBalance,0)-@receivingComm          
  from agentDetail a with (nolock),agentBranchDetail b with (nolock)         
  where a.agentcode=b.agentcode and comm_main_branch_id=@branch_id           
 end          
end           
--############# Payout agent Agent Commission of Service Charges          
if @agent_receiverSCommission > 0          
 begin          
            
          
 set @invoice_no=ident_current('agentbalance') + 1          
          
 insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,          
 Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)          
 select @invoice_no,a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),  
 cast((@agent_receiverSCommission*m.agent_settlement_rate)/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) as money),  
 a.CurrencyType, 1,'cr','Commission Gain: On Service Charge '+ dbo.decryptDB(@refno)+ '<br>Total '+cast(@agent_receiverSCommission as varchar)+'  
 '+m.PaidCType+'@'+cast(round(isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate)/m.agent_settlement_rate,4,0) as varchar),@user_id,           
 cast((@agent_receiverSCommission*m.agent_settlement_rate)/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) as money),b.agent_branch_code,         
 dbo.getDateHO(getutcdate()),@user_id,dbo.getDateHO(getutcdate())          
 from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode join moneysend m           
 on m.agentid=@send_agent_id           
 where b.comm_main_branch_id=@payoutagentid and m.tranno=@tranno          
          
 set @roweffect=@@rowcount          
 if @roweffect > 0           
 begin           
 --HO Ledger Updated DR           
  insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,          
  Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)          
  select @invoice_no,a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),@agent_receiverSCommission,a.CurrencyType,          
  isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate)/m.agent_settlement_rate,'dr',          
  'Commission Gain: On Service Charge '+ dbo.decryptDB(@refno)+ '<br>Total '+cast(@agent_receiverSCommission as varchar)+' '+m.PaidCType+'@'+cast(round(isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate)/m.agent_settlement_rate,4,0) as varchar),@user_id,           
  cast(@agent_receiverSCommission/(isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate)/m.agent_settlement_rate) as money),NULL,          
  dbo.getDateHO(getutcdate()),@user_id,dbo.getDateHO(getutcdate())          
  from agentdetail a with (nolock) join moneysend m with (nolock)           
  on m.agentid=@send_agent_id           
  where a.agentcode=@MAIN_LEDGER_ID and m.tranno=@tranno          
            
  Update agentDetail set currentBalance=isNull(currentBalance,0)+cast(@agent_receiverSCommission as money)          
  where agentcode=@MAIN_LEDGER_ID          
 --HO Ledger End          
           
  Update agentBranchDetail set currentBalance=isNull(b.currentBalance,0)-cast((@agent_receiverSCommission*m.agent_settlement_rate)/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) as money)          
  from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode join moneysend m           
  on m.agentid=@send_agent_id           
  where b.comm_main_branch_id=@payoutagentid and m.tranno=@tranno          
            
  Update agentDetail set currentBalance=isNull(a.currentBalance,0)-cast((@agent_receiverSCommission*m.agent_settlement_rate)/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) as money)          
  from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode join moneysend m           
  on m.agentid=@send_agent_id           
  where b.comm_main_branch_id=@payoutagentid and m.tranno=@tranno          
 end           
end          
--############# Payout agent Agent Commission of Flat          
if @agent_receiveingComm > 0          
 begin          
            
          
 set @invoice_no=ident_current('agentbalance') + 1          
          
 insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,          
 Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)          
 select @invoice_no,a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),          
 cast(case when isNull(@agent_receiverComm_Currency,'l')='l' then @agent_receiveingComm/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) else @agent_receiveingComm end as money),a.CurrencyType,          
 1,'cr','Commission Gain: On Flat '+ dbo.decryptDB(@refno)+ case when isNull(@agent_receiverComm_Currency,'l')='l' then '<br>Total '+cast(@agent_receiveingComm as varchar)+' '+m.receiveCtype+'@'+cast(round(cast(isNull(@paid_date_usd_rate,m.exchangeRate * 
 m.agent_settlement_rate) as money),4,0) as varchar) else '' end,@user_id,           
 cast(case when isNull(@agent_receiverComm_Currency,'l')='l' then @agent_receiveingComm/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) else @agent_receiveingComm end as money),b.agent_branch_code,          
 dbo.getDateHO(getutcdate()),@user_id,dbo.getDateHO(getutcdate())          
 from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode join moneysend m           
 on m.agentid=@send_agent_id           
 where b.comm_main_branch_id=@payoutagentid and m.tranno=@tranno          
          
 set @roweffect=@@rowcount          
 if @roweffect > 0           
 begin           
 --HO Ledger Updated DR           
  insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,          
  Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)          
  select @invoice_no,a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),cast(case when isNull(@agent_receiverComm_Currency,'l')='l' then @agent_receiveingComm/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate)         
 else @agent_receiveingComm end as money),a.CurrencyType,          
  1,'dr','Commission Gain: On Flat '+ dbo.decryptDB(@refno)+ case when isNull(@agent_receiverComm_Currency,'l')='l' then '<br>Total   
  '+cast(@agent_receiveingComm as varchar)+' '+m.receiveCtype+'@'+cast(round(cast(isNull(@paid_date_usd_rate,m.exchangeRate *       
  m.agent_settlement_rate) as money),4,0) as varchar) else '' end,@user_id,          
  cast(case when isNull(@agent_receiverComm_Currency,'l')='l' then @agent_receiveingComm/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) else @agent_receiveingComm end as money),NULL,          
  dbo.getDateHO(getutcdate()),@user_id,dbo.getDateHO(getutcdate())          
  from agentdetail a with (nolock) join moneysend m with (nolock)           
  on m.agentid=@send_agent_id           
  where a.agentcode=@MAIN_LEDGER_ID and m.tranno=@tranno          
            
  Update agentDetail set currentBalance=isNull(currentBalance,0)+cast(case when isNull(@agent_receiverComm_Currency,'l')='l' then @agent_receiveingComm/@paid_date_usd_rate else @agent_receiveingComm end as money)          
  where agentcode=@MAIN_LEDGER_ID          
 --HO Ledger End          
           
  Update agentBranchDetail set currentBalance=isNull(b.currentBalance,0)-cast(case when isNull(@agent_receiverComm_Currency,'l')='l'   
then @agent_receiveingComm/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate) else @agent_receiveingComm end as money)          
  from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode join moneysend m           
  on m.agentid=@send_agent_id           
  where b.comm_main_branch_id=@payoutagentid and m.tranno=@tranno          
            
  Update agentDetail set currentBalance=isNull(a.currentBalance,0)-cast(case when isNull(@agent_receiverComm_Currency,'l')='l' then @agent_receiveingComm/isNull(@paid_date_usd_rate,m.exchangeRate * m.agent_settlement_rate)         
 else @agent_receiveingComm end as money)          
  from agentbranchdetail b with (nolock) join agentdetail a with (nolock) on b.agentcode=a.agentcode join moneysend m           
  on m.agentid=@send_agent_id           
  where b.comm_main_branch_id=@payoutagentid and m.tranno=@tranno          
 end           
end          
          
--######## Update Branch Baance as they Paid TRN and check if Checked Branch is Created          
select @check_comm_branch=agent_branch_code from agentBranchDetail           
where comm_main_branch_id=@branch_id          
if @check_comm_branch is not null          
 set @receivingComm=0          
          
Update agentBranchDetail set currentBalance=isNull(currentBalance,0)-(@totalroundamt+@receivingComm),          
currentCommission=isNull(currentCommission,0)+@receivingComm          
where agent_branch_code=@branch_id           
          
-----------------------------------------
IF @isApiTXN='API Transaction'   
BEGIN  
 INSERT INTO SOAP_TXN_NOTIFICATION  
 (  
  refno,  
  agentid,  
  notification_type,  
  notification_remarks,  
  notification_date  
 )  
 VALUES  
 (  
  @refno_decrypt,  
  @send_agent_id,  
  'Paid',  
  'TXN Paid',  
  dbo.getDateHO(getutcdate())  
   
 )  
END       
 
--------------------------------------------------------------------------------
-- SMS Send to Sender After payment---------------------------------  
INSERT INTO sms_pending (deliverydate,mobileno,message,refno,smsto,country,agentuser,status,sender_id)
SELECT dbo.getDateHO(GETUTCDATE()),sender_mobile,dbo.FNA_GET_SMS_MSG(tranno),dbo.decryptDb(refno),'S',SenderCountry,paidBy,'p','447937900000'
FROM dbo.moneySend WITH(NOLOCK) WHERE status='Paid' AND sender_mobile IS NOT NULL AND isIRH_trn IS NULL AND send_sms='y' AND Tranno=@tranno 
--------------------------------------------------------------------------------
	
COMMIT TRAN         
       declare @tranno_char varchar(50)  
set @tranno_char=@tranno  
 IF @table_name IS NOT NULL           
  EXEC ('insert into '+@table_name+' (status,Confirm_ID,Message)            
  select ''SUCCESS'','''+@tranno_char+''','''+@GMT_Date+'''')           
 ELSE           
 
select 'SUCCESS' status,@tranno Id,@GMT_Date Message          
 --UPdate USA  
  
if exists(select enable_update_remote_DB from tbl_interface_setup   
 where agentcode=@send_agent_id and mode='Pay')  
begin  
DECLARE @enable_update_remoteDB char(1),@remote_db varchar(100),@sql2 varchar(1000)     
--DECLARE @enable_update_remoteDB_noneed char(1),@remote_db_noneed varchar(100),@sql2_noneed varchar(1000)  
declare @external_agent_id varchar(50),@external_branch_id varchar(50)  
   
 select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB,  
 @external_agent_id=external_agent_id,@external_branch_id=external_branch_id from tbl_interface_setup with (nolock)  
 where agentcode=@send_agent_id and mode='Pay'  
  
insert into TransPaidStatus_OUT(        
 refno,rBankId,rBankName,rBankBranch,paidBy,paidDate,podDate,paidTime,status,        
 receiverCommission,receiveAgentID,digital_id_payout,agent_receiverCommission,        
 agent_receiverComm_Currency,lock_status,agent_receiverSCommission,paid_agent_id,        
 paid_date_usd_rate)      
select refno,rBankId,rBankName,rBankBranch,paidBy,paidDate,podDate,paidTime,status,  
 receiverCommission,receiveAgentID,digital_id_payout,agent_receiverCommission,  
 agent_receiverComm_Currency,lock_status,agent_receiverSCommission,paid_agent_id,  
 paid_date_usd_rate from   
 moneysend m  
 where m.tranno=@tranno_char  
--  
--declare @refno_R varchar(50),@rBankId_R varchar(50),@rBankName_R varchar(50),@rBankBranch_R varchar(50),@paidBy_R varchar(50)  
-- ,@paidDate_R varchar(50),@podDate_R varchar(50),@paidTime_R varchar(50),@status_R varchar(50),    
-- @receiverCommission_R varchar(50),@receiveAgentID_R varchar(50),@digital_id_payout_R varchar(50),  
-- @agent_receiverCommission_R varchar(50),@agent_receiverComm_Currency_R varchar(50),@lock_status_R varchar(50),  
-- @agent_receiverSCommission_R varchar(50),@paid_agent_id_R varchar(50),@paid_date_usd_rate_R varchar(50)  
-- set @rBankId_R=@external_branch_id  
-- select @refno_R=refno,@rBankName_R=rBankName,@rBankBranch_R=rBankBranch,@paidBy_R=paidBy,@paidDate_R=paidDate,@podDate_R=podDate,  
-- @paidTime_R=paidTime,@status_R=status,@receiverCommission_R=receiverCommission,@receiveAgentID_R=receiveAgentID,  
-- @digital_id_payout_R=digital_id_payout,@agent_receiverCommission_R=agent_receiverCommission,    
-- @agent_receiverComm_Currency_R=agent_receiverComm_Currency,@lock_status_R=lock_status,@agent_receiverSCommission_R=agent_receiverSCommission,  
-- @paid_agent_id_R=paid_agent_id,@paid_date_usd_rate_R=paid_date_usd_rate  
-- from moneysend m where m.refno=@refno and expected_payoutagentid=@expected_payoutagentid  
--   
-- set @sql2='Exec '+@remote_db+'spRemote_pay_process '''+@refno_R+''','+  
-- case when @rBankId_R is null then ' Null ' else  '''' + @rBankId_R  +  '''' end +','+  
-- case when @rBankName_R is null then ' Null ' else  '''' + @rBankName_R  +  '''' end +','+  
--case when @rBankBranch_R is null then ' Null ' else  '''' + @rBankBranch_R  +  '''' end +','+  
-- case when @paidBy_R is null then ' Null ' else  '''' + @paidBy_R  +  '''' end +','+  
-- case when @paidDate_R is null then ' Null ' else  '''' + @paidDate_R  +  '''' end +','+  
-- case when @podDate_R is null then ' Null ' else  '''' + @podDate_R  +  '''' end +','+  
-- case when @paidTime_R is null then ' Null ' else  '''' + @paidTime_R  +  '''' end +','+  
-- case when @status_R is null then ' Null ' else  '''' + @status_R  +  '''' end +','+  
-- case when @receiverCommission_R is null then ' Null ' else  '''' + @receiverCommission_R  +  '''' end +','+  
-- case when @receiveAgentID_R is null then ' Null ' else  '''' + @receiveAgentID_R  +  '''' end +','+  
-- case when @digital_id_payout_R is null then ' Null ' else  '''' + @digital_id_payout_R  +  '''' end +','+  
-- case when @agent_receiverCommission_R is null then ' Null ' else  '''' + @agent_receiverCommission_R  +  '''' end +','+  
-- case when @agent_receiverComm_Currency_R is null then ' Null ' else  '''' + @agent_receiverComm_Currency_R  +  '''' end +','+  
-- case when @lock_status_R is null then ' Null ' else  '''' + @lock_status_R  +  '''' end +','+  
-- case when @agent_receiverSCommission_R is null then ' Null ' else  '''' + @agent_receiverSCommission_R  +  '''' end +','+  
-- case when @paid_agent_id_R is null then ' Null ' else  '''' + @paid_agent_id_R  +  '''' end +','+  
-- case when @paid_date_usd_rate_R is null then ' Null ' else  '''' + @paid_date_usd_rate_R  +  '''' end   
--print @sql2  
--exec (@sql2)  
end  
--Update USA end  
        
          
END TRY          
begin catch            
          
  if @@trancount>0           
 rollback transaction          
          
     declare @desc varchar(1000)            
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'            
 INSERT INTO [error_info]            
           ([ErrorNumber]            
           ,[ErrorDesc]            
           ,[Script]            
           ,[ErrorScript]            
           ,[QueryString]            
           ,[ErrorCategory]            
           ,[ErrorSource]            
           ,[error_date])            
 select -1,@desc,'spa_make_payment','SQL',@desc,'SQL','spa_make_payment',getdate()            
          
 select 'ERROR','1013','Error Please try again'            
            
end catch  
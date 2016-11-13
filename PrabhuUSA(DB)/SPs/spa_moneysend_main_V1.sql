set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER procedure [dbo].[spa_moneysend_main_V1]        
@flag char(1),        
@refno varchar(15),        
@branch_code varchar(50)=null,        
@customerid varchar(50)=null,        
@sendername varchar(50)=null,        
@senderaddress varchar(100)=null,        
@senderphoneno varchar(50)=null,        
@sendersalary varchar(100)=null,        
@sendercity varchar(100)=null,        
@senderemail varchar(100)=null,        
@sendercompany varchar(150)=null,        
@senderpassport varchar(50)=null,        
@sendervisa varchar(50)=null,        
@receivername varchar(50)=null,        
@receiveraddress varchar(100)=null,        
@receiverphone varchar(50)=null,        
@receivercity varchar(50)=null,        
@receivercountry varchar(50)=null,        
@receiverrelation varchar(50)=null,        
@paidamt money=null,        
@receiveamt money=null,        
@today_dollar_rate  money=null,        
@dollar_amt money=null,        
@scharge money=null,        
@cash_voucher_id varchar(150)=null,        
@paymenttype varchar(50)=null,        
@rbankid varchar(50)=null,        
@rbankacno varchar(50)=null,        
@rbankactype varchar(150)=null,        
@othercharge money=null,        
@sempid varchar(50)=null,        
@payout_agent_id varchar(50)=null,        
@send_mode varchar(10)=null,        
@totalroundamt money=null,        
@payoutcomm money=0,        
@gmtdate1 varchar(50)=null,        
@sendermobile varchar(20)=null,        
@receivermobile varchar(20)=null,        
@session_id varchar(100)=null,        
@transstatus varchar(50)=null,        
@customer_type char(1)=null,        
@sender_native_country varchar(100)=null,        
@agent_dollar_rate money=NULL,        
@ho_dollar_rate money=NULL,        
@ip_address varchar(15)=NULL,        
@bonus_amt money=NULL,        
@request_new_account char(1)=NULL,        
@trans_mode char(1)=NULL,        
@digital_id_sender varchar(100)=NULL,        
@bonus_value_amt money=NULL,        
@bonus_type char(1)=NULL,        
@bonus_on char(1)=NULL,        
@ben_bank_id varchar(10)=NULL,        
@ReciverMessage varchar(500)=null,        
@send_sms varchar(1)=null,        
@agent_ex_gain money=null,        
@txtsPassport_type varchar(100)=NULL, --- Used in Sender Fax Clm        
@ReceiverIDDescription varchar(100)=NULL,        
@receiverID varchar(100)=NULL,        
@TRN_Remarks varchar(500)=NULL,        
@cash_date varchar(20)=NULL,        
@receiverID_placeOfIssue varchar(50)=NULL,        
@source_of_income varchar(50)=NULL,        
@reason_for_remittance varchar(50)=NULL,        
@c2c_receiver_code varchar(200)=NULL,        
@c2c_secure_pwd varchar(10)=NULL,        
@ofac_list char(1)=NULL, ---added later        
@ID_Issue_date datetime=null,      
@Date_of_Birth datetime=NULL,      
@SSN_Card_ID VARCHAR(50)=NULL,      
@PartnerAgentID VARCHAR(50)=NULL,      
@PictureIdType VARCHAR(50)=NULL,      
@customer_category_id int=NULL         
-----        
as        
      
BEGIN TRY        
declare @agentid varchar(50),@agentname varchar(150),@branch varchar(150),@sendercountry varchar(100),@paidctype varchar(50)        
declare @cash_ledger_id int,@allow_exrate_change char(1)        
declare @ext_bank_id varchar(50),@ben_bank_name varchar(100),@exRateBy varchar(50),@sChargeBy varchar(50),@gmtdate datetime,@limit_date datetime        
        
if (select isNUll(sum(amtpaid),-1) from session_deposit_log with (nolock) where session_id=@session_id) <> @paidamt and @send_mode in ('s','v')        
begin        
 select 'ERROR','1009','Error in Deposit Detail, please try send transaction from main menu'        
 return        
end        
      
DECLARE @mileage_enable varchar(50),@mileage_earn int,@check_cust_per_date char(1),        
@limit_per_day money,@branch_limit_enable money        
        
-- SENDING AGENT DETAIL        
select @agentid=a.agentcode,@agentname=a.companyName,@branch=b.branch,@sendercountry=a.country,@paidctype=currencyType,        
@allow_exrate_change=allow_exrate_change,@cash_ledger_id=cash_ledger_id,@exRateBy=exRateBy,@sChargeBy=sChargeBy,        
@gmtdate=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@limit_date=trn_limit_date,        
@mileage_enable=f.mileage_enable,@check_cust_per_date=limit_for_customer,        
@limit_per_day=limitPerTran,@branch_limit_enable=isNull(b.branch_limit,-1)        
from agentdetail a  with (nolock) join agentbranchdetail b  with (nolock) on a.agentcode=b.agentcode        
join agent_function f on agent_id=a.agentcode        
where agent_branch_code=@branch_code        
        
declare @check_amt money        
SELECT @check_amt=isNUll(sum(paidAmt),0)+@paidamt FROM customer_trans_limit  with (nolock)  WHERE customer_passport=@senderpassport        
if @check_amt>50000 and @sendercountry='Malaysia'        
begin        
 select 'ERROR','1009','ID No: '+@senderpassport +' Exceeded daily Limit'        
 return        
end        
        
IF @cash_date IS null        
SET @cash_date=@gmtdate        
        
declare @sendercommission float,@agent_settlement_rate money,@exchangerate money,        
@agent_receiverSCommission money,@round_by int,@new_scharge money,@isSlab varchar(10)        
        
IF @mileage_enable='y'        
 SET @mileage_earn=cast(@paidamt AS int)/100         
        
declare @ho_cost_send_rate money,        
 @ho_premium_send_rate money,        
 @ho_premium_payout_rate money,        
 @agent_customer_diff_value money,        
 @agent_sending_rate_margin money,        
 @agent_payout_rate_margin money,        
 @agent_sending_cust_exchangerate money,        
 @agent_payout_agent_cust_rate money,        
 @ho_exrate_applied_type varchar(20),        
@receivectype varchar(50)        
        
      
 IF EXISTS(select * FROM agentpayout_CurrencyRate_Branch  with (nolock) WHERE agentId=@agentid         
 AND agent_branch_code=@branch_code AND payout_agent_id=@payout_agent_id)        
 begin        
  PRINT 'insert Payout agent wise Branch'        
   select         
    @ho_dollar_rate=x.DollarRate,        
    @agent_settlement_rate=x.NPRRate,        
    @exchangerate=x.exchangerate,        
    @today_dollar_rate=x.customer_rate,        
    @round_by=x.qtyCurrency,        
    @isSlab=NULL,        
    @receivectype=x.receivectype,        
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),        
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),        
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),        
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),        
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),        
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),        
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),        
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),        
    @ho_exrate_applied_type='payoutbranchwise'        
    from agentpayout_CurrencyRate_Branch x    with (nolock)       
    where x.agentId=@agentid and agent_branch_code=@branch_code  and payout_agent_id=@payout_agent_id        
 end        
 ELSE IF EXISTS(select * FROM agentpayout_CurrencyRate with (nolock)  WHERE agentId=@agentid        
 AND payout_agent_id=@payout_agent_id)        
 begin        
  PRINT 'insert Payout agent wise'        
   select         
    @ho_dollar_rate=x.DollarRate,        
    @agent_settlement_rate=x.NPRRate,        
    @exchangerate=x.exchangerate,        
    @today_dollar_rate=x.customer_rate,        
    @round_by=x.qtyCurrency,        
    @isSlab=NULL,        
    @receivectype=x.receivectype,        
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),        
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),        
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),        
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),        
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),        
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),        
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),        
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),        
    @ho_exrate_applied_type='payoutwise'        
    from agentpayout_CurrencyRate x    with (nolock)       
    where x.agentId=@agentid and payout_agent_id=@payout_agent_id        
          
 end        
 ELSE IF EXISTS(select * FROM agent_branch_rate  with (nolock) WHERE agentId=@agentid         
 AND agent_branch_code=@branch_code AND receiveCountry=@receivercountry)        
 begin        
  PRINT 'insert Agent wise Country Branch'        
   select         
    @ho_dollar_rate=x.DollarRate,        
    @agent_settlement_rate=x.NPRRate,        
    @exchangerate=x.exchangerate,        
    @today_dollar_rate=x.customer_rate,        
    @round_by=x.qtyCurrency,        
    @receivectype=x.receivectype,        
    @isSlab=NULL,        
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),        
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),        
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),        
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),        
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),        
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),        
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),        
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),        
    @ho_exrate_applied_type='branchwise'        
    from agent_branch_rate x    with (nolock)       
    where x.agentId=@agentid and agent_branch_code=@branch_code  and receiveCountry=@receivercountry        
 end        
         
 else        
 begin        
  PRINT 'insert Agent wise Country'        
   select         
    @ho_dollar_rate=x.DollarRate,        
    @agent_settlement_rate=x.NPRRate,        
    @exchangerate=x.exchangerate,        
    @today_dollar_rate=x.customer_rate,        
    @round_by=x.qtyCurrency,        
    @isSlab=NULL,        
    @receivectype=x.receivectype,        
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),        
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),        
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),        
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),        
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),        
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),        
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),        
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),        
    @ho_exrate_applied_type='countrywise'        
    from agentCurrencyRate x    with (nolock)       
    where x.agentId=@agentid and receiveCountry=@receivercountry        
  end        
      
        
------------############# new added  Service Charge        
create table #temp_charge(slab_id int,        
min_amount money,        
max_amount money,        
service_charge money,        
send_commission money,paid_commission money        
)        
insert into #temp_charge(slab_id,min_amount,max_amount,service_charge,send_commission,paid_commission)        
exec spa_GetServiceCharge @agentid,@payout_agent_id,@paidamt,@paymenttype,@branch_code,@receivercountry        
select @new_scharge=service_charge,@sendercommission=send_commission,        
@agent_receiverSCommission=paid_commission from #temp_charge        
      
--------------###############3        
 if @round_by is null        
  set @round_by=0        
 if @exchangerate is null --or @round_by is null        
 begin        
   select 'ERROR','1012','Error!! please try again'        
   return        
 end        
      
set @receiveamt=(@paidamt - @scharge) * @today_dollar_rate        
set @totalroundamt=round(@receiveamt,@round_by,1)        
--set @totalroundamt=floor(@receiveamt)        
        
if @totalroundamt<=0        
begin        
 select 'ERROR','1013','Error!! please try again'        
 return        
end      
if @sendercommission is null        
 set @sendercommission=0        
      
      
declare @rbankname varchar(150),@rbankbranch varchar(150),@receiveagentid varchar(50),        
@payout_country varchar(100),@branch_group varchar(500)        
      
IF @PartnerAgentID  IS NULL       
BEGIN      
       
 if @rbankid is not null        
 begin        
   select @receiveagentid=a.agentcode ,@rbankname=a.companyName,@rBankBranch=b.branch,@branch_group=b.branch_group,      
  @receivectype=a.currencyType,@payout_country=a.country from        
  agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode        
  where agent_branch_code=@rbankid      
 end        
 else        
 begin        
  select @receiveagentid=agentcode,@rbankname=companyName,@receivectype=a.currencyType,@payout_country=a.country       
  From agentdetail a  where agentcode=@payout_agent_id      
 END      
SET @PartnerAgentID=@payout_agent_id      
END      
      
      
if @rbankid is not null and @paymenttype='bank transfer'        
begin        
  if exists(select service_charge_id from Agent_Wise_charge where sending_agent_code=@agentid and         
  agentcode=@receiveagentid and paymentType='d' and branch_group=@branch_group)        
  begin        
    set @new_scharge=case when @paidamt <= 1500 then 10 else 15 end        
    set @sendercommission=@new_scharge * 0.5        
    SET @agent_receiverSCommission=@new_scharge*0.5        
  end        
end     

if @customer_category_id=1       
begin      
   set @new_scharge=0              
   SET @sendercommission=0              
   SET @agent_receiverSCommission=0      
end        
        
if @scharge <> @new_scharge        
begin        
 select 'ERROR','1013','Service charge is Invalid. Please re-try it again'        
 return        
end        
        
if  @payout_country <> @receivercountry         
begin        
  select 'ERROR','1010','Payout agent and country doesn''t matched'        
  return        
end        
if @ben_bank_id is not null        
begin        
 select @ext_bank_id=external_bank_id,@ben_bank_name=bank_name from commercial_bank where commercial_id=@ben_bank_id        
 if @ReciverMessage is not NULL        
  set @ReciverMessage=@ReciverMessage +'\'+@ben_bank_name        
 else        
  set @ReciverMessage=@ben_bank_name        
end         
------------Retrive Payout Settlement USD Rate ----------------        
declare @payout_settle_usd money        
select @payout_settle_usd=buyRate from Roster  with (nolock) where payoutagentid=@payout_agent_id        
if @payout_settle_usd is null        
 select @payout_settle_usd=buyRate from Roster  with (nolock)  where country=@payout_country        
if @payout_settle_usd is null        
 set @payout_settle_usd=@ho_dollar_rate        
----------- end -----------------------------------------------        
------------Retrive Send Settlement USD Rate ----------------        
declare @send_settle_usd money        
select @send_settle_usd=sellRate from Roster  with (nolock) where payoutagentid=@agentid        
if @send_settle_usd is null        
 select @send_settle_usd=sellRate from Roster with (nolock)  where country=@sendercountry        
if @send_settle_usd is null        
 set @send_settle_usd=@exchangerate        
----------- end -----------------------------------------------        
        
if @flag='i'        
begin        
        
 if @send_mode='v'        
 begin        
  if exists(select tranno from  cash_collected  with (nolock)         
   where cash_id=@cash_voucher_id and         
   collected_date=cast(@cash_date as datetime)        
   and branch_id=@branch_code and tranno is not null)        
  begin        
   select 'ERROR','4001','Error WITH Cash ID:'+ @cash_voucher_id +', TXN NOT saved!!!'        
   return        
  END        
  if exists(select cash_id from  cash_collected    with (nolock)       
   where cash_id=@cash_voucher_id and collected_date=cast(@cash_date as datetime)        
   and branch_id=@branch_code and status='cancel')        
  begin        
   select 'ERROR','4002','CASH Voucher: '+ @cash_voucher_id +' has been cancelled already!!!'        
   return        
  END        
 end        
      
 declare @bankcom money,@amt1 money,@bankamt1 money,@bankamt2 money,@transfertype varchar(50)        
 --retriving bank commision        
 if @paymenttype='bank transfer'        
 begin        
  select @transfertype=agentbranchdetail.transfertype,        
   @bankamt1= case transfertype when 'fax' then forfax1         
   when 'tt' then fortt1         
   when 'draft' then fordraft1 else 0 end,         
   @bankamt2=case transfertype when 'fax' then forfax2         
    when 'tt' then fortt2         
    when 'draft' then fordraft2 else 0 end ,@amt1=amt1,        
    @payoutcomm=imebanktransfer        
   from agentbranchdetail  with (nolock) inner join bankcommissionrates         
   on agentbranchdetail.agentcode = bankcommissionrates.agent_code         
   where agentbranchdetail.agent_branch_code=@rbankid      
        
  if @totalroundamt >= @amt1        
  begin        
   set @bankcom=@bankamt1        
  end        
  else        
  begin        
   set  @bankcom=@bankamt2         
  end        
 end        
 else        
 begin        
    set  @bankcom=0        
    set @payoutcomm=0        
    set @transfertype='CashPay'        
 end        
        
 -- customer detail ###################        
if @payoutcomm is not null        
 set @totalroundamt=@totalroundamt-@payoutcomm        
        
 if  exists (select customerid from customerdetail  with (nolock) where senderpassport=@senderpassport)        
 begin        
   select @customerid=customerid from customerdetail  with (nolock)  where senderpassport=@senderpassport        
   set @customer_type='u'        
 end        
      
 declare @cust_sno bigint        
 if @customer_type='i'        
 begin        
  set @cust_sno= ident_current('customerdetail')+1        
        
   set @customerid =cast(@cust_sno as varchar)        
        
  --new customer        
  insert into customerdetail( customerid, sendername, senderaddress, senderphoneno,  sendercity, sendercountry,         
  senderemail, sendercompany, senderpassport, sendervisa, receivername, receiveraddress, receiverphone,        
    receivercity, receivercountry, salary_earn,relation,sendermobile,receivermobile,        
  sendernativecountry,trn_date,trn_amt,senderFax,ReceiverIDDescription,        
  ReceiverID,receiverID_placeOfIssue,mileage_earn,        
  source_of_income,reason_for_remittance,reg_agent_id,c2c_receiver_code,ID_Issue_date,Date_of_Birth,SSN_Card_ID,picture_id_type)         
  values(@customerid,@sendername,@senderaddress,@senderphoneno,@sendercity,@sendercountry,        
  @senderemail,@sendercompany,@senderpassport, @sendervisa, @receivername, @receiveraddress, @receiverphone,        
    @receivercity, @receivercountry, @sendersalary,@receiverrelation,@sendermobile,@receivermobile,        
  @sender_native_country,@gmtdate,@paidamt,@txtsPassport_type,@ReceiverIDDescription,        
  @ReceiverID,@receiverID_placeOfIssue,@mileage_earn,@source_of_income,        
  @reason_for_remittance,@agentid,@c2c_receiver_code,@ID_Issue_date,@Date_of_Birth,@SSN_Card_ID,@PictureIdType)        
 end        
 else        
 begin         
  select @cust_sno=sno from customerdetail  with (nolock) where customerid=@customerid        
  -- update customer        
  update customerdetail set sendername=@sendername, senderaddress=@senderaddress,         
  senderphoneno=@senderphoneno, sendercity=@sendercity, sendercountry=@sendercountry,        
   senderemail=@senderemail, sendercompany=@sendercompany, senderpassport=@senderpassport, sendervisa=@sendervisa,        
   receivername=@receivername, receiveraddress=@receiveraddress, receiverphone=@receiverphone,         
  receivercity=@receivercity, receivercountry=@receivercountry,        
  salary_earn=@sendersalary,relation=@receiverrelation,sendermobile=@sendermobile,        
  receivermobile=@receivermobile, sendernativecountry=@sender_native_country,         
  trn_amt=case when convert(varchar, trn_date,102)=convert(varchar, getdate(),102)        
  then isNUll(trn_amt,0)+@paidamt else @paidamt end,        
   trn_date=@gmtdate,        
  senderFax=@txtsPassport_type,        
  ReceiverIDDescription=@ReceiverIDDescription,        
  ReceiverID=@ReceiverID,        
  receiverID_placeOfIssue=@receiverID_placeOfIssue,        
  mileage_earn=isNull(mileage_earn,0)+@mileage_earn,        
  source_of_income=@source_of_income,        
  reason_for_remittance=@reason_for_remittance,        
  c2c_receiver_code=@c2c_receiver_code ,      
  ID_Issue_date=@ID_Issue_date,      
  Date_of_Birth=@Date_of_Birth,      
  SSN_Card_ID=@SSN_Card_ID,
  picture_id_type= @PictureIdType      
  where sno=@cust_sno        
 end        
         
 if @payoutcomm is null        
  set @payoutcomm=0        
        
------------FX Sharing calc-------------------------        
DECLARE @send_share float,@payout_fx_share float,@Head_fx_share float,@check_agent_ex_gain money        
        
if @agent_settlement_rate=@today_dollar_rate        
 set @agent_ex_gain=0        
        
set @check_agent_ex_gain=((@agent_settlement_rate-@today_dollar_rate)* (@paidamt - @scharge))/@agent_settlement_rate        
        
--if cast(round(round(@agent_ex_gain,3),0) as money)<> cast(round(@check_agent_ex_gain,0) as money)        
if (@check_agent_ex_gain-@agent_ex_gain) > 0.5        
begin        
 select 'ERROR','5010',cast(round(round(@agent_ex_gain,2),0)  as varchar) + 'Session Expired, Please re-do transaction'+        
cast(round(@check_agent_ex_gain,0) as varchar)        
 return        
end        
-----------end FX Sharing---------------        
        
begin transaction
	declare @tranno bigint,@dot datetime ,@dottime varchar(20),@rnd_id varchar(4),@rnd_id1 varchar(4),@trannoref bigint,@refno_seed varchar(20)

	set @dot=convert(varchar,dbo.getDateHO(getutcdate()),101)
	set @dottime=convert(varchar,dbo.getDateHO(getutcdate()),108)

	SET @rnd_id=left(abs(checksum(newid())),2)
	SET @rnd_id1=left(abs(checksum(newid())),2)

	set @tranno=ident_current('moneysend') + 1
	set @trannoref=ident_current('tbl_refno')+1
	-------------------------
	declare @process_id varchar(100)
	set @process_id=left(cast(abs(CHECKSUM(newid())) as varchar),6)
	set @refno_seed =[dbo].[FNARefno](@trannoref, @process_id)
	---------------------------------
	
	set @refno='11'+ left(@rnd_id,1)+left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) + + left(@rnd_id,1)
    
 if @allow_exrate_change is null        
  --set @today_dollar_rate=@agent_settlement_rate        
        
 declare @confirmDate datetime ,@approved_by varchar(50),@process_transStatus VARCHAR(50)      
         
 SET @process_transStatus='Staging'      
 if @transstatus='Payment'        
 begin        
 set @confirmDate=@gmtdate        
 set @approved_by=@sempid        
 end        
 declare @enc_refno varchar(50)        
 set @enc_refno=dbo.encryptdb(@refno)        
      
INSERT tbl_refno(refno)        
VALUES(@enc_refno)       
      
       
 if exists(select tranno from moneysend_arch1 WITH (NOLOCK) where refno=@enc_refno)        
 begin        
  select 'ERROR','1004','Please try it again!!!'        
  rollback transaction        
  return        
 end        
        
 set @dollar_amt=@paidamt/@exchangerate        
 insert moneysend( refno, agentid, agentname, branch_code, branch, customerid,         
        sendername, senderaddress, senderphoneno, sendersalary,  sendercity,         
                      sendercountry, senderemail, sendercompany, senderpassport, sendervisa, receivername, receiveraddress, receiverphone,          
                      receivercity, receivercountry, receiverrelation,   dot, dottime, paidamt, paidctype, receiveamt, receivectype,         
                      exchangerate, today_dollar_rate, dollar_amt, scharge,           
                        senderbankvoucherno,  paymenttype, rbankid, rbankname, rbankbranch, rbankacno,         
                      rbankactype, othercharge, transstatus, status, sempid,  imecommission, bankcommission, totalroundamt, transfertype,          
                      sendercommission,   receiveagentid, send_mode,local_dot,sender_mobile,receiver_mobile,sendernativecountry,        
 ip_address, agent_dollar_rate, ho_dollar_rate, bonus_amt, request_for_new_account,digital_id_sender,        
 expected_payoutagentid,bonus_value_amount,bonus_type,bonus_on,ben_bank_id,ben_bank_name,paid_agent_id,        
 ReciverMessage,send_sms,agent_settlement_rate,agent_ex_gain,agent_receiverSCommission,        
 confirmDate,approve_by,customer_sno,senderFax,ReceiverIDDescription,        
 receiverID,TestQuestion,receiverID_placeOfIssue,mileage_earn,source_of_income,        
 reason_for_remittance,payout_settle_usd,c2c_receiver_code,c2c_secure_pwd,ofac_list,        
 ho_cost_send_rate ,        
 ho_premium_send_rate ,        
 ho_premium_payout_rate ,        
 agent_customer_diff_value ,        
 agent_sending_rate_margin ,        
 agent_payout_rate_margin ,        
 agent_sending_cust_exchangerate ,        
 agent_payout_agent_cust_rate ,        
 ho_exrate_applied_type,      
ID_Issue_date,Date_of_Birth,SSN_Card_ID ,picture_id_type,customer_category_id     
 )        
         
 values(@enc_refno, @agentid, @agentname, @branch_code, @branch, @customerid,         
  upper(@sendername), @senderaddress, @senderphoneno, @sendersalary,  @sendercity,         
                      @sendercountry, @senderemail, @sendercompany, @senderpassport, @sendervisa,         
  upper(@receivername), @receiveraddress, @receiverphone,          
                      @receivercity, @receivercountry, @receiverrelation,@dot , @dottime,         
  @paidamt, @paidctype, @receiveamt, @receivectype,         
                      @exchangerate, @today_dollar_rate, @dollar_amt, @scharge,         
  @cash_voucher_id,          
  @paymenttype, @rbankid, @rbankname, @rBankBranch, @rbankacno,@rbankactype,         
  @othercharge, @process_transStatus, 'Un-Paid', @sempid,  @payoutcomm, @bankcom, @totalroundamt, @transfertype,          
                      @sendercommission, @receiveagentid, @send_mode,@gmtdate,@sendermobile,@receivermobile,@sender_native_country,        
 @ip_address, @agent_dollar_rate, @ho_dollar_rate, @bonus_amt, @request_new_account,        
 @digital_id_sender,@PartnerAgentID,@bonus_value_amt,@bonus_type,@bonus_on,@ext_bank_id,@ben_bank_name,@payout_agent_id,        
 @ReciverMessage,@send_sms,@agent_settlement_rate,@agent_ex_gain,        
 @agent_receiverSCommission,@confirmDate,@approved_by,@cust_sno,@txtsPassport_type,        
 @ReceiverIDDescription,@receiverID,@TRN_Remarks,@receiverID_placeOfIssue,        
 @mileage_earn,@source_of_income,@reason_for_remittance,@payout_settle_usd,@c2c_receiver_code,@c2c_secure_pwd,@ofac_list,        
 @ho_cost_send_rate ,        
 @ho_premium_send_rate ,        
 @ho_premium_payout_rate ,        
 @agent_customer_diff_value ,        
 @agent_sending_rate_margin ,        
 @agent_payout_rate_margin ,        
 @agent_sending_cust_exchangerate ,        
 @agent_payout_agent_cust_rate ,        
 @ho_exrate_applied_type   ,      
 @ID_Issue_date,@Date_of_Birth,@SSN_Card_ID ,@PictureIdType ,@customer_category_id     
)        
 set @tranno=@@identity        
        
       
         
  --NPJKJJJLKKK           
 --set @tranno=@@identity   dbo.encryptdb(@refno)        
if @bonus_amt is not null and @bonus_amt > 0         
 begin        
  insert transactionNotes(refno,comments,datePosted,postedby,uploadBy,notetype,tranno)        
  values(@enc_refno,'Bonus Gain:'+cast(@bonus_amt as varchar),@gmtdate,@sempid,'S',0,@tranno)        
        
 end        
 declare @branch_bank_code int        
        
 select @branch_bank_code=branch_bank_code from agentbranchdetail  with (nolock) where agent_branch_code=@branch_code        
        
        
 insert deposit_detail(bankcode,deposit_detail1,deposit_detail2,amtpaid,depositdot,tranno,pending_id,bank_serial_no)        
 select bankcode,deposit_detail1,deposit_detail2,amtpaid,depositdot,@tranno,pending_id,        
 (select isNull(max(bank_serial_no),@branch_bank_code)+1         
 from deposit_detail d  with (nolock) join moneysend m  with (nolock) on d.tranno=m.tranno         
 where bankCode=t.bankCode and         
 convert(varchar,depositDot,102)=convert(varchar,t.depositdot,102)         
  and m.branch_code=@branch_code and m.transStatus not in ('cancel')) SerialID        
  from session_deposit_log t   with (nolock)       
 where session_id=@session_id         
 and convert(varchar,update_ts,102)=convert(varchar,getdate(),102)        
         
      
 -- agent current balance        
 update agentdetail set currentbalance=ISNULL(currentbalance,0)+(@paidamt-(@sendercommission+isNull(@agent_ex_gain,0))),         
 currentcommission=ISNULL(currentcommission,0) + @sendercommission where agentcode=@agentid        
        
 --UPDATING PAYOUT AGNENT BALANCE START        
  if @payout_agent_id IS NOT NULL        
  begin        
  update agentdetail set payout_agent_balance=isNull(payout_agent_balance,0)-@totalroundamt where agentcode=@PartnerAgentID        
  end        
 --- Branch wise Limit Enabled        
 if @branch_limit_enable>=0         
 begin        
  update agentbranchdetail set current_branch_limit=ISNULL(current_branch_limit,0)+@paidamt        
  where agent_branch_code=@branch_code        
 end        
 --UPDATING PAYOUT AGNENT BALANCE END        
 if @send_mode='v'        
 begin        
  update cash_collected set tranno=@tranno        
  from cash_collected v ,agentbranchdetail b         
  where v.branch_id=b.agent_branch_code         
  and cash_id=@cash_voucher_id         
  and collected_date=cast(@cash_date as datetime)         
  and branch_id=@branch_code        
 end        
 else if @send_mode='s' and @cash_ledger_id is not null  and         
 exists (select bankcode from session_deposit_log  with (nolock) where bankcode=@cash_ledger_id and session_id=@session_id )  -- BANK DEPOSIT WITH CASH ID        
 begin        
  update cash_collected set tranno=@tranno        
  from cash_collected c,session_deposit_log s,agentbranchdetail b         
  where  isNumeric(s.deposit_detail2)=1 and  c.cash_id=s.deposit_detail2         
  and c.branch_id=b.agent_branch_code         
  and collected_date=cast(@cash_date as datetime)        
  and c.branch_id=@branch_code and s.bankcode=@cash_ledger_id        
  and s.session_id=@session_id         
 end        
         
  update pendingtransaction        
  set bankcode=t.bankcode,        
  deposit_detail1=t.deposit_detail1,        
  deposit_detail2=t.deposit_detail2,        
  depositdot=t.depositdot,        
  sendername=@refno,        
  confirmdate=@gmtdate,        
  confirmby=@sempid,        
  pending='n'        
  from pendingtransaction p, session_deposit_log t        
  where p.sno=t.pending_id and t.session_id=@session_id         
  and convert(varchar,t.update_ts,102)=convert(varchar,getdate(),102)        
  and p.pending='y'        
          
 delete session_table where session_id=@session_id         
        
--Passport Number for Limit checking        
if @senderpassport is not null        
begin        
  if exists(select sno from customer_trans_limit  with (nolock) where customer_passport=@senderpassport and customer_name=@senderName        
  and customer_id_type=@txtsPassport_type)        
  update customer_trans_limit set paidAmt=paidAmt + @paidAmt,        
  nos_of_txn=isNull(nos_of_txn,0)+1,update_ts=getDate()        
  where customer_passport=@senderpassport and customer_name=@senderName and customer_id_type=@txtsPassport_type        
 else        
  insert customer_trans_limit(customer_passport,paidAmt,trans_date,agent_id,update_ts,nos_of_txn,customer_name,customer_id_type)        
  values(@senderpassport,@paidAmt,convert(varchar,@gmtdate,101),@agentid,getdate(),1,@senderName,@txtsPassport_type)        
        
end        
--Passport Number for Limit checking        
      
exec spa_ComplianceCheck_Job @tranno,@transstatus      
      
select 'SUCCESS',@refno,@customerid,@tranno TRNNo        
commit transaction        
end        
        
end try        
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
           ,[IP]        
           ,[error_date])        
 select -1,@desc,'MoneySend','SQL',@desc,'SQL','SP',@digital_id_sender,getdate()        
 select 'ERROR','1050','Error Please try again'        
        
end catch

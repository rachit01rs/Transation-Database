IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_moneysend_main]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_moneysend_main]
GO

/****** Object:  StoredProcedure [dbo].[spa_moneysend_main]    Script Date: 09/01/2013 23:52:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--spa_moneysend_main 'i','93523','10100500','111','Anoop','Teku','11111','23444','KTM','aanoop@inficare.net','Ktm','12333','2010-03-04','Saiyon Sherchan','Bafal','44444','Kathmandu','Bangladesh','Son',2000,38933.928,19.6636,598.587333892015,20,NULL,'Cash     
--Pay',NULL,NULL,NULL,NULL,'shivakhanal','31800000','s',38933.928,NULL,'3/3/2010 1:29:58 AM','222','55555','32400378_F1C2B036_AAA0_467B_B46F_5488D5541E14','Hold','i','Nepal',Null,0,'127.0.0.1',0,NULL,NULL,':',5,'f','s',NULL,NULL,'y',0,'Passport','CITIZEN         
--','1333',NULL,NULL,'Rupendehi','SALARY','INTEREST ON LOANS',NULL,NULL,NULL,'3333','01/03/2008','SSNO1','03/01/1975',NULL              
CREATE procedure [dbo].[spa_moneysend_main]              
@flag char(1),              
@refno varchar(15),              
@branch_code varchar(50)=null,              
@customerid varchar(50)=null,              
@sendername varchar(50)=null,              
@senderaddress varchar(150)=null, -- contains '|' pipe sign seperated value (House no.|Cross street)             
@senderphoneno varchar(50)=null,              
@sendersalary varchar(100)=null,              
@sendercity varchar(100)=null,              
@senderemail varchar(100)=null,              
@sendercompany varchar(150)=null, -- contains '|' pipe sign seperated value (street/Ave|Apt/Suit No.)              
@senderpassport varchar(50)=null,              
@sendervisa varchar(50)=null,              
@receivername varchar(50)=null,              
@receiveraddress varchar(150)=null,              
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
@sender_fax_no varchar(50)=null,              
@ID_Issue_date varchar(20)=null,              
@SSN_Card_ID varchar(50)=null,              
@Date_of_Birth varchar(20)=NULL,           
@Sender_State varchar(100)=NULL,              
@compliance_flag varchar(1)=NULL,              
@compliance_sys_msg varchar(200)=NULL,              
@customer_sno_id varchar(10)=NUll,              
@receiver_sno varchar(10)=NULL ,      
@customer_category_id int=NULL,    
@senderOccupation VARCHAR(150)=NULL ,            
@FreeSMS CHAR(1)=NULL,        
@PictureIdType VARCHAR(50)=NULL,
@agent_limit_exceed char(1)=NULL             
-----              
as              
BEGIN TRY              
declare @agentid varchar(50),@agentname varchar(150),@branch varchar(150),@sendercountry varchar(100),@paidctype varchar(50)              
declare @cash_ledger_id int,@allow_exrate_change char(1)              
declare @ext_bank_id varchar(50),@ben_bank_name varchar(100),@exRateBy varchar(50),@sChargeBy varchar(50),@gmtdate datetime,@limit_date DATETIME,  
  @ben_bank_branch_id VARCHAR(50)              
              
if (select isNUll(sum(amtpaid),-1) from session_deposit_log WITH(NOLOCK) where session_id=@session_id) <> @paidamt and @send_mode in ('s','v')              
begin              
 select 'ERROR','1009','Error in Deposit Detail, please try send transaction from main menu'              
 return              
end        
              
if @paymenttype is NULL                
begin                  
 select 'ERROR','1011','Error No PaymentType Selected'                  
 return                  
end                
              
DECLARE @mileage_enable varchar(50),@mileage_earn int,@check_cust_per_date char(1),              
@limit_per_day money,@branch_limit_enable money              
              
-- SENDING AGENT DETAIL              
select @agentid=a.agentcode,@agentname=a.companyName,@branch=b.branch,@sendercountry=a.country,@paidctype=currencyType,              
@allow_exrate_change=allow_exrate_change,@cash_ledger_id=cash_ledger_id,@exRateBy=exRateBy,@sChargeBy=sChargeBy,              
@gmtdate=dbo.FNADateUTC(isNull(gmt_value,-300),GETUTCDATE()),@limit_date=trn_limit_date,              
@mileage_enable=f.mileage_enable,@check_cust_per_date=limit_for_customer,              
@limit_per_day=limitPerTran,@branch_limit_enable=isNull(b.branch_limit,-1)              
from agentdetail a WITH(NOLOCK) join agentbranchdetail b WITH(NOLOCK) on a.agentcode=b.agentcode              
join agent_function f WITH(NOLOCK) on agent_id=a.agentcode              
where agent_branch_code=@branch_code              
              
IF @cash_date IS null              
SET @cash_date=@gmtdate              
              
declare @sendercommission float,@agent_settlement_rate money,@exchangerate money,              
@agent_receiverSCommission money,@round_by int,@new_scharge money,@isSlab varchar(10),@checkReceiveCType VARCHAR(50)              
              
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
 @ho_exrate_applied_type varchar(20)              
              
if @exRateBy in('agent')              
begin              
 IF EXISTS(select 'x' FROM agentpayout_CurrencyRate_Branch WITH(NOLOCK) WHERE agentId=@agentid               
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
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),              
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),              
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),              
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),              
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),              
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),              
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),              
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),              
    @ho_exrate_applied_type='payoutbranchwise',      
    @checkReceiveCType=x.receiveCType              
    from agentpayout_CurrencyRate_Branch x WITH(NOLOCK)               
    where x.agentId=@agentid and agent_branch_code=@branch_code  and payout_agent_id=@payout_agent_id         
          
 end              
 ELSE IF EXISTS(select 'x' FROM agentpayout_CurrencyRate WITH(NOLOCK) WHERE agentId=@agentid              
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
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),              
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),              
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),              
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),              
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),              
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),              
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),              
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),              
    @ho_exrate_applied_type='payoutwise' ,      
    @checkReceiveCType=x.receiveCType             
    from agentpayout_CurrencyRate x WITH(NOLOCK)               
    where x.agentId=@agentid and payout_agent_id=@payout_agent_id              
                
 end              
 ELSE IF EXISTS(select 'x' FROM agent_branch_rate WITH(NOLOCK) WHERE agentId=@agentid               
 AND agent_branch_code=@branch_code AND receiveCountry=@receivercountry)              
 begin              
  PRINT 'insert Agent wise Country Branch'              
   select               
    @ho_dollar_rate=x.DollarRate,              
    @agent_settlement_rate=x.NPRRate,              
    @exchangerate=x.exchangerate,              
    @today_dollar_rate=x.customer_rate,              
    @round_by=x.qtyCurrency,              
    @isSlab=NULL,              
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),              
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),              
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),              
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),              
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),              
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),              
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),              
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),              
    @ho_exrate_applied_type='branchwise' ,      
    @checkReceiveCType=x.receiveCType             
    from agent_branch_rate x  WITH(NOLOCK)             
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
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),              
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),              
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),              
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),              
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),              
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),              
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),              
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),              
    @ho_exrate_applied_type='countrywise',      
    @checkReceiveCType=x.receiveCType              
    from agentCurrencyRate x WITH(NOLOCK)               
    where x.agentId=@agentid and receiveCountry=@receivercountry              
  end              
end              
              
------------############# new added  Service Charge              
create table #temp_charge(slab_id int,              
min_amount money,              
max_amount money,              
service_charge money,              
send_commission money,paid_commission money              
)              
insert into #temp_charge(slab_id,min_amount,max_amount,service_charge,send_commission,paid_commission)              
exec spa_GetServiceCharge @agentid,@payout_agent_id,@paidamt,@paymenttype,@branch_code              
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
set @totalroundamt=round(@receiveamt,0)                            
--set @totalroundamt=round(@receiveamt,@round_by,1)              
--set @totalroundamt=floor(@receiveamt)              
              
if @sendercommission is null              
 set @sendercommission=0              
                  
declare @rbankname varchar(150),@rbankbranch varchar(150),@receiveagentid varchar(50),      
@receivectype varchar(50),@payout_country varchar(100),@branch_group varchar(500)              
              
if @rbankid is not null              
begin              
 select @receiveagentid=a.agentcode,@rbankname=a.companyName,@rBankBranch=b.branch,      
 @branch_group=b.branch_group,@receivectype=a.currencyType,@payout_country=a.country   from              
 agentdetail a WITH(NOLOCK) join agentbranchdetail b WITH(NOLOCK) on a.agentcode=b.agentcode              
 where agent_branch_code=@rbankid              
end              
else              
begin              
 select @receiveagentid=agentcode,@rbankname=companyName,@receivectype=currencyType,@payout_country=country       
 from agentdetail WITH(NOLOCK) where agentcode=@payout_agent_id              
end              
       
IF isNull(@checkReceiveCType,'c')<>isNUll(@receivectype,'a')       
BEGIN      
 select 'ERROR','3010','Exchange rate define not valid'              
 return      
END              
if @rbankid is not null and @paymenttype='bank transfer'              
begin              
 if exists(select service_charge_id from Agent_Wise_charge WITH(NOLOCK) where sending_agent_code=@agentid and               
    agentcode=@receiveagentid and paymentType='n' and branch_group=@branch_group)              
 begin              
  if @request_new_account='y'              
  begin              
   set @new_scharge=0              
   SET @sendercommission=0              
   SET @agent_receiverSCommission=0              
  end              
--  else              
--  begin              
--   select @new_scharge=charge_amount,@sendercommission=isNull(send_comm,0),              
--   @agent_receiverSCommission=isNULL(pay_comm,0)              
--   from Agent_Wise_charge where sending_agent_code=@agentid and               
--   agentcode=@receiveagentid and paymentType='d' and branch_group=@branch_group              
--   and @paidamt between min_amt and max_amt              
--  end              
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
 return            end              
if @ben_bank_id is not null              
begin              
 select @ext_bank_id=external_bank_id,@ben_bank_name=bank_name from commercial_bank WITH(NOLOCK) where commercial_id=@ben_bank_id              
 if @ReciverMessage is not NULL              
  set @ReciverMessage=@ReciverMessage +'\'+@ben_bank_name              
 else              
  set @ReciverMessage=@ben_bank_name              
end    
--- ADDED FOR MAPPING Branch of NEPAL (ACCOUNT DEPOSIT TO OTHER)  
 IF EXISTS(SELECT 'x' FROM dbo.commercial_bank c WITH(NOLOCK) 
 JOIN dbo.commercial_bank_branch b WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id  
 WHERE b.IFSC_Code=@rbankactype AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id)  
 BEGIN  
  SELECT @rbankactype=b.BranchName,@ben_bank_branch_id=b.IFSC_Code FROM dbo.commercial_bank c WITH(NOLOCK)  
 JOIN dbo.commercial_bank_branch b WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id  
 WHERE b.IFSC_Code=@rbankactype AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id  
 END  
---- END          
---- IFSC codes FOR NEFT AND RTGS ----        
if @paymenttype='NEFT' AND @c2c_receiver_code is not null        
begin        
 select @ben_bank_name=Bankname,@rbankbranch=Bankname+', '+BranchName  from tbl_ifsc_code WITH(NOLOCK) where IFSC_Code=@c2c_receiver_code      
end        
if @paymenttype='RTGS' AND @c2c_receiver_code is not null       
begin      
 select @ben_bank_name=Bankname,@rbankbranch=Bankname+', '+BranchName,@rbankactype=BranchName  from tbl_ifsc_code WITH(NOLOCK) where IFSC_Code=@c2c_receiver_code      
end       
--- end of IFSC codes -----              
------------Retrive Payout Settlement USD Rate ----------------              
declare @payout_settle_usd money              
select @payout_settle_usd=buyRate from Roster WITH(NOLOCK) where payoutagentid=@payout_agent_id              
if @payout_settle_usd is null              
 select @payout_settle_usd=buyRate from Roster WITH(NOLOCK) where country=@receivercountry and payoutagentid is null             
if @payout_settle_usd is null              
 set @payout_settle_usd=@ho_dollar_rate              
----------- end -----------------------------------------------              
              
------------Retrive Send Settlement USD Rate ----------------              
declare @send_settle_usd money              
select @send_settle_usd=sellRate from Roster WITH(NOLOCK) where payoutagentid=@agentid              
if @send_settle_usd is null              
 select @send_settle_usd=sellRate from Roster WITH(NOLOCK) where country=@sendercountry and payoutagentid is null            
if @send_settle_usd is null              
 set @send_settle_usd=@exchangerate              
----------- end -----------------------------------------------              
              
if @flag='i'              
begin              
              
 -- checking duplicate entry              
-- if exists (select  m.tranno from  moneysend m left outer join deposit_detail d               
-- on m.tranno=d.tranno where d.depositdot in (select depositdot from session_deposit_log where session_id=@session_id )              
--  and d.amtpaid in (select amtpaid from session_deposit_log where session_id=@session_id )               
-- and d.bankcode in(select bankcode from session_deposit_log where session_id=@session_id ) and m.sendername=@sendername)              
-- begin              
--                
--  select 'ERROR','1001','duplicate transaction!!!'              
--  return              
-- end              
 if @send_mode='v'              
 begin              
  if exists(select tranno from  cash_collected WITH(NOLOCK)              
   where cash_id=@cash_voucher_id and               
   collected_date=cast(@cash_date as datetime)              
   and branch_id=@branch_code and tranno is not null)              
  begin              
   select 'ERROR','4001','Error WITH Cash ID:'+ @cash_voucher_id +', TXN NOT saved!!!'              
   return              
  END              
  if exists(select cash_id from  cash_collected  WITH(NOLOCK)             
   where cash_id=@cash_voucher_id and collected_date=cast(@cash_date as datetime)              
   and branch_id=@branch_code and status='cancel')              
  begin              
   select 'ERROR','4002','CASH Voucher: '+ @cash_voucher_id +' has been cancelled already!!!'              
   return              
  END              
  if NOT exists(select cash_id from  cash_collected WITH(NOLOCK)               
   where cash_id=@cash_voucher_id and collected_date=cast(@cash_date as datetime)              
   and branch_id=@branch_code and session_id=@session_id)              
  begin              
   select 'ERROR','4003','Cash ID Session Doesn''t matched !!!'              
   return              
  END              
 end              
 else if @send_mode='s' and @cash_ledger_id is not null               
 and exists (select bankcode from session_deposit_log WITH(NOLOCK) where bankcode=@cash_ledger_id and session_id=@session_id )  -- BANK DEPOSIT WITH CASH ID              
 begin              
  if NOT exists(select cash_sno from  cash_collected c WITH(NOLOCK) join               
session_deposit_log l WITH(NOLOCK) on c.cash_id=l.deposit_detail2 and l.session_id=c.session_id              
and c.collected_date=cast(@cash_date as datetime) and c.branch_id=@branch_code              
and bankcode=@cash_ledger_id where l.session_id=@session_id)              
  begin              
   select 'ERROR','4005','Cash ID Session Doesn''t matched !!!'              
   return              
  END              
  if exists(select cash_sno from  cash_collected c WITH(NOLOCK) join               
session_deposit_log l WITH(NOLOCK) on c.cash_id=l.deposit_detail2               
and c.collected_date=cast(@cash_date as datetime) and c.branch_id=@branch_code              
and bankcode=@cash_ledger_id where l.session_id=@session_id and c.status='cancel')              
  begin              
   select 'ERROR','4004','CASH Voucher: '+ @cash_voucher_id +' has been cancelled already!!!'              
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
   from agentbranchdetail WITH(NOLOCK) inner join bankcommissionrates WITH(NOLOCK)              
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
  --retriving cash commision              
  set  @bankcom=0              
  --set @rbankname=NULL              
  set @payoutcomm=0              
  --set @rbankbranch=NULL              
  set @transfertype='CashPay'              
 end         
              
 -- customer detail ###################              
 if @payoutcomm is not null              
  set @totalroundamt=@totalroundamt-@payoutcomm              
begin transaction              
               
 declare @cust_sno bigint              
               
 if @customer_sno_id='-1' and @customer_type='i'              
 begin                
  set @cust_sno= ident_current('customerdetail')+1              
  set @customerid=cast(@cust_sno as varchar)              
 end              
 if @customer_sno_id='-1' and @customer_type is null              
 begin              
  set @cust_sno= ident_current('customerdetail')+1              
  set @customer_type='i'              
 end              
 if @customer_sno_id is NULL              
 begin              
  set @cust_sno= ident_current('customerdetail')+1              
 end              
 if @customer_type='i'              
 begin              
                
  if  exists (select customerid from customerdetail WITH(NOLOCK) where customerid=@customerid)              
  begin              
   set @customerid = upper(left(ltrim(@sendername), 1)) + upper(left(ltrim(@receivername), 1)) + cast(@cust_sno as varchar)              
  end  
  -- checking duplicate entry              
 if exists (SELECT 'x' FROM customerDetail  WITH(NOLOCK) 
 WHERE senderpassport=@senderpassport AND senderFax=@txtsPassport_type
		AND CASE WHEN @txtsPassport_type = 'passport'
		THEN SenderNativeCountry
		ELSE SenderCountry
		END = CASE WHEN @txtsPassport_type = 'passport'
		THEN @sender_native_country
		ELSE @SenderCountry
		END )              
 begin              
                
  select 'ERROR','1001','duplicate ID Type and ID value!!!'              
  return              
 end             
  if @customerid is NULL               
   set @customerid=cast(@cust_sno as varchar)              
  --new customer              
  insert into customerdetail( customerid, sendername, senderaddress, senderphoneno,  sendercity, sendercountry,               
  senderemail, sendercompany, senderpassport, sendervisa, receivername, receiveraddress, receiverphone,              
    receivercity, receivercountry, salary_earn,relation,sendermobile,receivermobile,        sendernativecountry,trn_date,trn_amt,senderFax,ReceiverIDDescription,              
  ReceiverID,receiverID_placeOfIssue,mileage_earn,              
  source_of_income,reason_for_remittance,reg_agent_id,c2c_receiver_code,sender_fax_no,      
ID_Issue_date,SSN_Card_ID,Date_of_Birth,Sender_State,create_ts,sender_occupation,FreeSMS,picture_id_type)               
  values(@customerid,@sendername,@senderaddress,@senderphoneno,@sendercity,@sendercountry,              
  @senderemail,@sendercompany,@senderpassport, @sendervisa, @receivername, @receiveraddress, @receiverphone,              
    @receivercity, @receivercountry, @sendersalary,@receiverrelation,@sendermobile,@receivermobile,              
  @sender_native_country,@gmtdate,@paidamt,@txtsPassport_type,@ReceiverIDDescription,              
  @ReceiverID,@receiverID_placeOfIssue,@mileage_earn,@source_of_income,              
  @reason_for_remittance,@agentid,@c2c_receiver_code,@sender_fax_no,@ID_Issue_date,      
@SSN_Card_ID,@Date_of_Birth,@Sender_State,getdate(),@senderOccupation,@FreeSMS,@PictureIdType)              
         SELECT @cust_sno=sno FROM customerDetail cd with (nolock) WHERE cd.CustomerId=@customerid       
                
 ------------------FOR MULTIPLE CUSTOMER INSERT START------------------------              
  insert into customerReceiverDetail(sender_sno,ReceiverName,ReceiverAddress,ReceiverPhone,ReceiverCity,              
  ReceiverCountry,ReceiverMobile,relation,ReceiverIDDescription,ReceiverID,create_ts,              
  create_by)                  
  values(@cust_sno,@receivername,@receiveraddress,@receiverphone,@receivercity,@receivercountry,                
  @receivermobile,@receiverrelation,@ReceiverIDDescription,@ReceiverID,getdate(),@sempid)              
 ------------------FOR MULTIPLE CUSTOMER INSERT END------------------------              
              
 end              
 else if @customerid is not null              
 begin   
 	DECLARE  @senderpassport_old VARCHAR(50), @txtsPassport_type_old  VARCHAR(50)       
  select @cust_sno=sno,@senderpassport_old=senderPassport,@txtsPassport_type_old=senderFax
    from customerdetail WITH(NOLOCK) where customerid=@customerid   
    IF     @senderpassport_old <>@senderpassport OR  @txtsPassport_type_old<>@txtsPassport_type 
    BEGIN
    	if exists (SELECT 'x' FROM customerDetail  WITH(NOLOCK) 
    	WHERE senderpassport=@senderpassport AND senderFax=@txtsPassport_type
    	AND CASE WHEN @txtsPassport_type = 'passport'
		THEN SenderNativeCountry
		ELSE SenderCountry
		END = CASE WHEN @txtsPassport_type = 'passport'
		THEN @sender_native_country
		ELSE @SenderCountry
		END )              
		 begin              
		                
			 select 'ERROR','1001','duplicate ID Type and ID value!!!'              
		  return              
		end  
    END
  -- update customer              
  if @cust_sno is not null              
   begin              
  update customerdetail set sendername=@sendername, senderaddress=@senderaddress,               
  senderphoneno=@senderphoneno, sendercity=@sendercity, sendercountry=@sendercountry,              
   senderemail=@senderemail, sendercompany=@sendercompany, senderpassport=@senderpassport, sendervisa=@sendervisa,              
   receivername=@receivername, receiveraddress=@receiveraddress, receiverphone=@receiverphone,               
  receivercity=@receivercity, receivercountry=@receivercountry,              
  salary_earn=@sendersalary,relation=@receiverrelation,sendermobile=@sendermobile,              
  receivermobile=@receivermobile, sendernativecountry=@sender_native_country,               
  trn_amt=@paidamt ,              
  trn_date=@gmtdate,              
  senderFax=@txtsPassport_type,              
  ReceiverIDDescription=@ReceiverIDDescription,              
  ReceiverID=@ReceiverID,              
  receiverID_placeOfIssue=@receiverID_placeOfIssue,              
  mileage_earn=isNull(mileage_earn,0)+@mileage_earn,              
  source_of_income=@source_of_income,              
  reason_for_remittance=@reason_for_remittance,              
  c2c_receiver_code=@c2c_receiver_code,              
  sender_fax_no=@sender_fax_no,ID_Issue_date=@ID_Issue_date,SSN_Card_ID=@SSN_Card_ID,              
  Date_of_Birth=@Date_of_Birth,Sender_State=@Sender_State,sender_occupation = @senderOccupation,  
  FreeSMS = @FreeSMS,update_ts=GETDATE(),picture_id_type=@PictureIdType              
  where sno=@cust_sno              
 ------------------FOR MULTIPLE CUSTOMER INSERT START------------------------              
  if @receiver_sno is NULL              
  begin              
   insert into customerReceiverDetail(sender_sno,ReceiverName,ReceiverAddress,ReceiverPhone,ReceiverCity,              
   ReceiverCountry,ReceiverMobile,relation,ReceiverIDDescription,ReceiverID,create_ts,              
   create_by)                  
   values(@cust_sno,@receivername,@receiveraddress,@receiverphone,@receivercity,@receivercountry,                
   @receivermobile,@receiverrelation,@ReceiverIDDescription,@ReceiverID,getdate(),@sempid)              
  end              
  else              
  begin              
   update customerReceiverDetail set ReceiverName=@receivername,ReceiverAddress=@receiveraddress,              
   ReceiverPhone=@receiverphone,ReceiverCity=@receivercity,ReceiverCountry=@receivercountry,              
   ReceiverMobile=@receivermobile,ReceiverID=@ReceiverID,              
   ReceiverIDDescription=@ReceiverIDDescription,update_ts=getdate(),update_by=@sempid,              
   relation=@receiverrelation where sno=@receiver_sno               
  end            
               
 ------------------FOR MULTIPLE CUSTOMER INSERT END------------------------              
 end              
 end              
               
 if @payoutcomm is null              
  set @payoutcomm=0              
              
------------FX Sharing calc-------------------------              
DECLARE @send_share float,@payout_fx_share float,@Head_fx_share float,@check_agent_ex_gain money              
              
if @agent_settlement_rate=@today_dollar_rate              
 set @agent_ex_gain=0              
              
set @check_agent_ex_gain=((@agent_settlement_rate-@today_dollar_rate)* (@paidamt - @scharge))/@agent_settlement_rate              
   
--if cast(round(round(@agent_ex_gain,3),0) as money)<> cast(round(@check_agent_ex_gain,0) as money)    
set @agent_ex_gain=round(@agent_ex_gain,2,0)                
set @check_agent_ex_gain=round(@check_agent_ex_gain,2,0)                          
if (@check_agent_ex_gain-@agent_ex_gain) > 5              
begin              
 select 'ERROR','5010',cast(round(round(@agent_ex_gain,2),0)  as varchar) + 'Session Expired , Please re-do transaction'+              
cast(round(@check_agent_ex_gain,0) as varchar)              
 return              
end              
-----------end FX Sharing---------------              
              
              
              
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
declare @check_muthoot varchar(50)      
select @check_muthoot=agentcode from tbl_integrated_agents WITH(NOLOCK) where agentName='Royal Exchange'      
      
 IF @payout_agent_id=@check_muthoot --- Muthoot      
 SET  @refno='36'+ left(@rnd_id,1)+left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) + + left(@rnd_id,1)      
 ELSE if @payout_agent_id='10000004' ---  MUSLIM COMMERCIAL BANK    
  set @refno='111'+ left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) + + left(@rnd_id,1)              
else  
 set @refno='11'+ left(@rnd_id,1)+left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) + + left(@rnd_id,1)              
              
 declare @confirmDate datetime ,@approved_by varchar(50)              
 if @transstatus='Payment'              
 begin              
  set @confirmDate=@gmtdate              
  set @approved_by=@sempid              
 end              
 declare @enc_refno varchar(50)              
 set @enc_refno=dbo.encryptdb(@refno)              
 if exists(select tranno from moneysend with (nolock) where refno=@enc_refno)              
 begin              
  select 'ERROR','1003','Please try it again!!!'              
  rollback transaction              
  return              
 end              
 if exists(select tranno from moneysend_arch1 WITH(NOLOCK) where refno=@enc_refno)              
 begin              
  select 'ERROR','1004','Please try it again!!!'              
  rollback transaction              
  return              
 end              
                
 set @dollar_amt=@paidamt/@exchangerate              
              
 if @dollar_amt>=3000 --and @compliance_flag is NULL              
 begin              
  set @compliance_flag='y'              
  --set @compliance_sys_msg='Large Volume Transaction Limit Exceeded'
  SET @compliance_sys_msg= case when @compliance_sys_msg is null then 'Large Volume Transaction Limit Exceeded'               
            else @compliance_sys_msg + '<br> Large Volume Transaction Limit Exceeded' End   
 end              
              
              
  DECLARE @duplicate_TXN VARCHAR(500)              
 SELECT TOP 1 @duplicate_TXN=Tranno  FROM moneysend WITH (NOLOCK) WHERE SenderName=RTRIM(LTRIM(@sendername))              
   AND ReceiverName=RTRIM(LTRIM(@receivername)) AND paidamt=@paidamt              
  AND agentid=@agentid              
  AND convert(varchar,local_DOT,102)=CONVERT(VARCHAR,@gmtdate,102)              
  And TransStatus not in ('Cancel')              
  ORDER BY tranno DESC               
                
 IF @duplicate_TXN IS NOT NULL              
 BEGIN               
  IF @transstatus='Payment'              
  BEGIN               
   select 'ERROR','2001','Similar Transaction Found'              
   rollback transaction              
   return              
  END              
  ELSE              
  BEGIN              
   SET @compliance_flag='y'              
   --SET @compliance_sys_msg='Duplicate Suspicious'               
  SET @compliance_sys_msg= case when @compliance_sys_msg is null then 'Duplicate Suspicious'               
            else @compliance_sys_msg + '<br> Duplicate Suspicious' End              
  END               
 END              
              
 if @customerid is NULL               
  set @cust_sno=NULL              
 --ADDED FOR INTEGRATED AGNET SAVE               
declare @status varchar(50)                
set @status='Un-Paid'                
if exists (select agentcode from tbl_integrated_agents WITH(NOLOCK) where agentcode=@payout_agent_id and isNULL(paymentType,@paymenttype)=@paymenttype)                
begin                
 set @status='Post'       
 if @compliance_flag ='y'                 
  set @transstatus='Compliance'       
if @ofac_list ='y'                 
  set @transstatus='OFAC'               
end                
--INTEGRATED AGENT END    
           
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
 sender_fax_no,ID_Issue_date,SSN_Card_ID,Date_of_Birth,Sender_State,              
 compliance_flag,compliance_sys_msg,agent_receiverCommission,payout_send_agent_id,customer_category_id,sender_occupation,ben_bank_branch_id,FreeSMS,picture_id_type,agent_limit_exceed            
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
  @othercharge, @transstatus, @status, @sempid,  @payoutcomm, @bankcom, @totalroundamt, @transfertype,                
                      @sendercommission, @receiveagentid, @send_mode,@gmtdate,@sendermobile,@receivermobile,@sender_native_country,              
 @ip_address, @agent_dollar_rate, @ho_dollar_rate, @bonus_amt, @request_new_account,              
 @digital_id_sender,@payout_agent_id,@bonus_value_amt,@bonus_type,@bonus_on,@ext_bank_id,@ben_bank_name,@payout_agent_id,              
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
 @ho_exrate_applied_type ,              
@sender_fax_no,@ID_Issue_date,@SSN_Card_ID,@Date_of_Birth,@Sender_State,              
@compliance_flag,@compliance_sys_msg,0, @payout_agent_id ,@customer_category_id,@senderOccupation,@ben_bank_branch_id,@FreeSMS,@PictureIdType,@agent_limit_exceed    
)                               
 set @tranno=@@identity              
              
INSERT tbl_refno(refno)              
VALUES(@enc_refno)              
               
  --NPJKJJJLKKK                 
 --set @tranno=@@identity   dbo.encryptdb(@refno)              
              
 declare @branch_bank_code int              
              
 select @branch_bank_code=branch_bank_code from agentbranchdetail WITH(NOLOCK) where agent_branch_code=@branch_code              
              
              
 insert deposit_detail(bankcode,deposit_detail1,deposit_detail2,amtpaid,depositdot,tranno,pending_id)              
 select bankcode,deposit_detail1,deposit_detail2,amtpaid,depositdot,@tranno,pending_id              
  from session_deposit_log t              
 where session_id=@session_id               
 and convert(varchar,update_ts,102)=convert(varchar,dbo.getDateHO(getutcdate()),102)              
              
 -- agent current balance              
 update agentdetail set currentbalance=ISNULL(currentbalance,0)+(@paidamt-(@sendercommission+isNull(@agent_ex_gain,0))),               
 currentcommission=ISNULL(currentcommission,0) + @sendercommission where agentcode=@agentid              
              
 --UPDATING PAYOUT AGNENT BALANCE START              
  if @payout_agent_id IS NOT NULL              
  begin              
   update agentdetail set payout_agent_balance=isNull(payout_agent_balance,0)-@totalroundamt where agentcode=@payout_agent_id              
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
  from cash_collected v WITH(NOLOCK) ,agentbranchdetail b WITH(NOLOCK)               
  where v.branch_id=b.agent_branch_code               
  and cash_id=@cash_voucher_id               
  and collected_date=cast(@cash_date as datetime)               
  and branch_id=@branch_code              
 end              
 else if @send_mode='s' and @cash_ledger_id is not null  and               
 exists (select bankcode from session_deposit_log WITH(NOLOCK) where bankcode=@cash_ledger_id and session_id=@session_id )  -- BANK DEPOSIT WITH CASH ID              
 begin              
  update cash_collected set tranno=@tranno              
  from cash_collected c WITH(NOLOCK),session_deposit_log s WITH(NOLOCK),agentbranchdetail b WITH(NOLOCK)              
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
  from pendingtransaction p WITH(NOLOCK), session_deposit_log t WITH(NOLOCK)             
  where p.sno=t.pending_id and t.session_id=@session_id               
  and convert(varchar,t.update_ts,102)=convert(varchar,dbo.getDateHO(getutcdate()),102)              
  and p.pending='y'              
                
 delete session_table where session_id=@session_id               
              
--Passport Number for Limit checking              
if @cust_sno is NOT NULL              
begin              
 if exists(select sno from customer_trans_limit WITH(NOLOCK) where customer_passport=@cust_sno)              
  update customer_trans_limit set paidAmt=paidAmt + @paidAmt,nos_of_txn=ISNULL(nos_of_txn,0)+1              
  where customer_passport=@cust_sno              
 else              
  insert customer_trans_limit(customer_passport,paidAmt,trans_date,agent_id,update_ts,nos_of_txn,customer_name)              
  values(@cust_sno,@paidAmt,convert(varchar,@gmtdate,101),@agentid,dbo.getDateHO(getutcdate()),1,@sendername)              
end              
--Passport Number for Limit checking              
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
 select -1,@desc,'spa_moneysend_main','SQL',@desc,'SQL','SP',@ip_address,dbo.getDateHO(getutcdate())              
 select 'ERROR','1050','Error Please try again'              
              
end catch 
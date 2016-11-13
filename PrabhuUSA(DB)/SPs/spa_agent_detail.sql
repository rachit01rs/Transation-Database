drop procedure [dbo].[spa_agent_detail]  
go 
--spa_agent_detail 'r','24400000'      
CREATE procedure [dbo].[spa_agent_detail]      
 @flag char(1),      
 @agentCode varchar(50)=NULL,      
 @agentPinCode varchar(50)=NULL,      
 @ContactName1 varchar(100)=NULL,      
 @Post1 varchar(100)=NULL,      
 @email1 varchar(100)=NULL,      
 @ContactName2 varchar(100)=NULL,      
 @Post2 varchar(100)=NULL,      
 @email2 varchar(100)=NULL,      
 @ContactName3 varchar(100)=NULL,      
 @Post3 varchar(50)=NULL,      
 @Email3 varchar(50)=NULL,      
 @ContactName4 varchar(50)=NULL,      
 @Post4 varchar(50)=NULL,      
 @Email4 varchar(50)=NULL,      
 @ContactName5 varchar(50)=NULL,      
 @Post5 varchar(50)=NULL,      
 @Email5 varchar(50)=NULL,      
 @CompanyName varchar(100)=NULL,      
 @LicNo varchar(50)=NULL,      
 @AgentType varchar(100)=NULL,      
 @Address varchar(100)=NULL,      
 @City varchar(50)=NULL,      
 @Country varchar(50)=NULL,      
 @Phone1 varchar(50)=NULL,      
 @Phone2 varchar(50)=NULL,      
 @Fax varchar(50)=NULL,      
 @Email varchar(50)=NULL,      
 @BankName varchar(100)=NULL,      
 @BankACNo varchar(50)=NULL,      
 @CurrentBalance money=NULL,      
 @CurrencyType varchar(50)=NULL,      
 @DateOfJoin datetime=NUll,      
 @AgentCan varchar(50)=NULL,      
 @accessed varchar(50)=NULL,      
 @remarks varchar(1000)=NULL,      
 @commission float=NULL,      
 @cType varchar(50)=NULL,      
 @limit money=NULL,      
 @limitPerTran money=NULL ,      
 @upload varchar(50)=NULL,      
 @agent_serial_send int=NULL,      
 @ext_agent_code int=NULL,      
 @GMT_Value int=NULL,      
 @sms_sender char(5)=NULL,      
 @mobileNoformat varchar(50)=NULL,      
 @mobile_digit_min char(2)=NULL,      
 @mobile_digit_max char(2)=NULL,      
 @sms_receiver char(5)=NULL,      
 @credit_bank_limit money =NULL,      
 @limit_for_customer char(1)=NULL,      
 @created_user varchar(50)=NULL,      
 @created_ts datetime=NULL ,      
 @updated_user varchar(50)=NULL,      
 @updated_ts datetime=NULL,      
 @agent_short_code varchar(50)=NULL,      
 @CurrentCommission money=NULL ,      
 @door_to_door_charge money=NULL,      
 @trn_limit_per_day money=NULL ,      
 @trn_limit_date datetime=NULL ,      
 @trn_limit_balance money=NULL,      
 @Intermediary_Bank varchar(50)=NULL,      
 @Swift_Code_IB varchar(50)=NULL,      
 @Account_No_IB varchar(50)=NULL,      
 @Beneficiary_Bank varchar(50)=NULL,      
 @Swift_Code_BB varchar(50)=NULL,      
 @Account_No_BB varchar(50)=NULL,      
 @Further_Credit varchar(50)=NULL,      
 @payout_overlimit money=NULL,      
 @alert_balance_enable char(1)=NULL,      
 @alert_balance_amount money=NULL,      
 @date_format varchar(20)=null,      
 @receiver_mobileformat varchar(20)=null,      
 @chk_create_comission char(1) = null,      
 @restrict_anywhere_payment char(1) = NULL,      
 @calc_commission_daily char(1)=NULL,      
 @dont_allow_apv_same_user char(1)=NULL,      
 @max_payout_amt_per_trans money=NULL,      
 @agt_settlement char(1)=NULL,      
 @non_IRH_Agent varchar(50)=NULL,      
 @max_payout_amt_per_trans_deposit money=NULL,      
 @super_agent_id as varchar(50)=Null,      
 @settlement_date as varchar(50)=Null,      
 @payout_fund_limit char(1)=NULL,      
 @state varchar(50)=Null ,    
 @generate_partner_pinno CHAR(1)=NULL,  
 @external_ledgerID varchar(50)=null,
 @disable_payout CHAR(1)=NULL ,
 @is_compliancePlus CHAR(1)=NULL,
 @send_txn_without_balance char(1)=NULL           
      
AS      
declare @audit_record int      
select @audit_record=audit_record_no from tbl_setup WITH(NOLOCK)     
      
if @flag='i'  --insert into agentdetail      
begin      
 SELECT @agentCode=MAX(AGENTCODE)+1 FROM AGENTDETAIL      
 if @agentCode is NUll      
 set @agentCode='20100000'      
  Insert into AgentDetail       
( agentCode, ContactName1, Post1,  email1,      
    ContactName2, Post2, email2,      
    CompanyName,  LicNo,       
    AgentType, Address,      
    City, Country,      
    Phone1, Phone2,       
    Fax,  Email,      
    BankName, BankACNo,       
    CurrentBalance, CurrencyType,      
    DateOfJoin, AgentCan, accessed,non_IRH_Agent,      
    remarks, commission,cType,      
    limit, limitPerTran, GMT_value,      
    credit_bank_limit, limit_for_customer,      
    created_user, created_ts, agent_short_code,      
    CurrentCommission,Intermediary_Bank,Swift_Code_IB,      
   Account_No_IB,Beneficiary_Bank,Swift_Code_BB,Account_No_BB,      
   Further_Credit, date_format,cal_commission_daily,     
   dont_allow_apv_same_user, max_payout_amt_per_trans,      
   ext_agent_code, receiver_mobileformat,restrict_anywhere_payment,      
   sms_sender,sms_receiver,mobileNoformat,mobile_digit_min,      
   mobile_digit_max,alert_balance_enable,      
   alert_balance_amount,      
   payout_overlimit,settlement_type,      
   max_payout_amt_per_trans_deposit,      
   STATE,generate_partner_pinno,external_ledgerID ,is_compliancePlus,disable_payout,send_txn_without_balance     
   )      
  Values       
     (@agentCode,      
    @ContactName1,      
    @Post1,      
    @email1,      
    @ContactName2,      
    @Post2,      
    @email2,      
    @CompanyName,       
    @LicNo,       
    @AgentType,      
    @Address,      
    @City,      
    @Country,      
    @Phone1,      
    @Phone2,      
    @Fax,       
    @Email,      
    @BankName,      
    @BankACNo,       
    @CurrentBalance,       
    @CurrencyType,      
    dbo.getDateHO(getutcdate()) ,      
    @AgentCan,      
    @accessed,      
    @non_IRH_Agent,      
    @remarks,      
    @commission,      
    @cType,      
    @limit,       
    @limitPerTran,      
    @GMT_value,      
    @credit_bank_limit,      
    @limit_for_customer ,      
    @created_user,      
    dbo.getDateHO(getutcdate()),      
    @agent_short_code,      
    @CurrentCommission,      
      
    @Intermediary_Bank,      
    @Swift_Code_IB,      
    @Account_No_IB,      
    @Beneficiary_Bank,      
    @Swift_Code_BB,      
    @Account_No_BB,      
    @Further_Credit,      
   isNull(@date_format,'mm/dd/yyyy'),      
   @calc_commission_daily,      
   @dont_allow_apv_same_user,      
   @max_payout_amt_per_trans,      
   @ext_agent_code,      
      
   @receiver_mobileformat,         
   @restrict_anywhere_payment,      
   @sms_sender,      
   @sms_receiver,      
   @mobileNoformat,      
   @mobile_digit_min,      
   @mobile_digit_max,      
   @alert_balance_enable,      
   @alert_balance_amount,      
   @payout_overlimit,      
            @agt_settlement,      
   @max_payout_amt_per_trans_deposit,      
   @state,@generate_partner_pinno,@external_ledgerID ,@is_compliancePlus,@disable_payout,@send_txn_without_balance        
     )      
        
  if @AgentCan in ('Both','None')      
  insert BankCommissionRates(agent_code, BankName, amt1, forTT1, forFax1, forDraft1, forTT2,        
forFax2, forDraft2, IMEBankTransfer, IMECashTransfer)       
    values(@agentCode,@CompanyName,0,0,0,0,0,0,0,0,0)      
 select 'Success' Status,@agentCode agentCode      
      
end      
      
else if @flag='u'-- update into agentdetail      
 begin      
   Update agentDetail       
   set       
    AgentCan=@AgentCan      
    ,accessed=@accessed      
    ,non_IRH_Agent=@non_IRH_Agent      
    ,remarks=@remarks      
    ,contactname1=@contactname1      
    ,post1=@post1      
    ,contactname2=@contactname2      
    ,post2=@post2      
    ,companyname=@companyname      
    ,licno=@licno      
    ,agenttype=@agentType      
    ,email1=@email1      
    ,email2=@email2       
    ,address=@address      
    ,city=@city      
    ,country=@country      
    ,phone1=@phone1      
    ,phone2=@phone2      
    ,fax=@fax      
    ,email=@email      
    ,credit_bank_limit=@credit_bank_limit      
    ,limit=@limit+isNULL(Increased_Credit_limit,0)      
    ,CurrencyType=@CurrencyType      
    --,DateOfJoin=dbo.getDateHO(getutcdate())      
    ,limitPerTran=@limitPerTran      
    ,ext_agent_code=@ext_agent_code      
    ,gmt_value=@gmt_value      
    ,sms_sender=@sms_sender      
    ,mobileNoformat=@mobileNoformat      
    ,mobile_digit_min=@mobile_digit_min      
    ,mobile_digit_max=@mobile_digit_max      
    ,sms_receiver=@sms_receiver       
    ,limit_for_customer=@limit_for_customer      
    ,agent_short_code=@agent_short_code       
    ,updated_user=@updated_user      
    ,updated_ts= dbo.getDateHO(getutcdate())                 
    ,door_to_door_charge=@door_to_door_charge
	,trn_limit_per_day=@trn_limit_per_day       
    ,Intermediary_Bank=@Intermediary_Bank      
    ,Swift_Code_IB=@Swift_Code_IB      
    ,Account_No_IB=@Account_No_IB      
    ,Beneficiary_Bank=@Beneficiary_Bank      
    ,Swift_Code_BB=@Swift_Code_BB      
    ,Account_No_BB=@Account_No_BB      
    ,Further_Credit=@Further_Credit      
    ,payout_overlimit=@payout_overlimit      
    ,alert_balance_enable=@alert_balance_enable      
    ,alert_balance_amount=@alert_balance_amount      
  --Updates from PrideExp      
    ,date_format=isNull(@date_format,'mm/dd/yyyy')      
    ,receiver_mobileformat=@receiver_mobileformat      
    ,restrict_anywhere_payment=@restrict_anywhere_payment      
    ,cal_commission_daily=@calc_commission_daily      
    ,dont_allow_apv_same_user=@dont_allow_apv_same_user      
    ,max_payout_amt_per_trans=@max_payout_amt_per_trans      
    ,settlement_type=@agt_settlement      
    ,max_payout_amt_per_trans_deposit=@max_payout_amt_per_trans_deposit      
    ,super_agent_id=@super_agent_id      
    ,agent_settlement_date=@settlement_date      
    ,payout_fund_limit=@payout_fund_limit      
    ,state=@state      
    ,generate_partner_pinno=@generate_partner_pinno  
    ,external_ledgerID=@external_ledgerID
    ,is_compliancePlus=@is_compliancePlus  
    ,disable_payout=@disable_payout
    ,send_txn_without_balance=@send_txn_without_balance    
   where agentCode=@agentCode
	      
if @agentCan <>'Fund Account'      
begin      
update agentbranchdetail set payout_overlimit=@payout_overlimit where agentCode=@agentCode      
      
 if @calc_commission_daily='n' or @calc_commission_daily is null      
 begin      
   declare @com_agent_id varchar(50),@payout_commission_id varchar(50)      
   SELECT @com_agent_id=MAX(agent_branch_Code)+1 FROM agentbranchdetail WITH(NOLOCK)     
      
  SELECT @payout_commission_id=payout_commission_id FROM tbl_setup WITH(NOLOCK)     
      
  if @payout_commission_id is not null      
  begin      
   if not exists (select agent_branch_Code from agentBranchdetail WITH(NOLOCK) where        
agentCode=@payout_commission_id      
  and comm_main_branch_id=@agentCode)      
   insert into agentBranchdetail(agent_branch_Code, agentCode, Branch, Address,Country,       
          
created_by,created_ts,updated_by,updated_ts,agent_code_id,currentBalance,comm_main_branch_id)      
   select @com_agent_id,@payout_commission_id,CompanyName + '- Comm',CompanyName,country,      
          @updated_user,dbo.getDateHO(getutcdate()),@updated_user,dbo.getDateHO(getutcdate()),agentcode,0,agentcode 
   from	agentdetail  WITH(NOLOCK)     
   where agentcode=@agentCode      
   end      
  end      
end      
end      
else if @flag='B'-- update into agent_bank_detail      
 begin      
   Update agentDetail      
   SET        
     Intermediary_Bank=@Intermediary_Bank      
    ,Swift_Code_IB=@Swift_Code_IB      
    ,Account_No_IB=@Account_No_IB      
    ,Beneficiary_Bank=@Beneficiary_Bank      
    ,Swift_Code_BB=@Swift_Code_BB      
    ,Account_No_BB=@Account_No_BB      
    ,Further_Credit=@Further_Credit      
   where agentCode=@agentCode      
 end      
      
      
      
else if @flag='s'      
 begin      
  --select * from AgentDetail      
  Select a.currencyType,a.Country,AgentCode,CompanyName,      
   limit,CurrentBalance,Accessed,exRateBy,schargeBy,AGENTCAN,      
   AGENTTYPE,CurrentCommission,agent_short_code       
  from AgentDetail a WITH(NOLOCK) left outer join agent_function f WITH(NOLOCK)      
  on a.agentcode=f.agent_id  where accessed =@accessed      
  and agentType=@agentType      
  order by country,CompanyName      
 end      
else if @flag='a'       
 begin      
  select *,limit-isNULL(Increased_Credit_limit,0) actual_limit from AgentDetail WITH(NOLOCK) where        
agentCode=@agentCode      
 end      
      
      
else if @flag='m' -- select max agentcode       
 begin      
  select max(agentcode)from AgentDetail WITH(NOLOCK)       
 end      
      
else if @flag='r' --for audit report      
begin      
select top(@audit_record) * from agentDetail_audit WITH(NOLOCK) where agentcode=@agentCode order by updated_ts desc      
end      
      
else if @flag='z'      
begin      
select top(@audit_record) * from agentDetail_audit WITH(NOLOCK) where sno=@agentCode order by updated_ts desc      
end      
      
else if @flag='c'      
begin      
select a.agentcode,a.companyname,isNUll(a.limit,0) limit,a.country,isNUll(a.Increased_Credit_limit,0)        
Increased_Credit_limit,      
isNUll(a.currentbalance,0) currentbalance,Max(c.currencyType)        
currencyType,a.agent_short_code,avg(c.exchangeRate) Exrate       
from agentdetail a WITH(NOLOCK) join      
agentcurrencyrate c WITH(NOLOCK) on a.agentcode=c.agentid  where agentcan in ('sender','SenderReceiver')       
AND accessed IN ('Blocked','Granted')      
group by        
a.agentcode,a.companyname,a.limit,a.country,a.Increased_Credit_limit,a.currentbalance,a.agent_short_code      
order by companyname      
end      
      
--for bank details LOG      
else if @flag='w'       
begin      
select top(@audit_record) * from agentDetail_audit WITH(NOLOCK) where agentcode=@agentCode and user_action='UPDATE-Bank        
Details'  order by updated_ts desc      
END      
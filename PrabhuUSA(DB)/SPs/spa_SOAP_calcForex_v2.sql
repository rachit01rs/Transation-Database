
/****** Object:  StoredProcedure [dbo].[spa_SOAP_calcForex_v2]    Script Date: 04/08/2014 03:22:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_SOAP_AgentList 'KM101','km_api','kash881','111','c'      
--spa_SOAP_calcForex_v2 'MYKL01','klanoop','ktmnepal1','123123',NULL,1000,'C','Indonesia','c'      
--exec spa_SOAP_calcForex_v2 'MYKL01','klanoop','ktmnepal1','1233',Null,1000,'c','Indonesia','c'      
--exec spa_SOAP_calcForex_v2 'MYKL01','klanoop','ktmnepal1','1233','30302200',100,'c','Bangladesh','c'      
create proc [dbo].[spa_SOAP_calcForex_v2_OLD]      
    @accesscode varchar(100),      
    @username varchar(100),      
    @password varchar(100),      
    @AGENT_REFID varchar(100),      
    @payout_agent_id varchar(50)=NULL,      
    @COLLECT_AMT Money,      
    @PAYMENTTYPE varchar(50),      
    @Payout_Country varchar(100)=NULL ,      
    @CALC_BY varchar(1)=null,  
	@client_pc_id varchar(100)=null     
      
as      
      
declare @agentcode varchar(50),@agent_branch_code varchar(50),@user_pwd varchar(50), @accessed varchar(50)      
declare @Block_branch varchar(50), @BranchCodeChar varchar(50), @lock_status varchar(5),@agent_user_id varchar(50)      
declare @country varchar(50),@user_count int,      
@agentname varchar(100),@branch varchar(100),@gmtdate datetime,@COLLECT_CURRENCY varchar(5)      
  
      
declare @return_value varchar(1000)      
      
declare @api_agent_id varchar(200),@sql varchar(8000)      
      
if @username='' or @password='' or @accesscode='' or @AGENT_REFID=''      
begin      
 set @return_value='Invalid Request Parameter'      
 insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
 values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,NULL,@username,'******','Invalid Request Parameter','Failed')      
 select '1001' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
declare @currentBalance money,@limit_per_TXN money      
SELECT @agentcode=a.agentcode,@agentname=a.companyName,@user_pwd=u.user_pwd,@agent_user_id=u.agent_user_id,      
@accessed=a.accessed,@country=a.country,@branch=b.branch,      
@agent_branch_code=b.agent_branch_code,@BranchCodeChar=b.BranchCodeChar,       
@Block_branch=isNUll(b.block_branch,'n'),@lock_status=isNUll(u.lock_status,'n'),@COLLECT_CURRENCY=a.currencyType,      
@gmtdate=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@currentBalance=isNUll(a.currentBalance,0),      
@limit_per_TXN=a.limitPerTran      
FROM agentDetail a JOin agentbranchdetail b on a.agentcode=b.agentcode      
JOIN agentsub u ON b.agent_branch_code=u.agent_branch_code       
where u.user_login_id=@username      
      
set @user_count=@@rowcount      
set @api_agent_id=@agentcode      
----AUTHENTICATING USER----------      
if @user_count=0      
begin      
set @return_value='Invalid User ID'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,NULL,@username,'******','Invalid User Name','Failed')      
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
return      
end      
if @user_pwd<>dbo.encryptdb(@password)      
begin      
set @return_value='Invalid Password'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,@password,'Invalid Password','Failed')      
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
return      
end      
if @BranchCodeChar<>@accesscode      
begin      
set @return_value='Partner id invalid'      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******','Branch Code invalid','Failed')      
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
return      
end      
if @Block_branch='y'   OR @lock_status='y'      
begin        
set @return_value='Your userid is Blocked'        
select '1003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT        
return        
end        
  
declare @isError char(1)  
 select @isError=isError,@PAYMENTTYPE=item from dbo.FNA_ApiGetPaymentType(@PAYMENTTYPE)  
 if @isError is not null  
  begin  
  select '3001' Code,@AGENT_REFID AGENT_REFID,@PAYMENTTYPE Message,NULL REFID    
  return  
   end  
--      
--if upper(@PAYMENTTYPE)='C'      
-- set @PAYMENTTYPE='Cash Pay'      
--else if upper(@PAYMENTTYPE)='B'      
-- set @PAYMENTTYPE='Bank Transfer'      
--else if upper(@PAYMENTTYPE)='D'      
-- set @PAYMENTTYPE='Account Deposit to Other Bank'    
--else if upper(@PAYMENTTYPE)='E'        
--set @PAYMENTTYPE='Cash Payment BDP'    
--else      
--begin      
-- set @return_value='Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank'      
-- insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
-- values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******',@return_value,'Failed')      
-- select '3001' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
--return      
--END      
      
DECLARE @check_anywhere CHAR(1)      
--SELECT @check_anywhere=ISNULL(isanywhere,'n') FROM service_charge_setup WHERE agent_id=@agentcode       
--AND rec_country= @Payout_Country      
set @check_anywhere='n'      
if @check_anywhere='n' AND (@payout_agent_id='' or @payout_agent_id is NULL)      
begin      
 set @return_value='Location Id must be selected'      
 insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
 values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,NULL,@username,'******','Payout Agent Id must be selected','Failed')      
 select '1001' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
      
declare @payout_branch_code varchar(50)      
set @payout_branch_code=@payout_agent_id      
      
declare @rBankName varchar(100),@receivercountry varchar(100),@PAYOUTCURRENCY varchar(5),@max_payout_amt_cash money,      
@max_payout_amt_account money,@branch_block varchar(50),@payout_agent_status varchar(50)      
if @payout_branch_code is not null      
begin      
 select @payout_agent_id=a.agentCode,@rBankName=companyName,@payout_agent_status=a.accessed,      
 @branch_block=isNUll(block_branch,'n'),      
 @receivercountry=a.country,@PAYOUTCURRENCY=currencyType,      
 @max_payout_amt_cash=isNull(a.max_payout_amt_per_trans,0),      
 @max_payout_amt_account=isNUll(max_payout_amt_per_trans_deposit,0)      
 from agentdetail a join agentbranchdetail b on      
 a.agentcode=b.agentcode where agent_branch_code=@payout_branch_code      
end      
if @branch_block='y'       
begin      
 set @return_value='Selected Branch is inactive'      
 select '3004' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
if @payout_agent_status<>'Granted'       
begin      
 set @return_value=isNUll(@rBankName,'')+ ' Agent is inactive'      
 select '3004' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
if @Payout_Country<> @receivercountry      
begin      
 set @return_value='Invalid Location ID and Country'      
 select '3003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
END      
      
      
      
declare @ho_cost_send_rate money,      
 @ho_premium_send_rate money,      
 @ho_premium_payout_rate money,      
 @agent_customer_diff_value money,      
 @agent_sending_rate_margin money,      
 @agent_payout_rate_margin money,      
 @agent_sending_cust_exchangerate money,      
 @agent_payout_agent_cust_rate money,      
 @ho_exrate_applied_type varchar(20),      
 @scharge money,@sendercommission money,@agent_receiverSCommission money,      
 @ho_dollar_rate money,@agent_settlement_rate money, @exchangerate money,@today_dollar_rate money,@round_by int,      
@receiveamt money, @totalroundamt money       
      
 select      
 @ho_dollar_rate=x.DollarRate,      
 @agent_settlement_rate=x.NPRRate,      
 @exchangerate=x.exchangerate,      
 @today_dollar_rate=isNull(b.customer_rate,x.customer_rate),      
 @round_by=x.qtyCurrency,      
 @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),      
 @ho_premium_send_rate=isNull(x.agent_premium_send,0),      
 @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),      
 @agent_customer_diff_value=isNull(x.customer_diff_value,0),      
 @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),      
 @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),      
 @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),      
 @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),      
 @ho_exrate_applied_type='countrywise',      
 @PAYOUTCURRENCY=x.ReceiveCType      
 from agentCurrencyRate x left outer join agent_branch_rate b       
 on x.agentId=b.agentid and b.agent_branch_code=@agent_branch_code       
 where x.agentId=@agentcode  and x.receiveCountry=@PAYOUT_COUNTRY       
 and x.currencyType=@COLLECT_CURRENCY 
--AND x.receiveCType  <> 'USD'      
      
IF exists(select Currencyid FROM agentpayout_CurrencyRate WHERE agentid=@agentcode AND payout_agent_id=@payout_agent_id)      
begin      
--PRINT 'insert agent wise'      
select      
 @ho_dollar_rate=x.DollarRate,      
 @agent_settlement_rate=x.NPRRate,      
 @exchangerate=x.exchangerate,      
 @today_dollar_rate=x.customer_rate,      
 @round_by=x.qtyCurrency,      
    @ho_cost_send_rate=x.exchangeRate+isNull(x.agent_premium_send,0),      
    @ho_premium_send_rate=isNull(x.agent_premium_send,0),      
    @ho_premium_payout_rate=isNull(x.agent_premium_payout,0),      
    @agent_customer_diff_value=isNull(x.customer_diff_value,0),      
    @agent_sending_rate_margin=isNull(x.margin_sending_agent,0),      
    @agent_payout_rate_margin=isNull(x.receiver_rate_diff_value,0),      
    @agent_sending_cust_exchangerate=isNull(x.sending_cust_exchangerate,0),      
    @agent_payout_agent_cust_rate=isNull(x.payout_agent_rate,0),      
    @ho_exrate_applied_type='payoutwise'      
 from agentpayout_CurrencyRate x       
 where x.agentId=@agentcode  and payout_agent_id=@payout_agent_id      
       
END      
      
declare @check_sc varchar(50)      
-- select @check_sc=max(slab_id) from service_charge_setup       
--where agent_id=@agentcode and Rec_country=@Payout_Country      
--and (isNULL(payment_type,'Bank Transfer')=@PAYMENTTYPE       
--or isNULL(payment_type,'Cash Pay')=@PAYMENTTYPE)      
SELECT @check_sc = MAX(slab_id)      
 FROM   service_charge_setup      
 WHERE  agent_id = @agentcode      
        AND Rec_country = @PAYOUT_COUNTRY      
        AND (      
                ISNULL(payment_type, 'Bank Transfer') = @PAYMENTTYPE      
                OR ISNULL(payment_type, 'Cash Pay') = @PAYMENTTYPE      
            )      
if @check_sc is null      
begin      
 SELECT @check_sc = MAX(slab_id)      
     FROM   service_charge_setup      
     WHERE  agent_id = @agentcode      
            AND payout_agent_id = @payout_agent_id      
            AND (      
                    ISNULL(payment_type, 'Bank Transfer') = @PAYMENTTYPE      
                    OR ISNULL(payment_type, 'Cash Pay') = @PAYMENTTYPE      
                )      
 IF @check_sc is null      
 BEGIN       
 select '30081' Code,@AGENT_REFID AGENT_REFID,'Select Country is not allowed, please contact Head Office'  Message,NULL COLLECT_AMT      
 RETURN      
 END        
END      
      
------------############# new added  Service Charge      
create table #temp_charge(slab_id int,      
min_amount money,      
max_amount money,      
service_charge money,      
send_commission money,      
paid_commission money,      
deposit_amt money      
)      
      
declare @pay_in_amt money,@clc_COLLECT_AMT money      
      
if @CALC_BY='p'      
begin      
 set @totalroundamt=@COLLECT_AMT      
 set @pay_in_amt=@totalroundamt/@today_dollar_rate      
 set @receiveamt=@COLLECT_AMT      
       
 --spa_GetServiceCharge_by_payinamt '10100000',NULL,2000,'Cash Pay','Nepal'     
    
 set @COLLECT_AMT=0      
 set @scharge=0      
 insert into #temp_charge(slab_id,min_amount,max_amount,deposit_amt,service_charge,send_commission,paid_commission)      
 exec spa_GetServiceCharge_by_payinamt @agentcode,@payout_agent_id,@pay_in_amt,@PAYMENTTYPE,@PAYOUT_COUNTRY      
-- exec spa_GetServiceCharge_by_payinamt_v1 @agentcode,@payout_agent_id,@pay_in_amt,@PAYMENTTYPE,@PAYOUT_COUNTRY      
 select @scharge=service_charge,@COLLECT_AMT=deposit_amt,@sendercommission=send_commission,@agent_receiverSCommission=paid_commission      
 from #temp_charge      
    
--  PRINT @COLLECT_AMT     
 if @scharge is NULL      
  begin      
   set @return_value='Service Charge is Not Defined for the Amount Range'      
   select '3013' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
   return      
  end      
end      
else       
begin      
 set @clc_COLLECT_AMT=@COLLECT_AMT      
 if @COLLECT_AMT=0      
 begin      
  set @clc_COLLECT_AMT=100      
 end       
      
 set @scharge=0      
 insert into #temp_charge(slab_id,min_amount,max_amount,service_charge,send_commission,paid_commission)      
 exec spa_GetServiceCharge @agentcode,@payout_agent_id,@clc_COLLECT_AMT,@PAYMENTTYPE,@agent_branch_code,@PAYOUT_COUNTRY      
 select @scharge=service_charge,@sendercommission=send_commission,      
 @agent_receiverSCommission=paid_commission from #temp_charge      
      
 if @scharge is NULL      
  begin      
   set @return_value='Service Charge is Not Defined for the Amount Range'      
   select '3013' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
   return      
  end      
        
 set @receiveamt=(@COLLECT_AMT - @scharge) * @today_dollar_rate      
 set @totalroundamt=floor(@receiveamt)      
      
 if @totalroundamt <= 0        
 begin      
  set @return_value='Collected Amount is Invalid must be more than '+ cast(@scharge as varchar)      
  insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
  values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******',@return_value,'Failed')      
  select '3009' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
  return      
 end      
      
end      
--------------###############3      
      
if @exchangerate is null --or @round_by is null      
begin      
 set @return_value='Selected Country is not allowed'      
 insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
 values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******',@return_value,'Failed')      
 select '3008' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
if @COLLECT_AMT <= 0        
begin      
 set @return_value='Amount is Invalid'      
 insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
 values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******',@return_value,'Failed')      
 select '3009' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
      
if @COLLECT_AMT = 0       
begin      
 set @receiveamt=0      
 set @totalroundamt=0      
end      
else      
begin      
 set @receiveamt=(@COLLECT_AMT - @scharge) * @today_dollar_rate      
 set @totalroundamt=round(@receiveamt,@round_by)      
end      
      
if @totalroundamt <= 0        
begin      
 set @return_value='Collected Amount is Invalid must be more than '+ cast(@scharge as varchar)      
 insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
 values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******',@return_value,'Failed')      
 select '3009' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
if @max_payout_amt_account=0       
set @max_payout_amt_account=@totalroundamt      
      
if @max_payout_amt_cash=0       
set @max_payout_amt_cash=@totalroundamt      
      
if @PAYMENTTYPE='Cash Pay' and @totalroundamt>@max_payout_amt_cash      
begin      
 set @return_value='Cash Pickup TXN can not be more than '+ cast(@max_payout_amt_cash as varchar) + ' '+ @PAYOUTCURRENCY +' for Country:'+ @PAYOUT_COUNTRY      
 select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end       
if @PAYMENTTYPE='Bank Transfer' and @totalroundamt>@max_payout_amt_account      
begin      
 set @return_value='Bank Transfer can not be more than '+ cast(@max_payout_amt_account as varchar) + ' '+ @PAYOUTCURRENCY +' for Country:'+ @PAYOUT_COUNTRY      
 select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end       
if @limit_per_TXN < @COLLECT_AMT       
begin      
 set @return_value='TXN Limit exceeded. You have limit up to  '+ cast(@limit_per_TXN as varchar) + ' '+ @COLLECT_CURRENCY +' per Transaction '      
 select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL COLLECT_AMT      
 return      
end      
      
if @sendercommission is null      
 set @sendercommission=0      
      
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)       
values(@client_pc_id,'SOAP_FOREX',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,'******','Login','Success')      
      
declare @forex_id int      
insert SOAP_LOG_FOREX([AGENT_CODE]      
           ,[AGENT_REFID]      
           ,[payout_agent_id]      
           ,[COLLECT_AMT]      
           ,[COLLECT_CURRENCY]      
           ,[SERVICE_CHARGE]      
           ,[exchangerate]      
           ,[today_dollar_rate]      
           ,[PAYOUTAMT]      
           ,[ho_cost_send_rate]      
           ,[ho_premium_send_rate]      
           ,[ho_premium_payout_rate]      
           ,[agent_customer_diff_value]      
           ,[agent_sending_rate_margin]      
           ,[agent_payout_rate_margin]      
           ,[agent_sending_cust_exchangerate]      
           ,[agent_payout_agent_cust_rate]      
           ,[ho_exrate_applied_type]      
           ,[sendercommission]      
           ,[agent_receiverSCommission]      
           ,[ho_dollar_rate]      
           ,[agent_settlement_rate]      
   ,Create_ts      
   ,PAYOUTCURRENCY      
   ,agent_branch_code      
      
)      
values(@agentcode,@AGENT_REFID,@payout_agent_id,@COLLECT_AMT,@COLLECT_CURRENCY,@scharge,@exchangerate,@today_dollar_rate,      
@totalroundamt,@ho_cost_send_rate,      
 @ho_premium_send_rate ,      
 @ho_premium_payout_rate ,      
 @agent_customer_diff_value ,      
 @agent_sending_rate_margin ,      
 @agent_payout_rate_margin ,      
 @agent_sending_cust_exchangerate ,      
 @agent_payout_agent_cust_rate ,      
 @ho_exrate_applied_type,      
@sendercommission,@agent_receiverSCommission,@ho_dollar_rate,@agent_settlement_rate,getdate(),@PAYOUTCURRENCY,      
@payout_branch_code      
 )      
      
set @forex_id=@@identity      
      
select '0' Code,@AGENT_REFID AGENT_REFID,isNUll(@rBankName,@PAYOUT_COUNTRY) Message,      
@COLLECT_AMT COLLECT_AMT,@COLLECT_CURRENCY COLLECT_CURRENCY,      
@scharge SERVICE_CHARGE,@today_dollar_rate EXCHANGE_RATE,@totalroundamt PAYOUTAMT,@PAYOUTCURRENCY PAYOUTCURRENCY,      
@forex_id SESSION_ID      
      
return      
      
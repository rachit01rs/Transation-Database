
/****** Object:  StoredProcedure [dbo].[spa_MobileSaveTransaction]    Script Date: 08/31/2013 23:46:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter proc [dbo].[spa_MobileSaveTransaction]
@branch_code varchar(50),
@payout_agent_id varchar(50),
@payout_branch_id varchar(50)=null,
@customerid varchar(50),
@paymentType varchar(50),
@ben_bank_id varchar(50)=null,
@ben_bank_branch_sno varchar(50)=null,
@bank_branch_name varchar(50)=null,
@bank_account_no varchar(50)=null,
@ben_id varchar(50)=null,
@ben_name varchar(100),
@ben_address varchar(200),
@ben_city varchar(50),
@ben_tel varchar(50),
@paidamt money,
@scharge money,
@exrate float,
@totalroundamt money,
@session_id varchar(150)=null,
@digital_id_sender varchar(150)=null,
@apps_mobile_no varchar(20)=null, -- -IPADDRESS
@SenderAddress varchar(150)=null,
@SenderCity varchar(150)=null,
@SenderState varchar(150)=null,
@SenderZipCode varchar(150)=null,
@SenderMobile varchar(150)=null,
@SenderDOB varchar(150)=null,
@PaymentRoutingNumber varchar(150)=null,
@PaymentAccountNO varchar(150)=null,
@PaymentAccountType varchar(150)=null

as
BEGIN TRY 
declare @enable_staging char(1)        
set @enable_staging='y'        
----BAC Coupon  Validation        
   DECLARE @bca_category_id INT         
   DECLARE @MLKP_Agentid varchar(50),@BANK_MANDIRI_Agentid varchar(50)   
   DECLARE @check_muthoot varchar(50)
   select @check_muthoot=agentcode from tbl_integrated_agents where agentName='Royal Exchange'        
             
 DECLARE @agentid              VARCHAR(50),        
         @agentname            VARCHAR(150),        
         @branch               VARCHAR(150),        
         @sendercountry        VARCHAR(100),        
         @paidctype            VARCHAR(50),        
         @branch_voucher_prefix VARCHAR(10),        
		 @branch_voucher_seq INT,        
         @branch_voucher VARCHAR(50)         
         
 DECLARE @cash_ledger_id       INT,        
         @allow_exrate_change  CHAR(1)        
         
 DECLARE @ext_bank_id          VARCHAR(50),        
         @ben_bank_name        VARCHAR(100),        
         @exRateBy             VARCHAR(50),        
         @sChargeBy            VARCHAR(50),        
         @gmtdate              DATETIME,        
         @limit_date           DATETIME              
         
   
         
 IF @paymenttype IS NULL        
 BEGIN        
     SELECT 'ERROR',        
            '1011',        
            'Error No PaymentType Selected'        
             
     RETURN        
 END        
         
 IF @paymenttype <> 'Cash Pay'        
    AND @payout_agent_id IS NULL        
 BEGIN        
     SELECT 'ERROR',        
            '1012',        
            'Error in Agent Selection, For the Selected Payment Type you must have to select Payout Agent'        
     RETURN        
 END  
 
 DECLARE @mileage_enable       VARCHAR(50),        
         @mileage_earn         MONEY,  
         @mileage_point   MONEY,        
         @check_cust_per_date  CHAR(1),        
         @limit_per_day        MONEY,        
         @branch_limit_enable  MONEY         
         
 -- SENDING AGENT DETAIL         
 -- ALter table agentbranchdetail add branch_voucher_seq int            
 SELECT @agentid = a.agentcode,        
        @agentname = a.companyName,        
        @branch = b.branch,        
        @sendercountry = a.country,        
        @paidctype = currencyType,        
        @allow_exrate_change = allow_exrate_change,        
        @cash_ledger_id = cash_ledger_id,        
        @exRateBy = exRateBy,        
        @sChargeBy = sChargeBy,        
        @gmtdate = DATEADD(mi, ISNULL(gmt_value, 345), GETUTCDATE()),        
        @limit_date = trn_limit_date,        
        @mileage_enable = f.mileage_enable,        
        @check_cust_per_date = limit_for_customer,        
        @limit_per_day = limitPerTran,        
        @branch_limit_enable = ISNULL(b.branch_limit, -1),        
        @branch_voucher_prefix=isNull(b.branch_voucher_prefix,b.branchCodeChar),        
        @branch_voucher_seq=isNUll(b.branch_voucher_seq,0)+1        
 FROM   agentdetail a WITH (NOLOCK)        
        JOIN agentbranchdetail b WITH (NOLOCK)        
             ON  a.agentcode = b.agentcode        
        JOIN agent_function f        
             ON  agent_id = a.agentcode        
 WHERE  agent_branch_code = @branch_code         
         
 SET @branch_voucher=right(cast(1000000 + @branch_voucher_seq AS VARCHAR),4)        
 SET @branch_voucher=@branch_voucher_prefix+@branch_voucher        

---- Get Customer/User Detail
 declare @sendername VARCHAR(50),        
         
 @senderphoneno VARCHAR(50),        
 @sendersalary VARCHAR(100),        
 @senderemail VARCHAR(100),        
 @sendercompany VARCHAR(150),        
 @senderpassport VARCHAR(50),        
 @sendervisa VARCHAR(50),  
 @ID_Issue_date datetime,
 @source_of_income varchar(50),
 @reason_for_remittance varchar(50),
 @employmentType VARCHAR(50),        
 @gender VARCHAR(50), 
 @id_place_of_issue varchar(50),
 @txtsPassport_type varchar(50),
 @sender_native_country varchar(50),
 @receivercountry varchar(150),
 @cust_sno             BIGINT,        
 @receiverrelation VARCHAR(50) ,        
 @customer_type CHAR(1) ,        
 @agent_dollar_rate MONEY ,              
 @ReceiverIDDescription VARCHAR(100) ,        
 @receiverID VARCHAR(100) ,        
 @TRN_Remarks VARCHAR(500) ,        
 @receiverID_placeOfIssue VARCHAR(50) ,        
 @c2c_receiver_code VARCHAR(200) ,        
 @c2c_secure_pwd VARCHAR(10) ,        
 @ofac_list CHAR(1) , ---added later        
 @sender_occupation VARCHAR(50) ,        
 @sim_token_id_confirm INT ,        
 @customer_category_id INT ,        
 @bca_coupon_id VARCHAR(10),            
 @receiverFax VARCHAR(50) ,        
 @receiverEmail VARCHAR(50) ,        
 @customerType VARCHAR(50) ,        
 @relation_other VARCHAR(100),    
 @source_of_income_other VARCHAR(100) ,    
 @sender_occupation_other VARCHAR(100)  ,  
 @premium_rate FLOAT,
 @receiverphone varchar(50) 
 	
        
 select @cust_sno = sno,
		@sendername=c.senderName,
		@senderphoneno=c.SenderPhoneno,
		@sendersalary=c.Salary_Earn,
		@senderemail=c.SenderEmail,
		@sendercompany=c.SenderCompany,
		@senderpassport=c.senderPassport,
		@sendervisa=c.senderVisa,
		@id_place_of_issue=c.id_place_of_issue,
		@ID_Issue_date=c.id_issue_date,
		@source_of_income=c.source_of_income,
		@reason_for_remittance=c.reason_for_remittance,
		@senderState=c.senderState,
		@employmentType=c.employmentType,
		@gender=c.gender,
		@txtsPassport_type=c.senderFax,
		@sender_native_country=c.SenderNativeCountry,
			
		@receivercountry=c.ReceiverCountry,
		@sender_occupation=c.sender_occupation,
		@sender_occupation_other=c.sender_occupation_other,
		@source_of_income=c.source_of_income,
		@source_of_income_other=c.source_of_income_other,
		@receiverFax=c.ReceiverFax,
		@receiverEmail=c.ReceiverEmail
		from customerDetail c where CustomerId=@customerid
      
	update customerDetail set eWallet=isNUll(eWallet,0)-@paidamt,
	ReceiverName=@ben_name,ReceiverAddress=@ben_address,ReceiverCity=@ben_city,ReceiverMobile=@ben_tel,
	SenderAddress=@SenderAddress,SenderCity=@SenderCity,senderState=@SenderState,sender_State=@SenderState,
	date_of_birth=@SenderDOB,SenderMobile=@SenderMobile
	where sno=@cust_sno


      if @ben_id is null or @ben_id='-1'  --- New Beneficiary
      begin
		  insert customerReceiverDetail(sender_sno,ReceiverName,ReceiverAddress,ReceiverCity,ReceiverCountry,ReceiverMobile,ReceiverPhone,
		  receivingbank,branch_MIRC,accountno,bankbranch)
		  values(@cust_sno,@ben_name,@ben_address,@ben_city,@receiverCountry,@ben_tel,@ben_tel,@ben_bank_id,@ben_bank_branch_sno,@bank_account_no,@bank_branch_name)
		  set @ben_id=@@IDENTITY
      end
      else
      begin
			  update customerReceiverDetail set ReceiverAddress=@ben_address,
			  ReceiverCity=@ben_city,
			  ReceiverMobile=@ben_tel,
			  receivingbank=isNUll(@ben_bank_id,receivingbank),
			  branch_MIRC=isNull(@ben_bank_branch_sno,branch_MIRC),
			  accountno=isNUll(@bank_account_no,accountno),
			  bankbranch=isNull(@bank_branch_name,bankbranch)
			  from customerReceiverDetail c where sno=@ben_id
			 
			  select @ben_name=c.ReceiverName,
				@receiverphone=c.ReceiverPhone,
				@receiverrelation=c.relation							
				from customerReceiverDetail c where sno=@ben_id
      end 
      
-----          
 --Check payout id (anywhere payment)            

 IF @payout_agent_id IS NULL        
    OR RTRIM(LTRIM(@payout_agent_id)) = ''        
 BEGIN        
     IF NOT EXISTS(        
            SELECT slab_id        
            FROM   service_charge_setup    WITH (NOLOCK)     
            WHERE  agent_id = @agentid        
                   AND rec_country = @receivercountry        
                       
        )        
     BEGIN        
         SELECT 'ERROR',        
                '1055',        
                'Payout Agent is not selected when it is required.'        
                 
         RETURN        
     END        
 END  
 
         
 DECLARE @check_amt MONEY              
 SELECT @check_amt = ISNULL(SUM(paidAmt), 0) + @paidamt        
 FROM   customer_trans_limit WITH (NOLOCK)        
 WHERE  customer_passport = @senderpassport        
         
 IF @check_amt > 50000        
    AND @sendercountry = 'Malaysia'        
 BEGIN        
     SELECT 'ERROR',        
            '1009',        
            'ID No: ' + @senderpassport + ' Exceeded daily Limit'        
             
     RETURN        
 END            
 
 DECLARE @sendercommission           FLOAT,        
         @agent_settlement_rate      MONEY,        
         @exchangerate               FLOAT,        
         @agent_receiverSCommission  MONEY,        
         @round_by                   INT,        
         @new_scharge                MONEY,        
		 @isSlab                     VARCHAR(10)              
                 
         
 DECLARE @ho_cost_send_rate                FLOAT,        
         @ho_premium_send_rate             MONEY,        
         @ho_premium_payout_rate           MONEY,        
         @agent_customer_diff_value        MONEY,        
         @agent_sending_rate_margin        MONEY,        
         @agent_payout_rate_margin         MONEY,        
         @agent_sending_cust_exchangerate  FLOAT,        
         @agent_payout_agent_cust_rate     FLOAT,        
         @ho_exrate_applied_type           VARCHAR(20),        
         @receivectype                     VARCHAR(50),
         @ho_dollar_rate				    float,
         @today_dollar_rate					Float              
         
       
     IF EXISTS(        
            SELECT agentId        
            FROM   agentpayout_CurrencyRate_Branch WITH (NOLOCK)        
            WHERE  agentId = @agentid        
                   AND agent_branch_code = @branch_code        
                   AND payout_agent_id = @payout_agent_id        
        )        
     BEGIN        
         PRINT 'insert Payout agent wise Branch'              
         SELECT @ho_dollar_rate = x.DollarRate,        
                @agent_settlement_rate = x.NPRRate,        
                @exchangerate = x.exchangerate,        
                @today_dollar_rate = x.customer_rate,        
                @round_by = x.qtyCurrency,        
                @isSlab = NULL,        
                @receivectype = x.receivectype,        
                @ho_cost_send_rate = x.exchangeRate + ISNULL(x.agent_premium_send, 0),        
                @ho_premium_send_rate = ISNULL(x.agent_premium_send, 0),        
                @ho_premium_payout_rate = ISNULL(x.agent_premium_payout, 0),        
                @agent_customer_diff_value = ISNULL(x.customer_diff_value, 0),        
                @agent_sending_rate_margin = ISNULL(x.margin_sending_agent, 0),        
                @agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value, 0),        
                @agent_sending_cust_exchangerate = ISNULL(x.sending_cust_exchangerate, 0),        
                @agent_payout_agent_cust_rate = ISNULL(x.payout_agent_rate, 0),        
                @ho_exrate_applied_type = 'payoutbranchwise'        
         FROM   agentpayout_CurrencyRate_Branch x WITH (NOLOCK)        
         WHERE  x.agentId = @agentid        
                AND agent_branch_code = @branch_code        
                AND payout_agent_id = @payout_agent_id        
     END        
     ELSE         
     IF EXISTS(        
            SELECT agentId        
            FROM   agentpayout_CurrencyRate WITH (NOLOCK)        
            WHERE  agentId = @agentid        
                   AND payout_agent_id = @payout_agent_id        
        )        
     BEGIN        
         PRINT 'insert Payout agent wise'              
         SELECT @ho_dollar_rate = x.DollarRate,        
                @agent_settlement_rate = x.NPRRate,        
                @exchangerate = x.exchangerate,        
                @today_dollar_rate = x.customer_rate,        
                @round_by = x.qtyCurrency,        
                @isSlab = NULL,        
                @receivectype = x.receivectype,        
                @ho_cost_send_rate = x.exchangeRate + ISNULL(x.agent_premium_send, 0),        
                @ho_premium_send_rate = ISNULL(x.agent_premium_send, 0),        
                @ho_premium_payout_rate = ISNULL(x.agent_premium_payout, 0),        
                @agent_customer_diff_value = ISNULL(x.customer_diff_value, 0),       
                @agent_sending_rate_margin = ISNULL(x.margin_sending_agent, 0),        
                @agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value, 0),        
                @agent_sending_cust_exchangerate = ISNULL(x.sending_cust_exchangerate, 0),        
                @agent_payout_agent_cust_rate = ISNULL(x.payout_agent_rate, 0),        
                @ho_exrate_applied_type = 'payoutwise'        
         FROM   agentpayout_CurrencyRate x WITH (NOLOCK)        
         WHERE  x.agentId = @agentid        
                AND payout_agent_id = @payout_agent_id        
     END        
     ELSE         
     IF EXISTS(        
            SELECT agentId        
            FROM   agent_branch_rate WITH (NOLOCK)        
            WHERE  agentId = @agentid        
                   AND agent_branch_code = @branch_code        
                   AND receiveCountry = @receivercountry        
        )        
     BEGIN        
         PRINT 'insert Agent wise Country Branch'              
         SELECT @ho_dollar_rate = x.DollarRate,        
                @agent_settlement_rate = x.NPRRate,        
                @exchangerate = x.exchangerate,        
                @today_dollar_rate = x.customer_rate,        
                @round_by = x.qtyCurrency,        
                @receivectype = x.receivectype,        
                @isSlab = NULL,        
                @ho_cost_send_rate = x.exchangeRate + ISNULL(x.agent_premium_send, 0),        
                @ho_premium_send_rate = ISNULL(x.agent_premium_send, 0),        
                @ho_premium_payout_rate = ISNULL(x.agent_premium_payout, 0),        
                @agent_customer_diff_value = ISNULL(x.customer_diff_value, 0),        
                @agent_sending_rate_margin = ISNULL(x.margin_sending_agent, 0),        
                @agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value, 0),        
                @agent_sending_cust_exchangerate = ISNULL(x.sending_cust_exchangerate, 0),        
                @agent_payout_agent_cust_rate = ISNULL(x.payout_agent_rate, 0),        
                @ho_exrate_applied_type = 'branchwise'        
         FROM   agent_branch_rate x WITH (NOLOCK)        
         WHERE  x.agentId = @agentid        
                AND agent_branch_code = @branch_code        
                AND receiveCountry = @receivercountry        
     END        
     ELSE        
     BEGIN        
         PRINT 'insert Agent wise Country'              
         SELECT @ho_dollar_rate = x.DollarRate,        
                @agent_settlement_rate = x.NPRRate,        
                @exchangerate = x.exchangerate,        
                @today_dollar_rate = x.customer_rate,        
                @round_by = x.qtyCurrency,        
                @isSlab = NULL,        
                @receivectype = x.receivectype,        
                @ho_cost_send_rate = x.exchangeRate + ISNULL(x.agent_premium_send, 0),        
                @ho_premium_send_rate = ISNULL(x.agent_premium_send, 0),        
                @ho_premium_payout_rate = ISNULL(x.agent_premium_payout, 0),        
                @agent_customer_diff_value = ISNULL(x.customer_diff_value, 0),        
                @agent_sending_rate_margin = ISNULL(x.margin_sending_agent, 0),        
                @agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value, 0),        
                @agent_sending_cust_exchangerate = ISNULL(x.sending_cust_exchangerate, 0),        
                @agent_payout_agent_cust_rate = ISNULL(x.payout_agent_rate, 0),        
                @ho_exrate_applied_type = 'countrywise'        
         FROM   agentCurrencyRate x WITH (NOLOCK)        
         WHERE  x.agentId = @agentid        
                AND receiveCountry = @receivercountry        
     END        
      
 
 ------------######### New Charge from function    
 DECLARE @error_status VARCHAR(50),@error_msg VARCHAR(100),@superAgent_commission MONEY    
 IF EXISTS(SELECT Exc_STATUS FROM dbo.FNAGetServiceCharge(@agentid,@payout_agent_id,@paidamt,@paymenttype,@branch_code,@receivercountry,NULL))    
 BEGIN    
  SELECT     
   @error_status=Exc_STATUS,    
   @error_msg=msg,    
   @new_scharge = service_charge,    
         @sendercommission = send_commission,    
         @agent_receiverSCommission = paid_commission,    
         @superAgent_commission=superAgent_commission    
  FROM  dbo.FNAGetServiceCharge(@agentid,@payout_agent_id,@paidamt,@paymenttype,@branch_code,@receivercountry,NULL)    
 END    
     
 IF @error_status IS NOT NULL    
 BEGIN    
  SELECT 'ERROR',    
            '2012',    
            'Error!! '+@error_msg    
     RETURN    
 END    
          
 IF @round_by IS NULL        
     SET @round_by = 0        
         
 IF @exchangerate IS NULL --or @round_by is null        
 BEGIN        
     SELECT 'ERROR',        
            '1012',        
            'Error!! please try again'        
             
     RETURN        
 END         
         
DECLARE @agent_receiveingComm MONEY,@agent_receiverComm_Currency CHAR(1)    
-- MAIN AGENT COMMISSION SLAB    
     
select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission  with (nolock)     
where agent_code=@payout_agent_id and country=@sendercountry and @totalroundamt between min_amount and max_amount    
and payment_mode=@paymenttype    
    
if @agent_receiveingComm is null    
 begin    
  select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission  with (nolock)     
  where agent_code=@payout_agent_id and country=@sendercountry and @totalroundamt between min_amount and max_amount    
  and payment_mode='Default'    
 end    
if @agent_receiveingComm is null    
 begin    
 select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission  with (nolock)     
 where agent_code=@payout_agent_id and country='All' and @totalroundamt between min_amount and max_amount    
 and payment_mode=@paymenttype    
 end    
if @agent_receiveingComm is null    
 begin    
  select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission  with (nolock)     
  where agent_code=@payout_agent_id and country='All' and @totalroundamt between min_amount and max_amount    
  and payment_mode='Default'    
 end 
 
 declare @receiveamt money
 
  SET @receiveamt = (@paidamt - @scharge) * @today_dollar_rate              
 SET @totalroundamt = ROUND(@receiveamt, @round_by, 1)         
  
  IF ISNULL(@totalroundamt, 0) <= 0        
    OR ISNULL(@paidamt, 0) <= 0        
 BEGIN        
     SELECT 'ERROR',        
            '1013',        
            'Error!! Service charge'        
             
     RETURN        
 END
 
 
 
 
 DECLARE @rbankname       VARCHAR(150),        
         @rbankbranch     VARCHAR(150),        
         @receiveagentid  VARCHAR(50),        
         @payout_country  VARCHAR(100),        
         @branch_group    VARCHAR(500)              
         
      
     SELECT @receiveagentid = agentcode,        
            @rbankname = companyName,  
            @mileage_point=isNull(a.mileage_points_per_txn,0)        
     FROM   agentdetail a WITH (NOLOCK)
     WHERE  agentcode = @payout_agent_id        
            
 IF @paymenttype='Cash Pay'        
 BEGIN        
   SET @bank_account_no=NULL         
   SET @ben_bank_id=NULL         
 END         
   
IF @mileage_enable='y'   
 SET @mileage_earn=@mileage_point 
 
declare @ReciverMessage varchar(300) 
 IF @ben_bank_id IS NOT NULL        
 BEGIN        
     SELECT @ext_bank_id = external_bank_id,        
            @ben_bank_name = bank_name        
     FROM   commercial_bank with (nolock)        
     WHERE  commercial_id = @ben_bank_id        
     if @ext_bank_id is NULL        
  set @ext_bank_id=@ben_bank_id        
     IF @ReciverMessage IS NOT NULL        
         SET @ReciverMessage = @ReciverMessage + '\' + @ben_bank_name        
     ELSE        
         SET @ReciverMessage = @ben_bank_name        
 END  
   
 DECLARE @ben_bank_branch_extid  VARCHAR(50)       
 IF @ben_bank_branch_sno IS NOT NULL  
 SELECT @ben_bank_branch_extid=cbb.IFSC_Code  
   FROM commercial_bank_branch cbb WHERE sno=@ben_bank_branch_sno  
   
 ------------Retrive Payout Settlement USD Rate ----------------              
 DECLARE @payout_settle_usd MONEY              
 SELECT @payout_settle_usd = buyRate        
 FROM   Roster WITH (NOLOCK)        
 WHERE  payoutagentid = @payout_agent_id        
         
 IF @payout_settle_usd IS NULL        
     SELECT @payout_settle_usd = buyRate        
     FROM   Roster WITH (NOLOCK)        
     WHERE  country = @receivercountry AND payoutagentid IS NULL         
         
 IF @payout_settle_usd IS NULL        
     SET @payout_settle_usd = @ho_dollar_rate     

DECLARE @send_settle_usd MONEY              
 SELECT @send_settle_usd = sellRate        
 FROM   Roster WITH (NOLOCK)        
 WHERE  payoutagentid = @agentid        
         
 IF @send_settle_usd IS NULL        
     SELECT @send_settle_usd = sellRate        
     FROM   Roster WITH (NOLOCK)        
     WHERE  country = @sendercountry AND payoutagentid IS NULL         
         
 IF @send_settle_usd IS NULL        
     SET @send_settle_usd = @exchangerate  
     
        
             
                
     DECLARE @bankcom       MONEY,        
             @amt1          MONEY,        
             @bankamt1      MONEY,        
             @bankamt2      MONEY,        
             @transfertype  VARCHAR(50),
             @payoutcomm	money         
     --retriving bank commision              
            
         --retriving cash commision              
         SET @bankcom = 0         
         --set @rbankname=NULL              
         SET @payoutcomm = 0         
         --set @rbankbranch=NULL              
         SET @transfertype = 'CashPay'        
              
       
     IF @rBankBranch IS NULL OR @paymenttype='Account Deposit to Other Bank'  
			SET @rBankBranch=@bank_branch_name  
          
              
             
             
                
          
         -- update customer              
         UPDATE customerdetail        
         SET    trn_amt = CASE         
                               WHEN CONVERT(VARCHAR, trn_date, 102) = CONVERT(VARCHAR, GETDATE(), 102) THEN         
                                    ISNULL(trn_amt, 0) + @paidamt        
                               ELSE @paidamt        
                          END,        
                trn_date = @gmtdate      
         WHERE  sno = @cust_sno        
                  
             
     IF @payoutcomm IS NULL        
         SET @payoutcomm = 0         
             
     ------------FX Sharing calc-------------------------              
     DECLARE @send_share           FLOAT,        
             @payout_fx_share      FLOAT,        
             @Head_fx_share        FLOAT,        
             @check_agent_ex_gain  MONEY,
             @agent_ex_gain			Float              
             
     IF @agent_settlement_rate = @today_dollar_rate        
         SET @agent_ex_gain = 0              
             
     SET @check_agent_ex_gain = (        
             (@agent_settlement_rate -@today_dollar_rate) * (@paidamt - @scharge)        
         ) / @agent_settlement_rate         
             
                   
     IF (@check_agent_ex_gain -@agent_ex_gain) > 0.5        
     BEGIN        
         SELECT 'ERROR',        
                '5010',        
                CAST(ROUND(ROUND(@agent_ex_gain, 2), 0) AS VARCHAR) +        
                'Session Expired, Please re-do transaction' +        
                CAST(ROUND(@check_agent_ex_gain, 0) AS VARCHAR)        
                 
       --  ROLLBACK TRANSACTION         
         RETURN        
     END         
     -----------end FX Sharing---------------              
            
  DECLARE @expected_payoutagentid VARCHAR(50)  
  SELECT @expected_payoutagentid=agentcode FROM agent_sub_agent WHERE sub_agent_id=@payout_agent_id  
    
  IF @expected_payoutagentid IS NULL  
	SET @expected_payoutagentid=@payout_agent_id  
         
   declare @tranno bigint,@dot datetime ,@dottime varchar(20),@rnd_id varchar(4),@rnd_id1 varchar(4),@trannoref bigint,@refno_seed varchar(20)                    
                    
 set @dot=convert(varchar,dbo.getDateHO(getutcdate()),101)                    
 set @dottime=convert(varchar,dbo.getDateHO(getutcdate()),108)                    
                    
 SET @rnd_id=left(abs(checksum(newid())),2)                    
 SET @rnd_id1=left(abs(checksum(newid())),2)                    
                    
set @tranno=ident_current('moneysend') + 1                    
     
             
     --set @tranno=ident_current('moneysend') + 1              
     SET @trannoref = IDENT_CURRENT('tbl_refno') + 1              
      declare @process_id varchar(100),@refno varchar(50)                    
	 set @process_id=left(cast(abs(CHECKSUM(newid())) as varchar),6)                    
	 set @refno_seed =[dbo].[FNARefno](@trannoref, @process_id)  

 IF @payout_agent_id=@check_muthoot --- Muthoot      
 SET  @refno='36'+ left(@rnd_id,1)+left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) + + left(@rnd_id,1)      
 ELSE       
 set @refno='11'+ left(@rnd_id,1)+left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) + + left(@rnd_id,1)              
   
                
                 
         DECLARE @confirmDate DATETIME,        
                 @approved_by VARCHAR(50),@process_transStatus VARCHAR(50),@transstatus varchar(20)        
             
     SET @process_transStatus='Staging' 
     set @transstatus = 'Hold'        
           
             
     DECLARE @enc_refno VARCHAR(50)              
     SET @enc_refno = dbo.encryptdb(@refno)              
                  
             
     --ADDED FOR INTEGRATED AGNET SAVE            
     DECLARE @status VARCHAR(50)            
     SET @status = 'Un-Paid'            
     IF EXISTS (        
            SELECT agentcode        
            FROM   tbl_integrated_agents WITH (NOLOCK)
            WHERE  agentcode = @payout_agent_id        
                         
        )        
     BEGIN        
         SET @status = 'Post'            
            
     END         
     --INTEGRATED AGENT END            
     DECLARE @duplicate_TXN       VARCHAR(500),        
             @compliance_flag     CHAR(1),        
             @compliance_sys_msg  VARCHAR(500),        
             @compliance_refno VARCHAR(50)        
             
     SELECT TOP 1 @duplicate_TXN = Tranno,@compliance_refno=dbo.decryptDb(refno)        
     FROM   moneysend WITH (NOLOCK)        
     WHERE  SenderName = RTRIM(LTRIM(@sendername))        
            AND ReceiverName = RTRIM(LTRIM(@ben_name))        
            AND paidamt = @paidamt        
            AND agentid = @agentid        
            AND CONVERT(VARCHAR, local_DOT, 102) = CONVERT(VARCHAR, @gmtdate, 102)        
            AND TransStatus NOT IN ('Cancel')        
     ORDER BY        
            tranno DESC             
             
     IF @duplicate_TXN IS NOT NULL        
     BEGIN        
         IF @transstatus = 'Payment'        
         BEGIN        
             SELECT 'ERROR',        
                    '2001',        
                    'Similar Transaction Found'        
                   
             RETURN        
         END        
         ELSE        
         BEGIN        
             SET @compliance_flag = 'y'            
             SET @compliance_sys_msg = 'Duplicate Suspected : '+@compliance_refno        
         END        
     END        
     if @enable_staging='n'        
     begin        
    set @process_transStatus=@transStatus        
  end         
            
     IF EXISTS (SELECT * FROM tbl_refno tr WHERE tr.refno=@enc_refno)        
     BEGIN        
          SELECT 'ERROR',        
                    '2001',        
                    'Server Busy, Please try again'        
                   
             RETURN        
     END        
            
     INSERT tbl_refno        
       (        
         refno        
       )        
     VALUES        
       (        
         @enc_refno        
       )         
    
    declare @dollar_amt money
          
  BEGIN TRANSACTION        
     SET @dollar_amt = @paidamt / @exchangerate              
     INSERT moneysend        
       (        
         refno,        
         agentid,        
         agentname,        
         branch_code,        
         branch,        
         customerid,        
         sendername,        
         senderaddress,        
         senderphoneno,        
         sendersalary,        
         sendercity,        
         sendercountry,        
         senderemail,        
         sendercompany,        
         senderpassport,        
         sendervisa,        
         receivername,        
         receiveraddress,        
         receiverphone,        
         receivercity,        
         receivercountry,        
         receiverrelation,        
         dot,        
         dottime,        
         paidamt,        
         paidctype,        
         receiveamt,        
         receivectype,        
         exchangerate,        
         today_dollar_rate,        
         dollar_amt,        
         scharge,        
         senderbankvoucherno,        
         paymenttype,        
         rbankid,        
         rbankname,        
         rbankbranch,        
         rbankacno,        
         rbankactype,        
         othercharge,        
         transstatus,        
         STATUS,        
         sempid,        
         imecommission,        
         bankcommission,        
         totalroundamt,        
         transfertype,        
         sendercommission,        
         receiveagentid,        
         send_mode,        
         local_dot,        
         sender_mobile,        
         receiver_mobile,        
         sendernativecountry,        
         ip_address,        
         agent_dollar_rate,        
         ho_dollar_rate,        
         bonus_amt,        
         request_for_new_account,        
         digital_id_sender,        
         expected_payoutagentid,        
         bonus_value_amount,        
         bonus_type,        
         bonus_on,        
         ben_bank_id,        
         ben_bank_name,        
         paid_agent_id,        
         ReciverMessage,        
		 send_sms,        
         agent_settlement_rate,        
         agent_ex_gain,        
         agent_receiverSCommission,        
         confirmDate,        
         approve_by,        
         customer_sno,        
         senderFax,        
         ReceiverIDDescription,        
         receiverID,        
         TestQuestion,        
         receiverID_placeOfIssue,        
         mileage_earn,        
         source_of_income,        
         reason_for_remittance,        
         payout_settle_usd,        
         c2c_receiver_code,        
         c2c_secure_pwd,        
         ofac_list,        
         ho_cost_send_rate,        
         ho_premium_send_rate,        
         ho_premium_payout_rate,        
         agent_customer_diff_value,        
         agent_sending_rate_margin,        
         agent_payout_rate_margin,        
         agent_sending_cust_exchangerate,        
         agent_payout_agent_cust_rate,        
         ho_exrate_applied_type,        
         sender_occupation,        
         compliance_flag,        
         compliance_sys_msg,        
         process_id,        
         customer_category_id,        
         payout_send_agent_id,        
         sender_State,        
         employmentType,        
         gender,        
         receiverFax,        
         receiverEmail,        
         customerType,        
         id_place_of_issue,        
         Date_of_Birth,        
         ID_Issue_date   ,    
         relation_other,source_of_income_other,sender_occupation_other ,    
         agent_receiverCommission,agent_receiverComm_Currency,  
         ben_bank_branch_extid,  
         premium_rate,
         receiver_sno,
         PaymentRoutingNumber,
         PaymentAccountNumber,
         PaymentAccountType,
         SenderBankName    
       )        
          
     VALUES        
       (        
         @enc_refno,        
         @agentid,        
         @agentname,        
         @branch_code,        
         @branch,        
         @customerid,        
         UPPER(@sendername),        
         @senderaddress,        
         @senderphoneno,        
         @sendersalary,        
         @sendercity,        
         @sendercountry,        
         @senderemail,        
         @sendercompany,        
         @senderpassport,        
         @sendervisa,        
         UPPER(@ben_name),        
         @ben_address,        
         @ben_tel,        
         @ben_city,        
         @receivercountry,        
         @receiverrelation,        
         @dot,        
         @dottime,        
         @paidamt,        
         @paidctype,        
         @receiveamt,        
         @receivectype,        
         @exchangerate,        
         @today_dollar_rate,        
         @dollar_amt,        
         @scharge,        
         @branch_voucher,        
         @paymenttype,        
         @payout_branch_id,        
         @rbankname,        
         @rBankBranch,        
         LTRIM(RTRIM(@bank_account_no)),        
         @bank_branch_name,        
         0,        
         @process_transStatus,        
         @status,        
         @customerid,        
         @payoutcomm,        
		 @bankcom,        
         @totalroundamt,        
         @transfertype,        
         @sendercommission,        
         @receiveagentid,    
			'm',        -- Mobile 
         @gmtdate,        
         @sendermobile,        
         @ben_tel,        
         @sender_native_country,        
         @apps_mobile_no,        
         @agent_dollar_rate,        
         @ho_dollar_rate,        
         0,        
         null,        
         @digital_id_sender,        
         @expected_payoutagentid,        
         NULL,        
         null,        
         null,        
         @ext_bank_id,        
         @ben_bank_name,        
         @payout_agent_id,        
         @ReciverMessage,        
         'y',        
         @agent_settlement_rate,        
         @agent_ex_gain,        
         @agent_receiverSCommission,        
       @confirmDate,        
         @approved_by,        
         @cust_sno,        
         @txtsPassport_type,        
         @ReceiverIDDescription,        
         @receiverID,        
         @TRN_Remarks,        
         @receiverID_placeOfIssue,        
         @mileage_earn,        
         @source_of_income,        
         @reason_for_remittance,        
         @payout_settle_usd,        
         @c2c_receiver_code,        
         @c2c_secure_pwd,        
         @ofac_list,        
         @ho_cost_send_rate,        
         @ho_premium_send_rate,        
         @ho_premium_payout_rate,        
         @agent_customer_diff_value,        
         @agent_sending_rate_margin,        
         @agent_payout_rate_margin,        
         @agent_sending_cust_exchangerate,        
         @agent_payout_agent_cust_rate,        
         @ho_exrate_applied_type,        
         @sender_occupation,        
         @compliance_flag,        
         @compliance_sys_msg,        
         @session_id,        
         @customer_category_id,        
         @payout_agent_id,        
		   @senderState,        
		   @employmentType,        
		   @gender,        
		   @receiverFax,        
		   @receiverEmail,        
		   @customerType,        
		   @id_place_of_issue,        
		   @SenderDOB,        
		   @ID_Issue_date  ,    
		   @relation_other,@source_of_income_other,@sender_occupation_other  ,    
		   @agent_receiveingComm,@agent_receiverComm_Currency,  
		   @ben_bank_branch_extid,  
		   @premium_rate,
		   @ben_id,
		   @PaymentRoutingNumber,
		   @PaymentAccountNO,
		   @PaymentAccountType,
		   'Mobile'
       )              
                    
         
     SET @tranno = @@identity         
             
     UPDATE agentbranchdetail SET branch_voucher_seq=@branch_voucher_seq WHERE agent_branch_Code=@branch_code        
             
     INSERT deposit_detail        
       (        
         bankcode,        
         deposit_detail1,        
         deposit_detail2,        
         amtpaid,        
         depositdot,        
         tranno, 
         bank_serial_no        
       )        
     SELECT cash_ledger_id,        
            @PaymentRoutingNumber,        
            @PaymentAccountNO +'-'+@PaymentAccountType,        
            @paidamt,        
            @gmtdate,        
            @tranno,    
           @branch_voucher_seq        
     FROM  agent_function
     where agent_Id=@agentid 
     
              
      COMMIT TRANSACTION        
              
     if @enable_staging='y'        
     begin         
   exec spa_ComplianceCheck_Job @tranno,@transstatus          
  end         
          
  IF @compliance_flag='y'        
  BEGIN        
   INSERT INTO transactionNotes        
              (        
                RefNo,        
                Tranno,        
                Comments,        
                DatePosted,        
                notetype,        
                PostedBy,        
                uploadby        
              )        
            VALUES        
              (        
       @enc_refno,        
                @tranno,        
                @compliance_sys_msg,        
                dbo.GETDATEHo(GETUTCDATE()),        
                '3',        
                @customerid,        
                'Duplicate Suspected'        
              )         
  END         
             
     -- agent current balance              
     UPDATE agentdetail        
     SET    currentbalance = ISNULL(currentbalance, 0) + (@paidamt -(@sendercommission + ISNULL(@agent_ex_gain, 0))),        
            currentcommission = ISNULL(currentcommission, 0) + @sendercommission        
     WHERE  agentcode = @agentid         
             
     --UPDATING PAYOUT AGNENT BALANCE START              
     IF @payout_agent_id IS NOT NULL        
     BEGIN        
         UPDATE agentdetail        
         SET    payout_agent_balance = ISNULL(payout_agent_balance, 0) -@totalroundamt        
         WHERE  agentcode = @payout_agent_id        
     END         
     --- Branch wise Limit Enabled              
     IF @branch_limit_enable >= 0        
     BEGIN        
         UPDATE agentbranchdetail        
         SET    current_branch_limit = ISNULL(current_branch_limit, 0) + @paidamt        
         WHERE  agent_branch_code = @branch_code        
     END         
     
     DELETE session_table        
     WHERE  session_id = @session_id         
             
     --Passport Number for Limit checking              
     IF @senderpassport IS NOT NULL        
     BEGIN        
         IF EXISTS(        
                SELECT sno        
                FROM   customer_trans_limit WITH (NOLOCK)        
                WHERE  customer_passport = @senderpassport        
                       AND customer_name = @senderName        
                       AND customer_id_type = @txtsPassport_type        
            )        
             UPDATE customer_trans_limit        
             SET    paidAmt = paidAmt + @paidAmt,        
                    nos_of_txn = ISNULL(nos_of_txn, 0) + 1,        
                    update_ts = GETDATE()        
             WHERE  customer_passport = @senderpassport        
                    AND customer_name = @senderName        
                    AND customer_id_type = @txtsPassport_type        
         ELSE        
             INSERT customer_trans_limit        
               (        
                 customer_passport,        
                 paidAmt,        
                 trans_date,        
                 agent_id,        
                 update_ts,        
                 nos_of_txn,        
                 customer_name,        
                 customer_id_type        
               )        
             VALUES        
               (        
                 @senderpassport,        
                 @paidAmt,        
                 CONVERT(VARCHAR, @gmtdate, 101),        
                 @agentid,        
                 GETDATE(),        
                 1,        
                 @senderName,        
                 @txtsPassport_type        
               )        
     END         
      
                
     SELECT 'SUCCESS',        
            @refno Refno,        
            @customerid CustID,        
            @tranno TRNNo        
             
           
        
END TRY              
BEGIN CATCH        
 IF @@trancount > 0        
     ROLLBACK TRANSACTION              
         
 DECLARE @desc VARCHAR(1000)              
 SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'              
         
         
 INSERT INTO [error_info]        
   (        
     [ErrorNumber],        
     [ErrorDesc],        
     [Script],        
     [ErrorScript],        
     [QueryString],        
     [ErrorCategory],        
     [ErrorSource],        
     [IP],        
     [error_date]        
   )        
 SELECT -1,        
        @desc,        
        'SPS_MoneyMobile',        
        'SQL',        
        @desc,        
        'SQL',        
        'SP',        
        @digital_id_sender,        
        GETDATE()        
         
 SELECT 'ERROR',        
        '1050',        
        'Error Please try again'        
END CATCH            
            
  
  
  
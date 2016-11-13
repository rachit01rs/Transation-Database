
alter PROCEDURE [dbo].[spa_Common_moneysend_SaveAPI]                                              
 @flag CHAR(1),                                              
 @refno VARCHAR(15),                                              
 @branch_code VARCHAR(50) = NULL,                                              
 @customerid VARCHAR(50) = NULL,                                              
 @sendername VARCHAR(50) = NULL,                                              
 @senderaddress VARCHAR(100) = NULL,                                              
 @senderphoneno VARCHAR(50) = NULL,                                              
 @sendersalary VARCHAR(100) = NULL,                                              
 @sendercity VARCHAR(100) = NULL,                                              
 @senderemail VARCHAR(100) = NULL,                                              
 @sendercompany VARCHAR(150) = NULL,                                              
 @senderpassport VARCHAR(50) = NULL,                                              
 @sendervisa VARCHAR(50) = NULL,                                              
 @receivername VARCHAR(50) = NULL,                                              
 @receiveraddress VARCHAR(100) = NULL,                                              
 @receiverphone VARCHAR(50) = NULL,                                              
 @receivercity VARCHAR(50) = NULL,                                              
 @receivercountry VARCHAR(50) = NULL,                                              
 @receiverrelation VARCHAR(50) = NULL,                                              
 @paidamt MONEY = NULL,                                              
 @receiveamt MONEY = NULL,                                              
 @today_dollar_rate float = NULL,                                              
 @dollar_amt Float = NULL,                                              
 @scharge MONEY = NULL,                                              
 @cash_voucher_id VARCHAR(150) = NULL,                                              
 @paymenttype VARCHAR(50) = NULL,                                              
 @rbankid VARCHAR(50) = NULL,                                              
 @rbankacno VARCHAR(150) = NULL,                                              
 @rbankactype VARCHAR(150) = NULL,                                              
 @othercharge MONEY = NULL,                                              
 @sempid VARCHAR(50) = NULL,                                              
 @payout_agent_id VARCHAR(50) = NULL,                                              
 @send_mode VARCHAR(10) = NULL,                                              
 @totalroundamt MONEY = NULL,                                              
 @payoutcomm MONEY = 0,                                              
 @gmtdate1 VARCHAR(50) = NULL,                                              
 @sendermobile VARCHAR(20) = NULL,                                              
 @receivermobile VARCHAR(20) = NULL,                                              
 @session_id VARCHAR(100) = NULL,                                              
 @transstatus VARCHAR(50) = NULL,                                              
 @customer_type CHAR(1) = NULL,                                              
 @sender_native_country VARCHAR(100) = NULL,                                              
 @agent_dollar_rate MONEY = NULL,                                              
 @ho_dollar_rate MONEY = NULL,                                              
 @ip_address VARCHAR(15) = NULL,                                              
 @bonus_amt MONEY = NULL,                                              
 @request_new_account CHAR(1) = NULL,                                              
 @trans_mode CHAR(1) = NULL,                                              
 @digital_id_sender VARCHAR(100) = NULL,                                              
 @bonus_value_amt MONEY = NULL,                                              
 @bonus_type CHAR(1) = NULL,                                              
 @bonus_on CHAR(1) = NULL,                                    
 @ben_bank_id VARCHAR(10) = NULL,       
 @ReciverMessage VARCHAR(500) = NULL,                                              
 @send_sms VARCHAR(1) = NULL,                                              
 @agent_ex_gain MONEY = NULL,                                              
 @txtsPassport_type VARCHAR(100) = NULL, --- Used in Sender Fax Clm                                              
 @ReceiverIDDescription VARCHAR(100) = NULL,                                              
 @receiverID VARCHAR(100) = NULL,                          
 @TRN_Remarks VARCHAR(500) = NULL,                                              
 @cash_date VARCHAR(20) = NULL,                                     
 @receiverID_placeOfIssue VARCHAR(50) = NULL,                                              
 @source_of_income VARCHAR(50) = NULL,                                              
 @reason_for_remittance VARCHAR(50) = NULL,                                              
 @c2c_receiver_code VARCHAR(200) = NULL,                                              
 @c2c_secure_pwd VARCHAR(10) = NULL,                                   
 @ofac_list CHAR(1) = NULL, ---added later                                              
 @sender_occupation VARCHAR(50) = NULL,                                                    
 @customer_category_id INT = NULL,                                                                                             
 @employmentType VARCHAR(50) = NULL,                                              
 @gender VARCHAR(50) = NULL,                                              
 @receiverFax VARCHAR(50) = NULL,                                              
 @receiverEmail VARCHAR(50) = NULL,                                              
 @customerType VARCHAR(50) = NULL,                                              
 @id_place_of_issue VARCHAR(50) = NULL,                                              
 @Date_of_Birth VARCHAR(50) = NULL,                                              
 @ID_Issue_date VARCHAR(50) = NULL  ,                                            
 @relation_other VARCHAR(100)=NULL,                                          
 @source_of_income_other VARCHAR(100)=NULL,                                          
 @sender_occupation_other VARCHAR(100)=NULL ,                                        
 @ben_bank_branch_sno VARCHAR(50)=NULL,                                        
 @premium_rate FLOAT=NULL,                                                                
 @rGender CHAR=NULL,    --receiver gender                      
 @API_Session VARCHAR(200)=NULL                                     
AS                                     
                                           
BEGIN TRY                                              
declare @enable_staging char(1)                                              
--set @enable_staging='y'                                                   
                                                                
 DECLARE @agentid               VARCHAR(50),                                              
         @agentname             VARCHAR(150),                                              
         @branch                VARCHAR(150),                                              
         @sendercountry         VARCHAR(100),                                              
         @paidctype             VARCHAR(50),                                              
         @branch_voucher_prefix VARCHAR(10),                                              
   @branch_voucher_seq    INT,                                              
   @branch_voucher        VARCHAR(50)                                               
                                               
 DECLARE @cash_ledger_id       INT,                                              
         @allow_exrate_change  CHAR(1)                                              
                                             
 DECLARE @ext_bank_id          VARCHAR(50),                                              
         @ben_bank_name        VARCHAR(100),                           
         @exRateBy             VARCHAR(50),                                              
         @sChargeBy            VARCHAR(50),                            
         @gmtdate              DATETIME,                                              
         @limit_date           DATETIME                                                    
                     
 IF (                                              
        SELECT ISNULL(SUM(amtpaid), -1)                                              
        FROM   session_deposit_log WITH (NOLOCK)                                              
       WHERE  session_id = @session_id                                              
    ) <> @paidamt                                              
    AND @send_mode IN ('s', 'v')                                              
 BEGIN                      
     SELECT 'ERROR',                                              
            '1001',                                              
            'Error in Deposit Detail, please try send transaction from main menu'                                
                                                   
     RETURN                                              
 END                                              
                                               
 IF @paymenttype IS NULL                                              
 BEGIN                                              
     SELECT 'ERROR',                                              
            '1002',                                              
            'Error No PaymentType Selected'                                              
                                                   
     RETURN                                              
 END                                              
                                               
 IF @paymenttype <> 'Cash Pay'                                              
    AND @payout_agent_id IS NULL                                              
 BEGIN                                              
     SELECT 'ERROR',                                              
            '1003',                                              
            'Error in Agent Selection, For the Selected Payment Type you must have to select Payout Agent'                                              
                                                   
     RETURN                                              
 END                                                  
                                             
 DECLARE @mileage_enable       VARCHAR(50),                                              
         @mileage_earn         MONEY,                                        
         @mileage_point        MONEY,                                   
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
                                                
/* --######### Check payout id (anywhere payment) #########                                                   
                                               
 IF @payout_agent_id IS NULL                                
    OR RTRIM(LTRIM(@payout_agent_id)) = ''                                              
 BEGIN                                              
     IF NOT EXISTS(                                              
            SELECT slab_id                                              
            FROM   service_charge_setup                                              
            WHERE  agent_id = @agentid                                         
                   AND rec_country = @receivercountry                                              
                   AND ISNULL(isAnyWhere, 'n') = 'y'                                              
        )                                              
     BEGIN                                              
         SELECT 'ERROR',                                              
                '1004',                    
                'Payout Agent is not selected when it is required.'                                              
                                                       
         RETURN                                              
     END                                              
 END                                               
                                               
 --######### END Check payout id (anywhere payment) #########*/                      
                                               
 DECLARE @check_amt MONEY                          
                                                   
 SELECT @check_amt = ISNULL(SUM(paidAmt), 0) + @paidamt                            FROM                           
  customer_trans_limit WITH (NOLOCK)                                              
 WHERE  customer_passport = @senderpassport                                              
                                               
 IF @check_amt > 50000                                              
    AND @sendercountry = 'Malaysia'                                              
 BEGIN          
     SELECT 'ERROR',                                              
            '1005',                                              
            'ID No: ' + @senderpassport + ' Exceeded daily Limit'                                              
                                                   
     RETURN                                              
 END             
                                               
 IF @cash_date IS NULL                                              
     SET @cash_date = @gmtdate                                                    
                                               
 DECLARE @sendercommission           FLOAT,                                              
         @agent_settlement_rate      MONEY,                                    
         @exchangerate               MONEY,                                              
         @agent_receiverSCommission  MONEY,                                              
         @round_by                   INT,                                              
         @new_scharge                MONEY,                                              
         @isSlab                     VARCHAR(10)                                          
                                                       
                                               
 DECLARE @ho_cost_send_rate                MONEY,                                              
         @ho_premium_send_rate             MONEY,                                              
         @ho_premium_payout_rate           MONEY,                                              
         @agent_customer_diff_value        MONEY,                      
         @agent_sending_rate_margin        MONEY,                                              
         @agent_payout_rate_margin         MONEY,                                              
         @agent_sending_cust_exchangerate  MONEY,                                              
         @agent_payout_agent_cust_rate     MONEY,                                              
         @ho_exrate_applied_type           VARCHAR(20),                               
         @receivectype                     VARCHAR(50)                                                    
                                            
 --################### GET ALL RATES from API ################                                             
   IF EXISTS(SELECT *FROM tbl_apiforex WITH(NOLOCK) WHERE process_id=@API_Session)                                                                          
     BEGIN                                               
  DECLARE    @ext_payout_amt MONEY,                        
			 @payoutamt      MONEY,                        
			 @API_PayCountry VARCHAR(50),                        
			 @ext_settlement_amt MONEY,                                                                     
			 @sChargeUSD     FLOAT,                         
			 @send_USDrate   FLOAT,                        
			 @exp_PaidCtype  varchar(50),
			 @exp_receiveCtype  varchar(50)                                       
                                                        
   PRINT 'insert Payout agent wise Branch'                     
                         
   select                          
		 @API_PayCountry    = x.payoutCountry,                         
		 @exchangerate      = x.Exrate,                       
		 @scharge           = x.Service_Fee ,                        
		 @today_dollar_rate = x.custRate,
		 @exp_PaidCtype     = x.payinCCY,                        
		 @payoutamt         = x.payoutAmt ,                        
		 @exp_receiveCtype  = acs.currencyType,                        
		 @ext_payout_amt    = x.sendAmt,       -- TXN sendAmt in CCY ---   
		 @dollar_amt        = x.Partner_Settle_Amt                                     
   FROM tbl_apiforex x with(NOLOCK) join API_country_setup acs with(NOLOCK) 
   ON x.payoutCountry=acs.country WHERE x.process_id=@API_Session    
                                                                                    
  --    SELECT  @sendercommission = @scharge*0.30,    --##### 30% of service charge #####--                                                                        
  --   @agent_receiverSCommission = @scharge*0.70,    --##### 70% of service charge #####--                                                                    
  --   @ho_dollar_rate = x.Ho_dollar_rate,                           
  --   @agent_settlement_rate = x.agent_rate,                                                                       
  --   @exchangerate= x.ExchangeRate,                                                                          
  --   @today_dollar_rate = x.customer_rate,                                              
  --   @dollar_amt=x.dollarAmt,                                                                          
  --   @round_by = NULL,                                                                  
  --   @isSlab = NULL,                                              
  --   @payoutamt=x.payoutAmt,                                              
  --   @API_senderCountry=x.payoutCountry ,                                              
  --   @ext_payout_amt=x.paidamt,                                      
  --   @send_USDrate=x.send_USDrate, --fin_rate1[Rate Source currency aganist USD]                                      
  --   @netAmt_Send=x.netAmt_Send,   --fin_midValueMYR[NetAMT in sendingCurrency]                                      
  --   @sChargeUSD =x.sChargeUSD,     --fin_chgAmt_mid[sCHarge IN USD]                                      
  --   @exp_PaidCtype=x.paidCtype                                                                                    
  --    FROM   CIMB_API_rates x                                                                          
  --    WHERE x.confirm_process_id=@confirm_process_id                                                 
  --                                                      
   /*--- for API get EXCHANGE RATE from roster ---*/                                               
                                                       
     --   SELECT                                                         
     --    @roster_agent_settlement_rate = sellRate,                                               
     --    @roster_payout_settle_rate = buyRate,                                                      
     --    --@exchangerate = sellRate,                                                        
     --    --@round_by = Round_By,                                                        
     --    @isSlab = NULL                                                       
     --   FROM Roster where country=@API_senderCountry                                               
                                          
     -- SET @ext_payout_amt = @payoutamt * @today_dollar_rate                                               
    SET @ext_settlement_amt = @payoutamt--@ext_payout_amt/ @today_dollar_rate                                              
                                                                     
     END                                    
     ELSE                                  
      BEGIN                                  
     SELECT 'ERROR',                                          
      '1006',                                          
      'Error!! Unable to Get Rates.'                                         
       RETURN                                     
      END                                     
--################### END GETTING ALL RATES  ##############################                                          
                                               
                               
-- ------------######### New Charge from function                                          
-- DECLARE @error_status VARCHAR(50),@error_msg VARCHAR(100),@superAgent_commission MONEY                          
-- IF EXISTS(SELECT Exc_STATUS FROM dbo.FNAGetServiceCharge(@agentid,@payout_agent_id,@paidamt,@paymenttype,@branch_code,@receivercountry,NULL))                                          
-- BEGIN                                          
--  SELECT                                           
--   @error_status=Exc_STATUS,                                          
--   @error_msg=msg,                                          
--   @new_scharge = service_charge,                                          
--         @sendercommission = send_commission,                                          
--         @agent_receiverSCommission = paid_commission,                                          
--         @superAgent_commission=superAgent_commission                                          
--  FROM  dbo.FNAGetServiceCharge(@agentid,@payout_agent_id,@paidamt,@paymenttype,@branch_code,@receivercountry,NULL)                                          
-- END                                          
                                           
-- IF @error_status IS NOT NULL                                          
-- BEGIN                           
--  SELECT 'ERROR',                                          
--            '2012',                                          
--            'Error!! '+@error_msg                                          
--     RETURN                                          
-- END                                          
                                                
 IF @round_by IS NULL                                              
SET @round_by = 0                                              
                                               
 IF @exchangerate IS NULL --or @round_by is null                                              
 BEGIN                  
     SELECT 'ERROR',                                              
            '1007',                                     
            'Error!! ExchangeRate Not Defined!!'                                              
                                            
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
                         
  ------ Muthoot Update Anywhere                                              
  --if @receivercountry='India' and @paymenttype='Cash Pay' and @payout_agent_id is NULL                                              
  -- select @payout_agent_id=agentcode FROM tbl_integrated_agents tia with (nolock) WHERE tia.agentName='Royal Exchange'                                              
  ------ Muthoot end                                              
                                                
 ---Check Premium rate                                             
                                        
 IF ISNULL(@bonus_amt, 0) <> 0                      
    AND @bonus_on = 's' AND @customer_category_id IS NOT NULL                                           
 BEGIN                                            
     DECLARE @check_bonus_value  MONEY,                                            
    @share_expenses     CHAR(1),                                          
             @check_premium_rate MONEY                                         
                                                 
     SELECT top 1 @check_bonus_value = bonus_value/*,                                           
            @share_expenses = ISNULL(share_expenses, 'p'),                                          
            @check_premium_rate=isNull(premium_rate,0)*/                                            
     FROM   bonus_setup with (nolock)                                            
     WHERE  bonus_enable = 'e'                                            
            AND agentid = @agentid                                            
            AND country = @receivercountry                                          
           -- AND category_id=@customer_category_id                                          
            /*AND isNUll(payout_agent_id,@payout_agent_id)=@payout_agent_id                                        
  ORDER BY isNUll(payout_agent_id,'1') DESC*/                                         
                                       
     IF @bonus_amt <> ISNULL(@check_bonus_value, 0)                                            
     BEGIN                                            
         SELECT 'ERROR',                                
                '1008',                                            
                'Bonus Amt is Invalid. Please re-try it again'                                            
                                                     
         RETURN                                            
     END                             
     IF @check_premium_rate<>isNUll(@premium_rate,0)                                           
     BEGIN                                          
      SELECT 'ERROR',                                            
                '1009',                                            
                'Premium Rate is Invalid. Please re-try it again'                                            
                                                     
         RETURN                                          
     END                               
                                             
     IF @check_premium_rate <>0                                           
     BEGIN                                          
      SET @today_dollar_rate = @today_dollar_rate + @check_premium_rate                                           
     END                                          
     IF @share_expenses = 'p' --- bear by payout agent                                     
     BEGIN                                            
         SET @agent_receiverSCommission = ISNULL(@agent_receiverSCommission, 0) -@bonus_amt                                            
  END                                            
                                                 
     IF @share_expenses = 's' --- bear by send agent                                            
     BEGIN                                            
         SET @sendercommission = ISNULL(@sendercommission, 0) -@bonus_amt                                            
END                                            
                                                 
     IF @share_expenses = 'h' --- half/half                                            
     BEGIN                                            
         SET @sendercommission = ISNULL(@sendercommission, 0) -(@bonus_amt / 2)                                                
         SET @agent_receiverSCommission = ISNULL(@agent_receiverSCommission, 0)                                            
             -(@bonus_amt / 2)                                            
     END                                            
 END                                            
                                                
                                               
 SET @receiveamt    = @payoutamt                                                     
 SET @totalroundamt = ROUND(@payoutamt, @round_by, 1)                                
                                                         
 IF ISNULL(@totalroundamt, 0) <= 0                                              
    OR ISNULL(@paidamt, 0) <= 0                                              
 BEGIN                                              
     SELECT 'ERROR',                                              
            '1010',                                              
            'Error!! Invalid Payout Amount!!'                                                             
     RETURN                                              
 END                                              
                                                 
 IF @sendercommission IS NULL                                   
     SET @sendercommission = 0                                                    
                                               
                                               
 DECLARE @rbankname       VARCHAR(150),                                              
         @rbankbranch     VARCHAR(150),                                              
         @receiveagentid  VARCHAR(50),                                              
         @payout_country  VARCHAR(100),                                              
         @branch_group    VARCHAR(500)                                                    
                                            
 IF @rbankid IS NOT NULL                                              
 BEGIN                                              
     SELECT @receiveagentid = a.agentcode,                                              
            @rbankname = a.companyName,                                              
            @rBankBranch = b.branch,                                       
            @branch_group = b.branch_group,                                        
            @mileage_point=isNull(a.mileage_points_per_txn,0)                                              
     FROM   agentdetail a with (nolock)                                          
            JOIN agentbranchdetail b with (nolock)                                              
        ON  a.agentcode = b.agentcode                                              
     WHERE  agent_branch_code = @rbankid                                              
 END                      
 ELSE                                              
 BEGIN                                              
     SELECT @receiveagentid = agentcode,                                              
            @rbankname = companyName,                                        
            @mileage_point=isNull(a.mileage_points_per_txn,0)                    
     FROM   agentdetail a                                             
     WHERE  agentcode = @payout_agent_id                                              
 END                             
                                               
 IF @paymenttype='Cash Pay'                                              
 BEGIN                              
   SET @rbankacno   = NULL                                               
   SET @ben_bank_id = NULL                                               
 END                            
                                         
IF @mileage_enable='y'                                         
 SET @mileage_earn=@mileage_point                                        
 -------CHECK sCharge from API --------------                  
 IF @scharge IS NULL                  
 BEGIN                  
  SELECT 'ERROR',                                              
            '1011',                                              
            'Invalid Service charge. Please Re-try'                                                           
     RETURN                    
 END                                
 ------ check Bonus condition on Service Charge                                                                             
-- IF @scharge + ISNULL(@bonus_amt, 0) <> @new_scharge                                              
--    AND ISNULL(@bonus_on, 's') = 's'                                      
-- BEGIN                                              
--     SELECT 'ERROR',                                              
--            '1011',                                              
--            'Invalid Service charge. Please Re-try'                                                           
--     RETURN                                              
-- END                                              
--                                            
-- IF @scharge <> ISNULL(@new_scharge, 0)                                              
--    AND ISNULL(@bonus_on, 's') = 'x'                                              
-- BEGIN                                      
--     SELECT 'ERROR',                                              
--            '1012',                                              
--      'Invalid Service charge. Please Re-try'                                              
--                                                   
--     RETURN                             
-- END                                              
                                               
 SELECT @receivectype   = currencyType,                                              
        @payout_country = country                                              
 FROM   agentdetail WITH (NOLOCK)                                              
 WHERE  agentcode = @payout_agent_id                                              
                                             
-- IF @payout_country <> 'MALAYSIA'                                     
-- BEGIN                                              
--     SELECT 'ERROR',                                              
--            '1013',                                              
--            'Payout agent and country doesn''t matched'                                              
--                                                   
--     RETURN                                              
-- END                                              
                                         
 IF @ben_bank_id IS NOT NULL     BEGIN                                              
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
 DECLARE @payout_settle_usd float                                      
 SET @payout_settle_usd = isnull(@ho_dollar_rate,0)  --[from CIMB_API_rates table]                   
                                 
-- SELECT @payout_settle_usd = buyRate                                              
-- FROM   Roster WITH (NOLOCK)                                              
-- WHERE  payoutagentid = @payout_agent_id                                              
--                                               
-- IF @payout_settle_usd IS NULL                                              
--     SELECT @payout_settle_usd = buyRate                                              
--     FROM   Roster WITH (NOLOCK)                                              
--     WHERE  country = @receivercountry AND payoutagentid IS NULL                                              
--                                               
-- IF @payout_settle_usd IS NULL                                              
--     SET @payout_settle_usd = @ho_dollar_rate                                               
 ----------- end -----------------------------------------------                            
 ----------HARD CODE for IME Nepal IRH Rate----------------                                                    
                                               
 ------------Retrive Send Settlement USD Rate ----------------                                                    
-- DECLARE @send_settle_usd MONEY                                                    
-- SELECT @send_settle_usd = sellRate                                              
-- FROM   Roster WITH (NOLOCK)                                              
-- WHERE  payoutagentid = @agentid                                              
--                                               
-- IF @send_settle_usd IS NULL                                              
--     SELECT @send_settle_usd = sellRate                                              
--     FROM   Roster WITH (NOLOCK)                                              
--     WHERE  country = @sendercountry AND payoutagentid IS NULL                                               
--                                               
-- IF @send_settle_usd IS NULL                                              
--     SET @send_settle_usd = @exchangerate                                               
 ----------- end -----------------------------------------------                                                    
                                               
 IF @flag = 'i'                      
 BEGIN                                              
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
                                                      
     DECLARE @bankcom       MONEY,                                              
             @amt1          MONEY,                                           
             @bankamt1      MONEY,                                              
             @bankamt2      MONEY,                                              
             @transfertype  VARCHAR(50)                                               
    --retriving bank commision                                                    
     IF @paymenttype = 'bank transfer'                                           
     BEGIN                                              
         SELECT @transfertype = agentbranchdetail.transfertype,                                              
                @bankamt1 = CASE transfertype                                              
                                 WHEN 'fax' THEN forfax1                                              
                                 WHEN 'tt' THEN fortt1                                              
                                 WHEN 'draft' THEN fordraft1                                              
                          ELSE 0                                              
                            END,                                              
                @bankamt2 = CASE transfertype                                              
                                 WHEN 'fax' THEN forfax2                               
                                 WHEN 'tt' THEN fortt2                                              
           WHEN 'draft' THEN fordraft2                                              
                                 ELSE 0                                              
                           END,                                              
                @amt1 = amt1,                                              
                @payoutcomm = imebanktransfer                                              
         FROM   agentbranchdetail WITH (NOLOCK)                                              
                INNER JOIN bankcommissionrates                                              
                     ON  agentbranchdetail.agentcode = bankcommissionrates.agent_code                
         WHERE  agentbranchdetail.agent_branch_code = @rbankid                                          
                                                       
         IF @totalroundamt >= @amt1                                              
         BEGIN                                              
         SET @bankcom = @bankamt1                                              
         END                                              
         ELSE                               
         BEGIN                                              
             SET @bankcom = @bankamt2                                              
         END                                           
     END                                              
     ELSE                                              
     BEGIN                                              
         --retriving cash commision                                                    
         SET @bankcom = 0                                               
         --set @rbankname=NULL                                                    
         SET @payoutcomm = 0                                               
         --set @rbankbranch=NULL                                                    
         SET @transfertype = 'CashPay'                  
     END                                               
                                             
     IF @rBankBranch IS NULL OR @paymenttype='Account Deposit to Other Bank'                                        
        SET @rBankBranch=@rbankactype                                        
                                                
     -- customer detail ###################                                                    
     IF @payoutcomm IS NOT NULL                                
         SET @totalroundamt = @totalroundamt -@payoutcomm                                                    
                                                   
     DECLARE @cust_sno             BIGINT                             
     DECLARE @check_customer_name  VARCHAR(100),@check_senderpassport VARCHAR(50)                                              
                                                   
     IF @customerid IS NOT NULL                                              
     BEGIN                                              
      set @customerid=ltrim(rtrim(@customerid))                                              
         SELECT @customerid = customerid,                                              
                @check_customer_name = SenderName,                                              
                @cust_sno = sno,                                              
                @check_senderpassport=senderpassport                                              
         FROM   customerdetail WITH (NOLOCK)                                              
         WHERE  customerid=@customerid                                              
         -- senderpassport = @senderpassport                                              
                                                       
         IF @check_customer_name IS NOT NULL                                              
         BEGIN                                              
             IF @customer_type = 'i'                                              
             BEGIN                                              
                 SELECT 'ERROR',                                              
                        '2001',                                              
                        'Sender ID ' + @customerid +                                               
                        ' Already exists TXN NOT saved!!!'                                              
                                                               
                 RETURN                                              
             END                                              
                                                           
             IF REPLACE(@check_customer_name, ' ', '') <> REPLACE(@sendername, ' ', '')                                    
             BEGIN                                              
                 SELECT 'ERROR',                                              
               '2002',                                    
                        'Sender ID ' + @customerid + ' ' + @sendername +                                               
          ' Doesnot matched existing customer detail!!!'                                              
                                                               
     RETURN                                              
             END                                              
                                                           
             IF exists(SELECT sno FROM customerDetail cd with (nolock) WHERE cd.senderPassport=@senderpassport                                               
             AND cd.CustomerId <> @customerid)                                              
             BEGIN                                               
               SELECT 'ERROR',                                              
                        '2003',                                              
                        'Sender Passport ' + @senderpassport + ' found duplicate with other customer detail'                                              
                                                               
                 RETURN                                              
             END                                              
             SET @customer_type = 'u'               
         END                                              
                                                        
     END                                               
     ELSE                                    
     BEGIN                                             
          SET @customer_type = 'i'                                               
     END                                              
                                               
     IF @customer_type = 'i'                                              
     BEGIN                                              
      SET @cust_sno = IDENT_CURRENT('customerdetail') + 2                                                    
         IF EXISTS (                                              
                SELECT customerid                                              
                FROM   customerdetail WITH (NOLOCK)                                              
                WHERE  customerid = @customerid                                              
            )                                              
   BEGIN                                              
             SET @customerid = UPPER(LEFT(LTRIM(@sendername), 1)) + UPPER(LEFT(LTRIM(@receivername), 1))                                               
                 + CAST(@cust_sno AS VARCHAR)                                              
     END                                               
         IF exists(SELECT sno FROM customerDetail cd with (nolock) WHERE cd.senderPassport=@senderpassport                                               
             )              BEGIN                                               
               SELECT 'ERROR',                                              
                        '2004',                                              
                        'Sender Passport ' + @senderpassport + ' found duplicate with other customer detail'                                              
                                                               
                 RETURN                                              
            END                                              
            if @customerid is null                                              
    begin                                              
      SET @customerid = UPPER(LEFT(LTRIM(@sendername), 1)) + UPPER(LEFT(LTRIM(@receivername), 1))                                               
                 + CAST(@cust_sno AS VARCHAR)                                               
 end                                              
         --new customer                                                   
                                          
         INSERT INTO customerdetail                                              
           (                                              
             customerid,                                              
             sendername,                          
             senderaddress,                                              
             senderphoneno,                                       
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
             salary_earn,                                              
             relation,                                              
             sendermobile,                                              
             receivermobile,                                              
             sendernativecountry,                                              
             trn_date,                                              
             trn_amt,                                              
             senderFax,                          
             ReceiverIDDescription,                                              
             ReceiverID,                                              
             receiverID_placeOfIssue,                                              
             mileage_earn,                                              
             source_of_income,                              
             reason_for_remittance,                                              
             reg_agent_id,                                              
             c2c_receiver_code,                                              
             sender_occupation,                                                                    
             employmentType,                                              
             gender,                                              
             receiverFax,                                              
             receiverEmail,                                              
             id_place_of_issue,                                              
             Date_of_Birth,                                              
             ID_Issue_date,                                          
             source_of_income_other,                      
             sender_occupation_other ,                                        
             create_ts                                        
           )                                              
                                               
         VALUES                                              
           (                                              
 @customerid,                                              
             upper(@sendername),                                              
             @senderaddress,                                              
          @senderphoneno,                                              
             @sendercity,                                              
             @sendercountry,                                              
             @senderemail,                                              
             @sendercompany,                                              
             @senderpassport,                                              
             @sendervisa,                                              
             upper(@receivername),                                              
             @receiveraddress,                                              
         @receiverphone,                                              
             @receivercity,                                              
             @receivercountry,                                              
             @sendersalary,                                              
             @receiverrelation,                    
             @sendermobile,                                              
             @receivermobile,                                              
             @sender_native_country,                                              
     @gmtdate,                                              
             @paidamt,                                              
             @txtsPassport_type,                                              
             @ReceiverIDDescription,                                              
  @ReceiverID,                                              
             @receiverID_placeOfIssue,                                              
             @mileage_earn,                                              
             @source_of_income,                                              
             @reason_for_remittance,                                              
             @agentid,                                              
             @c2c_receiver_code,                                              
             @sender_occupation,                                 
             @employmentType,                                              
             @gender,                                              
             @receiverFax,                               
             @receiverEmail,                                                                    
             @id_place_of_issue,                                          
             @Date_of_Birth,                                              
             @ID_Issue_date ,                                          
             @source_of_income_other,                      
             @sender_occupation_other    ,                                                         
             GETDATE()                                          
         )                                                   
                                                                        
     SELECT @cust_sno = sno   FROM   customerdetail WITH (NOLOCK)                                              
         WHERE  customerid = @customerid                                               
     END                    
                                                 
     ELSE IF @customer_type = 'u'                                              
     BEGIN  SET @customerid = LTRIM(RTRIM(@customerid))                                                  
         SELECT @cust_sno = sno                                              
         FROM   customerdetail WITH (NOLOCK)                                              
         WHERE  customerid = @customerid                                    
         -- update customer                                                    
         UPDATE customerdetail                                              
         SET    sendername = upper(@sendername),                                             
                senderaddress = @senderaddress,                                              
                senderphoneno = @senderphoneno,                                              
        sendercity = @sendercity,                                              
                sendercountry = @sendercountry,                                              
    senderemail = @senderemail,                                              
                sendercompany = @sendercompany,                                              
                senderpassport = @senderpassport,                                              
                sendervisa = @sendervisa,                                              
                receivername = upper(@receivername),                                              
                receiveraddress = @receiveraddress,                                              
                receiverphone = @receiverphone,                                              
                receivercity = @receivercity,                                              
                receivercountry = @receivercountry,                                              
                salary_earn = @sendersalary,                                              
                relation = @receiverrelation,                       
                sendermobile = @sendermobile,                                              
                receivermobile = @receivermobile,                                              
                sendernativecountry = @sender_native_country,                                              
                trn_amt = CASE                                               
                               WHEN CONVERT(VARCHAR, trn_date, 102) = CONVERT(VARCHAR, GETDATE(), 102) THEN                                               
                                    ISNULL(trn_amt, 0) + @paidamt                                              
                               ELSE @paidamt                                              
                          END,                                              
                trn_date = @gmtdate,                                 
                senderFax = @txtsPassport_type,                                              
                ReceiverIDDescription = @ReceiverIDDescription,                                              
                ReceiverID = @ReceiverID,                                              
                receiverID_placeOfIssue = @receiverID_placeOfIssue,                                              
                mileage_earn = ISNULL(mileage_earn, 0) + ISNULL(@mileage_earn, 0),                                              
                source_of_income = @source_of_income,                                              
                reason_for_remittance = @reason_for_remittance,                                              
                c2c_receiver_code = @c2c_receiver_code,                                          
                sender_occupation = @sender_occupation,                                              
                --senderState=@senderState,                                              
                --employmentType=@employmentType,                                              
                gender=@gender,                                              
                receiverFax=@receiverFax,                                              
                receiverEmail=@receiverEmail,                                              
                --customerType=@customerType,                                              
             id_place_of_issue=@id_place_of_issue,                                              
             Date_of_Birth=@Date_of_Birth,                                              
             ID_Issue_date=@Id_issue_date  ,                                          
             --relation_other=@relation_other,                                          
             source_of_income_other=@source_of_income_other,                                          
             sender_occupation_other=@sender_occupation_other    ,                                        
               -- update_by = @sempid,                                        
                update_ts = GETDATE(),                                        
                --agentCode = @agentid,                                        
                --branchCode = @branch_code,                                        
               -- create_by = ISNULL(create_by,@sempid),                                        
                create_ts = ISNULL(create_ts,GETDATE())                                               
         WHERE  sno = @cust_sno                      
     END                                                    
                                              
     IF @payoutcomm IS NULL                                              
         SET @payoutcomm = 0                                               
                                                   
     ------------FX Sharing calc-------------------------                              
     DECLARE @send_share           FLOAT,                                              
             @payout_fx_share      FLOAT,                                              
             @Head_fx_share        FLOAT,                                              
             @check_agent_ex_gain  MONEY                                                    
                  
     IF @agent_settlement_rate = @today_dollar_rate                                              
         SET @agent_ex_gain = 0                                                    
                                                   
     SET @check_agent_ex_gain = (                                              
             (@agent_settlement_rate -@today_dollar_rate) * (@paidamt - @scharge)                                              
         ) / @agent_settlement_rate                     
                                                   
     --if cast(round(round(@agent_ex_gain,3),0) as money)<> cast(round(@check_agent_ex_gain,0) as money)                                                    
--     IF (@check_agent_ex_gain -@agent_ex_gain) > 0.5                                              
--     BEGIN                                              
--         SELECT 'ERROR',                                              
--                '5010',                                              
--                CAST(ROUND(ROUND(@agent_ex_gain, 2), 0) AS VARCHAR) +                                              
--                'Session Expired, Please re-do transaction' +                                              
--                CAST(ROUND(@check_agent_ex_gain, 0) AS VARCHAR)                                              
--                                                       
--       --  ROLLBACK TRANSACTION                                               
--         RETURN                                              
--   END                                               
     -----------end FX Sharing---------------                                                    
                                                  
     DECLARE @tranno     BIGINT,               
             @dot        DATETIME,                                              
             @dottime    VARCHAR(20),                                              
             @rnd_id     VARCHAR(4),                                              
             @trannoref  BIGINT                                                    
                                                   
     SET @dot = CONVERT(VARCHAR, GETDATE(), 101)                                                    
     SET @dottime = CONVERT(VARCHAR, GETDATE(), 108)                                                    
                                                   
     SET @rnd_id = LEFT(ABS(CHECKSUM(NEWID())), 2)         
                                                   
     --set @tranno=ident_current('moneysend') + 1                                                    
     SET @trannoref = IDENT_CURRENT('tbl_refno') + 1                                                    
                                              
       SET @refno = 'T'+ @rnd_id + '1' + LEFT(CAST(@trannoref AS VARCHAR), 4)                                              
          + REVERSE(SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3))                                               
         + RIGHT(CAST(@trannoref AS VARCHAR), 1) + LEFT(ABS(CHECKSUM(NEWID())), 2)        
                                   
     IF @allow_exrate_change IS NULL                                              
         --set @today_dollar_rate=@agent_settlement_rate                                                    
                                                       
         DECLARE @confirmDate DATETIME,                                              
                 @approved_by VARCHAR(50),@process_transStatus VARCHAR(50)                                              
                                                   
  SET @process_transStatus='Staging'                                              
     IF @transstatus = 'Payment'                                              
     BEGIN                                              
         SET @confirmDate = @gmtdate                                                 
         SET @approved_by = @sempid                                              
     END                                              
                                                   
     DECLARE @enc_refno VARCHAR(50)                                            
     SET @enc_refno = dbo.encryptdb(@refno)                                                    
                                                        
     DECLARE @duplicate_TXN       VARCHAR(500),                                              
             @compliance_flag     CHAR(1),                                              
             @compliance_sys_msg  VARCHAR(500),                                              
             @compliance_refno VARCHAR(50)                                              
                                                   
     SELECT TOP 1 @duplicate_TXN = Tranno,@compliance_refno=dbo.decryptDb(refno)                                              
     FROM   moneysend WITH (NOLOCK)                                         
     WHERE  SenderName = RTRIM(LTRIM(@sendername))                                              
            AND ReceiverName = RTRIM(LTRIM(@receivername))                                              
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
                    '3001',                                        
                   'Similar Transaction Found'                                              
                                                         
            RETURN                                              
         END                                              
         ELSE                                              
         BEGIN                                              
             SET @compliance_flag = 'y'                                                  
             SET @compliance_sys_msg = 'Duplicate Suspected : '+@compliance_refno                                              
         END                             
     END           
-------- COMPLIANCE CHECKING --------------------      
 IF EXISTS(SELECT * FROM temp_compliance_log tcl WHERE tcl.process_id=@session_id)                
  BEGIN                 
  SET @compliance_flag='y'                          
    SET @compliance_sys_msg= case when @compliance_sys_msg is null then 'Transaction is in Compliance'                           
    else @compliance_sys_msg + 'Transaction is in Compliance' End                 
  END          
----------------------------------------------------      
      
------ ADDED FOR INTEGRATED AGENT SAVE -------------      
     DECLARE @status VARCHAR(50)                                                  
     SET @status = 'Un-Paid'                                                  
     IF EXISTS (                                              
            SELECT agentcode                                              
            FROM   tbl_integrated_agents                                              
            WHERE  agentcode = @payout_agent_id                                              
                   --AND ISNULL(paymentType, @paymenttype) = @paymenttype                                              
        )                                              
     BEGIN                                              
        SET @status = 'Post'                                                  
  if @ofac_list ='y' OR @ofac_list IS NOT NULL                       
   set @transstatus='OFAC'                       
  if @compliance_flag ='y' OR @compliance_flag IS NOT NULL                            
   set @transstatus='Compliance'                                             
     END                                               
-------- INTEGRATED AGENT END ------------------------                                                                             
                                                  
     IF EXISTS (SELECT * FROM tbl_refno tr WHERE tr.refno=@enc_refno)                                              
     BEGIN                                              
          SELECT 'ERROR',                                              
           '3002',                                              
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
                                                      
                                                
BEGIN TRANSACTION                                                           
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
         --c2c_secure_pwd,                                           
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
        -- senderState,                                              
         employmentType,                                              
         gender,                                              
receiverFax,                                              
         receiverEmail,                                              
         customerType,                                              
         id_place_of_issue,                                              
         Date_of_Birth,                                        
         ID_Issue_date   ,                                          
         relation_other,                                      
         source_of_income_other,                                      
         sender_occupation_other ,                                          
         agent_receiverCommission,                                      
         agent_receiverComm_Currency,                                        
         ben_bank_branch_extid,                                        
         premium_rate,                                    
         --#### ADDED FOR API ####                                    
         Send_Settle_USD ,                                    
         xm_exRate ,                        
         ext_sCharge ,                                    
         ext_payout_amount,                                    
         ext_settlement_amt,                                    
         PNBReferenceNo,                                    
         TestAnswer ,                                    
         c2c_secure_pwd ,                                    
         c2c_pin_no,                              
         --receiverState,                              
   --paid_beneficiary_id_expire_date ,                              
   fax_trans, --receiver Gender M=male or F=Female                                        
   confirm_process_id          
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
         UPPER(@receivername),                                              
         @receiveraddress,                                              
         @receiverphone,                                              
         @receivercity,                                    
         @receivercountry,                                              
         @receiverrelation,                                              
         @dot,                                              
         @dottime,                                              
         @paidamt,          --PaidAmt                                    
         @exp_PaidCtype,    --Paidctype,                                              
         @receiveamt,       --@paidamt-@scharge ,--receiveAmt,                                              
         @exp_receiveCtype, --receivectype,                                              
         @exchangerate,                                              
		 @today_dollar_rate,--[today_dollar_rate]                                              
         @dollar_amt,                                              
         @scharge,                                        
         @branch_voucher,                                              
         @paymenttype,                                              
         @rbankid,                                              
         @rbankname,                                              
         @rBankBranch,                                              
         LTRIM(RTRIM(@rbankacno)),                                              
         @rbankactype,                                        
         @othercharge,                                              
         @transstatus,/*@process_transStatus,*/                                             
         @status,                                             
         @sempid,                                              
         @payoutcomm,                                              
   @bankcom,                                              
         @totalroundamt,                                              
         @transfertype,                                              
         @sendercommission,                                              
         @receiveagentid,                                              
         @send_mode,                                              
         @gmtdate,                                              
         @sendermobile,                                       
         @receivermobile,                                              
         @sender_native_country,                                              
         @ip_address,                                              
         @agent_dollar_rate,                                              
   @ho_dollar_rate,                                              
         @bonus_amt,                                              
    @request_new_account,                                              
         @digital_id_sender,                                              
         @payout_agent_id,                                              
    @today_dollar_rate, --bonus_value_amount [Agent_settlement_rate]                                             
         @bonus_type,                                              
         @bonus_on,                                              
         @ext_bank_id,                                              
         @ben_bank_name,                                              
         @payout_agent_id,                                              
         @ReciverMessage,                                              
         @send_sms,                                              
    '1',--@agent_settlement_rate                                    
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
    @payout_settle_usd, --payout_settle_usd                                             
         @c2c_receiver_code,                                              
         --@c2c_secure_pwd,                                              
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
       --@senderState,                                              
       @employmentType,                                             
       @gender,                                              
       @receiverFax,                                              
       @receiverEmail,                                              
       @customerType,                                              
      @id_place_of_issue,                                              
       @Date_of_Birth,                                              
       @ID_Issue_date  ,                                          
       @relation_other,                                      
       @source_of_income_other,                                      
       @sender_occupation_other  ,                                          
       @agent_receiveingComm,                                      
       @agent_receiverComm_Currency,                                    
     @ben_bank_branch_extid,                                        
       @premium_rate ,                                    
       --##### ADDED FOR API #####                                    
       @exchangerate,                                    
       @today_dollar_rate,                                    
       @scharge,                                    
       @payoutamt,                                    
       @ext_payout_amt,     --@ext_settlement_amt ,                                    
       @exp_receiveCtype,                                    
       @send_USDrate,                
       @c2c_secure_pwd,                                    
       @sChargeUSD ,                              
       --@receiverState,                              
    --@beneficary_id_expire_date ,                              
    @rGender,          
    @API_Session                                     
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
          pending_id                                        
        /* bank_serial_no*/                                              
       )                                              
     SELECT bankcode,                                              
            deposit_detail1,                                              
            deposit_detail2,                                              
            amtpaid,                                              
            depositdot,                                              
            @tranno,                                              
            pending_id/*,                                              
           @branch_voucher*/                                              
     FROM   session_deposit_log t WITH (NOLOCK)                                              
     WHERE  session_id = @session_id                                              
           AND CONVERT(VARCHAR, update_ts, 102) = CONVERT(VARCHAR, GETDATE(), 102)                                               
                          
COMMIT TRANSACTION                                              
                                                                                         
                                           
 IF EXISTS(SELECT * FROM temp_compliance_log tcl WHERE tcl.process_id=@session_id)                
 BEGIN                 
   INSERT INTO TransactionNotes                
   (                        
    RefNo,                
    Comments,                
    DatePosted,                
    PostedBy,                
    uploadBy,                
    noteType,                
    tranno,                
    [status]                
                    
   )                
   select distinct                
   @enc_refno,                
   prsv.RuleName,                
   dbo.GETDATEHo(getutcdate()),                
   'system',                
prsv.RuleName,                
   '3',                
   @tranno,                
   tcl.compliance_id                   
   FROM temp_compliance_log tcl JOIN PaymentRule_Setup_v2 prsv                
   ON tcl.compliance_id=prsv.sno                
   WHERE tcl.process_id=@session_id                
 END                 
               
                                              
     -- LIMIT PER DAY CALCULATION                                              
     ---- WHY THIS IS ADDED                                              
     -- if @limit_date is null or convert(varchar,@limit_date,102)<>convert(varchar,getdate(),102)                                              
     --  update agentdetail set trn_limit_date=getdate(),                                              
     --  trn_limit_balance=isNUll(trn_limit_per_day,0)-(@paidamt-(@sendercommission+isNull(@agent_ex_gain,0)))                                              
     --   where agentcode=@agentid and trn_limit_per_day is not null       
     -- else                                              
     --  update agentdetail set  trn_limit_balance=isNUll(trn_limit_balance,0)-(@paidamt-(@sendercommission+isNull(@agent_ex_gain,0)))                                              
     --   where agentcode=@agentid and trn_limit_per_day is not null                                             
                                                   
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
                                                   
                                                   
                                                   
    IF @bonus_amt IS NOT NULL                                              
        AND @bonus_amt > 0                                              
     BEGIN                                              
         INSERT transactionNotes                                              
           (                                              
          refno,                                              
             comments,                                              
             datePosted,                                              
             postedby,                                              
             uploadBy,                                              
             notetype,                          
             tranno                                              
       )                                              
         VALUES                                              
           (                                              
             @enc_refno,                                              
             'Bonus Gain:' + CAST(@bonus_amt AS VARCHAR),                                              
             @gmtdate,                                              
             @sempid,                                              
             'S',                         
             0,                                              
  @tranno                                              
           )                                              
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
            @refno,                                              
            @customerid,                                              
            @tranno TRNNo                                                                       
 END                                              
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
        '[spa_Common_moneysend_SaveAPI]',                                              
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
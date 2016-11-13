set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
  
  
--exec spa_SOAP_createTXN_v2 'UCSB','APIUSER','APIUSER','5/13/2012 11:05:46 PM','2205860','TEST REMITTER NAME',Null,'0123456789','Kuala             
--Lumpur','Malaysia','Passport','909090','TEST REC','No 77, Road             
--name2','0123456789','katmandu','Nepal','50000','50000','c',Null,Null,'p','30107739',Null,'2012-12-18',Null,'110.159.158.74',NULL            
            
CREATE PROC [dbo].[spa_SOAP_createTXN_v2]            
    @accesscode VARCHAR(100),            
    @username VARCHAR(100),            
    @password VARCHAR(100),            
    @AGENT_REFID VARCHAR(50),            
    @AGENT_TXNID VARCHAR(50),            
    @SENDER_NAME VARCHAR(50),            
    @SENDER_ADDRESS VARCHAR(150),            
    @SENDER_MOBILE VARCHAR(100) = NULL,            
    @SENDER_CITY VARCHAR(100) = NULL,            
    @SENDER_COUNTRY VARCHAR(100),            
    @SENDERS_IDENTITY_TYPE VARCHAR(100) = NULL,            
    @SENDER_IDENTITY_NUMBER VARCHAR(100) = NULL,            
    @RECEIVER_NAME VARCHAR(100),            
    @RECEIVER_ADDRESS VARCHAR(100),            
    @RECEIVER_CONTACT_NUMBER VARCHAR(100) = NULL,            
    @RECEIVER_CITY VARCHAR(100) = NULL,            
    @RECEIVER_COUNTRY VARCHAR(100) = NULL,            
    @COLLECT_AMT MONEY,            
    @PAYOUTAMT MONEY,            
    @PAYMENTTYPE VARCHAR(50),            
    @BANKID VARCHAR(50) = NULL,            
    @BANK_ACCOUNT_NUMBER VARCHAR(100) = NULL,            
    @CALC_BY CHAR(1) = NULL,  ---- 'c' by Collected AMT, 'p' Payout amt            
    @LOCATIONID VARCHAR(50) = NULL,            
    @SENDER_ID_ISSUE_DATE VARCHAR(10) = NULL,            
    @SENDER_ID_EXPIRE_DATE VARCHAR(10) = NULL,            
    @SENDER_DATE_OF_BIRTH VARCHAR(10) = NULL,            
    @client_pc_id VARCHAR(50) = NULL,            
    @AUTHORIZED_REQUIRED CHAR(1) = 'n',        
  @OTHER_BANK_BRANCH_NAME VARCHAR(200) = NULL,        
  @BANK_BRANCHID VARCHAR(50)=NULL,        
  @SENDER_OCCUPATION VARCHAR(50)=NULL,        
  @SENDER_SOURCE_OF_FUND VARCHAR(50)=NULL,        
  @SENDER_BENEFICIARY_RELATIONSHIP VARCHAR(50)=NULL,        
  @PURPOSE_OF_REMITTANCE VARCHAR(50)=NULL,    
  @Waive_Fee char(1)=null        
              
AS            
    
declare @FreeAgentID varchar(50)    
set @FreeAgentID='20100231' --JAPAN REMIT FINANCE    
    
    
DECLARE @agentcode               VARCHAR(50),        
        @agent_branch_code       VARCHAR(50),        
        @user_pwd                VARCHAR(50),        
        @accessed                VARCHAR(50)        
            
DECLARE @Block_branch            VARCHAR(50),        
        @BranchCodeChar          VARCHAR(50),        
        @lock_status             VARCHAR(5),        
        @agent_user_id           VARCHAR(50)        
            
DECLARE @user_count              INT,        
        @limit_per_TXN           MONEY,        
        @agentname               VARCHAR(100),        
        @branch                  VARCHAR(100),        
        @gmtdate                 DATETIME,        
        @COLLECT_CURRENCY        VARCHAR(5),        
        @generate_partner_pinno  CHAR(1)            
            
IF @client_pc_id IS NULL        
    SET @client_pc_id = '192.168.1.100'        
            
BEGIN TRY        
 SET XACT_ABORT ON;            
 DECLARE @sql           VARCHAR(8000)            
 DECLARE @return_value  VARCHAR(1000)         
 --------------------Check Mandatory Fields            
 IF @username IS NULL        
    OR @password IS NULL        
    OR @accesscode IS NULL        
 BEGIN        
     SET @return_value = 'User information missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_NAME IS NULL        
 BEGIN        
     SET @return_value = 'Sender Name missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_ADDRESS IS NULL        
 BEGIN        
     SET @return_value = 'Sender Address missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_CITY IS NULL        
 BEGIN        
     SET @return_value = 'Sender City missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_COUNTRY IS NULL        
 BEGIN        
     SET @return_value = 'Sender Country missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @RECEIVER_NAME IS NULL        
 BEGIN        
     SET @return_value = 'Receiver Name missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @RECEIVER_COUNTRY IS NULL        
 BEGIN        
     SET @return_value = 'Receiver Country missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
 if @RECEIVER_CONTACT_NUMBER is NULL and @PAYMENTTYPE='H'        
 BEGIN        
  SET @return_value = 'RECEIVER_CONTACT_NUMBER is mandatory for Home Delivery Payment Type'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
 IF @PURPOSE_OF_REMITTANCE IS NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'PURPOSE_OF_REMITTANCE is mandatory for NFET Payment Type'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
 IF @SENDERS_IDENTITY_TYPE IS NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'SENDER_IDENTITY_TYPE is mandatory for selected PaymentType'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END         
 IF @SENDER_IDENTITY_NUMBER IS NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'SENDER_IDENTITY_NUMBER is mandatory for selected PaymentType'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END         
 IF @SENDER_ID_ISSUE_DATE IS NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'SENDER_ID_ISSUE_DATE is mandatory for selected PaymentType'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_ID_EXPIRE_DATE IS NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'SENDER_ID_EXPIRE_DATE is mandatory or selected PaymentType'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
 if not exists(SELECT static_data FROM static_values sv WHERE sv.sno=15 AND isNUll(sv.static_data,'')<>''        
 AND sv.static_data=@PURPOSE_OF_REMITTANCE) AND @PURPOSE_OF_REMITTANCE IS NOT NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'PURPOSE_OF_REMITTANCE is didnot matched, please verify with the List'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 if not exists(SELECT static_data FROM static_values sv WHERE sv.sno=8 AND isNUll(sv.static_data,'')<>''        
 AND sv.static_data=@SENDERS_IDENTITY_TYPE) AND @SENDERS_IDENTITY_TYPE IS NOT NULL AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'SENDERS_IDENTITY_TYPE is didnot matched, please verify with the List'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @RECEIVER_COUNTRY<>'India' AND @PAYMENTTYPE='N'        
 BEGIN        
  SET @return_value = 'NFET Payment Type allowed only in country INDIA'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
 IF @RECEIVER_ADDRESS IS NULL        
 BEGIN        
     SET @return_value = 'Receiver Address missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @COLLECT_AMT IS NULL        
 BEGIN        
     SET @return_value = 'TRANSFER AMOUNT missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @PAYMENTTYPE IS NULL        
 BEGIN        
     SET @return_value = 'Payment Type missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @CALC_BY IS NULL        
 BEGIN        
     SET @return_value = 'Calculate Method missing'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
 IF @AGENT_REFID IS NULL        
 BEGIN        
     SET @return_value = 'Agent SESSION ID is missing'            
     SELECT '1005' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF ISNUMERIC(@COLLECT_AMT) = 0        
 BEGIN        
     SET @return_value = 'COLLECT_AMT must be numeric value'            
     SELECT '1006' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 DECLARE @currentBalance          MONEY,        
         @allow_integration_user  CHAR(1),        
         @last_login              DATETIME,
		 @send_txn_without_balance char(1)
         
 SELECT @agentcode = a.agentcode,        
        @agentname = a.companyName,        
        @user_pwd = u.user_pwd,        
        @agent_user_id = u.agent_user_id,        
        @accessed = a.accessed,        
        @SENDER_COUNTRY = a.country,        
        @branch = b.branch,        
        @agent_branch_code = b.agent_branch_code,        
        @BranchCodeChar = b.BranchCodeChar,        
        @Block_branch = ISNULL(b.block_branch, 'n'),        
        @lock_status = ISNULL(u.lock_status, 'n'),        
        @COLLECT_CURRENCY = a.currencyType,        
        @gmtdate = DATEADD(mi, ISNULL(gmt_value, 345), GETUTCDATE()),        
        @currentBalance = (ISNULL(a.limit, 0) -ISNULL(a.currentBalance, 0)),        
        @limit_per_TXN = a.limitPerTran,        
        @allow_integration_user = ISNULL(u.allow_integration_user, 'n'),        
        @generate_partner_pinno = ISNULL(a.generate_partner_pinno, 'n'),        
        @last_login = last_login ,
		@send_txn_without_balance= ISNULL(a.send_txn_without_balance,'n')
 FROM   agentDetail a with(nolock)       
        JOIN agentbranchdetail b  with(nolock)      
             ON  a.agentcode = b.agentcode        
        JOIN agentsub u with(nolock)        
             ON  b.agent_branch_code = u.agent_branch_code        
 WHERE  u.user_login_id = @username        
         
 SET @user_count = @@rowcount         
         
         
 ----AUTHENTICATING USER----------            
 IF @user_count = 0        
 BEGIN     
     SET @return_value = 'Invalid User ID'            
     INSERT sys_access        
       (        
         ipadd,        
         LOGIN_TYPE,        
         log_date,        
         log_time,        
         branch_code,        
         emp_id,        
         USER_ID,        
         pwd,        
         msg,        
         STATUS        
       )        
     VALUES        
       (        
         @client_pc_id,        
         'SOAP_CreateTXN',        
         CONVERT(VARCHAR, GETDATE(), 102),        
         CONVERT(VARCHAR, GETDATE(), 108),        
         @accesscode,        
         NULL,        
         @username,        
         '******',        
         'Invalid User Name',        
         'Failed'        
       )            
     SELECT '1002' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN     END        
         
 IF @user_pwd <> dbo.encryptdb(@password)        
 BEGIN        
     SET @return_value = 'Invalid Password'            
     INSERT sys_access        
       (        
         ipadd,        
         LOGIN_TYPE,        
         log_date,        
         log_time,        
         branch_code,        
         emp_id,        
         USER_ID,        
         pwd,        
         msg,        
         STATUS        
       )        
     VALUES        
       (        
         @client_pc_id,        
         'SOAP_CreateTXN',        
         CONVERT(VARCHAR, GETDATE(), 102),        
         CONVERT(VARCHAR, GETDATE(), 108),        
         @accesscode,        
         @agent_user_id,        
         @username,        
         @password,        
         'Invalid Password',        
         'Failed'        
       )            
     SELECT '1002' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @BranchCodeChar <> @accesscode        
 BEGIN        
     SET @return_value = 'Agent ID invalid'            
     SELECT '1002' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @Block_branch = 'y'        
    OR @lock_status = 'y'        
 BEGIN        
     SET @return_value = 'Your userid is Blocked'            
     SELECT '1003' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END         
 --if @last_login IS NULL        
 --BEGIN        
 -- set @return_value='Your should changed your passsword'        
 -- select '9001' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID        
 -- return        
 --END             
         
 IF @allow_integration_user = 'n'        
 BEGIN        
     SET @return_value = 'Your userid is not allowed for Web Services'            
     SELECT '1003' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_ID_ISSUE_DATE IS NOT NULL        
    AND ISDATE(@SENDER_ID_ISSUE_DATE) = 0     
    AND @SENDER_ID_ISSUE_DATE <> ''        
 BEGIN        
     SET @return_value = 'Sender ID Issue Date is invalid Must be YYYY-MM-DD'            
     SELECT '1004' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_ID_EXPIRE_DATE IS NOT NULL        
    AND ISDATE(@SENDER_ID_EXPIRE_DATE) = 0        
    AND @SENDER_ID_EXPIRE_DATE <> ''        
 BEGIN        
     SET @return_value =         
         'Sender ID Expire Date is invalid Must be YYYY-MM-DD'        
             
     SELECT '1004' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @SENDER_DATE_OF_BIRTH IS NOT NULL        
    AND ISDATE(@SENDER_DATE_OF_BIRTH) = 0        
    AND @SENDER_DATE_OF_BIRTH <> ''        
 BEGIN        
     SET @return_value = 'Sender Date of Birth is invalid Must be YYYY-MM-DD'            
     SELECT '1004' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
         
 DECLARE @isError CHAR(1)        
 SELECT @isError = isError,        
        @PAYMENTTYPE = item        
 FROM   dbo.FNA_ApiGetPaymentType(@PAYMENTTYPE)        
         
 IF @isError IS NOT NULL        
 BEGIN        
     SELECT '3001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @PAYMENTTYPE MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
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
 -- select '3001' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID        
 -- return        
 --end            
         
 DECLARE @payout_branch_id  VARCHAR(50),        
         @payout_agent_id   VARCHAR(50)        
         
 SET @payout_branch_id = @LOCATIONID            
         
 DECLARE @check_anywhere CHAR(1)         
 --SELECT @check_anywhere=ISNULL(isanywhere,'n') FROM service_charge_setup WHERE agent_id=@agentcode        
 --AND rec_country= @RECEIVER_COUNTRY            
 SET @check_anywhere = 'n'            
         
         
 DECLARE @BANK_NAME               VARCHAR(100),        
         @PAYOUTCURRENCY          VARCHAR(5),        
         @max_payout_amt_cash     MONEY,        
         @BANK_BRANCH_NAME        VARCHAR(100),        
         @max_payout_amt_account  MONEY,        
         @branch_block            VARCHAR(50),        
         @payout_agent_status     VARCHAR(50),        
         @PAYOUT_COUNTRY          VARCHAR(100),        
         @Payout_AgentCan         VARCHAR(50),        
   @Branch_Type   Varchar(50)            
         
 SELECT @payout_agent_id = a.agentCode,        
        @BANK_NAME = companyName,        
        @payout_agent_status = a.accessed,        
        @BANK_BRANCH_NAME = CASE         
                            WHEN b.Branch_Type = 'AC Deposit' THEN         
                                      ISNULL(b.branch_group, '') + ' '        
                                 ELSE ''        
                            END + b.branch,        
        @Payout_AgentCan = a.agentCan,        
        @branch_block = ISNULL(block_branch, 'n'),        
        @PAYOUT_COUNTRY = a.country,        
        @PAYOUTCURRENCY = currencyType,        
        @max_payout_amt_cash = ISNULL(a.max_payout_amt_per_trans, 0),        
        @max_payout_amt_account = ISNULL(max_payout_amt_per_trans_deposit, 0),        
   @Branch_Type=b.Branch_Type        
 FROM   agentdetail a with(nolock)       
        JOIN agentbranchdetail b  with(nolock)      
             ON  a.agentcode = b.agentcode        
 WHERE  agent_branch_code = @payout_branch_id        
        AND a.accessed = 'Granted'        
        AND a.Country = @RECEIVER_COUNTRY            
-- select b.branch,* FROM   agentdetail a        
--        JOIN agentbranchdetail b        
--             ON  a.agentcode = b.agentcode        
-- WHERE  agent_branch_code = @payout_branch_id        
--        AND a.accessed = 'Granted'        
--        AND a.Country = @RECEIVER_COUNTRY         
         
 IF @check_anywhere = 'n'        
    AND (@payout_agent_id = '' OR @payout_agent_id IS NULL)        
 BEGIN        
     SET @return_value = 'Location Id is not provided or Location ID doesnt matched with PayoutCountry'            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
 IF @payout_agent_id IS NULL        
    AND @check_anywhere = 'n'        
 BEGIN        
     SET @return_value = 'Invalid Location ID'            
     SELECT '3003' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @branch_block = 'y'        
 BEGIN        
     SET @return_value = 'Location ID is not active'            
     SELECT '3004' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
 IF @check_anywhere = 'y'        
     SET @PAYOUT_COUNTRY = @RECEIVER_COUNTRY        
 ELSE         
 IF @Payout_Country <> @RECEIVER_COUNTRY        
 BEGIN        
     SET @return_value = 'Invalid Location ID and Country'            
     SELECT '3003' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
 DECLARE @check_bank     VARCHAR(50),        
         @ben_bank_name  VARCHAR(150),        
         @ben_bank_id    VARCHAR(50),        
         @ifsc_code  VARCHAR(50)        
                
         
 IF @PAYMENTTYPE = 'Account Deposit to Other Bank'        
 BEGIN        
     IF @BANKID IS NULL        
     BEGIN        
         SET @return_value =         
             'For Bank Transfer Location ID and Bank ID must be defined'        
                 
         SELECT '3002' Code,        
          @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
        
  if exists(SELECT 'x' FROM   commercial_bank cb with(nolock) JOIN commercial_bank_branch cbb with(nolock)       
     ON cb.Commercial_id=cbb.Commercial_id        
     WHERE  cbb.sno = @BANK_BRANCHID)        
  BEGIN        
  SELECT @check_bank = cb.COMMERCIAL_ID,        
            @ben_bank_name = cbb.bankName,        
            @ben_bank_id=cb.external_bank_id,        
            @OTHER_BANK_BRANCH_NAME=cbb.BranchName,        
            @ifsc_code=cbb.IFSC_Code        
     FROM   commercial_bank cb with(nolock) JOIN commercial_bank_branch cbb with(nolock)        
     ON cb.Commercial_id=cbb.Commercial_id        
     WHERE  cbb.sno = @BANK_BRANCHID        
  END        
  ELSE        
  BEGIN     
    --SET @ben_bank_id = @BANKID            
    SET @check_bank = NULL      
    IF EXISTS ( SELECT    'x'    
       FROM      dbo.commercial_bank with(nolock)   
       WHERE     Commercial_id = CASE WHEN ISNUMERIC(@BANKID)=0 THEN '00' ELSE @BANKID END     
        AND PAYOUT_AGENT_ID = @payout_agent_id )     
   BEGIN    
    SELECT  @check_bank = COMMERCIAL_ID ,    
      @ben_bank_name = BANK_NAME ,    
      @ben_bank_id = external_bank_id    
    FROM    commercial_bank with(nolock)   
    WHERE   commercial_id = @BANKID    
      AND PAYOUT_AGENT_ID = @payout_agent_id    
   END     
    ELSE     
   BEGIN    
    SELECT  @check_bank = COMMERCIAL_ID ,    
      @ben_bank_name = BANK_NAME ,    
      @ben_bank_id = external_bank_id    
    FROM    commercial_bank with(nolock)   
    WHERE   external_bank_id = @ben_bank_id    
      AND PAYOUT_AGENT_ID = @payout_agent_id     
   END         
            
  END             
        
     IF @check_bank IS NULL        
     BEGIN        
         SET @return_value = 'Payout BANK ID is invalid'            
         SELECT '3002' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
    END        
             
     IF @BANK_ACCOUNT_NUMBER IS NULL        
     BEGIN        
         SET @return_value = 'Bank Account No is blank'            
         SELECT '3010' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
     print @OTHER_BANK_BRANCH_NAME        
     SET @OTHER_BANK_BRANCH_NAME = RTRIM(LTRIM(@OTHER_BANK_BRANCH_NAME))         
         IF @OTHER_BANK_BRANCH_NAME='' OR @OTHER_BANK_BRANCH_NAME IS NULL        
         BEGIN        
           set @return_value='For Account Deposit to Other Bank payment mode OTHER_BANK_BRANCH_NAME is mandatory valid.'        
           select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID        
           return        
         END        
 END        
 IF @PAYMENTTYPE = 'Cash Pay BDP' and @branch_type <>'External'        
 BEGIN        
   SET @return_value =         
             'LOCATION_ID is not valid BDP Location'        
         SELECT '3002' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
 End        
 IF @PAYMENTTYPE = 'NEFT'        
 BEGIN        
     IF @BANK_BRANCHID IS NULL        
     BEGIN        
         SET @return_value =         
             'For NEFT LOCATION_ID and BANK_BRANCHID must be defined'        
         SELECT '3002' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
             
             
     SET @ben_bank_id = @BANKID            
     SET @check_bank = NULL            
             
     SELECT @check_bank = cb.COMMERCIAL_ID,        
            @ben_bank_name = cbb.bankName,        
            @ben_bank_id=cb.external_bank_id,        
            @OTHER_BANK_BRANCH_NAME=cbb.BranchName,        
            @ifsc_code=cbb.IFSC_Code        
     FROM   commercial_bank cb with(nolock) JOIN commercial_bank_branch cbb with(nolock)       
     ON cb.Commercial_id=cbb.Commercial_id        
     WHERE  cbb.sno = @BANK_BRANCHID        
            AND PAYOUT_AGENT_ID = @payout_agent_id        
             
     IF @check_bank IS NULL        
     BEGIN        
         SET @return_value = 'Payout Branch ID is invalid'            
         SELECT '3002' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
             
     IF @BANK_ACCOUNT_NUMBER IS NULL        
     BEGIN        
         SET @return_value = 'Bank Account No is blank'            
         SELECT '3010' Code,        
                @AGENT_REFID AGENT_REFID,        
      @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
             
     SET @OTHER_BANK_BRANCH_NAME = RTRIM(LTRIM(@OTHER_BANK_BRANCH_NAME))         
         --IF @OTHER_BANK_BRANCH_NAME='' OR @OTHER_BANK_BRANCH_NAME IS NULL        
         --BEGIN        
         --  set @return_value='For Account Deposit to Other Bank payment mode Bank branch is mandatory valid.'        
         --  select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID        
         --  return        
         --END        
 END        
 DECLARE @Branch_group VARCHAR(200)            
 IF @PAYMENTTYPE = 'Bank Transfer'        
 BEGIN        
     IF @Payout_AgentCan NOT IN ('Both', 'None')        
     BEGIN        
         SET @return_value =         
             'Select Location ID can not perform Account Deposit'        
                 
         SELECT '3002' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
             
     IF @BANK_ACCOUNT_NUMBER IS NULL        
     BEGIN        
         SET @return_value = 'Bank Account No is blank'            
         SELECT '3010' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
 END            
         
         
 DECLARE @ho_cost_send_rate                MONEY,        
         @ho_premium_send_rate             MONEY,        
         @ho_premium_payout_rate           MONEY,        
         @agent_customer_diff_value        MONEY,        
         @agent_sending_rate_margin        MONEY,        
         @agent_payout_rate_margin         MONEY,        
         @agent_sending_cust_exchangerate  MONEY,        
         @agent_payout_agent_cust_rate     MONEY,        
         @ho_exrate_applied_type           VARCHAR(20),        
         @scharge                          MONEY,        
         @sendercommission                 MONEY,        
         @agent_receiverSCommission        MONEY,        
         @ho_dollar_rate                   MONEY,        
         @agent_settlement_rate            MONEY,        
         @exchangerate                     MONEY,        
         @today_dollar_rate                MONEY,        
         @round_by                         INT,        
         @receiveamt                       MONEY,        
         @totalroundamt                    MONEY,        
         @Create_ts                        DATETIME            
         
 SELECT @ho_dollar_rate = x.DollarRate,        
        @agent_settlement_rate = x.NPRRate,        
        @exchangerate = x.exchangerate,        
        @today_dollar_rate = ISNULL(b.customer_rate, x.customer_rate),        
        @round_by = ISNULL(x.qtyCurrency, 2),        
        @ho_cost_send_rate = x.exchangeRate + ISNULL(x.agent_premium_send, 0),        
        @ho_premium_send_rate = ISNULL(x.agent_premium_send, 0),        
        @ho_premium_payout_rate = ISNULL(x.agent_premium_payout, 0),        
        @agent_customer_diff_value = ISNULL(x.customer_diff_value, 0),        
        @agent_sending_rate_margin = ISNULL(x.margin_sending_agent, 0),        
        @agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value, 0),        
        @agent_sending_cust_exchangerate = ISNULL(x.sending_cust_exchangerate, 0),        
        @agent_payout_agent_cust_rate = ISNULL(x.payout_agent_rate, 0),        
        @ho_exrate_applied_type = 'countrywise',        
        @PAYOUTCURRENCY = x.ReceiveCType        
 FROM   agentCurrencyRate x with(nolock)       
        LEFT OUTER JOIN agent_branch_rate b        
             ON  x.agentId = b.agentid        
             AND b.agent_branch_code = @agent_branch_code        
 WHERE  x.agentId = @agentcode        
        AND x.receiveCountry = @PAYOUT_COUNTRY        
        AND x.currencyType = @COLLECT_CURRENCY        
--        AND x.receiveCType <> 'USD'         
 --AND x.receiveCType=@PAYOUTCURRENCY            
         
 IF EXISTS(        
        SELECT Currencyid        
        FROM   agentpayout_CurrencyRate with(nolock)        
        WHERE  agentid = @agentcode        
               AND payout_agent_id = @payout_agent_id        
    )       
 BEGIN        
   --PRINT 'insert agent wise'            
     SELECT @ho_dollar_rate = x.DollarRate,        
            @agent_settlement_rate = x.NPRRate,        
            @exchangerate = x.exchangerate,        
            @today_dollar_rate = x.customer_rate,        
            @round_by = ISNULL(x.qtyCurrency, 2),        
            @ho_cost_send_rate = x.exchangeRate + ISNULL(x.agent_premium_send, 0),        
            @ho_premium_send_rate = ISNULL(x.agent_premium_send, 0),        
            @ho_premium_payout_rate = ISNULL(x.agent_premium_payout, 0),        
            @agent_customer_diff_value = ISNULL(x.customer_diff_value, 0),        
            @agent_sending_rate_margin = ISNULL(x.margin_sending_agent, 0),        
            @agent_payout_rate_margin = ISNULL(x.receiver_rate_diff_value, 0),        
            @agent_sending_cust_exchangerate = ISNULL(x.sending_cust_exchangerate, 0),        
            @agent_payout_agent_cust_rate = ISNULL(x.payout_agent_rate, 0),        
            @ho_exrate_applied_type = 'payoutwise'        
     FROM   agentpayout_CurrencyRate x  with(nolock)       
     WHERE  x.agentId = @agentcode        
            AND payout_agent_id = @payout_agent_id        
 END        
         
 DECLARE @check_sc VARCHAR(50)         
 -- select @check_sc=max(slab_id) from service_charge_setup        
 --where agent_id=@agentcode and Rec_country=@PAYOUT_COUNTRY        
 --and (isNULL(payment_type,'Bank Transfer')=@PAYMENTTYPE        
 --or isNULL(payment_type,'Cash Pay')=@PAYMENTTYPE)            
 SELECT @check_sc = MAX(slab_id)        
 FROM   service_charge_setup with(nolock)        
 WHERE  agent_id = @agentcode        
        AND Rec_country = @PAYOUT_COUNTRY        
        AND (        
                ISNULL(payment_type, 'Bank Transfer') = @PAYMENTTYPE        
                OR ISNULL(payment_type, 'Cash Pay') = @PAYMENTTYPE        
            )        
         
 IF @check_sc IS NULL        
 BEGIN        
     SELECT @check_sc = MAX(slab_id)       FROM   service_charge_setup  with(nolock)      
     WHERE  agent_id = @agentcode        
            AND payout_agent_id = @payout_agent_id        
            AND (        
                    ISNULL(payment_type, 'Bank Transfer') = @PAYMENTTYPE        
                    OR ISNULL(payment_type, 'Cash Pay') = @PAYMENTTYPE        
                )        
             
     IF @check_sc IS NULL        
     BEGIN        
         SELECT '3008' Code,        
                @AGENT_REFID AGENT_REFID,        
                'Select Country is not allowed, please contact Head Office'         
                MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
 END         
         
 ------------############# new added  Service Charge            
 CREATE TABLE #temp_charge        
 (        
  slab_id          INT,        
  min_amount       MONEY,        
  max_amount       MONEY,        
  service_charge   MONEY,        
  send_commission  MONEY,        
  paid_commission  MONEY,        
  deposit_amt      MONEY        
 )            
         
 DECLARE @pay_in_amt       MONEY,        
         @clc_COLLECT_AMT  MONEY            
         
 IF @CALC_BY = 'p'        
 BEGIN        
     SET @totalroundamt = @COLLECT_AMT            
     SET @pay_in_amt = @totalroundamt / @today_dollar_rate            
     SET @receiveamt = @COLLECT_AMT         
             
     --spa_GetServiceCharge_by_payinamt '10100000',NULL,1000,'Cash Pay','Nepal'            
     SET @COLLECT_AMT = 0            
     SET @scharge = 0            
     INSERT INTO #temp_charge        
       (        
         slab_id,        
         min_amount,        
         max_amount,        
         deposit_amt,        
         service_charge,        
         send_commission,        
         paid_commission        
       )        
     EXEC spa_GetServiceCharge_by_payinamt @agentcode,        
          @payout_agent_id,        
          @pay_in_amt,        
          @PAYMENTTYPE,        
          @PAYOUT_COUNTRY              --exec spa_GetServiceCharge_by_payinamt_V1 @agentcode,@payout_agent_id,@pay_in_amt,@PAYMENTTYPE,@PAYOUT_COUNTRY            
             
     SELECT @scharge = service_charge,        
            @COLLECT_AMT = deposit_amt,        
            @sendercommission = send_commission,        
            @agent_receiverSCommission = paid_commission        
     FROM   #temp_charge            
             
     IF @scharge IS NULL        
     BEGIN        
         SET @return_value =         
             'Service Charge is Not Defined for the Amount Range'        
                 
         SELECT '3013' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END      
         
      if @agentcode=@FreeAgentID and @Waive_Fee='y'     
  begin    
   set @COLLECT_AMT=@pay_in_amt    
   set @scharge=0    
  end    
        
 END        
 ELSE        
 BEGIN        
     SET @clc_COLLECT_AMT = @COLLECT_AMT            
     IF @COLLECT_AMT = 0        
     BEGIN        
         SET @clc_COLLECT_AMT = 100        
     END             
             
     SET @scharge = 0            
     INSERT INTO #temp_charge        
       (        
         slab_id,        
         min_amount,        
         max_amount,        
         service_charge,        
         send_commission,        
         paid_commission        
       )        
     EXEC spa_GetServiceCharge @agentcode,        
          @payout_agent_id,        
          @clc_COLLECT_AMT,        
          @PAYMENTTYPE,        
          @agent_branch_code,        
          @PAYOUT_COUNTRY        
             
     SELECT @scharge = service_charge,        
            @sendercommission = send_commission,        
            @agent_receiverSCommission = paid_commission        
     FROM   #temp_charge            
             
     IF @scharge IS NULL        
     BEGIN        
         SET @return_value =         
             'Service Charge is Not Defined for the Amount Range'        
          
         SELECT '3013' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END            
     if @agentcode=@FreeAgentID and @Waive_Fee='y'     
 begin    
  set @scharge=0    
 end    
     
     SET @receiveamt = (@COLLECT_AMT - @scharge) * @today_dollar_rate            
    -- SET @totalroundamt = FLOOR(@receiveamt)            
     --SET @totalroundamt = ROUND(@receiveamt, ISNULL(@round_by, 2))    
     SET @totalroundamt = ROUND(@receiveamt,0)      
             
     IF @totalroundamt <= 0        
     BEGIN        
         SET @return_value = 'Collected Amount is Invalid must be more than '        
             + CAST(@scharge AS VARCHAR)        
                 
         INSERT sys_access        
           (        
             ipadd,        
             LOGIN_TYPE,        
             log_date,        
             log_time,        
             branch_code,        
             emp_id,        
             USER_ID,        
             pwd,        
			 msg,        
             STATUS        
           )        
         VALUES        
           (        
             @client_pc_id,        
             'SOAP_FOREX',        
             CONVERT(VARCHAR, GETDATE(), 102),        
             CONVERT(VARCHAR, GETDATE(), 108),        
             @accesscode,        
             @agent_user_id,        
             @username,        
             '******',        
             @return_value,        
             'Failed'        
           )            
         SELECT '3009' Code,        
                @AGENT_REFID AGENT_REFID,        
                @return_value MESSAGE,        
                NULL REFID        
                 
         RETURN        
     END        
 END         
 --------------###############3            
 IF @exchangerate IS NULL --or @round_by is null        
 BEGIN     
     SET @return_value = 'Selected Country is not allowed'            
     INSERT sys_access        
       (        
         ipadd,        
         LOGIN_TYPE,        
         log_date,        
         log_time,        
         branch_code,        
         emp_id,        
         USER_ID,        
         pwd,        
         msg,        
         STATUS        
       )        
     VALUES        
       (        
         @client_pc_id,        
         'SOAP_FOREX',        
         CONVERT(VARCHAR, GETDATE(), 102),        
         CONVERT(VARCHAR, GETDATE(), 108),        
         @accesscode,        
         @agent_user_id,        
         @username,        
         '******',        
         @return_value,        
         'Failed'        
       )            
     SELECT '3008' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @COLLECT_AMT <= 0        
 BEGIN        
     SET @return_value = 'Amount is Invalid'            
     INSERT sys_access        
       (        
         ipadd,        
         LOGIN_TYPE,        
         log_date,        
         log_time,        
         branch_code,        
         emp_id,        
         USER_ID,        
         pwd,        
         msg,        
         STATUS        
       )        
VALUES        
       (        
         @client_pc_id,        
         'SOAP_FOREX',        
         CONVERT(VARCHAR, GETDATE(), 102),        
         CONVERT(VARCHAR, GETDATE(), 108),        
         @accesscode,        
         @agent_user_id,        
         @username,        
         '******',        
         @return_value,        
         'Failed'        
       )            
     SELECT '3009' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
-- SET @receiveamt = (@COLLECT_AMT - @scharge) * @today_dollar_rate            
 SET @totalroundamt = ROUND(@totalroundamt,0)            
--         
 IF isNull(@totalroundamt,-1) <= 0        
 BEGIN        
     SET @return_value = 'Collected Amount is Invalid must be more than ' +         
         CAST(@scharge AS VARCHAR)        
             
     INSERT sys_access        
       (        
         ipadd,       
         LOGIN_TYPE,        
         log_date,        
         log_time,        
         branch_code,        
         emp_id,        
         USER_ID,        
         pwd,        
         msg,        
         STATUS        
       )        
     VALUES        
       (        
         @client_pc_id,        
         'SOAP_FOREX',        
         CONVERT(VARCHAR, GETDATE(), 102),        
         CONVERT(VARCHAR, GETDATE(), 108),        
         @accesscode,        
         @agent_user_id,        
         @username,        
         '******',        
         @return_value,        
         'Failed'        
       )            
     SELECT '3009' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @max_payout_amt_account = 0        
     SET @max_payout_amt_account = @totalroundamt            
         
 IF @max_payout_amt_cash = 0        
     SET @max_payout_amt_cash = @totalroundamt            
         
 IF @PAYMENTTYPE = 'Cash Pay'        
    AND @totalroundamt > @max_payout_amt_cash        
 BEGIN        
     SET @return_value = 'Cash Pickup TXN can not be more than ' + CAST(@max_payout_amt_cash AS VARCHAR)         
         + ' ' + @PAYOUTCURRENCY + ' for Country:' + @PAYOUT_COUNTRY        
             
     SELECT '3011' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @PAYMENTTYPE = 'Bank Transfer'        
    AND @totalroundamt > @max_payout_amt_account        
 BEGIN        
     SET @return_value = 'Bank Transfer can not be more than ' + CAST(@max_payout_amt_account AS VARCHAR)         
         + ' ' + @PAYOUTCURRENCY + ' for Country:' + @PAYOUT_COUNTRY        
             
     SELECT '3011' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
         
 IF @limit_per_TXN < @COLLECT_AMT        
 BEGIN        
     SET @return_value = 'TXN Limit exceeded. You have limit up to  ' + CAST(@limit_per_TXN AS VARCHAR)         
         + ' ' + @COLLECT_CURRENCY + ' per Transaction '        
             
     SELECT '3011' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END            
         
 IF @sendercommission IS NULL        
     SET @sendercommission = 0            
         
 IF @COLLECT_AMT IS NULL        
    OR @totalroundamt IS NULL        
 BEGIN        
     SET @return_value = 'Invalid amount'            
     INSERT sys_access        
       (        
         ipadd,        
         LOGIN_TYPE,        
         log_date,        
         log_time,        
         branch_code,        
         emp_id,        
         USER_ID,        
         pwd,        
         msg,        
         STATUS        
       )        
     VALUES        
       (        
         @client_pc_id,        
         'SOAP_CreateTXN',        
         CONVERT(VARCHAR, GETDATE(), 102),        
         CONVERT(VARCHAR, GETDATE(), 108),        
         @accesscode,        
         @agent_user_id,        
         @username,        
         '******',        
         @return_value,        
         'Failed'        
       )            
     SELECT '1001' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
          
     RETURN        
 END        
         
 IF @currentBalance < @COLLECT_AMT and @send_txn_without_balance='n'       
 BEGIN        
     SET @return_value = 'You don''t have sufficient balance to send txn'            
     SELECT '3012' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END        
 ---------- Customer Detail ------------  
 declare @customerid varchar(50),@customer_sno int,@receiver_sno int  
   
 declare @check_customerid varchar(50),@check_customersno varchar(50)  
   
 if @SENDER_IDENTITY_NUMBER is not null and @SENDERS_IDENTITY_TYPE is not null   
 begin  
  select @check_customerid=customerid,@check_customersno=sno from customerDetail with(nolock)   
  where SenderName=@SENDER_NAME and senderFax=@SENDERS_IDENTITY_TYPE  
  and senderPassport=@SENDER_IDENTITY_NUMBER and reg_agent_id=@agentcode  
 end   
 if @check_customerid is not null and @check_customersno is not null  
 begin  
 set @customerid=@check_customerid  
 set @customer_sno=@check_customersno  
   
  update customerDetail   
  set senderaddress=@SENDER_ADDRESS,  
   senderphoneno=@SENDER_MOBILE,    
   sendercity=@SENDER_CITY,   
  sendercountry=@SENDER_COUNTRY,   
  senderpassport=@SENDER_IDENTITY_NUMBER,   
  sendervisa=@SENDER_ID_EXPIRE_DATE,   
  receivername=@RECEIVER_NAME,   
  receiveraddress=@RECEIVER_ADDRESS,   
  receiverphone=@RECEIVER_CONTACT_NUMBER,                        
  receivercity=@RECEIVER_CITY,   
  receivercountry=@RECEIVER_COUNTRY,   
  relation=@SENDER_BENEFICIARY_RELATIONSHIP,  
  sendermobile=@SENDER_MOBILE,  
  receivermobile=@RECEIVER_CONTACT_NUMBER,          
  trn_date=GETDATE(),  
  trn_amt=@COLLECT_AMT,  
  senderFax=@SENDERS_IDENTITY_TYPE,                  
    source_of_income=@SENDER_SOURCE_OF_FUND,  
    reason_for_remittance=@PURPOSE_OF_REMITTANCE,  
    reg_agent_id=@agentcode,  
    ID_Issue_date=@SENDER_ID_ISSUE_DATE,  
    Date_of_Birth=@SENDER_DATE_OF_BIRTH                         
    where sno=@Customer_sno    
    
    
 end  
 else  
 begin  
  select @customer_sno=MAX(sno)+2 from customerDetail   
  set @customerid='API'+cast(@customer_sno as varchar)  
   
  insert into customerdetail( customerid, sendername, senderaddress, senderphoneno,  sendercity,   
 sendercountry, senderpassport, sendervisa, receivername, receiveraddress, receiverphone,                        
    receivercity, receivercountry, relation,sendermobile,receivermobile,          
    trn_date,trn_amt,senderFax,                  
  source_of_income,reason_for_remittance,reg_agent_id,ID_Issue_date,Date_of_Birth,create_ts)                         
  values(@customerid,@SENDER_NAME, @SENDER_ADDRESS,@SENDER_MOBILE,@SENDER_CITY,@SENDER_COUNTRY,                        
 @SENDER_IDENTITY_NUMBER, @SENDER_ID_EXPIRE_DATE, @RECEIVER_NAME, @RECEIVER_ADDRESS, @RECEIVER_CONTACT_NUMBER,                        
    @RECEIVER_CITY, @RECEIVER_COUNTRY, @SENDER_BENEFICIARY_RELATIONSHIP,@SENDER_MOBILE,@RECEIVER_CONTACT_NUMBER,                        
  GETDATE(),@COLLECT_AMT,@SENDERS_IDENTITY_TYPE,                        
  @SENDER_SOURCE_OF_FUND,                        
  @PURPOSE_OF_REMITTANCE,@agentcode,@SENDER_ID_ISSUE_DATE,@SENDER_DATE_OF_BIRTH,getdate())             
 --set @customer_sno=ident_current('customerdetail')  
 end  
  insert into customerReceiverDetail(sender_sno,ReceiverName,ReceiverAddress,ReceiverPhone,ReceiverCity,                        
  ReceiverCountry,ReceiverMobile,relation,create_ts,                        
  create_by)             
  values(@customer_sno,@RECEIVER_NAME,@RECEIVER_ADDRESS,@RECEIVER_CONTACT_NUMBER,@RECEIVER_CITY,@RECEIVER_COUNTRY,                          
  @RECEIVER_CONTACT_NUMBER,@SENDER_BENEFICIARY_RELATIONSHIP,getdate(), @username)    
       
  select @receiver_sno=sno from customerReceiverDetail where sender_sno=@customer_sno  
    
 ------------FX Sharing calc-------------------------            
 DECLARE @send_share           FLOAT,        
         @payout_fx_share      FLOAT,        
         @Head_fx_share        FLOAT,        
         @check_agent_ex_gain  MONEY,        
         @agent_ex_gain        MONEY        
         
 IF @agent_settlement_rate = @today_dollar_rate        
     SET @agent_ex_gain = 0        
 ELSE        
     SET @agent_ex_gain = (        
             (@agent_settlement_rate -@today_dollar_rate) * (@COLLECT_AMT - @scharge)        
         ) / @agent_settlement_rate         
 -----------end FX Sharing---------------            
         
 ------------Retrive Payout Settlement USD Rate ----------------            
 DECLARE @payout_settle_usd MONEY            
 SELECT @payout_settle_usd = buyRate        
 FROM   Roster with(nolock)       
 WHERE  payoutagentid = @payout_agent_id        
         
 IF @payout_settle_usd IS NULL        
     SELECT @payout_settle_usd = buyRate        
     FROM   Roster with(nolock)        
     WHERE  country = @PAYOUT_COUNTRY        
            AND payoutagentid IS NULL        
         
 IF @payout_settle_usd IS NULL        
     SET @payout_settle_usd = @ho_dollar_rate         
 ----------- end -----------------------------------------------            
         
 INSERT sys_access        
   (        
     ipadd,        
     LOGIN_TYPE,        
     log_date,        
     log_time,        
     branch_code,        
     emp_id,        
     USER_ID,        
     pwd,        
     msg,        
     STATUS        
   )        
 VALUES        
   (        
     @client_pc_id,        
     'SOAP_CreateTXN',        
     CONVERT(VARCHAR, GETDATE(), 102),        
     CONVERT(VARCHAR, GETDATE(), 108),        
     @accesscode,        
     @agent_user_id,        
     @username,        
     '******',        
     'Login',        
     'Success'        
   )            
         
 DECLARE @enc_refno     VARCHAR(20)            
         
         
         
 DECLARE @tranno        BIGINT,        
         @dot           DATETIME,        
         @dottime       VARCHAR(20),        
         @trCode        VARCHAR(20),        
         @our_refno     VARCHAR(15),        
         @rnd_id        VARCHAR(4),        
         @trannoref     BIGINT,        
         @country_code  CHAR(1),        
         @mm            CHAR(1),        
         @rnd_id1       VARCHAR(5),        
         @rnd           VARCHAR(1)            
         
 SET @dot = CONVERT(VARCHAR, GETDATE(), 101)            
 SET @dottime = CONVERT(VARCHAR, GETDATE(), 108)            
         
 SELECT @trannoref = MAX(ref_sno) + 1        
 FROM   tbl_refno        
         
 SET @trCode = CAST(@trannoref AS VARCHAR)            
         
 DECLARE @process_id  VARCHAR(100),        
         @refno_seed  VARCHAR(20)        
         
 SET @process_id = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 6)            
 SET @refno_seed = [dbo].[FNARefno](@trannoref, @process_id)            
         
 SET @rnd_id = LEFT(ABS(CHECKSUM(NEWID())), 2)            
 SET @rnd_id1 = LEFT(ABS(CHECKSUM(NEWID())), 2)         
         
 --    set @our_refno= '9'+ left(@rnd_id,1) + '1'+left(cast(@trannoref as varchar),3)+ substring(cast(@trannoref as varchar),7,1) + REVERSE(substring(cast(@trannoref as varchar),4,3)) + right(cast(@trannoref as varchar),1)              
 IF @generate_partner_pinno = 'n'        
 BEGIN        
     IF @payout_agent_id = '20100080'        
         SET @our_refno = '36' + LEFT(@rnd_id, 1) + LEFT(CAST(@trannoref AS VARCHAR), 3)        
             + RIGHT(@rnd_id, 1) + RIGHT(@rnd_id1, 1) + SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3)         
             + LEFT(@rnd_id1, 1)        
     ELSE if @payout_agent_id='10000004' ---  MUSLIM COMMERCIAL BANK          
    SET @our_refno = '111' + LEFT(CAST(@trannoref AS VARCHAR), 3)        
             + RIGHT(@rnd_id, 1) + RIGHT(@rnd_id1, 1) + SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3)         
             + LEFT(@rnd_id1, 1)        
  ELSE        
         SET @our_refno = '11' + LEFT(@rnd_id, 1) + LEFT(CAST(@trannoref AS VARCHAR), 3)        
             + RIGHT(@rnd_id, 1) + RIGHT(@rnd_id1, 1) + SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3)         
             + LEFT(@rnd_id1, 1)        
 END        
 ELSE        
     SET @our_refno = @AGENT_TXNID            
         
 SET @enc_refno = dbo.encryptDB(@our_refno)            
         
         
    
         
 SET @process_id = REPLACE(NEWID(), '-', '_')            
 DECLARE @TransStatus       VARCHAR(10),        
         @response_status   VARCHAR(100),       
   @confirmDate  DATETIME,        
   @approve_by  VARCHAR(100)    
 SET @confirmDate = NULL    
 SET @approve_by  = NULL    
 SET @AUTHORIZED_REQUIRED = LOWER(@AUTHORIZED_REQUIRED)    
 IF ISNULL(@AUTHORIZED_REQUIRED, 'n') = 'y'        
 BEGIN        
    SET @TransStatus = 'Hold'            
    SET @response_status = 'Transaction need Authorization'        
 END        
 ELSE        
 BEGIN       
 SET @confirmDate = @gmtdate    
 SET @approve_by  = @username     
    SET @TransStatus = 'Payment'            
    SET @response_status = 'Transaction saved successfully'        
 END         
         
 --ADDED FOR INTEGRATED AGNET SAVE                         
 DECLARE @status VARCHAR(50)                          
 SET @status = 'Un-Paid'                          
 IF EXISTS (        
        SELECT agentcode        
        FROM   tbl_integrated_agents with(nolock)       
        WHERE  agentcode = @payout_agent_id        
               AND ISNULL(paymentType, @paymenttype) = @paymenttype        
    )        
 BEGIN        
     SET @status = 'Post'                                        
  -- SET @transstatus = 'Hold'        
 END         
 --INTEGRATED AGENT END          
         
         
         
 DECLARE @duplicate_TXN VARCHAR(500)                
 SELECT TOP 1 @duplicate_TXN = Tranno        
 FROM   moneysend WITH (NOLOCK)        
 WHERE  SenderName = RTRIM(LTRIM(@SENDER_NAME))        
        AND ReceiverName = RTRIM(LTRIM(@RECEIVER_NAME))        
        AND paidamt = @COLLECT_AMT        
        AND agentid = @agentcode        
        AND CONVERT(VARCHAR, local_DOT, 102) = CONVERT(VARCHAR, @gmtdate, 102)        
        AND TransStatus NOT IN ('Cancel')        
 ORDER BY        
        tranno DESC             
         
 DECLARE @compliance_flag     CHAR(1),        
         @compliance_sys_msg  VARCHAR(500),        
         @dollar_amt          MONEY            
         
 SET @dollar_amt = @COLLECT_AMT / @exchangerate                
 IF @dollar_amt >= 2500        
 BEGIN        
     SET @TransStatus = 'Compliance'                
     SET @compliance_flag = 'y'                
     SET @compliance_sys_msg = 'Large Volume Transaction'        
 END             
         
 IF @duplicate_TXN IS NOT NULL        
    AND @TransStatus = 'Payment'        
 BEGIN        
     SET @TransStatus = 'Compliance'                
     SET @compliance_flag = 'y'                
     SET @compliance_sys_msg = CASE         
                                    WHEN @compliance_sys_msg IS NULL THEN         
                                         'Duplicate Suspicious'        
                                    ELSE @compliance_sys_msg +         
                                         'Duplicate Suspicious'        
        END        
 END                
 if @SENDER_IDENTITY_NUMBER is null  
 begin  
 SET @TransStatus = 'Compliance'                
     SET @compliance_flag = 'y'                
     SET @compliance_sys_msg = CASE         
                                    WHEN @compliance_sys_msg IS NULL THEN         
                                         'SENDER ID Number is Blank'        
                                    ELSE @compliance_sys_msg +         
                                         'SENDER ID Number is Blank'        
        END        
 end  
IF @currentBalance < @COLLECT_AMT and @send_txn_without_balance='y'       
 BEGIN        
     SET @TransStatus = 'Compliance'                
     SET @compliance_flag = 'y'                
     SET @compliance_sys_msg = CASE         
                                    WHEN @compliance_sys_msg IS NULL THEN         
                                         '<br> Agent Limit Exceed'        
                                    ELSE @compliance_sys_msg +         
                                         '<br> Agent Limit Exceed'        
        END         
 END 
 
 DECLARE @check_ofac  VARCHAR(100),        
         @ofac_list   CHAR(1)        
         
  
SELECT DISTINCT @check_ofac=ent_num    
FROM ofac_combined  with(nolock)  
INNER JOIN FREETEXTTABLE(ofac_combined, [name], @SENDER_NAME) AS KEY_TBL    
ON ofac_combined.sno = KEY_TBL.[KEY]     
WHERE KEY_TBL.[rank] >50  
  
  
 IF @check_ofac IS NOT NULL        
 BEGIN        
     SET @ofac_list = 'y'                   
     SET @transstatus = 'OFAC'     
     SET @compliance_sys_msg = CASE         
                                    WHEN @compliance_sys_msg IS NULL THEN         
                                         'Sender Name OFAC'        
                                    ELSE @compliance_sys_msg +         
                                         ' and Sender Name OFAC'        
        END           
 END     
  
 set @check_ofac=null  
SELECT DISTINCT @check_ofac=ent_num    
FROM ofac_combined  with(nolock)  
INNER JOIN FREETEXTTABLE(ofac_combined, [name], @RECEIVER_NAME) AS KEY_TBL    
ON ofac_combined.sno = KEY_TBL.[KEY]     
WHERE KEY_TBL.[rank] >50  
  
  
 IF @check_ofac IS NOT NULL        
 BEGIN        
     SET @ofac_list = 'y'                   
     SET @transstatus = 'OFAC'     
     SET @compliance_sys_msg = CASE         
                                    WHEN @compliance_sys_msg IS NULL THEN         
                                         'Receiver Name OFAC'        
                                    ELSE @compliance_sys_msg +         
                                         ' and Receiver Name OFAC'        
        END           
 END     
   
 --SELECT @check_ofac = sno        
 --FROM   ofac_combined WITH (NOLOCK)        
 --WHERE  NAME = @SENDER_NAME        
 --       OR  NAME = @RECEIVER_NAME        
         
 --IF @check_ofac IS NOT NULL        
 --BEGIN        
 --    SET @ofac_list = 'y'                   
 --    SET @transstatus = 'OFAC'        
 --END              
         
 DECLARE @exist_refno VARCHAR(50)            
 SELECT @tranno = tranno,        
        @exist_refno = dbo.decryptdb(refno)        
 FROM   moneysend  with (nolock)      
 WHERE  agentid = @agentcode        
        AND digital_id_sender = @AGENT_TXNID        
     
 IF @tranno IS NOT NULL        
 BEGIN        
     SET @return_value = 'Duplicate Agent TXN ID:' + @AGENT_TXNID            
     SELECT '1005' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            @exist_refno REFID        
             
     RETURN        
 END         
 IF EXISTS (        
        SELECT Tranno        
        FROM   moneysend WITH (NOLOCK)        
        WHERE  refno = @enc_refno        
    )        
 BEGIN        
     SET @return_value = 'Server Busy- Try again'            
     SELECT '9002' Code,        
            @AGENT_REFID AGENT_REFID,        
            @return_value MESSAGE,        
            NULL REFID        
             
     RETURN        
 END         
 IF ISNULL(@AUTHORIZED_REQUIRED, 'n') = 'y'   
 BEGIN  
  IF @ofac_list='y' OR @compliance_flag='y'    
   SET @transstatus = 'Hold'   
 END  
         
 BEGIN TRANSACTION            
 INSERT moneysend        
   (        
     refno,        
     agentid,        
     agentname,        
     branch_code,        
     branch,        
     sendername,        
    senderaddress,        
     senderphoneno,        
     sendercity,        
     sender_mobile,        
     sendercountry,        
     senderpassport,        
     receivername,        
     receiveraddress,        
     receiverphone,        
     receiver_mobile,        
     receivercity,        
     receivercountry,        
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
     sendernativecountry,        
     ip_address,        
     agent_dollar_rate,        
     ho_dollar_rate,        
     digital_id_sender,        
     expected_payoutagentid,        
     paid_agent_id,        
     ReciverMessage,        
     agent_settlement_rate,        
     agent_ex_gain,        
     agent_receiverSCommission,        
     senderFax,        
     confirmDate,        
     approve_by,        
     confirm_process_id,        
     ho_cost_send_rate,        
     ho_premium_send_rate,        
     ho_premium_payout_rate,        
     agent_customer_diff_value,        
     agent_sending_rate_margin,        
     agent_payout_rate_margin,        
     agent_sending_cust_exchangerate,        
     agent_payout_agent_cust_rate,        
     ho_exrate_applied_type,        
     payout_settle_usd,        
     ben_bank_name,        
     ben_bank_id,        
     ID_Issue_date,        
     senderVisa,        
     Date_of_Birth,        
     process_id,        
     compliance_flag,        
     compliance_sys_msg,        
     agent_receiverCommission,        
     ofac_list,        
     SenderBankName,        
     payout_send_agent_id,        
     sender_occupation,        
     source_of_income,        
     ReceiverRelation,        
     reason_for_remittance ,  
     CustomerId,  
     customer_sno,  
     receiver_sno       
             
   )        
 VALUES        
   (        
     @enc_refno,        
     @agentcode,        
     @agentname,        
     @agent_branch_code,        
     @branch,        
     UPPER(@SENDER_NAME),        
     @SENDER_ADDRESS,        
     @SENDER_MOBILE,        
     @SENDER_CITY,        
     RIGHT(@SENDER_MOBILE, 20),        
     @SENDER_COUNTRY,        
     @SENDER_IDENTITY_NUMBER,        
     UPPER(@RECEIVER_NAME),        
     @RECEIVER_ADDRESS,        
     @RECEIVER_CONTACT_NUMBER,        
     RIGHT(@RECEIVER_CONTACT_NUMBER, 20),        
     @RECEIVER_CITY,        
     @PAYOUT_COUNTRY,        
     @dot,        
     @dottime,        
     @COLLECT_AMT,        
     @COLLECT_CURRENCY,        
     @totalroundamt,        
     @PAYOUTCURRENCY,        
     @exchangerate,        
     @today_dollar_rate,        
     @COLLECT_AMT / @exchangerate,        
     @scharge,        
     @PAYMENTTYPE,        
     @payout_branch_id,        
     @BANK_NAME,        
     CASE         
          WHEN @paymenttype = 'Account Deposit to Other Bank' THEN ISNULL(@BANK_BRANCH_NAME, '')        
               + ISNULL(' ' + @OTHER_BANK_BRANCH_NAME, '')        
          WHEN @PAYMENTTYPE='NEFT' THEN @OTHER_BANK_BRANCH_NAME        
          ELSE @BANK_BRANCH_NAME        
     END,        
     @BANK_ACCOUNT_NUMBER,        
     CASE         
          WHEN @PAYMENTTYPE = 'Cash Pay' THEN NULL        
          WHEN @PAYMENTTYPE='NEFT' THEN @ifsc_code        
    WHEN @PAYMENTTYPE='Account Deposit to Other Bank' THEN @OTHER_BANK_BRANCH_NAME        
          ELSE @BANK_BRANCH_NAME        
     END,        
     0,        
     @TransStatus,        
     @status,        
     @username,        
     0,        
     0,        
     @totalroundamt,        
     @PAYMENTTYPE,        
     @sendercommission,        
     @payout_agent_id,        
     'd',        
     @gmtdate,        
     @SENDER_COUNTRY,        
     CAST(@AGENT_REFID AS VARCHAR),        
     NULL,        
     @ho_dollar_rate,        
     @AGENT_TXNID,        
     @payout_agent_id,        
     @payout_agent_id,        
     'TXN From:' + @SENDER_COUNTRY + ':' + ISNULL(@Branch_group, '') + ':' + ISNULL(@OTHER_BANK_BRANCH_NAME, ''),        
     @agent_settlement_rate,        
     ISNULL(@agent_ex_gain, 0),        
     ISNULL(@agent_receiverSCommission, 0),        
	 @SENDERS_IDENTITY_TYPE,        
     @confirmDate,        
     @approve_by,        
     @process_id,        
     @ho_cost_send_rate,        
     @ho_premium_send_rate,        
     @ho_premium_payout_rate,        
     @agent_customer_diff_value,        
     @agent_sending_rate_margin,        
     @agent_payout_rate_margin,        
     @agent_sending_cust_exchangerate,        
     @agent_payout_agent_cust_rate,        
     @ho_exrate_applied_type,        
     @payout_settle_usd,        
     @ben_bank_name,        
     @ben_bank_id,        
     @SENDER_ID_ISSUE_DATE,        
     @SENDER_ID_EXPIRE_DATE,        
     @SENDER_DATE_OF_BIRTH,        
     'API:' + @AGENT_TXNID,        
     @compliance_flag,        
     @compliance_sys_msg,        
     0,        
     @ofac_list,        
     'API Transaction',        
     @payout_agent_id,        
     @SENDER_OCCUPATION,        
     @SENDER_SOURCE_OF_FUND,        
     @SENDER_BENEFICIARY_RELATIONSHIP,        
     @PURPOSE_OF_REMITTANCE,  
     @customerid,  
     @customer_sno,  
     @receiver_sno        
   )            
         
 INSERT tbl_refno        
   (        
     refno        
   )        
 VALUES        
   (        
     @enc_refno        
   )            
 DECLARE @tranno_var VARCHAR(50)            
 SELECT @tranno_var = tranno        
 FROM   moneysend WITH (NOLOCK)        
 WHERE  refno = @enc_refno            
         
 UPDATE agentdetail        
 SET    currentbalance = ISNULL(currentbalance, 0) + (        
            @COLLECT_AMT -(ISNULL(@sendercommission, 0) + ISNULL(@agent_ex_gain, 0))        
        )        
 WHERE  agentcode = @agentcode         
         
 --update SOAP_LOG_FOREX set process_id=@enc_refno        
 --where sno=@FOREX_SESSION_ID and AGENT_CODE=@agentcode            
         
 DECLARE @remote_db               VARCHAR(50),        
         @enable_update_remoteDB  VARCHAR(50)        
         
 SELECT @remote_db = remote_db,        
        @enable_update_remoteDB = enable_update_remote_DB        
 FROM   tbl_interface_setup with(nolock)        
 WHERE  agentcode = @payout_agent_id        
        AND mode = 'Send'         
 --select @enable_update_remoteDB,@tranno,@username,@agentcode,@process_id            
         
 DECLARE @Partner_Settlement MONEY             
 SET @Partner_Settlement = @COLLECT_AMT -@sendercommission         
         
 COMMIT TRANSACTION            
 IF @enable_update_remoteDB = 'y'        
 BEGIN        
--     EXEC spRemote_sendTrns 'i',        
--          @tranno_var,        
--          @username,        
--          @agentcode,        
--          @process_id     
  --if @enable_update_remoteDB='y'    
  EXEC ('spRemote_sendTrns ''i'','''+@tranno_var+''','''+@username+''','''+@agentcode+''','''+ @process_id +'''')    
 END        
         
 SELECT '0' Code,        
        @AGENT_REFID AGENT_REFID,        
        @response_status MESSAGE,        
        CAST(@our_refno AS VARCHAR) REFID,        
        @COLLECT_AMT COLLECT_AMT,        
        @COLLECT_CURRENCY COLLECT_CURRENCY,        
        @today_dollar_rate EXRATE,        
        @scharge SERVICE_CHARGE,        
        @totalroundamt PAYOUTAMT,        
        @PAYOUTCURRENCY PAYOUTCURRENCY,        
        @gmtdate TXN_DATE,        
        @AGENT_TXNID AGENT_TXNID,        
        @Partner_Settlement Partner_Settlement,        
        @exchangerate PARTNER_CCYRATE         
    DROP table #temp_charge         
 RETURN        
END TRY            
BEGIN CATCH        
 IF @@trancount > 0        
     ROLLBACK TRANSACTION            
         
 DECLARE @desc VARCHAR(1000)            
 SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'            
 DECLARE @error_id VARCHAR(50)            
         
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
        'spa_SOAP_Create_v2',        
        'SQL',        
        @desc,        
        'SQL',        
        'SP',        
        @AGENT_REFID,        
        GETDATE()        
         
 SET @error_id = @@identity            
 SELECT '9001' Code,        
        @AGENT_REFID AGENT_REFID,        
        'Technical Error:' + @error_id MESSAGE,        
        NULL REFID  END CATCH      
    
    
  
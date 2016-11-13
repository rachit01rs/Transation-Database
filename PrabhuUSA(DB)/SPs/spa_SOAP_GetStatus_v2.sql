drop PROC [dbo].[spa_SOAP_GetStatus_v2]  
GO
/****** Object:  StoredProcedure [dbo].[spa_SOAP_GetStatus_v2]    Script Date: 10/16/2014 04:47:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[spa_SOAP_GetStatus_v2]    
    @accesscode VARCHAR(100),    
    @username VARCHAR(100),    
    @password VARCHAR(100),    
    @REFID VARCHAR(100)=NULL,    
    @AGENT_REFID VARCHAR(150),
	@AGENT_TXNID Varchar(50)=NULL,
	 @client_pc_id       VARCHAR(100)=null     
--WITH ENCRYPTION    
AS    
    
DECLARE @agentcode          VARCHAR(50),
        @agent_branch_code  VARCHAR(50),
        @user_pwd           VARCHAR(50),
        @accessed           VARCHAR(50)
    
DECLARE @Block_branch       VARCHAR(50),
        @BranchCodeChar     VARCHAR(50),
        @lock_status        VARCHAR(5),
        @agent_user_id      VARCHAR(50)
    
DECLARE @country            VARCHAR(50),
        @user_count         INT,
        @agentname          VARCHAR(100),
        @branch             VARCHAR(100),
        @gmtdate            DATETIME,
        @restrict_anywhere  CHAR(2)
     
    
    
DECLARE @api_agent_id    VARCHAR(200),
        @sql             VARCHAR(8000)
    
DECLARE @return_value    VARCHAR(1000),
        @payout_agentid  VARCHAR(50)    
    
IF @username = ''
   OR @password = ''
   OR @accesscode = ''
   OR (@AGENT_REFID = '' or @AGENT_TXNID='')
BEGIN
    SET @return_value = 'Invalid Request Parameter'    
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
        'SOAP_GetStatus',
        CONVERT(VARCHAR, GETDATE(), 102),
        CONVERT(VARCHAR, GETDATE(), 108),
        @accesscode,
        NULL,
        @username,
        '******',
        'Invalid Request Parameter',
        'Failed'
      )    
    SELECT '101' Code,
           @AGENT_REFID AGENT_REFID,
           @return_value MESSAGE,
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' PAID_DATE
    
    RETURN
END    
    
SELECT @agentcode = a.agentcode,
       @agentname = a.companyName,
       @user_pwd = u.user_pwd,
       @agent_user_id = u.agent_user_id,
       @accessed = a.accessed,
       @country = a.country,
       @branch = b.branch,
       @agent_branch_code = b.agent_branch_code,
       @BranchCodeChar = b.BranchCodeChar,
       @Block_branch = ISNULL(b.block_branch, 'n'),
       @lock_status = ISNULL(u.lock_status, 'n'),
       @gmtdate = DATEADD(mi, ISNULL(gmt_value, 345), GETUTCDATE()),
       @restrict_anywhere = ISNULL(restrict_anywhere_payment, 'n'),
       @payout_agentid = b.agentcode
FROM   agentDetail a
       JOIN agentbranchdetail b
            ON  a.agentcode = b.agentcode
       JOIN agentsub u
            ON  b.agent_branch_code = u.agent_branch_code
WHERE  u.user_login_id = @username
    
SET @user_count = @@rowcount    
    
    
SET @api_agent_id = @agentcode    
    
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
        'SOAP_GetStatus',
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
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' PAID_DATE
    
    RETURN
END
    
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
        'SOAP_GetStatus',
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
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' PAID_DATE
    
    RETURN
END
    
IF @BranchCodeChar <> @accesscode
BEGIN
    SET @return_value = 'Partner id invalid'    
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
        'SOAP_GetStatus',
        CONVERT(VARCHAR, GETDATE(), 102),
        CONVERT(VARCHAR, GETDATE(), 108),
        @accesscode,
        @agent_user_id,
        @username,
        '******',
        'Branch Code invalid',
        'Failed'
      )    
    SELECT '1002' Code,
           @AGENT_REFID AGENT_REFID,
           @return_value MESSAGE,
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' PAID_DATE
    
    RETURN
END
    
IF @Block_branch = 'y'
   OR @lock_status = 'y'
BEGIN
    SET @return_value = 'Your userid is Blocked'      
    SELECT '1003' Code,
           @AGENT_REFID AGENT_REFID,
           @return_value MESSAGE,
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' PAID_DATE 
    
    RETURN
END     
    
DECLARE @tranno                  INT,
        @sender_name             VARCHAR(100),
        @receiver_name           VARCHAR(100),
        @totalroundamt           MONEY,
        @receiveCtype            VARCHAR(3),
        @status                  VARCHAR(100),
        @paidDate                DATETIME,
        @cancel_date             DATETIME,
        @expected_payoutagentid  VARCHAR(50),
        @restrict_anywhere2      CHAR(1) ,
        @tran_agentid				VARCHAR(50)  
if @RefID is not null
begin 
SELECT @tranno = tranno,
	   @tran_agentid=m.agentid,
       @sender_name = sendername,
       @receiver_name = ReceiverName,
       @totalroundamt = totalroundamt,
       @receiveCtype = receiveCtype,
       @paidDate = paidDate,
       @cancel_date = cancel_date,
       @status = CASE 
                      WHEN STATUS = 'Paid' THEN 'PAID'
                      WHEN transStatus = 'Cancel' THEN 'Cancel'
                      WHEN transStatus = 'Hold' THEN 'Hold'
                      WHEN transStatus IN ('OFAC', 'BLOCKED','Compliance') THEN 
                           'Compliance'
                      WHEN transStatus = 'Payment' AND STATUS = 'Un-Paid' THEN 
                           'Un-Paid'
					else status
                 END,
       @expected_payoutagentid = expected_payoutagentid,
       @restrict_anywhere2 = ISNULL(a.restrict_anywhere_payment, 'n')
FROM   moneySend m WITH(NOLOCK)
       JOIN agentDetail a WITH(NOLOCK)
            ON  a.agentCode = m.expected_payoutagentid
WHERE  refno = dbo.encryptDB(@REFID)
       AND (
               agentid = @agentcode
               OR (
                      CASE 
                           WHEN @restrict_anywhere = 'y' THEN 
                                expected_payoutagentid
                           ELSE 1
                      END
                  ) = (
                      CASE 
                           WHEN @restrict_anywhere = 'y' THEN @agentcode
                           ELSE 1
                      END
                  )
           )    
    
 END 
 ELSE 
 BEGIN
 	SELECT @REFID=dbo.decryptDB(refno),
		@tranno = tranno,
	   @tran_agentid=m.agentid,
       @sender_name = sendername,
       @receiver_name = ReceiverName,
       @totalroundamt = totalroundamt,
       @receiveCtype = receiveCtype,
       @paidDate = paidDate,
       @cancel_date = cancel_date,
       @status = CASE 
                      WHEN STATUS = 'Paid' THEN 'PAID'
                      WHEN transStatus = 'Cancel' THEN 'Cancel'
                      WHEN transStatus = 'Hold' THEN 'Hold'
                      WHEN transStatus IN ('OFAC', 'BLOCKED','Compliance') THEN 
                           'Compliance'
                      WHEN transStatus = 'Payment' AND STATUS = 'Un-Paid' THEN 
                           'Un-Paid'
                      ELSE status
                 END,
       @expected_payoutagentid = expected_payoutagentid,
       @restrict_anywhere2 = ISNULL(a.restrict_anywhere_payment, 'n')
FROM   moneySend m WITH(NOLOCK)
       JOIN agentDetail a WITH(NOLOCK)
            ON  a.agentCode = m.expected_payoutagentid
WHERE  refno = dbo.encryptDB(@AGENT_TXNID)
       and m.agentid = @agentcode
           
 END    
----Check Cancel Hold
if @tranno is null 
begin 
SELECT @tranno = tranno,
	   @tran_agentid=m.agentid,
       @sender_name = sendername,
       @receiver_name = ReceiverName,
       @totalroundamt = totalroundamt,
       @receiveCtype = receiveCtype,
       @paidDate = paidDate,
       @cancel_date = cancel_date,
       @status = 'Cancel-Hold',
       @expected_payoutagentid = expected_payoutagentid,
       @restrict_anywhere2 = ISNULL(a.restrict_anywhere_payment, 'n')
FROM   delmoneySend m WITH(NOLOCK)
       left outer JOIN agentDetail a WITH(NOLOCK)
            ON  a.agentCode = m.expected_payoutagentid
WHERE  refno = dbo.encryptDB(@REFID)
       AND agentid = @agentcode
 END 

IF @tranno IS NULL
   OR @tranno = 0
BEGIN
    SET @return_value = 'Transaction Not Found PINNO:' + CAST(@REFID AS VARCHAR)    
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
        'SOAP_GetStatus',
        CONVERT(VARCHAR, GETDATE(), 102),
        CONVERT(VARCHAR, GETDATE(), 108),
        @accesscode,
        @agent_user_id,
        @username,
        '******',
        @return_value,
        'Failed'
      )    
    SELECT '2003' Code,
           @AGENT_REFID AGENT_REFID,
           @return_value MESSAGE,
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' STATUS_DATE
    
    RETURN
END
  
IF @restrict_anywhere = 'y' AND isNUll(@tran_agentid,'x')<>@agentcode 
   AND isNUll(@expected_payoutagentid,'x') <> @payout_agentid
BEGIN
    SELECT '2006' Code,
           @AGENT_REFID AGENT_REFID,
           'You are not allowed to  view status of this TXN' MESSAGE,
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' STATUS_DATE
    
    RETURN
END   
    
IF @restrict_anywhere = 'n'
   AND @restrict_anywhere2 = 'y' and isNUll(@tran_agentid,'x')<>@agentcode
BEGIN
    SELECT '2006' Code,
           @AGENT_REFID AGENT_REFID,
           'You are not allowed to view status of this TXN' MESSAGE,
           '' REFID,
           '' SENDER_NAME,
           '' RECEIVER_NAME,
           '' PAYOUTAMT,
           '' PAYOUTCURRENCY,
           '' STATUS,
           '' STATUS_DATE
    
    RETURN
END 
 
BEGIN
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
	    'SOAP_GetStatus',
	    CONVERT(VARCHAR, GETDATE(), 102),
	    CONVERT(VARCHAR, GETDATE(), 108),
	    @accesscode,
	    @agent_user_id,
	    @username,
	    '******',
	    CAST(@REFID AS VARCHAR),
	    'Success'
	  )    
	
	SELECT '0' Code,
	       @AGENT_REFID AGENT_REFID,
	       'TXN Summary' MESSAGE,
	       CAST(@REFID AS VARCHAR) REFID,
	       @sender_name SENDER_NAME,
	       @receiver_name RECEIVER_NAME,
	       @totalroundamt PAYOUTAMT,
	       @receiveCtype PAYOUTCURRENCY,
	       UPPER(@status) STATUS,
	       CASE 
	            WHEN @status in ('Cancel','Cancel-Hold') THEN ISNULL(CONVERT(VARCHAR, @cancel_date, 120), '')
	            ELSE ISNULL(CONVERT(VARCHAR, @paidDate, 120), '')
	       END STATUS_DATE
END


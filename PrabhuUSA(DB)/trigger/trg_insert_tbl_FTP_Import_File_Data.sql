IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_insert_tbl_FTP_Import_File_Data]'))
DROP TRIGGER [dbo].[trg_insert_tbl_FTP_Import_File_Data]
GO

/****** Object:  Trigger [dbo].[trg_insert_tbl_FTP_Import_File_Data]    Script Date: 03/12/2014 17:28:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
** Database : PrabhuUSA
** Object : trg_insert_tbl_FTP_Import_File_Data
**
** Purpose : [FTP intregation] transactin generate in replaceted moneysend table
**
** Author:  Sunita shrestha
** Date:    12/03/2014
**
** Modifications:
** Examples:
*/
CREATE TRIGGER [dbo].[trg_insert_tbl_FTP_Import_File_Data] ON [dbo].[tbl_FTP_Import_File_Data]
FOR insert 
AS
DECLARE @agentcode               VARCHAR(50),
        @agent_branch_code       VARCHAR(50),
        @user_pwd                VARCHAR(50),
        @accessed                VARCHAR(50),
        @CALC_BY CHAR(1) ,  ---- 'c' by Collected AMT, 'p' Payout amt 
		@AUTHORIZED_REQUIRED CHAR(1)   
SET @CALC_BY='p'
SET @AUTHORIZED_REQUIRED='y'
    
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
	
DECLARE     @payout_branch_id  VARCHAR(50),
	        @payout_agent_id   VARCHAR(50),
	        @BANK_BRANCHID VARCHAR(50) ,
	        @SENDER_NAME VARCHAR(50),
	        @RECEIVER_NAME VARCHAR(50),
	        @COLLECT_AMT money,
	        @RECEIVER_COUNTRY  VARCHAR(50),
	        @SENDER_COUNTRY VARCHAR(50),
	        @PAYMENTTYPE	VARCHAR(50),
	        @BANKID VARCHAR(50),
			@BANK_ACCOUNT_NUMBER VARCHAR(50),
			@OTHER_BANK_BRANCH_NAME VARCHAR(100),
			@AGENT_TXNID VARCHAR(50),
			@username	VARCHAR(50) ,
			@partnerID VARCHAR(50)
  
	DECLARE @sql           VARCHAR(8000)    
	DECLARE @return_value  VARCHAR(1000) 
		
	DECLARE @currentBalance          MONEY,
	        @allow_integration_user  CHAR(1),
	        @last_login              DATETIME
	        
	--------------------------------------------------------------------------------------------------
	  SELECT 		@partnerID=t.PartnerID,
					@payout_branch_id = T.LocationID ,
					@BANK_BRANCHID =T.BeneficiaryBankBranchCode,
					@COLLECT_CURRENCY=t.PayoutCCY,
					@SENDER_NAME=t.RemitterName,
					@RECEIVER_NAME=t.BeneficiaryName,
					@COLLECT_AMT=t.PayoutAMT ,
					@RECEIVER_COUNTRY=t.PayoutCountry,
					@BANKID=t.BeneficiaryBankCode,
					@BANK_ACCOUNT_NUMBER =T.BankAccountNo,
					@OTHER_BANK_BRANCH_NAME=T.BeneficiaryBankBranchName,
					@PAYMENTTYPE=t.PaymentMode,
					@AGENT_TXNID=t.pinno
		  FROM      [tbl_FTP_Import_File_Data] T WITH ( NOLOCK )
		  JOIN INSERTED i
		     ON  T.PINNO =i.PINNO 
			AND T.processid = i.processid 
			AND T.DataInsertedInMoneySend='p' 
	
	IF @partnerID IS NULL 
	BEGIN
		SET @return_value = '[1001] Invalid txn. Please contact Support Personal'    
	    	 UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END
	--------------------------------------------------------------------------------------------------
	
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
	       --@allow_integration_user = ISNULL(u.allow_integration_user, 'n'),
	       @generate_partner_pinno = ISNULL(a.generate_partner_pinno, 'n'),
	       @last_login = last_login,
	       @username=u.User_login_Id
	FROM   agentDetail a WITH(NOLOCK)
	       JOIN agentbranchdetail b WITH(NOLOCK)
	            ON  a.agentcode = b.agentcode
	       JOIN agentsub u WITH(NOLOCK)
	            ON  b.agent_branch_code = u.agent_branch_code
	WHERE  u.agent_user_id = @partnerID
	
	IF @agentcode IS NULL 
	BEGIN
		SET @return_value = '[1001] User not defined. Please to check the Setup.'    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	 	    
	    RETURN
	END
	
	IF @accessed NOT IN ('Granted')
	BEGIN
	    SET @return_value = '[1002] Agent is Blocked'    
	    
	     UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P' 
	   	    
	    RETURN
	END 
	
	IF @Block_branch = 'y'
	BEGIN
	    SET @return_value = '[1003] Branch is Blocked'    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END 
--	   
--	IF @allow_integration_user = 'n'
--	BEGIN
--	    SET @return_value = 'Your userid is not allowed for Web Services'    
--	    SELECT '1003' Code,
--	           @AGENT_REFID AGENT_REFID,
--	           @return_value MESSAGE,
--	           NULL REFID
--	    
--	    RETURN
--	END

	DECLARE @isError CHAR(1)
	SELECT @isError = isError,
	       @PAYMENTTYPE = item
	FROM   dbo.FNA_ApiGetPaymentType(@PAYMENTTYPE)
	
	IF @isError IS NOT NULL
	BEGIN
		UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@PAYMENTTYPE
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	        
	    RETURN
	END
	    
	
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
			@branch_Type			varchar(50)    
	
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
			@branch_Type=b.branch_type
	FROM   agentdetail a WITH(NOLOCK)
	       JOIN agentbranchdetail b WITH(NOLOCK)
	            ON  a.agentcode = b.agentcode
	WHERE  agent_branch_code = @payout_branch_id
	       AND a.accessed = 'Granted'
	       AND a.Country = @RECEIVER_COUNTRY    
	
	IF @check_anywhere = 'n'
	   AND (@payout_agent_id = '' OR @payout_agent_id IS NULL)
	BEGIN
	    SET @return_value = '[1001] Payout Branch ID is not provided or Payout Branch ID doesnt matched with PayoutCountry'    
	     UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	    
	    RETURN
	END    
	
	IF @payout_agent_id IS NULL
	   AND @check_anywhere = 'n'
	BEGIN
	    SET @return_value = '[3003] Invalid Payout Branch ID'    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	  
	    RETURN
	END
	
	IF @branch_block = 'y'
	BEGIN
	    SET @return_value = '[3004] Payout Branch ID is not active'    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	    
	    RETURN
	END    
	
	IF @check_anywhere = 'y'
	    SET @PAYOUT_COUNTRY = @RECEIVER_COUNTRY
	ELSE 
	IF @Payout_Country <> @RECEIVER_COUNTRY
	BEGIN
	    SET @return_value = '[3003] Invalid Payout Branch ID and Country'    
	   UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END    
	
	DECLARE @check_bank     VARCHAR(50),
	        @ben_bank_name  VARCHAR(150),
	        @ben_bank_id    VARCHAR(50),
	        @ifsc_code		VARCHAR(50)
	       
	
	IF @PAYMENTTYPE = 'Account Deposit to Other Bank'
	BEGIN
	    IF @BANKID IS NULL
	    BEGIN
	        SET @return_value = 
	            '[3002] For Bank Transfer Location ID and Bank ID must be defined'
	        
	        UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	        
	        RETURN
	    END
	    
	    if exists(SELECT * FROM   commercial_bank cb WITH(NOLOCK) JOIN commercial_bank_branch cbb WITH(NOLOCK)
	    ON cb.Commercial_id=cbb.Commercial_id
	    WHERE  cbb.sno = @BANK_BRANCHID)
		BEGIN
		SELECT @check_bank = cb.COMMERCIAL_ID,
	           @ben_bank_name = cbb.bankName,
	           @ben_bank_id=cb.external_bank_id,
	           @OTHER_BANK_BRANCH_NAME=cbb.BranchName,
	           @ifsc_code=cbb.IFSC_Code
	    FROM   commercial_bank cb WITH(NOLOCK) JOIN commercial_bank_branch cbb WITH(NOLOCK)
	    ON cb.Commercial_id=cbb.Commercial_id
	    WHERE  cbb.sno = @BANK_BRANCHID
		END
		ELSE
		BEGIN
	    --SET @ben_bank_id = @BANKID    
	    SET @check_bank = NULL    
	    SELECT @check_bank = COMMERCIAL_ID,
	           @ben_bank_name = BANK_NAME,
	           @ben_bank_id= external_bank_id
	    FROM   commercial_bank WITH(NOLOCK)
	    WHERE  commercial_id = @BANKID
	           AND PAYOUT_AGENT_ID = @payout_agent_id
		END	
	    
	    IF @check_bank IS NULL
	    BEGIN
	        SET @return_value = '[3002] Payout BANK ID is invalid'    
	         UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	        
	        RETURN
	    END
	    
	    IF @BANK_ACCOUNT_NUMBER IS NULL
	    BEGIN
	        SET @return_value = '[3010] Bank Account No is blank'    
	         UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'          
	        RETURN
	    END
	    SET @OTHER_BANK_BRANCH_NAME = RTRIM(LTRIM(@OTHER_BANK_BRANCH_NAME)) 
	        IF @OTHER_BANK_BRANCH_NAME='' OR @OTHER_BANK_BRANCH_NAME IS NULL
	        BEGIN
	        	 set @return_value='[3011] For Account Deposit to Other Bank payment mode Bank branch is mandatory valid.'
	        	 UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	        	 return
	        END
	        
	    IF @BANK_BRANCHID IS NOT NULL
			BEGIN
				--- ADDED FOR MAPPING Branch of NEPAL (ACCOUNT DEPOSIT TO OTHER)
					IF	EXISTS(SELECT 'x' FROM dbo.commercial_bank c WITH(NOLOCK)
					JOIN dbo.commercial_bank_branch b WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id
					WHERE b.IFSC_Code=@BANK_BRANCHID AND c.country='NEPAL' AND b.Commercial_id=@BANKID AND c.PAYOUT_AGENT_ID = @payout_agent_id)
					BEGIN
						SELECT @OTHER_BANK_BRANCH_NAME=b.BranchName,@ifsc_code=b.IFSC_Code FROM dbo.commercial_bank c WITH(NOLOCK) 
					JOIN dbo.commercial_bank_branch b WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id
					WHERE b.IFSC_Code=@BANK_BRANCHID AND c.country='NEPAL' AND b.Commercial_id=@BANKID
					AND c.PAYOUT_AGENT_ID = @payout_agent_id
					END
				---- END		    
			END
	    
	END
	IF @PAYMENTTYPE = 'Cash Pay BDP' and @branch_type <>'External'
	BEGIN
		 SET @return_value = 
	            '[3002] LOCATION_ID is not valid BDP Location'
	        UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	        
	        RETURN
	End
	IF @PAYMENTTYPE = 'NEFT'
	BEGIN
	    IF @BANK_BRANCHID IS NULL
	    BEGIN
	        SET @return_value = 
	            '[3002] For NEFT LOCATION_ID and BANK_BRANCHID must be defined'
	         UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	        
	        RETURN
	    END
	    
	    
	    SET @ben_bank_id = @BANKID    
	    SET @check_bank = NULL    
	    
	    SELECT @check_bank = cb.COMMERCIAL_ID,
	           @ben_bank_name = cbb.bankName,
	           @ben_bank_id=cb.external_bank_id,
	           @OTHER_BANK_BRANCH_NAME=cbb.BranchName,
	           @ifsc_code=cbb.IFSC_Code
	    FROM   commercial_bank cb WITH(NOLOCK) JOIN commercial_bank_branch cbb WITH(NOLOCK)
	    ON cb.Commercial_id=cbb.Commercial_id
	    WHERE  cbb.sno = @BANK_BRANCHID
	           AND PAYOUT_AGENT_ID = @payout_agent_id
	    
	    IF @check_bank IS NULL
	    BEGIN
	        SET @return_value = '[3002] Payout Branch ID is invalid'    
	        UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	        
	        RETURN
	    END
	    
	    IF @BANK_ACCOUNT_NUMBER IS NULL
	    BEGIN
	        SET @return_value = '[3010] Bank Account No is blank'    
	         UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	        
	        RETURN
	    END
	    
	    SET @OTHER_BANK_BRANCH_NAME = RTRIM(LTRIM(@OTHER_BANK_BRANCH_NAME)) 
	        --IF @OTHER_BANK_BRANCH_NAME='' OR @OTHER_BANK_BRANCH_NAME IS NULL
	        --BEGIN
	        --	 set @return_value='For Account Deposit to Other Bank payment mode Bank branch is mandatory valid.'
	        --	 select '3011' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID
	        --	 return
	        --END
	END
	DECLARE @Branch_group VARCHAR(200)    
	IF @PAYMENTTYPE = 'Bank Transfer'
	BEGIN
	    IF @Payout_AgentCan NOT IN ('Both', 'None')
	    BEGIN
	        SET @return_value = 
	            '[3002] Select Location ID can not perform Account Deposit'
	        
	        UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'          
	        RETURN
	    END
	    
	    IF @BANK_ACCOUNT_NUMBER IS NULL
	    BEGIN
	        SET @return_value = '[3010] Bank Account No is blank'    
	         UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	        
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
	FROM   agentCurrencyRate x WITH(NOLOCK)
	       LEFT OUTER JOIN agent_branch_rate b WITH(NOLOCK)
	            ON  x.agentId = b.agentid
	            AND b.agent_branch_code = @agent_branch_code
	WHERE  x.agentId = @agentcode
	       AND x.receiveCountry = @PAYOUT_COUNTRY
	       AND x.currencyType = @COLLECT_CURRENCY
	       AND x.receiveCType <> 'USD' 
	--AND x.receiveCType=@PAYOUTCURRENCY    
	
	IF EXISTS(
	       SELECT Currencyid
	       FROM   agentpayout_CurrencyRate WITH(NOLOCK)
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
	    FROM   agentpayout_CurrencyRate x WITH(NOLOCK)
	    WHERE  x.agentId = @agentcode
	           AND payout_agent_id = @payout_agent_id
	END
	
	DECLARE @check_sc VARCHAR(50) 
	-- select @check_sc=max(slab_id) from service_charge_setup
	--where agent_id=@agentcode and Rec_country=@PAYOUT_COUNTRY
	--and (isNULL(payment_type,'Bank Transfer')=@PAYMENTTYPE
	--or isNULL(payment_type,'Cash Pay')=@PAYMENTTYPE)    
	SELECT @check_sc = MAX(slab_id)
	FROM   service_charge_setup WITH(NOLOCK)
	WHERE  agent_id = @agentcode
	       AND Rec_country = @PAYOUT_COUNTRY
	       AND (
	               ISNULL(payment_type, 'Bank Transfer') = @PAYMENTTYPE
	               OR ISNULL(payment_type, 'Cash Pay') = @PAYMENTTYPE
	           )
	PRINT @PAYMENTTYPE
	IF @check_sc IS NULL
	BEGIN
	    SELECT @check_sc = MAX(slab_id)
	    FROM   service_charge_setup WITH(NOLOCK)
	    WHERE  agent_id = @agentcode
	           AND payout_agent_id = @payout_agent_id
	           AND (
	                   ISNULL(payment_type, 'Bank Transfer') = @PAYMENTTYPE
	                   OR ISNULL(payment_type, 'Cash Pay') = @PAYMENTTYPE
	               )
	    
	    IF @check_sc IS NULL
	    BEGIN
	         SET @return_value =  '[3008] Select Country is not allowed, please contact Head Office'
	       
	         UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	 
	       
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
	    PRINT @pay_in_amt
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
	         @PAYOUT_COUNTRY 
	    --exec spa_GetServiceCharge_by_payinamt_V1 @agentcode,@payout_agent_id,@pay_in_amt,@PAYMENTTYPE,@PAYOUT_COUNTRY    
	    
	    SELECT @scharge = service_charge,
	           @COLLECT_AMT = deposit_amt,
	           @sendercommission = send_commission,
	           @agent_receiverSCommission = paid_commission
	    FROM   #temp_charge    
	    
	    IF @scharge IS NULL
	    BEGIN
	        SET @return_value = 
	            '[3013] Service Charge is Not Defined for the Amount Range'
	        
	        UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	        
	        RETURN
	    END
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
	            '[3013] Service Charge is Not Defined for the Amount Range'
	        
	       UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	        
	        RETURN
	    END    
	    
	    SET @receiveamt = (@COLLECT_AMT - @scharge) * @today_dollar_rate    
	    SET @totalroundamt = FLOOR(@receiveamt)    
	    
	    
	    IF @totalroundamt <= 0
	    BEGIN
	        SET @return_value = '[3009] Collected Amount is Invalid must be more than '
	            + CAST(@scharge AS VARCHAR)  
	        UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	        RETURN
	    END
	END 
	--------------###############3    
	IF @exchangerate IS NULL --or @round_by is null
	BEGIN
	    SET @return_value = '[3008] Selected Country is not allowed'    
	    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END
	
	IF @COLLECT_AMT <= 0
	BEGIN
	    SET @return_value = '[3009] Amount is Invalid or Service Charge is not Defined.'    
	    
	   UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	    RETURN
	END    
	
	SET @receiveamt = (@COLLECT_AMT - @scharge) * @today_dollar_rate    
	SET @totalroundamt = ROUND(@receiveamt, ISNULL(@round_by, 2))    
	
	IF @totalroundamt <= 0
	BEGIN
	    SET @return_value = '[3009] Collected Amount is Invalid must be more than ' + 
	        CAST(@scharge AS VARCHAR)
	      
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END
	
	IF @max_payout_amt_account = 0
	    SET @max_payout_amt_account = @totalroundamt    
	
	IF @max_payout_amt_cash = 0
	    SET @max_payout_amt_cash = @totalroundamt    
	
	IF @PAYMENTTYPE = 'Cash Pay'
	   AND @totalroundamt > @max_payout_amt_cash
	BEGIN
	    SET @return_value = '[3011] Cash Pickup TXN can not be more than ' + CAST(@max_payout_amt_cash AS VARCHAR) 
	        + ' ' + @PAYOUTCURRENCY + ' for Country:' + @PAYOUT_COUNTRY
	    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	    
	    RETURN
	END
	
	IF @PAYMENTTYPE = 'Bank Transfer'
	   AND @totalroundamt > @max_payout_amt_account
	BEGIN
	    SET @return_value = '[3011] Bank Transfer can not be more than ' + CAST(@max_payout_amt_account AS VARCHAR) 
	        + ' ' + @PAYOUTCURRENCY + ' for Country:' + @PAYOUT_COUNTRY
	    
	     UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END
	PRINT @limit_per_TXN
	PRINT @COLLECT_AMT
	IF @limit_per_TXN < @COLLECT_AMT
	BEGIN
	    SET @return_value = '[3011] TXN Limit exceeded. You have limit up to  ' + CAST(@limit_per_TXN AS VARCHAR) 
	        + ' ' + @COLLECT_CURRENCY + ' per Transaction '
	    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	    
	    RETURN
	END    
	
	IF @sendercommission IS NULL
	    SET @sendercommission = 0    
	
	IF @COLLECT_AMT IS NULL
	   OR @totalroundamt IS NULL
	BEGIN
	    SET @return_value = '[1001] Invalid amount'    
	    
	    UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END
	
	IF @currentBalance < @COLLECT_AMT
	BEGIN
	    SET @return_value = '[3012] This agent don''t have sufficient balance to send txn'    
	   UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  
	    RETURN
	END 
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
	FROM   Roster WITH(NOLOCK)
	WHERE  payoutagentid = @payout_agent_id
	
	IF @payout_settle_usd IS NULL
	    SELECT @payout_settle_usd = buyRate
	    FROM   Roster WITH(NOLOCK)
	    WHERE  country = @PAYOUT_COUNTRY
	           AND payoutagentid IS NULL
	
	IF @payout_settle_usd IS NULL
	    SET @payout_settle_usd = @ho_dollar_rate 
	----------- end -----------------------------------------------    
  
	
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
	
	
	
	--    set @our_refno= '9'+ left(@rnd_id,1) + '1'+left(cast(@trannoref as varchar),3)+ substring(cast(@trannoref as varchar),7,1) + REVERSE(substring(cast(@trannoref as varchar),4,3)) + right(cast(@trannoref as varchar),1)      
	IF @generate_partner_pinno = 'n'
	BEGIN
		SELECT @trannoref = MAX(ref_sno) + 1
		FROM   tbl_refno WITH(NOLOCK)
		
		SET @trCode = CAST(@trannoref AS VARCHAR)    
		
		DECLARE @process_id  VARCHAR(100),
				@refno_seed  VARCHAR(20)
		
		SET @process_id = LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 6)    
		SET @refno_seed = [dbo].[FNARefno](@trannoref, @process_id)    
		
		SET @rnd_id = LEFT(ABS(CHECKSUM(NEWID())), 2)    
		SET @rnd_id1 = LEFT(ABS(CHECKSUM(NEWID())), 2) 
	
	    IF @payout_agent_id = '20100080'
	        SET @our_refno = '36' + LEFT(@rnd_id, 1) + LEFT(CAST(@trannoref AS VARCHAR), 3)
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
	
	
	IF EXISTS (
	       SELECT Tranno
	       FROM   moneysend WITH (NOLOCK)
	       WHERE  refno = @enc_refno
	   )
	BEGIN
	    SET @return_value = '[9002] Dublicate txn Found'    
	     UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'  	    
	    RETURN
	END
	
	SET @process_id = REPLACE(NEWID(), '-', '_')    
	DECLARE @TransStatus      VARCHAR(10),
	        @response_status  VARCHAR(100)
	
	IF ISNULL(@AUTHORIZED_REQUIRED, 'n') = 'y'
	BEGIN
	    SET @TransStatus = 'Hold'    
	    SET @response_status = 'Transaction need Authorization'
	END
	ELSE
	BEGIN
	    SET @TransStatus = 'Payment'    
	    SET @response_status = 'Transaction saved successfully'
	END 
	
	--ADDED FOR INTEGRATED AGNET SAVE                 
	DECLARE @status VARCHAR(50)                  
	SET @status = 'Un-Paid'                  
	IF EXISTS (
	       SELECT agentcode
	       FROM   tbl_integrated_agents WITH(NOLOCK)
	       WHERE  agentcode = @payout_agent_id
	              AND ISNULL(paymentType, @paymenttype) = @paymenttype
	   )
	BEGIN
	    SET @status = 'Post'                                
	    SET @transstatus = 'Hold'
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
	IF @dollar_amt >= 3000
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
	
	DECLARE @check_ofac  VARCHAR(100),
	        @ofac_list   CHAR(1)
	
	SELECT @check_ofac = sno
	FROM   ofac_combined WITH (NOLOCK)
	WHERE  NAME = @SENDER_NAME
	       OR  NAME = @RECEIVER_NAME
	
	IF @check_ofac IS NOT NULL
	BEGIN
	    SET @ofac_list = 'y'           
	    SET @transstatus = 'OFAC'
	END      
	
	DECLARE @exist_refno VARCHAR(50)    
	SELECT @tranno = tranno,
	       @exist_refno = dbo.decryptdb(refno)
	FROM   moneysend WITH(NOLOCK)
	WHERE  agentid = @agentcode
	       AND digital_id_sender = @AGENT_TXNID
	
	IF @tranno IS NOT NULL
	BEGIN
	    SET @return_value = '[1005] Duplicate Agent TXN ID:' + @AGENT_TXNID    
	   UPDATE dbo.tbl_FTP_Import_File_Data
			SET    DataInsertedInMoneySend = 'F' ,
				   DataInsertedDate = GETDATE() ,
			       Remarks =@return_value
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				 JOIN	INSERTED i on T.PINNO =i.PINNO
			      AND T.processid = i.processid
			      WHERe T.DataInsertedInMoneySend='P'    
	    RETURN
	END 
	
	
	BEGIN TRANSACTION trans   
	INSERT temp_ftp_moneysend
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
	    reason_for_remittance,
	    ben_bank_branch_id,
	    SSN_Card_ID	    
	  )
	SELECT 
	    @enc_refno,
	    @agentcode,
	    @agentname,
	    @agent_branch_code,
	    @branch,
	    UPPER(@SENDER_NAME),
	    t.RemitterAddress,
	    t.RemitterContact SENDER_MOBILE,
	    t.RemitterCity SENDER_CITY,
	    RIGHT(t.RemitterContact, 20),
	    @SENDER_COUNTRY,
	    t.RemitterIDNumber SENDER_IDENTITY_NUMBER,
	    UPPER(@RECEIVER_NAME),
	    t.BeneficiaryAddress RECEIVER_ADDRESS,
	    t.BeneficiaryContact RECEIVER_CONTACT_NUMBER,
	    RIGHT(t.BeneficiaryContact, 20),
	    NULL RECEIVER_CITY,
	    @PAYOUT_COUNTRY,
	    t.TransactionDate dot,
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
	         WHEN @paymenttype = 'Account Deposit to Other Bank' THEN @OTHER_BANK_BRANCH_NAME
	         ELSE @BANK_BRANCH_NAME  -- need to check 
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
	    'FTP Intregration',
	    NULL,
	    @ho_dollar_rate,
	    @AGENT_TXNID,
	    @payout_agent_id,
	    @payout_agent_id,
	    'TXN From:' + @SENDER_COUNTRY + ':' + ISNULL(@Branch_group, '') + ':' + 
	    ISNULL(@OTHER_BANK_BRANCH_NAME, ''),
	    @agent_settlement_rate,
	    ISNULL(@agent_ex_gain, 0),
	    ISNULL(@agent_receiverSCommission, 0),
	    t.RemitterIDType SENDERS_IDENTITY_TYPE,
	    @gmtdate,
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
	    NULL SENDER_ID_ISSUE_DATE,
	    NULL SENDER_ID_EXPIRE_DATE,
	    NULL SENDER_DATE_OF_BIRTH,
	    'FTP_API:' + @AGENT_TXNID,
	    @compliance_flag,
	    @compliance_sys_msg,
	    0,
	    @ofac_list,
	    'API Transaction',
	    @payout_agent_id,
	    t.RemitterOccupation SENDER_OCCUPATION,
	    t.SourceOfFunds SENDER_SOURCE_OF_FUND,
	    t.Relationship SENDER_BENEFICIARY_RELATIONSHIP,
	    t.PurposeOfRemittance PURPOSE_OF_REMITTANCE,
	    CASE WHEN @paymenttype = 'Account Deposit to Other Bank' AND @ifsc_code IS NOT NULL 
			AND t.PayoutCountry='NEPAL' THEN @ifsc_code END ,
	    t.futureUse
	 FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
		JOIN INSERTED i
	 on T.PINNO =i.PINNO
			AND T.processid = i.processid
			where T.DataInsertedInMoneySend='p'   
-------------Update the txn in temp table for reference-------------------------------------------	
	 UPDATE dbo.tbl_FTP_Import_File_Data
	 SET    DataInsertedInMoneySend = 'T' ,
			DataInsertedDate = GETDATE() ,
			Remarks = 'Ready for Approve.'
			FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
				JOIN	INSERTED i 
	 on T.PINNO =i.PINNO
			AND T.processid = i.processid
			WHERe T.DataInsertedInMoneySend='P'  
--------------------------------------------------------------------------------------------------	

--SELECT * FROM [tbl_FTP_Import_File_Data] T WITH(NOLOCK)
--					JOIN INSERTED i
--	 on T.PINNO =i.PINNO
--			AND T.processid = i.processid
--			WHERe T.DataInsertedInMoneySend='P'   
GO




/****** Object:  StoredProcedure [dbo].[spa_MobileCalcFee]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileCalcFee]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileCalcFee]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileAgentList]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileAgentList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileAgentList]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileCustomerDetail]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileCustomerDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileCustomerDetail]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetBeneficiaryDetail]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileGetBeneficiaryDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileGetBeneficiaryDetail]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetPayoutBankDetail]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileGetPayoutBankDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileGetPayoutBankDetail]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetPayoutServiceType]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileGetPayoutServiceType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileGetPayoutServiceType]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetTransaction]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileGetTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileGetTransaction]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileSaveTransaction]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileSaveTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileSaveTransaction]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetPayoutAgent]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileGetPayoutAgent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileGetPayoutAgent]
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileAuthentication]    Script Date: 09/09/2013 13:09:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_MobileAuthentication]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_MobileAuthentication]
GO



/****** Object:  StoredProcedure [dbo].[spa_MobileCalcFee]    Script Date: 09/09/2013 13:09:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_MobileCalcFee]      
@SenderCountry varchar(50),
@payout_country varchar(50),
@PaymentType Varchar(50),
@TransferAmount money  
as       
      
declare @check_Session varchar(150) ,@branch_id varchar(50),@agent_id varchar(50) 

select @branch_id=m.agent_branch_code,@agent_id=b.agentCode
from MobileAgentRoute m 
left outer join agentbranchdetail b on b.agent_branch_Code=m.agent_branch_code  
where country_name=@SenderCountry

declare @cust_rate float,@payout_ccy varchar(50),@send_ccy varchar(3)

  IF EXISTS(select * FROM agent_branch_rate WHERE agentId=@agent_id and agent_branch_code=@branch_id        
  AND receiveCountry=@payout_country)        
  begin        
	   select @cust_rate=[customer_rate],@payout_ccy=x.receiveCType,@send_ccy=x.CurrencyType        
	   from agent_branch_rate x         
	   where x.agentId=@agent_Id and agent_branch_code=@branch_id and x.receiveCountry=@payout_country        
  end        
  else        
  begin        
	   select @cust_rate=[customer_rate],@payout_ccy=x.receiveCType,@send_ccy=x.CurrencyType    
	   from agentCurrencyRate x         
	   where x.agentId=@agent_Id  and x.receiveCountry=@payout_country        
  end      
  
------------ Calc SErvice Fee
declare @error_status varchar(50),@service_charge money
  SELECT     
   @error_status=Exc_STATUS,    
   @service_charge = service_charge           
  FROM  dbo.FNAGetServiceCharge(@agent_id,NULL,@TransferAmount,@paymenttype,@branch_id,@payout_country,NULL)  

if @error_status='Error'
begin
	select 'Error' Status,'Error on calculation.' Message
	return
end

select 'Success' Status,@TransferAmount TransferAmount,@service_charge Fee,
@TransferAmount-@service_charge PrincipalAmount,
@cust_rate ExRate,
(@TransferAmount-@service_charge)*@cust_rate  PayoutAmount,
@send_ccy SendCCY,
@payout_ccy PayCCY
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileAgentList]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_MobileAgentList @PAYMENTTYPE='C',@Payout_Country='Nepal',@city=NULL,@states=NULL
CREATE proc [dbo].[spa_MobileAgentList]  
    @PAYMENTTYPE varchar(50),  
    @Payout_Country varchar(100),
	@city varchar(50)=null,
	@bank_name varchar(50)=null,
	@states varchar(50) =null 
as  
declare @agentcode varchar(50),@agent_branch_code varchar(50),@user_pwd varchar(50), @accessed varchar(50)  
declare @Block_branch varchar(50), @BranchCodeChar varchar(50), @lock_status varchar(5),@agent_user_id varchar(50)  
declare @country varchar(50),@user_count int,@client_pc_id varchar(100),  
@agentname varchar(100),@branch varchar(100)  
set @client_pc_id='192.168.1.100'  
 
set @PAYMENTTYPE=upper(@PAYMENTTYPE) 
  

declare @return_value varchar(1000)
  
CREATE TABLE #temp_list(  
 code INT,  
 LocationID VARCHAR(50),  
 Agent VARCHAR(150),  
 Branch VARCHAR(150),  
 ADDRESS VARCHAR(500),  
 City VARCHAR(150),  
 Currency VARCHAR(50),  
 BankID VARCHAR(50),
 Bank_BranchID VARCHAR(50),
 Branch_State varchar(50)  
)  
if upper(@PAYMENTTYPE)='C'  --- Cash PickUp
BEGIN  
 INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,Branch_State)  
select 0 Code,Agent_Branch_Code LocationID,a.CompanyName Agent,Branch,b.Address,  
b.City,a.CurrencyType Currency,isNUll(state_branch,Branch_group)  
 from agentbranchdetail b WITH (NOLOCK) 
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode  
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)   
and AgentType in ('ExtAgent','Send and Pay') and AgentCan in ('Both','Receiver','SenderReceiver')  
and accessed='Granted'
and case when @city is null then 'a' else b.City end=ISNULL(@city +'%','a') 
order by a.CompanyName,b.branch  
end  
else if upper(@PAYMENTTYPE)='B'  --- Account Deposit
BEGIN   
INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,Branch_State)  
select 0 Code,Agent_Branch_Code LocationID,  
case when a.Country='Nepal' then Branch_group else a.CompanyName end  Agent,  
Branch,b.Address,b.City,a.CurrencyType Currency,isNUll(state_branch,Branch_group)  
 from agentbranchdetail b WITH (NOLOCK)
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode  
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)  and AgentCan in ('Both','None')  
 and accessed='Granted' and AgentType in ('ExtAgent','Send and Pay') and   
 case when a.Country='Nepal' then Branch_type else 'AC Deposit' END IN ('AC Deposit','Both')
 and case when @city is null then 'a' else b.City end=ISNULL(@city +'%','a') 
order by a.CompanyName,b.branch_group,b.branch  
END   
else if upper(@PAYMENTTYPE) in ('N','d')  --- NEFT
BEGIN   
	if @bank_name is null and @states is null and @PAYMENTTYPE='N'
	begin
		 set @return_value='Must Provide BANK_NAME or BANK_BRANCH_STATE'  
		 select '5002' Code,@return_value MESSAGE  
		 RETURN 
	end
	SELECT distinct agent_branch_Code,agentCode INTO #agent1 FROM agentbranchdetail WITH (NOLOCK) WHERE isHeadOffice='y' 
	AND Country=@Payout_Country 
	
	INSERT #temp_list(code,LocationID,Agent,Branch,[ADDRESS],City,Currency,BankID,Bank_BranchID,Branch_State)  
	SELECT 0 Code,a.agent_branch_code LocationID,cb.Bank_name Agent,  
	cbb.BranchName Branch,[dbo].FNARemoveSpecialChar(cbb.[address]) Address,isnull(cbb.city,cbb.district) City,ad.CurrencyType Currency,
	isNULL(cb.external_bank_id,cb.commercial_id) external_bank_id,cbb.sno,cbb.state
	FROM commercial_bank cb WITH (NOLOCK) JOIN #agent1 a   
	ON cb.payout_agent_id=a.agentcode 
	JOIN agentDetail ad WITH (NOLOCK) ON ad.agentCode=cb.payout_agent_id  
	left outer JOIN commercial_bank_branch cbb ON cb.Commercial_id=cbb.Commercial_id
	WHERE cb.country=@Payout_Country --AND external_bank_id IS NOT NULL 
	and case when @states is not null then cbb.state else 'a' end =isNUll(@states,'a')  
	and case when @bank_name is not null then 
		case when @PAYMENTTYPE='N' then cbb.bankName else ad.Companyname end
		else 'a' end  like isNUll(@bank_name +'%','a')  
	order by cb.Bank_name,cbb.BranchName 
	
END   
else  
begin  
 set @return_value='Invalid Payment Type'  
 select '3001' Code,@return_value MESSAGE  
 RETURN   
end   
IF not EXISTS(SELECT * FROM #temp_list)  
BEGIN   
 set @return_value='Not Location Found'  
 select '5001' Code,@return_value MESSAGE  
 RETURN   
END   
ELSE   
alter table #temp_list add sno int identity(1,1)
SELECT code,LocationID,Agent,Branch,
ADDRESS + isnull(' ,'+City,'') +isNUll(' <br>'+Branch_State,'') +'<br>'+ @Payout_Country ADDRESS,Currency,BankID,@PAYMENTTYPE PAYMENTTYPE,
@Payout_Country Payout_Country,Bank_BranchID,Branch_State FROM #temp_list



GO

/****** Object:  StoredProcedure [dbo].[spa_MobileCustomerDetail]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_MobileCustomerDetail]                          
@flag varchar(2),                     
@customer_sno INT = NULL,                   
@CustomerID VARCHAR(50) = NULL,                       
@SenderName VARCHAR(100) = NULL,                       
@SenderAddress VARCHAR(150) = NULL,                                       
@SenderMobileno VARCHAR(30) = NULL,                        
@SenderCity  VARCHAR(100) = NULL,                        
@SenderCountry  VARCHAR(30) = NULL,                        
@SenderPassport  VARCHAR(50) = NULL,                  
@senderState VARCHAR(50) = NULL,                  
@senderpassportType VARCHAR(50) = NULL,                       
@SenderEmail VARCHAR(50) = NULL,                      
@SenderVisa VARCHAR(50) = NULL,                  
@idIssueDate VARCHAR(50) = NULL,                   
@Date_Of_Birth VARCHAR(50) = NULL,                  
@socailsecurity VARCHAR(50) = NULL,                     
@create_ts DATETIME = NULL ,                      
@update_ts DATETIME = NULL ,                      
@senderFax  VARCHAR(30) = NULL,                      
@SenderCompany  VARCHAR(30) = NULL,                      
@Salary_Earn  VARCHAR(30) = NULL,                      
@SenderNativeCountry VARCHAR(30) = NULL,                      
@mileage_earn VARCHAR(50) = NULL,                      
@trn_date DATETIME = NULL ,                      
@trn_amt MONEY = NULL,                      
@confirm_continue CHAR(1) = NULL,                    
@reg_agent_id VARCHAR(300) = NULL,                  
@t_customerID VARCHAR(50) = NULL,                  
@ReceiverName VARCHAR(50) = NULL,                  
@ReceiverAddress VARCHAR(50) = NULL,                  
@ReceiverCity VARCHAR(50) = NULL,                  
@ReceiverCountry VARCHAR(50) = NULL,                  
@txt_relation VARCHAR(50) = NULL,                  
@Receiverphone VARCHAR(50) = NULL,                  
@receiverMobile VARCHAR(50) = NULL,                  
@ReceiverEmail VARCHAR(50) = NULL,                  
@customer_code VARCHAR(500) = NULL,                  
@allow_web_online CHAR(1) = NULL,
@SenderZipCode varchar(50)=null,
@IMEI_Code varchar(150)=null,
@PaymentRoutingNumber varchar(9)=null,
@PaymentAccountNO varchar(20)=null,
@PaymentAccountType varchar(50)=null                          
AS                      
  
set @socailsecurity=replace(@socailsecurity,'-','')
  
IF @allow_web_online = 'y'
   AND @SenderEmail IS NULL
BEGIN
    SELECT 'Error' STATUS,
           'eMail Address should not BLANK !' Message
    
    RETURN
END
IF @allow_web_online = 'y'
   AND @SenderMobileno IS NULL
BEGIN
    SELECT 'Error' STATUS,
           'Mobile NO should not BLANK  !' Message
    
    RETURN
END                     
IF @flag = 'i' --insert into customerdetail
BEGIN
    IF EXISTS(
           SELECT *
           FROM   customerdetail
           WHERE  SenderMobile = @SenderMobileno
               
       )
    BEGIN
        SELECT 'Error' STATUS,
               'ERROR: Mobile No ''' + @SenderMobileno + ''' already exist !' Message
        
        RETURN
    END
 
        DECLARE @pwd        VARCHAR(50),
                @is_enable  CHAR(1)
        
        SET @pwd = NULL                  
        SET @is_enable = NULL                  
        IF @reg_agent_id = 'customer'
        BEGIN
            IF EXISTS(
                   SELECT *
                   FROM   customerdetail
                   WHERE  senderfax = @senderpassportType
                          AND senderpassport = @senderpassport
                          AND allow_web_online = 'y'
               )
            BEGIN
                SELECT 'Error' STATUS,
                       @senderpassportType + ': ' + @senderpassport + 
                       ' already exist !' Message
                
                RETURN
            END
            
            SET @pwd = dbo.encryptdb(
                    CAST(RIGHT(@CustomerID, 2) AS VARCHAR) + CAST(RIGHT(RAND(), 5) AS VARCHAR)
                )
            
            SET @pwd = dbo.encryptdb(@pwd)                  
            SET @is_enable = 'y'
        END
        
        SET @CustomerID = IDENT_CURRENT('customerdetail') + 1                  
        SET @pwd = dbo.encryptdb(
                      CAST(
                        RIGHT(@CustomerId + CAST(RIGHT(RAND(), 2) AS VARCHAR), 2) 
                        AS VARCHAR
                    ) +
                    CAST(RIGHT(RAND(), 5) AS VARCHAR) + CAST(RIGHT(RAND(), 2) AS VARCHAR)
                )
               
        
        INSERT INTO customerdetail
          (
            CustomerId,
            SenderName,
            SenderAddress,            
            SenderCity,
            SenderCountry,
            senderPassport,
            SenderEmail,
            SenderMobile,
			SenderPhoneNo,
            senderVisa,
            ID_Issue_date,
            create_ts,
            update_ts,
            SenderFax,
            SenderNativeCountry,
            senderState,
			--sender_State,
            Date_Of_Birth,
            SSN_Card_ID,
            is_enable,
            PASSWORD,           
            allow_web_online,
            SenderZipCode,
            IMEI_Code,
            PaymentRoutingNumber,
            PaymentAccountNumber,
            PaymentAccountType
          )
        VALUES
          (
            @CustomerId,
            @SenderName,
            @SenderAddress,       
            @SenderCity,
            @SenderCountry,
            @senderPassport,
            @SenderEmail,
            @SenderMobileno,
			@SenderMobileno,
            @senderVisa,
            @idIssueDate,
            dbo.getDateHO(GETUTCDATE()),
            @update_ts,
            @senderpassportType,
            @SenderNativeCountry,
            @senderState,
		--	@senderState,
            @Date_Of_Birth,
            @socailsecurity,
            'n',
            @pwd,
            'y',
            @SenderZipCode,
            @IMEI_Code,
            @PaymentRoutingNumber,
			@PaymentAccountNO,
			@PaymentAccountType            
          )   

declare @email_body varchar(5000)
set @email_body='Dear '+ upper(@SenderName) +',<br>'
set @email_body=@email_body +' Thank you for registering with Prabhu Money Transfer. <br><br>'
set @email_body=@email_body +' Customer ID:'+ @CustomerId +' <br>'
set @email_body=@email_body +' Password:'+ dbo.decryptDB(@pwd) +' <br><br>'
set @email_body=@email_body +' Your account is <font color=red>NOT ACTIVATED </font>yet to send transaction.<br><br>'
set @email_body=@email_body +'<p><b>Please follow to verify you bank account '+ @PaymentRoutingNumber + ' - xxxxxx'+Right(@PaymentAccountNO,4)+'</b></p>'
set @email_body=@email_body +'<div>'
set @email_body=@email_body +'To ensure the security and validity of your information, you will be asked to perform a simple verification process. </div>'
set @email_body=@email_body +'<ol>'
set @email_body=@email_body +'<li>Within two business days, we will generate two identical low value (less than USD 1.00) deposits in your account "xxxxxx'+Right(@PaymentAccountNO,4)+'".</li> '
set @email_body=@email_body +'<li>View your bank statement "xxxxxx'+Right(@PaymentAccountNO,4)+'" and the deposit will be labeled PRABHU or something similar.</li>'
set @email_body=@email_body +'<li>Sign in to Prabhu Money System again.</li>'
set @email_body=@email_body +'<li>Click the <i>Verify</i> tab, then click <i>Bank Settings</i>.</li>'
set @email_body=@email_body +'<li>Click Verify account.</li>'
set @email_body=@email_body +'<li>Enter the deposit amount exactly as it is displayed on your bank statement. If the deposit amount is $0.05, you should enter 0.05 as the deposit amount.</li>'
set @email_body=@email_body +'<li>Once the deposits are verified, we will activate your account and you will be notified by email as soon as it is completed with further instructions on activating the account.</li>'
set @email_body=@email_body +'</ol>'    
set @email_body=@email_body +' If you fail to verify your account for 3 days from the date of registration, you account will be automatic removed from system <br><br>'

set @email_body=@email_body +' Should you need any clarifications, please contact us at info@prabhugroupusa.com  <br>'
set @email_body=@email_body +' Looking forward to your continued patronage.  <br><br>'
set @email_body=@email_body +' Regards<br>Customer Service Team<br>www.prabhugroupusa.com '


INSERT INTO [email_request]      
           (      
           [notes_subject]      
           ,[notes_text]
			 ,[send_to]      
           , send_cc      
           ,[send_status]      
           ,[active_flag]      
          )      
SELECT 'Prabhu System Registration',      
 @email_body,      
    @SenderEmail,      
    'anoop@inficare.net',      
    'n',      
    'y'      
    
      exec spa_sendemail

              
        SELECT 'Success' STATUS,
               @CustomerId CustomerID,
               dbo.decryptdb(@pwd) PWD,
               @SenderEmail SenderEmail
    
END
ELSE IF @flag = 'u' --update into customerdetail
BEGIN
   
    IF EXISTS(
           SELECT *
           FROM   customerdetail
           WHERE  SenderMobile = @SenderMobileno and CustomerId <>@CustomerID
               
       )
    BEGIN
        SELECT 'Error' STATUS,
               'ERROR: Mobile No ''' + @SenderMobileno + ''' already exist !' Message
        
        RETURN
    END
     
    UPDATE customerdetail
    SET    SenderAddress = @SenderAddress,
           SenderCity = @SenderCity,
           SenderEmail = @SenderEmail,
		   SenderMobile = @SenderMobileno,
           update_ts = dbo.getDateHO(GETUTCDATE()),
           Date_Of_Birth = @Date_Of_Birth,
           senderState = @senderState,
		  -- sender_State = @senderState,
			SSN_Card_ID=@socailsecurity,
         --  ReceiverCountry = @ReceiverCountry,
           SenderZipCode=@SenderZipCode         
    WHERE  CustomerId	 = @CustomerId                     
    
    SELECT 'Success' STATUS,
           @CustomerId CustomerID,
           @SenderEmail
END
ELSE IF @flag = 'rc' --Receiver Country
BEGIN
        
    UPDATE customerdetail
    SET    ReceiverCountry = @ReceiverCountry   
    WHERE  CustomerId	 = @CustomerId                     
    
    SELECT 'Success' STATUS,
           @CustomerId CustomerID,
           @SenderEmail
END
ELSE IF @flag = 'y'
BEGIN
	
	 DECLARE @ssn_card_id  VARCHAR(50),
                @access   VARCHAR(50)
	
	UPDATE customerdetail
    SET    approve_ts = dbo.getDateHO(GETUTCDATE()),
           approve_by = @t_customerID,
           is_enable = 'y',
           allow_web_online = 'y'
    WHERE  CustomerId = @CustomerId
           AND sno = @customer_sno                    
    
            SELECT @SenderName = c.sendername,
               @SenderEmail = c.SenderEmail,
               @SenderMobileno = c.SenderMobile,
               @ssn_card_id = dbo.decryptdb(c.password),
               @access = b.agent_branch_code
        FROM   customerdetail c
               JOIN agentbranchdetail b
                    ON  c.sendercountry = b.country
        WHERE  c.CustomerId = @CustomerId
               AND c.sno = @customer_sno
               AND b.agent_branch_code IN (@customer_code)

    SELECT 'Success',
           @CustomerId,
           @SenderName,
           @ssn_card_id,
           @SenderEmail,
           @SenderMobileno,
           @access
	
END
ELSE IF @flag = 'a' -- select distinct from customerdetail
BEGIN
    SELECT CONVERT(varchar,Date_Of_Birth,101) SenderDOB,*
    FROM   customerdetail
    WHERE CustomerId = @CustomerID
           AND allow_web_online = 'y'
END 
ELSE IF @flag = 'd' --delete from customerdetail
BEGIN
    IF EXISTS(
           SELECT customer_sno
           FROM   moneySend
           WHERE  customer_sno = @customer_sno
       )
    BEGIN
        SELECT 'ERROR' STATUS,
               dbo.decryptDb(refno) AS ref,
               *
        FROM   moneySend
        WHERE  customer_sno = @customer_sno
        
        RETURN
    END
    
    DELETE customerdetail
    WHERE  sno = @customer_sno                  
    
    
    SELECT 'Success' STATUS,
           @customer_sno customer_sno
END
ELSE IF @flag = 'e'
BEGIN
    DECLARE @sno_old  INT,
            @sno_new  INT
    
    SELECT @sno_old = sno
    FROM   customerdetail
    WHERE  customerid = @CustomerID --and allow_web_online='y'                 
    SELECT @sno_new = sno
    FROM   customerdetail
    WHERE  customerid = @SenderName --and allow_web_online='y'                 
    UPDATE moneysend
    SET    customer_sno = @sno_new
    WHERE  customer_sno = @sno_old
    
    UPDATE customerReceiverDetail
    SET    sender_sno = @sno_new
    WHERE  sender_sno = @sno_old
    
    DELETE customerdetail
    WHERE  sno = @sno_old
END                  
                  
IF @flag = 'c' --checks custumer is disabled or not
BEGIN
    --if exists(select sno from customerdetail where customerid=@customerID and is_enable='n')                  
    SELECT 'This customer is disabled' msg,
           senderName,
           senderPassport,
           senderVisa
    FROM   customerdetail
    WHERE  customerid = @customerID
           AND is_enable = 'n'
END

IF @flag = 'r' -- reset passport
BEGIN
		
		UPDATE customerdetail
        SET    PASSWORD = dbo.encryptdb(
                   
                       CAST(
                           RIGHT(@CustomerId + CAST(RIGHT(RAND(), 2) AS VARCHAR), 2) 
                           AS VARCHAR
                       ) +
                       CAST(RIGHT(RAND(), 5) AS VARCHAR) + + CAST(RIGHT(RAND(), 2) AS VARCHAR)
                   )
               
        WHERE  ISNULL(allow_web_online, 'n') <> 'y'
               AND customerid = @CustomerId   
END
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetBeneficiaryDetail]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_MobileGetBeneficiaryDetail]
@flag char(1),
@beneficiary_sno int=null,
@customerID varchar(50)=null,
@payout_Country varchar(100)=null
as
if @flag='l'
begin
	select b.sno BenID,b.ReceiverName from customerReceiverDetail b join customerDetail c
	on b.sender_sno=c.sno
	where c.customerId=@customerID and b.ReceiverCountry=@payout_Country
	order by b.ReceiverName
end 
if @flag='a'
begin
	select b.ReceiverName,b.ReceiverAddress,b.ReceiverCity,b.ReceiverMobile,b.sno,
	ISNULL(cb.Bank_name,b.bank_name) ben_bank_detail,ISNULL(cbb.BranchName,b.branch_name) ben_bank_branch,
	b.accountno ben_bank_accountno,
	b.receivingbank Commercial_Bank_ID,b.branch_MIRC Commercial_Bank_Branch_ID
	from customerReceiverDetail b join customerDetail c
	on b.sender_sno=c.sno
	left outer join commercial_bank cb on cb.Commercial_id=b.receivingbank
	left outer join commercial_bank_branch cbb on cbb.sno=b.branch_MIRC
	where c.customerId=@customerID and b.sno=@beneficiary_sno
end

GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetPayoutBankDetail]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_MobileGetPayoutAgent 'Nepal'
--spa_MobileGetPayoutServiceType '12','Nepal'
Create proc [dbo].[spa_MobileGetPayoutBankDetail]
@payout_agent_id varchar(100),
@payout_country varchar(50)
as

if exists (select payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where payout_agent_id=@payout_agent_id)
begin
select distinct payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where payout_agent_id=@payout_agent_id
end
else if exists (select payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where Rec_Country=@payout_country)
begin
select distinct payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where Rec_Country=@payout_country
end
else
begin
select 'Cash Pay' payment_type,'C - Cash Payment' payment_name 
union 
select 'Bank Transfer' payment_type,'B - Account Deposit' payment_name 
end




GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetPayoutServiceType]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_MobileGetPayoutAgent 'Nepal'
--spa_RouteAgent 'Nepal','Send'
CREATE proc [dbo].[spa_MobileGetPayoutServiceType]
@payout_agent_id varchar(100),
@payout_country varchar(50)
as

if exists (select payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where payout_agent_id=@payout_agent_id)
begin
select distinct payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where payout_agent_id=@payout_agent_id
end
else if exists (select payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where Rec_Country=@payout_country)
begin
select distinct payment_type,additional_value +' - '+static_value payment_name from service_charge_setup s join static_values sv on s.payment_type=sv.static_data
and sv.sno=7 where Rec_Country=@payout_country
end
else
begin
select 'Cash Pay' payment_type,'C - Cash Payment' payment_name 
union 
select 'Bank Transfer' payment_type,'B - Account Deposit' payment_name 
end




GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetTransaction]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--spa_MobileGetTransaction 'r',1939766 ,'103617'
CREATE proc [dbo].[spa_MobileGetTransaction]
@flag char(1),
@tranno int=null,
@customerid varchar(50)
as
if @flag='r' --- Print Receipt
begin
declare @payment_instruction varchar(max)
set @payment_instruction='Thanks for doing a Transaction'
select a.AgentType , a.companyName PayoutPartner,     
case when a.AgentType<>'RTAgent' then totalroundamt else ext_payout_amount end PayoutAmount,      
case when a.AgentType<>'RTAgent' then ReceiveCType else isNUll(PNBReferenceNo,ReceiveCType) end PayoutCCY,      
case when a.AgentType<>'RTAgent' then today_dollar_rate else isNUll(bonus_value_amount,today_dollar_rate) end CustRate,
@payment_instruction payment_instruction,case when transStatus in ('Hold','Staging') then '<font color=red><i>Waiting Approval</i></font>' else dbo.decryptDB(refno) End PINNO,
'xxxxxxxx'+right(m.PaymentAccountNumber,4) PayAccountNumber,
* from moneysend m with (NOLOCK) left outer join agentdetail a with (NOLOCK) on m.expected_payoutagentid=a.agentcode 
 where tranno=@tranno and customerid=@customerid
end
if @flag='l' --- Report List
begin
	select top 10 Tranno,case when transStatus in ('Hold','Staging') then '<font color=red><i>Not Approve</i></font>' else dbo.decryptDB(refno) End PINNO,ReceiverName,
	case when transStatus in ('Hold','Staging') then '-' else Status End Status,
	case when a.AgentType<>'RTAgent' then totalroundamt else ext_payout_amount end PayoutAmount,      
	case when a.AgentType<>'RTAgent' then ReceiveCType else isNUll(PNBReferenceNo,ReceiveCType) end PayoutCCY,      
	case when a.AgentType<>'RTAgent' then today_dollar_rate else isNUll(bonus_value_amount,today_dollar_rate) end CustRate,
	local_DOT Trans_Date
	from  moneysend m with (NOLOCK) left outer join agentdetail a with (NOLOCK) on m.expected_payoutagentid=a.agentcode 
	where CustomerId=@customerid
	order by local_DOT desc 
end

GO

/****** Object:  StoredProcedure [dbo].[spa_MobileSaveTransaction]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_MobileSaveTransaction]
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
   SET @MLKP_Agentid='11000010'      
   SET @BANK_MANDIRI_Agentid='11000005'         
             
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
	SenderAddress=@SenderAddress,SenderCity=@SenderCity,senderState=@SenderState,
	date_of_birth=@SenderDOB,SenderMobile=@SenderMobile,SenderZipCode=@SenderZipCode
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
                   AND ISNULL(isAnyWhere, 'n') = 'y'        
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
         
     DECLARE @tranno     BIGINT,        
             @dot        DATETIME,        
             @dottime    VARCHAR(20),        
             @rnd_id     VARCHAR(4),        
             @trannoref  BIGINT,
             @refno		Varchar(20)              
             
     SET @dot = CONVERT(VARCHAR, GETDATE(), 101)              
     SET @dottime = CONVERT(VARCHAR, GETDATE(), 108)              
             
     SET @rnd_id = LEFT(ABS(CHECKSUM(NEWID())), 2)         
             
     --set @tranno=ident_current('moneysend') + 1              
     SET @trannoref = IDENT_CURRENT('tbl_refno') + 1              
        
       SET @refno = 'T'+ @rnd_id + '1' + LEFT(CAST(@trannoref AS VARCHAR), 4)        
          + REVERSE(SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3))         
         + RIGHT(CAST(@trannoref AS VARCHAR), 1) + LEFT(ABS(CHECKSUM(NEWID())), 2)        
       
       if @expected_payoutagentid=@MLKP_Agentid ---- MLKP REF NO WITH 12 DIGIT  
       BEGIN     
       SET @refno = @rnd_id + '1' + LEFT(CAST(@trannoref AS VARCHAR), 4)        
          + REVERSE(SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3))         
         + RIGHT(CAST(@trannoref AS VARCHAR), 1) + LEFT(ABS(CHECKSUM(NEWID())), 1)      
       END
       if @expected_payoutagentid=@BANK_MANDIRI_Agentid ---- Bank mandiri Cash Pay REF NO WITH 12 DIGIT    
       BEGIN       
       SET @refno = @rnd_id + '1' + LEFT(CAST(@trannoref AS VARCHAR), 4)          
          + REVERSE(SUBSTRING(CAST(@trannoref AS VARCHAR), 4, 3))           
         + RIGHT(CAST(@trannoref AS VARCHAR), 1) + LEFT(ABS(CHECKSUM(NEWID())), 1)        
       END    
                
                 
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
         senderState,        
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
         SenderBankName,
         SenderZipCode    
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
		   'Mobile',
		   @SenderZipCode
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
           @branch_voucher        
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
            
  
  
  
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileGetPayoutAgent]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_MobileGetPayoutAgent 'Nepal'
--spa_RouteAgent 'Nepal','Send'
CREATE proc [dbo].[spa_MobileGetPayoutAgent]
@payout_country varchar(100)
as
select * from (
select agentcode,companyname AgentName from agentDetail
where Country=@payout_country and accessed='Granted' 
and AgentType in ('ExtAgent','Send and Pay')
union all 
select static_data,Description from static_values s join API_Country_setup c
on s.static_data=c.API_Agent
where s.sno=500 and enable_send='y' and c.country=@payout_country
) l order by AgentName
GO

/****** Object:  StoredProcedure [dbo].[spa_MobileAuthentication]    Script Date: 09/09/2013 13:09:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_MobileAuthentication]      
@flag char(1), --- l : Login      
@UserName Varchar(50)=null,      
@UserPwd varchar(50)=null,      
@AuthenticationLog varchar(150)=null,      
@IMEI_Code varchar(150)=null,
@payout_agent_id varchar(50)=null      
as      
declare @HODate datetime      
declare @valid_pwd int,@isBlock char(1) , @categoryid varchar(10), @Discount_NTC varchar(10), @Discount_NCELL varchar(10),@eWallet money ,@senderName varchar(150)   
declare @agent_id varchar(50),@branch_id varchar(50),@payout_country varchar(50),@cust_rate float,@payout_ccy varchar(50),
@transaction_limit money,@isEnable char(1),@approve_by varchar(50)
set @transaction_limit=3000  
if @flag='l'      
begin      
    
Select @eWallet=eWallet,@isBlock=isNull(allow_web_online,'n'),@senderName=SenderName,@approve_by=approve_by from       
customerDetail where CustomerId=@UserName  and password=dbo.encryptDB(@UserPwd)  
   
 if @isBlock is null   
 begin  
 Select 'Error' Code,'Authentication invalid' MSG      
 return      
 end     
     
 if @isBlock='n'     
begin      
  Select 'Error' Code,'Your user id is not allowed to login. Please contact our support office' MSG      
  return     
end       
       
 set @HODate=dbo.getDateHO(getutcdate())      
      
 set @AuthenticationLog=REPLACE(newid(),'-','_')       
 insert [AuthenticationLog]      
           ([UserName]      
           ,[AuthenticationLog]      
           ,[IMEI_Code]      
           ,[AuthenticationDate]      
           )      
 values(@UserName,@AuthenticationLog,@IMEI_Code,@HODate)      
      
 select 'Success' Code,@AuthenticationLog AuthenticationLog,eWallet,SenderName,SenderMobile,ReceiverCountry  
 from customerDetail where CustomerId=@UserName  
      
end      
if @flag='c' -- Cookies      
begin      
      
 Select @eWallet=eWallet,@isBlock=isNull(allow_web_online,'n'),@senderName=SenderName from       
 customerDetail where CustomerId=@UserName  and password=@UserPwd  
   
       
 if @isBlock is NUll      
 begin      
  Select 'Error' Code,'Authentication invalid' MSG      
  return      
 end      
      
 if @isBlock='n'      
 begin      
   Select 'Error' Code,'You user is not active' MSG      
  return      
 end      
       
 set @HODate=dbo.getDateHO(getutcdate())      
      
 set @AuthenticationLog=REPLACE(newid(),'-','_')       
 insert [AuthenticationLog]      
           ([UserName]      
           ,[AuthenticationLog]      
           ,[IMEI_Code]      
           ,[AuthenticationDate]      
           )      
 values(@UserName,@AuthenticationLog,@IMEI_Code,@HODate)      
      
 select 'Success' Code,@AuthenticationLog AuthenticationLog,eWallet,SenderName,SenderMobile,ReceiverCountry  
 from customerDetail where CustomerId=@UserName  
   
end      
if @flag='v'      
begin      
   declare @check_Session varchar(150)    
     
 select @UserName=username from [AuthenticationLog] where [AuthenticationLog]=@AuthenticationLog     
 select top 1  @check_Session=AuthenticationLog from [AuthenticationLog]     
 where userName=@UserName order by sno desc     
     
 if @AuthenticationLog=@check_Session    
 begin  
    
  select @agent_id=b.agentCode,@payout_country=c.ReceiverCountry,@branch_id=m.agent_branch_code  
  from [AuthenticationLog] l join customerDetail c  
  on l.UserName=c.CustomerId  
  left outer join MobileAgentRoute m on m.country_name=c.SenderCountry  
  left outer join agentbranchdetail b on b.agent_branch_Code=m.agent_branch_code  
  where [AuthenticationLog]=@AuthenticationLog    
   
   IF EXISTS(        
            SELECT agentId        
            FROM   agentpayout_CurrencyRate_Branch WITH (NOLOCK)        
            WHERE  agentId = @agent_id        
                   AND agent_branch_code = @branch_id        
                   AND payout_agent_id = @payout_agent_id        
        )        
     BEGIN        
                 
         SELECT @cust_rate=[customer_rate],@payout_ccy=x.receiveCType           
         FROM   agentpayout_CurrencyRate_Branch x WITH (NOLOCK)        
         WHERE  x.agentId = @agent_id        
                AND agent_branch_code = @branch_id        
                AND payout_agent_id = @payout_agent_id        
     END        
     ELSE         
     IF EXISTS(        
            SELECT agentId        
            FROM   agentpayout_CurrencyRate WITH (NOLOCK)        
            WHERE  agentId = @agent_id        
                   AND payout_agent_id = @payout_agent_id        
        )        
     BEGIN        
         SELECT @cust_rate=[customer_rate],@payout_ccy=x.receiveCType      
         FROM   agentpayout_CurrencyRate x WITH (NOLOCK)        
         WHERE  x.agentId = @agent_id        
                AND payout_agent_id = @payout_agent_id        
     END        
     ELSE 
  IF EXISTS(select * FROM agent_branch_rate WHERE agentId=@agent_id and agent_branch_code=@branch_id        
  AND receiveCountry=@payout_country)        
  begin        
   select @cust_rate=[customer_rate],@payout_ccy=x.receiveCType        
   from agent_branch_rate x         
   where x.agentId=@agent_Id and agent_branch_code=@branch_id and x.receiveCountry=@payout_country        
  end        
  else        
  begin        
   select @cust_rate=[customer_rate],@payout_ccy=x.receiveCType    
   from agentCurrencyRate x         
   where x.agentId=@agent_Id  and x.receiveCountry=@payout_country        
  end      
  
    select l.UserName,l.IMEI_Code,    
    case when LogoutDate is null then 'valid' else 'invalid' end LogStatus,eWallet,upper(SenderName) SenderName,SenderMobile,isNUll(ReceiverCountry,'-1') ReceiverCountry,m.agent_branch_code,m.country_name,a.CurrencyType,  
    b.branchCodeChar,a.agentCode,@cust_rate Cust_Rate,@payout_ccy payout_ccy,@transaction_limit Trans_Limit,isNull(is_enable,'n') isAuthorized    
  from [AuthenticationLog] l join customerDetail c  
  on l.UserName=c.CustomerId  
  left outer join MobileAgentRoute m on m.country_name=c.SenderCountry  
  left outer join agentbranchdetail b on b.agent_branch_Code=m.agent_branch_code  
  left outer join agentdetail a on b.agentCode=a.agentCode  
  where [AuthenticationLog]=@AuthenticationLog      
 end   
   else    
 begin    
  select l.*,    
   'invalid' LogStatus,eWallet,SenderName,SenderMobile,ReceiverCountry      
    from [AuthenticationLog] l join customerDetail c  
    on l.UserName=c.CustomerId where [AuthenticationLog]=@AuthenticationLog      
 end     
       
end   
if @flag='o' -- Logout      
begin      
  update [AuthenticationLog] set logoutDate=getdate() where [AuthenticationLog]=@AuthenticationLog   
       
end 
GO



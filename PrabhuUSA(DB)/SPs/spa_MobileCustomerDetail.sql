set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROC [dbo].[spa_MobileCustomerDetail]                          
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
@PaymentAccountType varchar(50)=null,
@lock_status char(1)=null                          
AS                      
  
set @socailsecurity=replace(@socailsecurity,'-','')
 declare @email_body varchar(5000)
 
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
                      CAST(
                        right(RAND(),6)
                        AS VARCHAR
                    ) 
                )
            
            SET @pwd = dbo.encryptdb(@pwd)                  
            SET @is_enable = 'y'
        END
        
        SET @CustomerID = IDENT_CURRENT('customerdetail') + 1                  
        SET @pwd = dbo.encryptdb(
                      CAST(
                        right(RAND(),6)
                        AS VARCHAR
                    ) 
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
			sender_State,
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
			@senderState,
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
set @email_body=@email_body +' If you fail to verify your account for 3 days from the date of registration, your account will be automatic removed from system <br><br>'

set @email_body=@email_body +' Should you need any clarifications, please contact us at info@prabhuonline.com  <br>'
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
		   sender_State = @senderState,
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
else if @flag='ub'
begin
	update customerDetail set PaymentRoutingNumber=@PaymentRoutingNumber,
	PaymentAccountNumber=@PaymentAccountNO,PaymentAccountType=@PaymentAccountType,
	is_enable=null,ONlineVerificationDeposit2=null,ONlineVerificationDeposit1=null,
	onlineVerifyDate=null,onlineVerifyUser=null where customerid=@CustomerId
	
end
else if @flag='l' -- Lock User
begin
	UPDATE customerdetail
    SET    lock_status = 'y',lock_date=getdate()
    WHERE  CustomerId	 = @CustomerId   
end
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
		set @pwd= CAST(right(RAND(),6)     AS VARCHAR) 
		set @pwd=replace(@pwd,'.','9')
		UPDATE customerdetail
        SET    PASSWORD = dbo.encryptdb(@pwd)               
        WHERE  customerid = @CustomerId   
       select @SenderName=SenderName,@SenderEmail=SenderEmail from customerDetail where CustomerId=@CustomerID        
               
set @email_body='Dear '+ upper(@SenderName) +',<br>'
set @email_body=@email_body +' Your password has been reset. <br><br>'
set @email_body=@email_body +' Customer ID:'+ @CustomerId +' <br>'
set @email_body=@email_body +' Password:'+ (@pwd) +' <br><br>'

set @email_body=@email_body +' Should you need any clarifications, please contact us at info@prabhuonline.com  <br>'
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
SELECT 'Prabhu System - Password Reset',      
	@email_body,      
    @SenderEmail,      
    'anoop@inficare.net',      
    'n',      
    'y'      
      exec spa_sendemail
select @SenderEmail SenderEmail
END


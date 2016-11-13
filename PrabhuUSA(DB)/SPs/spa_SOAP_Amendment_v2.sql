CREATE proc [dbo].[spa_SOAP_Amendment_v2]  
    @accesscode varchar(100),  
    @username varchar(100),  
    @password varchar(100),  
    @AGENT_REFID VARCHAR(150),  
    @REFID VARCHAR(50),  
    @Amendment_Field VARCHAR(50),  
    @Amendment_value VARCHAR(150),
    @client_pc_id VARCHAR(150)=null 
as  
declare @agentcode varchar(50),@agent_branch_code varchar(50),@user_pwd varchar(50), @accessed varchar(50)  
declare @Block_branch varchar(50), @BranchCodeChar varchar(50), @lock_status varchar(5),@agent_user_id varchar(50)  
declare @user_count int,@limit_per_TXN money,  
@agentname varchar(100),@branch varchar(100),@gmtdate datetime,@COLLECT_CURRENCY varchar(5)  
IF @client_pc_id IS NULL 
	SET @client_pc_id='192.168.1.100'  
BEGIN TRY  
SET XACT_ABORT ON;  
declare @sql varchar(8000)  
declare @return_value varchar(1000)  
  
if @username is null or @password is null or @accesscode is null  
or @AGENT_REFID is NULL or @Amendment_Field is null or @Amendment_value is null OR @REFID IS NULL 
begin  
 set @return_value='Mandotoary field missing'  
 select '1001' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID  
 return  
end  
if  @AGENT_REFID is null   
begin  
 set @return_value='Agent Session ID is missing'  
 select '1005' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID  
 return  
end  
declare @currentBalance money  ,@allow_integration_user  CHAR(1)
SELECT @agentcode=a.agentcode,@agentname=a.companyName,@user_pwd=u.user_pwd,@agent_user_id=u.agent_user_id,  
@accessed=a.accessed,@branch=b.branch,  
@agent_branch_code=b.agent_branch_code,@BranchCodeChar=b.BranchCodeChar,   
@Block_branch=isNUll(b.block_branch,'n'),@lock_status=isNUll(u.lock_status,'n'),@COLLECT_CURRENCY=a.currencyType,  
@gmtdate=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@currentBalance=(isNUll(a.limit,0)-isNUll(a.currentBalance,0)),  
@limit_per_TXN=a.limitPerTran,@allow_integration_user=isNull(u.allow_integration_user,'n')  
 FROM agentDetail a JOin agentbranchdetail b on a.agentcode=b.agentcode  
JOIN agentsub u ON b.agent_branch_code=u.agent_branch_code   
where u.user_login_id=@username 
set @user_count=@@rowcount  
  
----AUTHENTICATING USER----------  
if @user_count=0  
begin  
set @return_value='Invalid User ID'  
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)   
values(@client_pc_id,'SOAP_CreateTXN',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,NULL,@username,'******','Invalid User Name','Failed')  
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID  
return  
end  
if @user_pwd<>dbo.encryptdb(@password)  
begin  
set @return_value='Invalid Password'  
insert  sys_access(ipadd, login_type, log_date, log_time, branch_code, emp_id, user_id, pwd, msg, status)   
values(@client_pc_id,'SOAP_CreateTXN',convert(varchar,getdate(),102),convert(varchar,getdate(),108),@accesscode,@agent_user_id,@username,@password,'Invalid Password','Failed')  
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID  
return  
end  
if @BranchCodeChar<>@accesscode  
begin  
set @return_value='Agent ID invalid'  
select '1002' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID  
return  
end  
if @Block_branch='y'   OR @lock_status='y'
begin  
set @return_value='Your userid is Blocked'  
select '1003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID  
return  
end  
IF @allow_integration_user='n'
begin
	set @return_value='Your userid is not allowed to access Web Services'
	select '1003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID
	return
END

DECLARE @field_matched INT ,@Amendment_Notes VARCHAR(100)

SET @Amendment_Notes=@Amendment_Field

IF @Amendment_Field='Sender_Name'
BEGIN 
		SET @Amendment_Field='SenderName'	
		set @field_matched=1	
END
IF @Amendment_Field='SENDER_MOBILE'
BEGIN 
		SET @Amendment_Field='senderphoneno'	
		set @field_matched=1
END
IF @Amendment_Field='Receiver_Name'
BEGIN 
		SET @Amendment_Field='ReceiverName'	
		set @field_matched=1
END
IF @Amendment_Field='RECEIVER_CONTACT_NUMBER'
BEGIN 
		SET @Amendment_Field='ReceiverPhone'	
		set @field_matched=1
END
IF @Amendment_Field='RECEIVER_ADDRESS'
BEGIN 
		SET @Amendment_Field='ReceiverAddress'	
		set @field_matched=1
END

IF @field_matched=0
BEGIN 
	set @return_value='You can not amendment this field:'+@Amendment_Field
	select '1004' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID
	return
END  
DECLARE @tranno                 INT,
        @sender_name            VARCHAR(100),
        @receiver_name          VARCHAR(100),
        @senderphoneno          VARCHAR(100),
        @ReceiverPhone	        VARCHAR(100),
        @status                 VARCHAR(100),
        @tran_agentid			VARCHAR(50)  ,
        @receiveraddress	VARCHAR(100),
        @transstatus	VARCHAR(50)

SELECT @tranno = tranno,
		@sender_name=senderName,
		@receiver_name=receiverName,
		@senderphoneno=m.SenderPhoneno,
		@ReceiverPhone=m.ReceiverPhone,
		@receiveraddress=m.ReceiverAddress,
	    @tran_agentid=m.agentid,
	    @transstatus=m.TransStatus,
	    @status = CASE 
                      WHEN STATUS = 'Paid' THEN 'PAID'
                      WHEN transStatus = 'Cancel' THEN 'Cancel'
                      WHEN transStatus IN ('Hold', 'OFAC', 'BLOCKED','Compliance') THEN 
                           'Hold'
                      WHEN transStatus = 'Payment' AND STATUS = 'Un-Paid' THEN 
                           'Un-Paid'
                 END
FROM   moneySend m WITH(NOLOCK)
WHERE  refno = dbo.encryptDB(@REFID) AND m.agentid=@agentcode

IF @tranno IS NULL
   OR @tranno = 0
BEGIN
    SET @return_value = 'Transaction Not Found PINNO:' + CAST(@REFID AS VARCHAR)    
    select '2003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID
    RETURN 
END
IF isNUll(@status,'x') <> 'Un-Paid'
BEGIN
    SET @return_value = 'Can not amendment this TXN:' + CAST(@REFID AS VARCHAR)  +' Current Stage:'+@transstatus + ' - '+   @status
    select '2003' Code,@AGENT_REFID AGENT_REFID,@return_value Message,NULL REFID
     RETURN 
END
DECLARE @Comments VARCHAR(1000)
SET @Comments='Amendment Request: '+@Amendment_Field + ' to '+ @Amendment_value 
if @status = 'Un-Paid' and @transstatus in ('Hold','Payment') and @field_matched=1
BEGIN

	SET @Comments='Amendment Done though API from '+ case when @Amendment_Field='SenderName' then isnull(@sender_name,'')	
		 when @Amendment_Field='senderphoneno' then	isnull(@senderphoneno,'')
		 when @Amendment_Field='ReceiverName' then isnull(@receiver_name,'')
		 when @Amendment_Field='ReceiverPhone' then isnull(@ReceiverPhone,'')
		when @Amendment_Field='ReceiverAddress' then isnull(@receiveraddress,'')
		else @Amendment_Field end+' to '+isnull(@Amendment_value,'')

	EXECUTE('UPDATE moneysend set '+@Amendment_Field+'='''+@Amendment_value+''' WHERE refno=dbo.encryptDB('''+@REFID+''') AND agentid='''+@agentcode+'''')
END


INSERT INTO TransactionNotes
(
	RefNo,
	Comments,
	DatePosted,
	PostedBy,
	uploadBy,
	noteType,
	tranno
)
VALUES
(
	dbo.encryptDB(@REFID),
	 @Comments,
	GETDATE(),
	'API:'+@username,
	'S',
	1,
	@tranno
)
DECLARE @email_body VARCHAR(MAX)
SET @email_body='PINNO:'+ @REFID +'<br>Amendment Request:' +@Amendment_Field + ' to '+ @Amendment_value
set @email_body=@email_body +'<br>Requested by:'+@username

INSERT INTO [email_request]  
           (  
           [notes_subject]  
           ,[notes_text]  
           ,[send_from]  
           ,[send_to]  
           , send_cc  
           ,[send_status]  
           ,[active_flag]  
          )  
            
SELECT 'Amendment Request :'+ @REFID,  
 @email_body,  
 '',  
    'ithead@prabhugroupus.com;support@prabhugroupusa.com',  
    '',  
    'n',  
    'y'  



	INSERT INTO SOAP_TXN_NOTIFICATION
	(
		refno,
		agentid,
		notification_remarks,
		notification_date,
		notification_type
		
	)
	VALUES
	(
		@REFID,
		@agentcode,
		'Amendment Request:' +@Amendment_Field + ' to '+ @Amendment_value,
		@gmtdate,
		'Amendment'
	
	)
	
	set @return_value='Your Amendment request was accepted, and its Pending to Head Office to approved'
	select '0' Code,@AGENT_REFID AGENT_REFID,@return_value Message,@REFID REFID
	return 
 
end try  
begin catch  
  
if @@trancount>0   
 rollback transaction  
   
 declare @desc varchar(1000)  
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'  
 declare @error_id varchar(50)  
   
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
 select -1,@desc,'spa_SOAP_Amendment_v2','SQL',@desc,'SQL','SP',@AGENT_REFID,getdate()  
set @error_id=@@identity  
 select '9001' Code,@AGENT_REFID AGENT_REFID,'Technical Error:'+@error_id  Message,NULL REFID  
  
end catch  
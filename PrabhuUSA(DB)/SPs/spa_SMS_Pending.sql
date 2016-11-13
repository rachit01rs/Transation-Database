drop PROC spa_SMS_Pending
go
create PROC spa_SMS_Pending
@flag CHAR(1),
@category_id INT,
@sms_Text VARCHAR(160),
@user_id VARCHAR(50)
AS 
IF @flag='i'
	insert into sms_pending (deliverydate,mobileno,message,smsto,country,agentuser,status,sender_id)
	SELECT GETDATE(),mobile_no,@sms_Text,'s',NULL,@user_id,'p','PrabhuUSA' FROM dbo.address_book
	WHERE category_type=@category_id
	SELECT @@ROWCOUNT Total
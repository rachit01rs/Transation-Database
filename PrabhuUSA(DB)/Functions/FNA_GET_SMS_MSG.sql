/****** Object:  UserDefinedFunction [dbo].[FNA_GET_SMS_MSG]    Script Date: 04/20/2014 18:06:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNA_GET_SMS_MSG]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNA_GET_SMS_MSG]
Go
CREATE FUNCTION [dbo].[FNA_GET_SMS_MSG]
(@tranno INT )
RETURNS VARCHAR(2000) 
AS
BEGIN
	

	DECLARE @result VARCHAR(2000)
	SELECT @result=smsMsgS FROM tbl_setup WITH(NOLOCK)
	SELECT @result=replace(@result,'#SENDER_NAME#',m.senderName)
	,@result=replace(@result,'#SENDER_COUNTRY#',m.senderCountry)
	,@result=replace(@result,'#RECEIVER_NAME#',m.receiverName)
	,@result=replace(@result,'#SENT_DATE#',m.dot)
	,@result=replace(@result,'#SENT_CURRENCY#',m.paidCType)
	,@result=replace(@result,'#SENT_AMT#',m.paidAmt)
	,@result=replace(@result,'#PAID_DATE#',isnull(m.paidDate,''))
	,@result=replace(@result,'#PAID_CURRENCY#',m.receiveCType)
	,@result=replace(@result,'#PAID_AMT#',m.receiveAmt)
	,@result=replace(@result,'#PAID_AGENT#',isNull(m.rBankName,'') +' - '+ isNull(m.rBankBranch,''))
	FROM moneysend m WITH(NOLOCK) WHERE m.tranno= @tranno AND m.STATUS='Paid'
	RETURN  @result	
END 
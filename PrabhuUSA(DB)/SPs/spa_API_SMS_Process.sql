DROP PROC [dbo].[spa_API_SMS_Process] 
Go  
CREATE PROC [dbo].[spa_API_SMS_Process] 
@flag CHAR(1)='u' 
AS  
BEGIN
	set nocount on
	IF @flag='u'
	BEGIN
		DELETE FROM sms_pending WHERE LEN(mobileNo)<7 AND status='p'
		SELECT CASE WHEN m.ReceiverCountry ='Nepal' THEN 'PrabhuBank' ELSE 'PrabhuUSA' END SYSTEMID,s.mobileNo [Receiver Mobile],
		s.REFNO [ControlNumber],s.Message [SMS Text],s.deliveryDate [SMS Date],      
		CASE WHEN UPPER(SmsTo)='R' THEN 'Receiver' WHEN UPPER(SmsTo)='S' THEN 'Sender' ELSE 'Other' END   [SMS Type],m.agentid,
		m.expected_payoutagentid [payoutagentid],s.sno 
		INTO #temp FROM sms_pending s LEFT OUTER JOIN moneysend m WITH(NOLOCK) ON  m.refno=dbo.encryptdb(s.refno)  WHERE s.status='p'
		ORDER BY sno

		UPDATE sms_pending SET status='a' FROM sms_pending s WITH(NOLOCK) join #temp t ON s.sno=t.sno WHERE status='p'
		
		SELECT SYSTEMID,[Receiver Mobile],[ControlNumber],[SMS Text],[SMS Date],[SMS Type],[agentid],[payoutagentid] FROM #temp
	END
END

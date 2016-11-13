DROP PROC [dbo].[spa_IntegrationTransactionCheck]  
Go  
CREATE PROC [dbo].[spa_IntegrationTransactionCheck]  
@refno VARCHAR(20),  
@payout_country VARCHAR(50),  
@user_login_id VARCHAR(50)  
AS  
SET NOCOUNT ON  
DECLARE @process_id VARCHAR(150)  
SET @process_id=replace(newid(),'-','_')  
  
DECLARE @status VARCHAR(50),@transStatus VARCHAR(50),@lock_status VARCHAR(50) ,@diable_payout CHAR(1) 
Select @status=m.[status],@transStatus=m.TransStatus,@lock_status=isNUll(m.lock_status,'unlocked')    
  ,@diable_payout=ISNULL(a.disable_payout,'n')
  from moneysend m  WITH (NOLOCK) JOIN agentDetail a   WITH (NOLOCK) ON a.agentCode=m.agentid 
  WHERE Refno=dbo.encryptDB(@refno) AND m.ReceiverCountry=@payout_country  
  
IF @status IS NULL   
BEGIN   
 SELECT 'Error' StatusMsg,'Transaction Number is not valid' MESSAGE  
 RETURN   
END   
IF @status='Paid'   
BEGIN   
 SELECT 'Error' StatusMsg,'Transaction is arleady Paid' MESSAGE  
 RETURN   
END   
IF @status='Post'   
BEGIN   
 SELECT 'Error' StatusMsg,'Transaction is arleady Proceed for Payment. You can not make it now' MESSAGE  
 RETURN   
END    
IF isNUll(@transStatus,'n') <> 'Payment'   
BEGIN   
 SELECT 'Error' StatusMsg,'Transaction is ['+@transStatus +'].Please contact Head Office for any assistance' MESSAGE  
 RETURN   
END    
IF @lock_status='Locked'  
BEGIN  
 SELECT 'Error' StatusMsg,'This Transaction is in Lock Status.Please retry later' MESSAGE  
 RETURN   
END  
IF LOWER(@diable_payout)='y'  
BEGIN  
 SELECT 'Error' StatusMsg,'This Transaction is blocked.Please contact the remitter.' MESSAGE  
 RETURN   
END  
  
UPDATE moneySend  
SET lock_status='locked',lock_by = @user_login_id,lock_dot = GETDATE() WHERE refno=dbo.encryptDb(@refno)   
AND [status]='Un-Paid' AND TransStatus='Payment'  
AND ReceiverCountry=@payout_country  
   
   
SELECT 'Success' StatusMsg,datediff(d,local_dot,getdate()) TotalDay,NULL LinkSrvInfo, NULL session_id,m.*,a.CompanyName PayoutAgent FROM moneysend m with (nolock)
     join agentdetail a on m.expected_payoutagentid=a.agentcode WHERE m.refno=dbo.encryptDb(@refno) AND m.[status]='Un-Paid' AND m.TransStatus='Payment'  
AND m.ReceiverCountry=@payout_country  
  
  
  
  
CREATE PROCEDURE [dbo].[spa_SampathBank_approve]  
    @StatusCode VARCHAR(50),  
    @tranno VARCHAR(50),    
    @refno VARCHAR(50),    
    @sempid VARCHAR(50),     
    @DIG_INFO VARCHAR(150)=null    
AS    
BEGIN    
  
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
 DECLARE @rDate datetime,@rTime VARCHAR(20), @rGMTValue VARCHAR(10)      
 DECLARE @sDate datetime,@sGMTValue VARCHAR(10)      
 DECLARE @senderAgent VARCHAR(20),@HoDollarRate MONEY      
 DECLARE @rBankId VARCHAR(100),@rBankBranch VARCHAR(100), @rBankName VARCHAR(100)    
    
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GET GMT VALUES OF SENDER AND RECEIVER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      
  SELECT @senderAgent=agentid, @HoDollarRate=ho_dollar_rate,@rGMTValue=GMT_value       
  FROM moneysend m with (Nolock) JOIN agentdetail a on a.agentcode=m.agentid       
  WHERE refno = dbo.encryptdb(@refno)  AND tranno=@tranno      
       
  SELECT @sGMTValue=GMT_value,      
   @sDate=dateadd(mi,GMT_value,getutcdate())     
  FROM agentDetail a join agent_function f on agent_id=a.agentcode       
  WHERE a.agentcode=@senderAgent      
       
 -- SET @rDate = dateadd(mi,@rGMTValue,getutcdate())       
  -- dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,1)      
  SET @rTime =  dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,2)      
    
 UPDATE moneysend SET    
 transStatus = 'Payment',      
 confirmDate = cast(@sDate as varchar),    
 approve_by  = isNULL(@SempId,'Sampath_user'),    
 imeCommission=0, bankCommission=0,       
 paid_date_usd_rate=cast(isNULL(@HoDollarRate,'') as varchar),      
 confirm_process_id= @StatusCode,        
 digital_id_payout=@DIG_INFO,      
 lock_status='unlocked'      
 WHERE refno=dbo.encryptdb(@refno) and tranno=@tranno      
--  if @LastBal is  not null      
--  UPDATE agentdetail SET currentBalance=@LastBal WHERE agentcode=@expected_payoutagentid      
       
 SELECT 'Success' STATUS, @tranno tranno,@refno refno      
END
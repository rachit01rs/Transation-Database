Create PROC [dbo].[spa_BSM_transaction]            
 @paidBy VARCHAR(50),                                  
 @tranno INT=NULL,                                      
 @refno VARCHAR(50)=NULL,                                    
 @SempId VARCHAR(50)=NULL,                    
 @expected_payoutagentid VARCHAR(50)=NULL,                                      
 @Refference VARCHAR(50)=NULL,            
 @NTP VARCHAR(14)=NULL,            
 @PIN VARCHAR(7)=NULL,                                
 @BSMREFF VARCHAR(16)=NULL,             
 @MsgKey VARCHAR(16)=NULL,            
 @DIG_INFO varchar(150)=NULL                              
AS                              
BEGIN TRY                              
BEGIN TRANSACTION                              
                     
                      
 SET NOCOUNT ON;                              
 DECLARE @rDate datetime,@rTime VARCHAR(20), @rGMTValue VARCHAR(10)                              
 DECLARE @sDate datetime,@sGMTValue VARCHAR(10),@GMT_Date DATETIME                  
 DECLARE @senderAgent VARCHAR(20),@HoDollarRate MONEY                              
 DECLARE @rBankId VARCHAR(100),@rBankBranch VARCHAR(100), @rBankName VARCHAR(100)                                             
                                       
 --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GET GMT VALUES OF SENDER AND RECEIVER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                              
 SELECT @senderAgent=agentid, @HoDollarRate=ho_dollar_rate,@rGMTValue=GMT_value                               
 FROM moneysend m with (Nolock) join agentdetail a on a.agentcode=m.agentid                               
 WHERE m.receiveAgentId=@expected_payoutagentid AND tranno=@tranno                              
                         
 SELECT @sGMTValue=GMT_value, @sDate=dateadd(mi,GMT_value,getutcdate()),@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate()) FROM agentDetail a WHERE a.agentcode=@senderAgent                              
 -- SET @rDate = dateadd(mi,@rGMTValue,getutcdate())                               
 -- dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,1)                          
                      
 SET @rTime =  dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,2)                              
                         
 UPDATE moneysend SET       
 transStatus = 'Payment',            
 confirmDate = CAST(@sDate AS VARCHAR),            
 approve_by = ISNULL(@SempId,'System'),            
 imeCommission= 0,             
 bankCommission=0,            
 paid_date_usd_rate=CAST(ISNULL(@HoDollarRate,'') AS VARCHAR),            
 testquestion = @BSMREFF,            
 testanswer = @Refference,            
 c2c_pin_no = @NTP,            
 c2c_receiver_code=@PIN,            
 c2c_secure_pwd=@MsgKey,            
 digital_id_payout=@DIG_INFO,            
 lock_status='unlocked',   
 recivermessage=CASE WHEN paymentType='Cash Pay' then isnull('PIN:'+@PIN,'')+isnull(' NTP:'+@NTP,'')+' '+isnull(recivermessage,'') else recivermessage end,  
 [status] = CASE WHEN paymentType='Cash Pay' OR paymenttype='NEFT' then 'Post' ELSE 'Paid' END,            
 PodDate = CASE WHEN paymentType='Cash Pay' OR paymenttype='NEFT'  then NULL ELSE CAST(@sDate AS VARCHAR) END,             
 paidDate = CASE WHEN paymentType='Cash Pay' OR paymenttype='NEFT'  then NULL ELSE CAST(@sDate AS VARCHAR) END,            
 paidTime = CASE WHEN paymentType='Cash Pay' OR paymenttype='NEFT'  then NULL ELSE isNull(@rTime,getdate()) END,             
 paidBy = CASE WHEN paymentType='Cash Pay' OR paymenttype='NEFT'  then NULL ELSE @paidBy END                           
 WHERE receiveAgentId=@expected_payoutagentid and tranno=@tranno                              
                            
-- if @LastBal is not null or @LastBal=''                              
--  update agentdetail set currentBalance=currentBalance+@LastBal where agentcode=@expected_payoutagentid                              
                              
SELECT 'Success' status, @tranno tranno,@refno refno ,@GMT_Date GMTdate                             
    
COMMIT TRANSACTION                              
END TRY                              
BEGIN CATCH    
                              
IF @@trancount>0                               
 ROLLBACK TRANSACTION                              
                              
 DECLARE @desc VARCHAR(1000)                         
 SET @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'            
INSERT INTO error_info(ErrorNumber, ErrorDesc, Script, ErrorScript, QueryString, ErrorCategory, ErrorSource, IP, error_date)                              
 SELECT -1,@desc,'BSM_transaction','SQL',@desc,'SQL','SP',@SempId,getdate()                              
 SELECT 'ERROR','1050','Error Please try again'                              
                              
END CATCH 
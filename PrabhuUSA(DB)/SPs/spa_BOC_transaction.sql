--update agentsub set
--api_user_login_id='PPPrabhuTest',
--api_user_password='Remithub1!',
--api_accesscode='Prabhu',
--api_url_wsdl='https://124.6.141.118:8443/bankcomapi.asmx'
--where user_login_id='API-USER-BOC'

----
----insert into sender_function(sno,function_name,link_file,main_menu)
----select max(sno)+1,'BOC Approve','API_BOC/holdtxn/holdtransAll.asp','BOC'
----from sender_function
go

/****** Object:  StoredProcedure [dbo].[spa_BOC_transaction]    Script Date: 12/23/2013 14:37:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_BOC_transaction]                
 @paidBy VARCHAR(50),                                      
 @tranno INT=NULL,                                          
 @refno VARCHAR(50)=NULL,                                        
 @SempId VARCHAR(50)=NULL,                        
 @expected_payoutagentid VARCHAR(50)=NULL,                                                       
 @DIG_INFO varchar(150)=NULL                                       
AS                                          
BEGIN TRY                                          
BEGIN TRANSACTION                                          
                                     
                                  
 SET NOCOUNT ON;                                          
 DECLARE @rDate datetime,@rTime VARCHAR(20), @rGMTValue VARCHAR(10)                                          
 DECLARE @sDate datetime,@sGMTValue VARCHAR(10),@GMT_Date DATETIME                              
 DECLARE @senderAgent VARCHAR(20),@HoDollarRate MONEY,@process_id varchar(200)                                            
 DECLARE @rBankId VARCHAR(100),@rBankBranch VARCHAR(100), @rBankName VARCHAR(100) ,      
 @agent_receiveingComm money,@agent_receiverComm_Currency char(1),      
 @sending_country varchar(200),@payment_type varchar(200),@totalroundamt float          
                                                   
 --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GET GMT VALUES OF SENDER AND RECEIVER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                          
 SELECT @senderAgent=agentid, @HoDollarRate=isnull(paid_date_usd_rate,ho_dollar_rate),@rGMTValue=GMT_value,@process_id=confirm_process_id,      
 @payment_type=paymentType,@totalroundamt=totalroundamt,@sending_country=senderCountry                  
 FROM moneysend m with (Nolock) join agentdetail a on a.agentcode=m.agentid                                           
 WHERE m.receiveAgentId=@expected_payoutagentid AND tranno=@tranno                                          
            
select top 1 @rBankId=b.agent_branch_Code,@rBankBranch=b.branch from agentbranchdetail b join agentdetail a on a.agentcode=b.agentcode                                           
 WHERE a.agentcode=@expected_payoutagentid       
            
if @process_id is null           
 begin          
  set @process_id=replace(newid(),'-','_')          
  update moneysend set confirm_process_id=@process_id           
  WHERE receiveAgentId=@expected_payoutagentid AND tranno=@tranno            
 end          
                        
 SELECT @sGMTValue=GMT_value, @sDate=dateadd(mi,GMT_value,getutcdate()),@GMT_Date=dateadd(mi,isNUll(gmt_value,345),getutcdate())                   
 FROM agentDetail a WHERE a.agentcode=@senderAgent                                          
 -- SET @rDate = dateadd(mi,@rGMTValue,getutcdate())                                           
 -- dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,1)                                      
                                  
 SET @rTime =  dbo.CTgetGMTDate( getUTCDate(),@rGMTValue,2)                                          
      
      
-- MAIN AGENT COMMISSION          
 select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission           
 where agent_code=@expected_payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount          
 and payment_mode=@payment_type          
          
 if @agent_receiveingComm is null          
  begin          
   select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission           
   where agent_code=@expected_payoutagentid and country=@sending_country and @totalroundamt between min_amount and max_amount          
   and payment_mode='Default'          
  end          
 if @agent_receiveingComm is null          
  begin          
  select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission           
  where agent_code=@expected_payoutagentid and country='All' and @totalroundamt between min_amount and max_amount          
  and payment_mode=@payment_type          
  end          
 if @agent_receiveingComm is null          
  begin          
   select @agent_receiveingComm=commission_value,@agent_receiverComm_Currency=comm_currency_type from agent_branch_commission           
   where agent_code=@expected_payoutagentid and country='All' and @totalroundamt between min_amount and max_amount          
   and payment_mode='Default'          
  end          
          
 if @agent_receiveingComm is null          
  set @agent_receiveingComm=0          
 -- MAIN AGENT COMMISSION END         
 if @sDate is null       
 SET @sDate=isnull(@sDate,dbo.getdateho(getutcdate()))      
                                    
 UPDATE moneysend SET                   
 transStatus = 'Payment',                
 confirmDate = CAST(@sDate AS VARCHAR),                
 approve_by = ISNULL(@SempId,'System'),                
 imeCommission= 0,                 
 bankCommission=0,                
 paid_date_usd_rate=CAST(ISNULL(@HoDollarRate,'') AS VARCHAR),                         
 digital_id_payout=@DIG_INFO,                
 lock_status='unlocked',      
 rbankid=ltrim(rtrim(isnull(rbankid,@rBankId))),      
 rbankbranch=ltrim(rtrim(isnull(rbankbranch,@rBankBranch))),      
 agent_receiverCommission=@agent_receiveingComm,          
 agent_receiverComm_Currency=@agent_receiverComm_Currency ,       
             
 [status] = CASE WHEN paymentType in('Cash Pay','Home Delivery') then 'Post' ELSE 'Paid' END,                
 PodDate  = CASE WHEN paymentType in('Cash Pay','Home Delivery')  then NULL ELSE CAST(@sDate AS VARCHAR) END,                 
 paidDate = CASE WHEN paymentType in('Cash Pay','Home Delivery') then NULL ELSE CAST(@sDate AS VARCHAR) END,                
 paidTime = CASE WHEN paymentType in('Cash Pay','Home Delivery')  then NULL ELSE dbo.ctgettime(isNull(@rTime,getdate())) END,                 
 paidBy  = CASE WHEN paymentType in('Cash Pay','Home Delivery')  then NULL ELSE @paidBy END                
 WHERE receiveAgentId=@expected_payoutagentid and tranno=@tranno                
            --select distinct paymentType from  moneysend  
                
                                        
-- if @LastBal is not null or @LastBal=''                                          
--  update agentdetail set currentBalance=currentBalance+@LastBal where agentcode=@expected_payoutagentid                                          
                                          
SELECT 'Success' status, @tranno tranno,@refno refno ,@GMT_Date GMTdate                                         
                                
COMMIT TRANSACTION                                          
END TRY                                          
BEGIN CATCH                                          
                                          
IF @@trancount>0                                           
 ROLLBACK TRANSACTION                     
                                          
 DECLARE @desc VARCHAR(1000)                                     
 SET @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'                     INSERT INTO error_info(ErrorNumber, ErrorDesc, Script, ErrorScript, QueryString, ErrorCategory, ErrorSource                                        
           , IP, error_date)                                          
 SELECT -1,@desc,'boc_transaction','SQL',@desc,'SQL','SP',@SempId,getdate()                                          
 SELECT 'ERROR','1050','Error Please try again'                                          
                                          
END CATCH       
           
    
    
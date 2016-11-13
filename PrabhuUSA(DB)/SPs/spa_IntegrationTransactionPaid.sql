/****** Object:  StoredProcedure [dbo].[spa_IntegrationTransactionPaid]    Script Date: 02/22/2015 13:36:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_IntegrationTransactionPaid]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_IntegrationTransactionPaid]
GO
/****** Object:  StoredProcedure [dbo].[spa_IntegrationTransactionPaid]    Script Date: 02/22/2015 13:36:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec spa_IntegrationTransactionPaid @control_no='113121538221',@payout_user_id='NANDA',@payout_partner_id='20100003',@rBankName='KATHMANDU-GHANTAGHAR',@rBankBranch='GHANTAGHAR',@DIGI_Info=':'    
CREATE PROC [dbo].[spa_IntegrationTransactionPaid]               
@control_no VARCHAR(20),            
@payout_user_id VARCHAR(50),            
@payout_partner_id VARCHAR(50)=NULL,            
@rBankName VARCHAR(150),            
@rBankBranch VARCHAR(150),            
@DIGI_Info VARCHAR(150),            
@is_own_branch char(1)=NULL , -- Flag from PFCL txn      
@call_from VARCHAR(5)=NULL,  -- Flag to know the requested system. eg . PCS        
@beneficiary_ID_type varchar(100)=NULL,                
@beneficiary_ID_number varchar(100)=NULL    
AS            
DECLARE @enc_refno varchar(50),          
  @tranno varchar(50),@temptablename varchar(1000)      
  ,@Payout_reciver_main_id varchar(50)       
  ,@commission_nepal FLOAT  
 ,@diable_payout CHAR(1),@payment_type varchar(50)          
SET @enc_refno=dbo.encryptdb(@control_no)      
--SELECT @tranno=tranno FROM dbo.moneySend WITH(NOLOCK) WHERE refno=@enc_refno      
 SELECT @tranno=m.tranno,@diable_payout=ISNULL(a.disable_payout,'n'),@payment_type=m.paymentType FROM dbo.moneySend m WITH(NOLOCK)  
JOIN agentDetail a   WITH (NOLOCK) ON a.agentCode=m.agentid  WHERE refno=@enc_refno    
   
IF LOWER(@diable_payout)='y'        
BEGIN        
 SELECT 'Error' StatusMsg,'This Transaction is blocked.Please contact the remitter.' MESSAGE        
 RETURN         
END   
   
--------------------------------------------------------------------      
----- Hardcoded PFCL Payout agent------------------------------------      
DECLARE @PFCL_agent_id VARCHAR(50),@isPCStxn CHAR(1),@PMT_Branch_id varchar(50),@PCS_Branch_id varchar(50),@PMT_agent_id varchar(50),
@commission_PFCL FLOAT
SET @PFCL_agent_id='20100074' --- PFCL Agent id In PrabhuUsa System 
SET @PMT_agent_id='20100003'  --- PMT Agent id In PrabhuUsa System      
SET @PCS_Branch_id='39319046'  --- PCS Branch id In PrabhuUsa System      
SET @PMT_Branch_id='39319047'  --- PMT Branch id In PrabhuUsa System      
SET @commission_nepal=110       ---- Flat PMT and PCS NEPAL Commission      
SET @commission_PFCL=25   ---- Flat PFCL NEPAL Commission    
      
if @call_from='PMT' and @payout_partner_id is null
	set @Payout_reciver_main_id=@PMT_agent_id --- Actual Requested Agent id    
else if  @payout_partner_id is null
	set @Payout_reciver_main_id=@PFCL_agent_id --- Actual Requested Agent id   
else
	set @Payout_reciver_main_id=@payout_partner_id --- Actual Requested Agent id 
	
BEGIN TRY        
BEGIN TRANSACTION trans       
      
UPDATE dbo.moneySend SET expected_payoutagentid=@Payout_reciver_main_id WHERE refno=@enc_refno       
SET @payout_partner_id=@Payout_reciver_main_id      
--------------------------------------------------------------------              
Declare @sql varchar(max),@sql1 varchar(max),@sqlErr varchar(max),@agent_country varchar(50),@payout_branch_id varchar(50)              
                
select top 1 @payout_branch_id=agent_branch_code, @agent_country=a.country from agentbranchdetail b WITH(NOLOCK) join agentdetail a WITH(NOLOCK) on b.agentcode=a.agentcode              
where a.agentcode=@payout_partner_id and isHeadoffice='y'              
              
if @payout_branch_id is null               
select top 1 @payout_branch_id=agent_branch_code,@agent_country=a.country from agentbranchdetail b WITH(NOLOCK) join agentdetail a WITH(NOLOCK) on b.agentcode=a.agentcode              
where a.agentcode=@payout_partner_id               
------------------------------------------------------------      
----Payout Branch-------------------------------------------      
---PCS Branch setup       
IF @call_from='PCS'      
 SET @payout_branch_id=@PCS_Branch_id      
---PMT Branch setup       
IF @Payout_reciver_main_id <> @PFCL_agent_id      
 SET @payout_branch_id=@PMT_Branch_id      
-------------------------------------------------------------                      
  -- Payout agent changed.
if @payment_type<>'Cash Pay'    
begin    
 update moneysend set status='Un-Paid',lock_status='locked',lock_by=@payout_user_id where refno=@enc_refno    
end    
else if not exists(                
 select  status from moneysend WITH(NOLOCK) where status='Un-Paid' and TransStatus='Payment'              
 and lock_status='locked'  and lock_by=@payout_user_id          
  and receivercountry=@agent_country                
 and refno=@enc_refno )            
 begin                
  select 'ERROR' StatusMsg,'Invalid Transaction Message' MESSAGE            
  return              
 end                     
 create table #temp_status(              
 status varchar(200),              
 Confirm_ID varchar(200),              
 Message varchar(100))              
              
insert #temp_status(status,confirm_id,Message)            
 exec spa_make_payment  @payout_branch_id , @tranno , @payout_user_id , @DIGI_Info,NULL,'p',@beneficiary_ID_type,@beneficiary_ID_number,null,@rBankName, @rBankBranch,@is_own_branch            
            
          
Declare @status varchar(50),@code varchar(50),@Message varchar(500)              
select @status=status,@code=Confirm_ID,@Message=Message from #temp_status         
-----------------------------------------------------------------------------------------      
--------------- Update who paid this txn and update the commission-----------------------      
      
 UPDATE dbo.moneySend SET receiveAgentID=@Payout_reciver_main_id,agent_receiverComm_Currency='l',    
 agent_receiverCommission=CASE WHEN @Payout_reciver_main_id=@PFCL_agent_id AND @call_from IS NULL AND paymentType='Bank Transfer' THEN 0    
          WHEN @Payout_reciver_main_id=@PFCL_agent_id AND @call_from IS NULL AND paymentType NOT IN ('Bank Transfer') THEN @commission_PFCL    
 ELSE @commission_nepal END      
 WHERE refno=@enc_refno      
      
------------------------------------------------------------------------------------------             
if @status='Error'       
begin   
  if @payment_type<>'Cash Pay'  
  begin  
   update moneysend set status='Post',lock_status='unlocked' where refno=@enc_refno and status='Un-Paid'  
  end    
  select 'Error' StatusMsg,Message from #temp_status          
end  
else            
 select 'Success' StatusMsg,* from moneysend WITH(NOLOCK) where refno=@enc_refno               
and status='Paid'  

COMMIT TRANSACTION trans        
END TRY        
BEGIN CATCH        
 IF @@trancount > 0        
     ROLLBACK TRANSACTION trans                 
         
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
        'spa_IntegrationTransactionPaid',        
        'SQL',        
        @desc,        
        'SQL',        
        'SP',        
        @control_no,        
        GETDATE()        
                
select 'Error' StatusMsg,'Error while Paying txn <br> Please try again after while.' [Message]        
        
END CATCH   
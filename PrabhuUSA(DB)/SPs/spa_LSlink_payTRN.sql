DROP proc [dbo].[spa_LSlink_payTRN]    
go           
--EXEC LS_PrabhuCash.PrabhuCash.dbo.spa_LSlink_payTRN '211105802101','96700000','pmtnepal',':','F38D5E3A_2388_4058_A538_9B6F01A44FAE'              
CREATE proc [dbo].[spa_LSlink_payTRN]              
@control_no varchar(50)=NULL,              
@payout_partner_id varchar(50)=NULL,              
@payout_user_id varchar(50)=NULL,              
@client_pc_id varchar(200)=NULL,-- Digital ID or IP Address              
@session_id varchar(200)=NULL,              
@rBankName varchar(200)=NULL,              
@rBankBranch varchar(200)=NULL,              
@is_own_branch char(1)=NULL,            
@call_from VARCHAR(5)=NULL,  -- Flag to know the requested system. eg . PCS             
@new_account varchar(50)=null       
as              
          
DECLARE @enc_refno varchar(50),              
  @tranno varchar(50),@temptablename varchar(1000)          
  ,@Payout_reciver_main_id varchar(50)           
  ,@commission_nepal FLOAT             
SET @enc_refno=dbo.encryptdb(@control_no)          
SELECT * INTO #temp_moneysend FROM dbo.moneySend WITH(NOLOCK) WHERE refno=@enc_refno          
SELECT @tranno=tranno FROM #temp_moneysend          
set @temptablename=dbo.FNAProcessTBl(@payout_user_id, @payout_partner_id, @session_id)           
--SELECT CompanyName,* FROM agentdetail WHERE CompanyName LIKE '%prabhu%'          
--SELECT * FROM dbo.agentbranchdetail WHERE agent_branch_code='39323428'             
--------------------------------------------------------------------          
----- Hardcoded PFCL Payout agent------------------------------------          
DECLARE @PFCL_agent_id VARCHAR(50),@isPCStxn CHAR(1),@PMT_Branch_id varchar(50),        
@PCS_Branch_id varchar(50),@commission_PFCL FLOAT        
SET @PFCL_agent_id='20100115' --- PFCL Agent id In PrabhuUsa System          
SET @PCS_Branch_id='39323428' --'20100115'-live id --- PCS Branch id In PrabhuUsa System          
SET @PMT_Branch_id='39323427' --'20100115'-live id --- PMT Branch id In PrabhuUsa System          
SET @commission_nepal=110     ---- Flat PMT and PCS NEPAL Commission          
SET @commission_PFCL=25        ---- Flat PFCL NEPAL Commission        
          
set @Payout_reciver_main_id=@payout_partner_id --- Actual Requested Agent id          
          
-- Payout agent changed.          
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
              
if NOT EXISTS(                
 SELECT  status FROM moneysend WITH(NOLOCK) WHERE status='Un-Paid' and TransStatus='Payment'              
 and lock_status='locked' and lock_by=@payout_user_id  and receivercountry=@agent_country                
 and refno=@enc_refno  )                
 BEGIN                
 SET @sql='select ''ERROR'' LS_status,''1002'' Code,''Invalid Transaction'' Message into '+@temptablename              
 EXEC(@sql)              
 RETURN         
 END                
              
 CREATE TABLE #temp_status(              
 status VARCHAR(200),              
 Confirm_ID VARCHAR(200),              
 Message VARCHAR(100))              
--print 'spa_make_payment '+ isnull(@payout_branch_id,'Null')+' , '+isnull(@tranno,'Null')+' ,'+ isnull(@payout_user_id,'Null')+' ,'+ isnull(@client_pc_id,'Null')+','+isnull(@new_account,'Null')+',''p'',null,null,null,'+isnull(@rBankName,'Null')+','+isnul
l(@rBankBranch,'Null')+','+isnull(@is_own_branch,'Null')                      
INSERT #temp_status(status,confirm_id,Message)              
EXEC spa_make_payment  @payout_branch_id , @tranno , @payout_user_id , @client_pc_id,@new_account,'p',null,null,null,@rBankName,@rBankBranch,@is_own_branch              
              
DECLARE @status varchar(50),@code varchar(50),@Message varchar(500)              
SELECT @status=status,@code=Confirm_ID,@Message=Message from #temp_status              
-----------------------------------------------------------------------------------------          
--------------- Update who paid this txn and update the commission-----------------------          
          
UPDATE dbo.moneySend SET receiveAgentID=@Payout_reciver_main_id,agent_receiverComm_Currency='l',        
 agent_receiverCommission=CASE WHEN @Payout_reciver_main_id=@PFCL_agent_id AND @call_from IS NULL AND paymentType='Bank Transfer' THEN 0        
          WHEN @Payout_reciver_main_id=@PFCL_agent_id AND @call_from IS NULL AND paymentType NOT IN ('Bank Transfer') THEN @commission_PFCL        
 ELSE @commission_nepal END          
 WHERE refno=@enc_refno         
          
------------------------------------------------------------------------------------------            
          
----Retrive Commission----------------              
declare @agent_receiverSCommission money,@agent_receiveingComm money,@agent_receiverComm_Currency char(1)              
declare @paid_date_usd_rate float            
              
select @agent_receiverSCommission=agent_receiverSCommission,@agent_receiveingComm=agent_receiverCommission,                
@agent_receiverComm_Currency=agent_receiverComm_Currency,@paid_date_usd_rate=paid_date_usd_rate from             
moneysend with (NOLOCK) where refno=@enc_refno and status='Paid'             
              
set @sql='select '''+ @status +''' as LS_status,'''+ @code +''' as Code,'''+ @Message +''' Message,              
'''+convert(varchar,isNull(@agent_receiverSCommission,0))+''' agent_receiverSCommission,              
'''+convert(varchar,isNull(@agent_receiveingComm,0))+''' agent_receiveingComm,              
'''+isNull(@agent_receiverComm_Currency,'l')+ ''' agent_receiverComm_Currency,            
'''+cast(@paid_date_usd_rate as varchar)+''' paid_date_usd_rate  into '+ @temptablename              
exec(@sql)    
DROP proc [dbo].[spa_update_payout_agent]   
Go
CREATE proc [dbo].[spa_update_payout_agent]     
@flag  char(1),      
@payout_agentid varchar(20),        
@agent_branch_id varchar(20)=Null,        
@tranno int,        
@refno varchar(20),        
@txt_remark varchar(200),        
@update_by varchar(20),        
@GMT_Now varchar(20),    
@paymentType varchar(50)=Null,    
@commercial_branch_name varchar(150)=Null,    
@AccountNo varchar(50)=Null ,  
@ben_bank_id varchar(50)=Null ,  
@ben_bank_name VARCHAR(200)=NULL,   
@ben_bank_branch_id VARCHAR(20)=Null    
        
as        
if not exists(select expected_payoutAgentId from moneysend with(nolock) where tranno=@tranno)        
begin                                          
 select 'ERROR','1001','Transaction detail not found" !!!'                                          
 return                                          
end         
else      
if @flag='l'   ---- Payout Location change    
begin        
--this is for comments         
declare @rBankName as varchar(50),@rBankBranch as varchar(50)        
select @rBankName=rbankName,@rBankBranch=rbankBranch,@paymentType=ISNULL(@paymentType,paymentType) from moneysend WITH(NOLOCK) where tranno=@tranno        
        
declare @companyName as varchar(50),@branch as varchar(50), @receiveAgentId as varchar(50)     
set @branch=Null    
    
select @companyName=companyName, @receiveAgentId=agentcode from agentDetail  WITH(NOLOCK) where agentCode=@payout_agentid     
    
if  @agent_branch_id is not null    
begin      
select @companyName=a.companyName,@receiveAgentID=a.agentcode  from agentDetail a  WITH(NOLOCK) join agentbranchdetail b  WITH(NOLOCK)    
on b.agentCode=a.agentCode where b.agent_branch_Code=@agent_branch_id        
    
select   @branch=branch from agentBranchDetail b with(nolock) join agentdetail a with(nolock) on b.agentCode=a.agentCode    
where b.agent_branch_Code=@agent_branch_id and b.agent_code_id=@payout_agentid      
end    
--select @branch=branch from agentBranchDetail         
--where agent_branch_Code=@agent_branch_id and agentCode=@payout_agentid      
         
IF @paymentType='Cash Pay' OR @paymentType='Bank Transfer'  
BEGIN        
 update moneysend set rBankName=@companyName,rBankBranch=@branch,        
 rBankId=@agent_branch_id,expected_payoutAgentId=@payout_agentid,        
 receiveAgentId=@receiveAgentId        
 where tranno=@tranno        
END  
ELSE  
BEGIN  
IF EXISTS(SELECT 'x' FROM dbo.commercial_bank c  WITH(NOLOCK) JOIN dbo.commercial_bank_branch b  WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id  
  WHERE b.IFSC_Code=@commercial_branch_name AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id)  
  BEGIN  
   SELECT @commercial_branch_name=b.BranchName,@ben_bank_branch_id=b.IFSC_Code FROM dbo.commercial_bank c WITH(NOLOCK)    
   JOIN dbo.commercial_bank_branch b  WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id  
   WHERE b.IFSC_Code=@commercial_branch_name AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id  
  END  
  --ELSE  
   --SET @commercial_branch_name=@ben_bank_branch_id  
  
  --END  
  SELECT @ben_bank_name=Bank_name,@ben_bank_id=external_bank_id FROM dbo.commercial_bank c  WITH(NOLOCK) WHERE c.Commercial_id= @ben_bank_id  
  
   UPDATE moneysend SET 
	rBankName=@companyName,
	rBankBranch=@branch,        
	rBankId=@agent_branch_id,
	expected_payoutAgentId=@payout_agentid,        
	receiveAgentId=@receiveAgentId, 
    rBankAcType=@commercial_branch_name,    
    rBankAcNo=@AccountNo,  
    ben_bank_id=@ben_bank_id,  
    ben_bank_name=@ben_bank_name,  
    ben_bank_branch_id=@ben_bank_branch_id   
   WHERE tranno=@tranno    
END  
        
declare @comments as varchar(500)        
set @comments='Payout Agent location/bank has been changed: <br>'+        
isNull(@rBankName,'')+', '+isNull(@rBankBranch,'')+' => '+@companyName+', '+isNUll(@branch,'') +'; '+@txt_remark        
insert TransactionNotes(refno,Comments,DatePosted,PostedBy,uploadBy,noteType)        
values(@refno,@comments,@GMT_Now,@update_by,'A',9)        
        
select 'SUCCESS','1002','Payout Agent location/bank has been updated',dbo.decryptDB(@refno)        
end    
 if @flag='p' --- payment type    
    
begin    
declare @sql as varchar(500),@TransferType   as varchar (50)    
if @paymentType='Bank Transfer'     
 set @TransferType='Deposit'    
ELSE   
 set @TransferType='CashPay'    
  
IF @paymentType='Cash Pay' OR @paymentType='Bank Transfer'  
 BEGIN  
  UPDATE moneysend SET paymentType=@paymentType, rBankAcType=@commercial_branch_name,    
   rBankAcNo=@AccountNo,transfertype= @transfertype WHERE tranno=@tranno    
 END  
ELSE  
 BEGIN  
 --DECLARE @ben_bank_name VARCHAR(200), @ben_bank_branch_id VARCHAR(20)  
  --- ADDED FOR MAPPING Branch of NEPAL (ACCOUNT DEPOSIT TO OTHER)  
  IF EXISTS(SELECT 'x' FROM dbo.commercial_bank c  WITH(NOLOCK) JOIN dbo.commercial_bank_branch b  WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id  
  WHERE b.IFSC_Code=@commercial_branch_name AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id)  
  BEGIN  
   SELECT @commercial_branch_name=b.BranchName,@ben_bank_branch_id=b.IFSC_Code FROM dbo.commercial_bank c WITH(NOLOCK)    
   JOIN dbo.commercial_bank_branch b  WITH(NOLOCK) ON c.Commercial_id = b.Commercial_id  
   WHERE b.IFSC_Code=@commercial_branch_name AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id  
  END  
--  ELSE  
--   SET @commercial_branch_name=@ben_bank_branch_id  
  
  
  --END  
  SELECT @ben_bank_name=Bank_name,@ben_bank_id=external_bank_id FROM dbo.commercial_bank c  WITH(NOLOCK) WHERE c.Commercial_id= @ben_bank_id  
    
    
   UPDATE moneysend SET   
   paymentType=@paymentType,  
    rBankAcType=@commercial_branch_name,    
    rBankAcNo=@AccountNo,  
    transfertype= @transfertype,  
    ben_bank_id=@ben_bank_id,  
    ben_bank_name=@ben_bank_name,  
    ben_bank_branch_id=@ben_bank_branch_id   
   WHERE tranno=@tranno    
 END  
   
set @comments='Payment Mode has been changed to: <br>'+        
isNull(@paymentType,'')+', '+isNull(@commercial_branch_name,'')+','+isNUll(@AccountNo,'') +'; '+@txt_remark         
insert TransactionNotes(refno,Comments,DatePosted,PostedBy,uploadBy,noteType)        
values(@refno,@comments,@GMT_Now,@update_by,'A',8)        
        
select 'SUCCESS','1002','Payment Mode  has been updated',dbo.decryptDB(@refno)       
end     
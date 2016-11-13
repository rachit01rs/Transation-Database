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
@ben_bank_id varchar(50)=Null   
      
as      
if not exists(select expected_payoutAgentId from moneysend where tranno=@tranno)      
begin                                        
 select 'ERROR','1001','Transaction detail not found" !!!'                                        
 return                                        
end       
else    
if @flag='l'   ---- Payout Location change  
begin      
--this is for comments       
declare @rBankName as varchar(50),@rBankBranch as varchar(50),@ben_bank_branch_id VARCHAR(50),@rbankactype VARCHAR(50)     
select @rBankName=rbankName,@rBankBranch=rbankBranch from moneysend where tranno=@tranno      
      
declare @companyName as varchar(50),@branch as varchar(50), @receiveAgentId as varchar(50)   
set @branch=Null  
  
select @companyName=companyName, @receiveAgentId=agentcode from agentDetail where agentCode=@payout_agentid   
  
if  @agent_branch_id is not null  
begin    
select @companyName=a.companyName,@receiveAgentID=a.agentcode  from agentDetail a join agentbranchdetail b  
on b.agentCode=a.agentCode where b.agent_branch_Code=@agent_branch_id      
  
select   @branch=branch from agentBranchDetail b join agentdetail a on b.agentCode=a.agentCode  
where b.agent_branch_Code=@agent_branch_id and b.agent_code_id=@payout_agentid    
end  
--select @branch=branch from agentBranchDetail       
--where agent_branch_Code=@agent_branch_id and agentCode=@payout_agentid    


       
      
update moneysend set rBankName=@companyName,rBankBranch=@branch,      
rBankId=@agent_branch_id,expected_payoutAgentId=@payout_agentid,      
receiveAgentId=@receiveAgentId,rBankACType=CASE WHEN @rbankactype IS NOT NULL THEN @rbankactype ELSE  rBankACType END,
   ben_bank_branch_id=CASE WHEN @ben_bank_branch_id IS NOT NULL THEN @ben_bank_branch_id ELSE  ben_bank_branch_id END
where tranno=@tranno      
      
declare @comments as varchar(500)      
set @comments='Payout Agent location/bank has been changed: <br>'+      
isNull(@rBankName,'')+', '+isNull(@rBankBranch,'')+' => '+@companyName+', '+isNUll(@branch,'') +'; '+@txt_remark      
insert TransactionNotes(refno,Comments,DatePosted,PostedBy,uploadBy,noteType)      
values(@refno,@comments,@GMT_Now,@update_by,'A',1)      
      
select 'SUCCESS','1002','Payout Agent location/bank has been updated',dbo.decryptDB(@refno)      
end  
 if @flag='p' --- payment type  
  
begin  
declare @sql as varchar(500),@TransferType   as varchar (50)  
if @paymentType='Bank Transfer'   
set @TransferType='Deposit'  
if @paymentType='Cash Pay'  
set @TransferType='CashPay'  
--- ADDED FOR MAPPING Branch of NEPAL (ACCOUNT DEPOSIT TO OTHER)
	IF	EXISTS(SELECT 'x' FROM dbo.commercial_bank c 
	JOIN dbo.commercial_bank_branch b ON c.Commercial_id = b.Commercial_id
	WHERE b.IFSC_Code=@rbankactype AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id)
	BEGIN
		SELECT @rbankactype=b.BranchName,@ben_bank_branch_id=b.IFSC_Code FROM dbo.commercial_bank c 
	JOIN dbo.commercial_bank_branch b ON c.Commercial_id = b.Commercial_id
	WHERE b.IFSC_Code=@rbankactype AND c.country='NEPAL' AND b.Commercial_id=@ben_bank_id
	END
---- END 
  
update moneysend set paymentType=@paymentType, rBankAcType=@commercial_branch_name,  
 rBankAcNo=@AccountNo,transfertype= @transfertype where tranno=@tranno  
  
exec (@sql)  
  
set @comments='Payment Mode has been changed to: <br>'+      
isNull(@paymentType,'')+', '+isNull(@commercial_branch_name,'')+','+isNUll(@AccountNo,'') +'; '+@txt_remark       
insert TransactionNotes(refno,Comments,DatePosted,PostedBy,uploadBy,noteType)      
values(@refno,@comments,@GMT_Now,@update_by,'A',1)      
      
select 'SUCCESS','1002','Payment Mode  has been updated',dbo.decryptDB(@refno)     
end  
  
  
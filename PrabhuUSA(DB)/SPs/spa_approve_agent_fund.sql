DROP PROC spa_approve_agent_fund
go  
CREATE proc [dbo].[spa_approve_agent_fund]      
@agent_id varchar(50),      
@invoice_no varchar(50),      
@user_id varchar(50),      
@flag CHAR(1)=NULL       
as      
declare @gmtdate datetime,@amt_approve money,@cash_ledger_id varchar(50),@branch_id varchar(50),    
@refno VARCHAR(50)      
      
select @gmtdate=dateadd(mi,isNUll(gmt_value,345),getutcdate()),@cash_ledger_id=cash_ledger_id      
from agentdetail a join agent_function f on a.agentcode=f.agent_id      
where agentcode=@agent_id      
    
 DECLARE @customer_refund_Ledger VARCHAR(50)    
 SET @customer_refund_Ledger='8052'    
       
IF @flag='a' --- Approved Voucher      
BEGIN       
update agent_fund_detail set approve_by=@user_id,      
approve_ts=@gmtdate where invoice_no=@invoice_no and      
agentcode=@agent_id      
      
select @amt_approve=local_amt,@branch_id=branch_code from agent_fund_detail      
where invoice_no=@invoice_no and      
agentcode=@agent_id and sender_bankId=@cash_ledger_id      
      
--update agentbranchdetail set current_branch_limit=ISNULL(current_branch_limit,0)-@amt_approve      
--where agent_branch_code=@branch_id and agentcode=@agent_id      
--and branch_limit is not null      
      
UPDATE store_cash      
SET mode = 'a' WHERE invoice_no=@invoice_no      
      
END       
IF @flag='c' --- Delete refund Voucher      
BEGIN       
 select @amt_approve=local_amt,@branch_id=branch_code,@refno=refno      
 from agent_fund_detail      
 where invoice_no=@invoice_no and      
 agentcode=@agent_id and sender_bankId=@customer_refund_Ledger       
     
 Delete agent_fund_detail where invoice_no=@invoice_no      
       
 UPDATE moneySend      
 SET digital_id_payout=NULL WHERE refno=dbo.encryptDb(@refno) AND TransStatus='Cancel'      
 AND digital_id_payout LIKE '%'+ @invoice_no       
       
 update agent_fund_detail_audit SET update_by=@user_id      
 WHERE user_action='Delete' AND invoice_no=@invoice_no      
      
END       
IF isNull(@flag,'u')='u' --- Delete Normal Voucher      
BEGIN       
    
 select @amt_approve=local_amt,@branch_id=branch_code,@refno=refno      
 from agent_fund_detail      
 where invoice_no=@invoice_no    
     
 IF @refno IS NOT NULL     
 BEGIN    
   UPDATE moneySend      
  SET digital_id_payout=NULL WHERE refno=dbo.encryptDb(@refno) AND TransStatus='Cancel'      
  AND digital_id_payout LIKE '%'+ @invoice_no      
 END    
     
 Delete agent_fund_detail where invoice_no=@invoice_no      
 Delete Store_Cash where invoice_no=@invoice_no      
       
 update agent_fund_detail_audit SET update_by=@user_id      
 WHERE user_action='Delete' AND invoice_no=@invoice_no       
     
     
END     
    
    
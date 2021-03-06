
/****** Object:  StoredProcedure [dbo].[spa_approve_voucher]    Script Date: 07/28/2014 21:53:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_approve_voucher '14','deepen'
create proc [dbo].[spa_approve_voucher]
	@invoiceNo varchar(500)=null,
	@userid varchar(50),
	@sno varchar(5000)=null
as
SET XACT_ABORT ON;

create table #temp_invoice(
invoiceNo varchar(50)
)

if @sno is not null
insert #temp_invoice(invoiceNo)
 SELECT b.InvoiceNo FROM dbo.SplitCommaSeperatedValues(@sno) t join agentBalance b
 on t.Item=b.sno

if @invoiceNo is not null 
  insert #temp_invoice(invoiceNo)
SELECT  item txnid  FROM   dbo.SplitCommaSeperatedValues(@invoiceNo)  
 
 
 update agentbalance set approved_by=@userid,approved_ts=dbo.getDateHO(getutcdate())
from agentBalance b join #temp_invoice t
on b.invoiceno=t.invoiceNo


print 'Agent -Update'
 
update agentdetail      
 set currentBalance=case when t.mode='dr' then isNUll(currentBalance,0)+t.amount else isNUll(currentBalance,0)-t.amount end,
  limit=case when t.mode='dr' then isNUll(limit,0) 
      when t.mode='cr' and t.amount>=isNUll(Increased_Credit_limit,0) then isNUll(limit,0)-isNUll(Increased_Credit_limit,0)
      when t.mode='cr' and t.amount<isNUll(Increased_Credit_limit,0) then isNUll(limit,0)-t.amount
      else limit
      end,
 Increased_Credit_limit=case when t.mode='dr' then isNUll(Increased_Credit_limit,0) 
      when t.mode='cr' and t.amount>=isNUll(Increased_Credit_limit,0) then 0
      when t.mode='cr' and t.amount<isNUll(Increased_Credit_limit,0) then isNUll(Increased_Credit_limit,0)-t.amount
      else isNUll(Increased_Credit_limit,0)
      end,
payout_agent_balance= case when t.mode='dr' then isNull(payout_agent_balance,0)+t.amount 
 else isNull(payout_agent_balance,0)-t.amount end  
 from agentbalance t with (nolock) join agentdetail a 
 on t.agentcode=a.agentcode join 
 #temp_invoice i on t.invoiceno=i.invoiceNo
  
 update agentbranchdetail  
 set currentBalance=case when t.mode='dr' then isNUll(currentBalance,0)+t.amount else isNUll(currentBalance,0)-t.amount end  
 from agentbalance t with (nolock) join agentbranchdetail a 
 on t.branch_code=a.agent_branch_code 
 join #temp_invoice i on i.invoiceno = t.InvoiceNo
 where t.branch_code is not null  
  
 insert agent_fund_detail(sender_bankId,dot,local_amt,dollar_amt,staff_id,remarks,xRate,invoice_no,agentcode,invoice_type)  
 select b.deposit_id,dot,amount,dollar_rate,b.staffId,b.Remarks,xrate,b.InvoiceNo,agentcode,  
 case when mode='cr' then 'f' else 'r' end from agentbalance b with (nolock) join #temp_invoice i 
 on b.InvoiceNo=i.invoiceNo 
 where b.deposit_id is not null
GO

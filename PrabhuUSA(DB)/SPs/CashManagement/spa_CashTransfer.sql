DROP PROC spa_CashTransfer
GO
--spa_CashTransfer 'u','10100500','klanoop',500,'ahmad'        
CREATE PROC [dbo].[spa_CashTransfer]        
@flag CHAR(1),        
@branch_id VARCHAR(50),        
@transfer_by VARCHAR(50),        
@amount MONEY,        
@transfer_to VARCHAR(50)=NULL ,        
@remarks VARCHAR(200)=NULL,        
@approve_id INT=NULL,        
@as_of_date DATETIME = NULL,        
@narration VARCHAR(500)=NULL         
--WITH ENCRYPTION        
AS        
 DECLARE @invoice_id VARCHAR(50),@cash_ledger_id VARCHAR(50),        
 @vault_ledger_id VARCHAR(50),@agent_id VARCHAR(50),@customer_refund_Ledger VARCHAR(50)        
 IF @as_of_date IS NULL         
  SET @as_of_date=GETDATE()        
 SELECT @agent_id=af.agent_Id,@cash_ledger_id=af.cash_ledger_id,@vault_ledger_id=af.cash_vault,@customer_refund_Ledger=af.customer_refund_ledger        
   FROM agent_function af JOIN agentbranchdetail a         
 ON af.agent_Id=a.agentCode WHERE a.agent_branch_Code=@branch_id         
         
         
        
IF @flag='u'         
BEGIN         
         
 insert store_cash (stored_amount,deposit_by,deposit_date,branch_code,mode,approve_by)        
 VALUES(@amount,@transfer_by,getdate(),@branch_id,'p',@transfer_to)        
         
 UPDATE agentsub SET current_balance = isNUll(current_balance,0)-@amount WHERE User_login_Id=@transfer_by        
         
 SELECT 'Success' MSG        
END         
         
IF @flag='a' -- Approve cash received         
BEGIN         
        
 SELECT @amount=stored_amount FROM store_cash WHERE sno=@approve_id AND mode='p'        
         
 UPDATE store_cash        
 SET        
  approve_date = GETDATE(),        
  approve_by=@transfer_to,        
  mode = 'a'        
  WHERE sno=@approve_id AND mode='p'        
         
 UPDATE agentsub SET current_balance = isNUll(current_balance,0)+@amount WHERE User_login_Id=@transfer_to        
         
 SELECT 'Success' MSG        
END         
IF @flag='v' ---From Teller to Vault        
BEGIN         
         
 SET @invoice_id='F'+cast(IDENT_CURRENT('agent_fund_detail') + 1  AS VARCHAR)        
 insert into agent_fund_detail(invoice_no,agentCode,Dot,Local_Amt,xRate,Sender_BankID,remarks,        
 staff_id,Dollar_amt,invoice_type,branch_code,teller_transfer)        
 VALUES(@invoice_id,@agent_id,@as_of_date,@amount,1,@cash_ledger_id,'Transfer to Vault'+ CASE WHEN @remarks IS NOT NULL THEN ' Notes:'+@remarks ELSE '' END,        
 @transfer_by,@amount,'w',@branch_id,'y')        
         
 insert into agent_fund_detail(invoice_no,agentCode,Dot,Local_Amt,xRate,Sender_BankID,remarks,        
 staff_id,Dollar_amt,invoice_type,branch_code,teller_transfer)        
 VALUES(@invoice_id,@agent_id,@as_of_date,@amount,1,@vault_ledger_id,'Transfer to Vault:'+ @transfer_by +' ' + CASE WHEN @remarks IS NOT NULL THEN ' Notes:'+@remarks ELSE '' END ,        
 @transfer_by,@amount,'m',@branch_id,'y')        
         
 insert store_cash (stored_amount,deposit_by,deposit_date,branch_code,mode,approve_by,approve_date,invoice_no)        
 VALUES(@amount,@transfer_by,@as_of_date,@branch_id,'p','Vault',@as_of_date,@invoice_id)        
         
 UPDATE agentsub SET current_balance = isNUll(current_balance,0)-@amount WHERE User_login_Id=@transfer_by        
         
 SELECT @invoice_id MSG        
END         
IF @flag='w' --- From Vault to Teller        
BEGIN         
         
 SET @invoice_id='F'+cast(IDENT_CURRENT('agent_fund_detail') + 1  AS VARCHAR)        
 insert into agent_fund_detail(invoice_no,agentCode,Dot,Local_Amt,xRate,Sender_BankID,remarks,        
 staff_id,Dollar_amt,invoice_type,branch_code,approve_by,approve_ts,teller_transfer)        
 VALUES(@invoice_id,@agent_id,@as_of_date,@amount,1,@cash_ledger_id,'Transfer From Vault'+ CASE WHEN @remarks IS NOT NULL THEN ' Notes:'+@remarks ELSE '' END,        
 @transfer_to,@amount,'m',@branch_id,@transfer_by,@as_of_date,'y')        
         
 insert into agent_fund_detail(invoice_no,agentCode,Dot,Local_Amt,xRate,Sender_BankID,remarks,        
 staff_id,Dollar_amt,invoice_type,branch_code,approve_by,approve_ts,teller_transfer)        
 VALUES(@invoice_id,@agent_id,@as_of_date,@amount,1,@vault_ledger_id,'Transfer From Vault to :'+ @transfer_to +' '+CASE WHEN @remarks IS NOT NULL THEN ' Notes:'+@remarks ELSE '' END,        
 @transfer_to,@amount,'w',@branch_id,@transfer_by,@as_of_date,'y')        
         
 insert store_cash (stored_amount,deposit_by,deposit_date,branch_code,mode,approve_by, invoice_no)        
 VALUES(@amount,'Vault',@as_of_date,@branch_id,'p',@transfer_to,@invoice_id)        
         
 --UPDATE agentsub SET current_balance = isNUll(current_balance,0)+@amount WHERE User_login_Id=@transfer_to        
         
 SELECT @invoice_id MSG        
END         
IF @flag='c' ---Refund to Customer From Vault to Customer        
BEGIN         
        
--select @amount=sum(d.amtPaid) from deposit_detail d join moneysend m         
--on d.tranno=m.tranno        
--where bankCode=@cash_ledger_id   
--and m.refno=dbo.encryptDb(@remarks) and m.TransStatus='Cancel'        
        
 SET @invoice_id='C'+cast(IDENT_CURRENT('agent_fund_detail') + 1  AS VARCHAR)        
 insert into agent_fund_detail(invoice_no,agentCode,Dot,Local_Amt,xRate,Sender_BankID,remarks,        
 staff_id,Dollar_amt,invoice_type,branch_code,refno)        
 VALUES(@invoice_id,@agent_id,@as_of_date,@amount,1,@customer_refund_Ledger,'Refund to Customer:'+@remarks +' Note:'+ isNUll(@narration,'') ,        
 @transfer_by,@amount,'m',@branch_id,@remarks)        
--,@transfer_by,@as_of_date        
 insert into agent_fund_detail(invoice_no,agentCode,Dot,Local_Amt,xRate,Sender_BankID,remarks,        
 staff_id,Dollar_amt,invoice_type,branch_code,refno)        
 VALUES(@invoice_id,@agent_id,@as_of_date,@amount,1,@vault_ledger_id,'Refund to Customer:'+@remarks +' Note:'+ isNUll(@narration,''),        
 @transfer_by,@amount,'w',@branch_id,@remarks)        
--,@transfer_by,@as_of_date          
 UPDATE moneysend set digital_id_payout='refund to customer Inv:'+@invoice_id WHERE refno=dbo.encryptDb(@remarks) AND Branch_code=@branch_id        
           
 SELECT @invoice_id MSG        
END  
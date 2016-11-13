
/****** Object:  StoredProcedure [dbo].[spa_invoice_save_temp]    Script Date: 12/24/2014 02:48:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_invoice_save_temp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_invoice_save_temp]
GO



/****** Object:  StoredProcedure [dbo].[spa_invoice_save_temp]    Script Date: 12/24/2014 02:48:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spa_invoice_save_temp]  
@flag char(1),  
@agent_type char(1),  
@voucher_id int=null,  
@agentCode varchar(50),  
@dot varchar(20),  
@settle_amount money,  
@CurrencyType varchar(10),  
@settlement_rate money,  
@mode varchar(10),  
@dollar_rate money,  
@session_id varchar(150),  
@bank_code int=null,
@ledger_effect_ccy char(1)=null  
as  
declare @branch_code varchar(50)  
if @flag='i'  
begin  
 if @agent_type='b'   
 begin  
  set @branch_code=@agentCode  
  select @agentCode=agentcode from agentbranchdetail where agent_branch_code=@branch_code  
 end  
 declare @serial_no int  
 
 select @serial_no=isNUll(max(serial_no),0)+1 from temp_agent_voucher where session_id=@session_id  
 insert temp_agent_voucher(agentCode,DOT,Amount,CurrencyType,XRate,mode,dollar_rate,branch_code,session_id,bank_code,serial_no,ledger_effect_ccy)  
 values(@agentCode,@dot,@settle_amount,@CurrencyType,@settlement_rate,@mode,@dollar_rate,@branch_code,@session_id,@bank_code,@serial_no,@ledger_effect_ccy)  
   
  
end   
if @flag='d'  
begin  
 if @voucher_id=-1  
  delete temp_agent_voucher where session_id=@session_id  
 else  
  delete temp_agent_voucher where sno=@voucher_id  
end   
  
  
  
  
  
  
GO



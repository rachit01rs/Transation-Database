USE [PrabhuUSA]
GO

/****** Object:  StoredProcedure [dbo].[spa_invoice_save]    Script Date: 12/24/2014 02:48:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_invoice_save]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_invoice_save]
GO

USE [PrabhuUSA]
GO

/****** Object:  StoredProcedure [dbo].[spa_invoice_save]    Script Date: 12/24/2014 02:48:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
-- select * from temp_agent_voucher where session_id='10100519_0CE0BB3F_878F_4708_880C_3B46D2ACC400'      
--spa_invoice_save 'a','105_DDF34A87_07B9_4AEE_ABE6_2FBF9EB7FD43','2007-11-25','test','kamal'      
--spa_invoice_save 'a','10100519_0CE0BB3F_878F_4708_880C_3B46D2ACC400','2007-11-25','TEsting','kamal'     
--spa_invoice_save @flag='d',@del_invoice_id='14',  @user_id='admin'    
CREATE proc [dbo].[spa_invoice_save]      
@flag char(1),      
@session_id varchar(150)=null,      
@voucher_date varchar(20)=null,      
@narration varchar(1000)=null,      
@user_id varchar(20)=null,      
@del_invoice_id varchar(50)=null    
as      
BEGIN TRY      
    
declare @chk_closeDate varchar(20)    
       
       
if @flag='a' --MAIN AGENT TYPE VOUCHER      
begin      
    
select top 1 @chk_closeDate=CONVERT(varchar,close_date,101) from Account_Book_Close where close_date>=@voucher_date    
order by close_date desc     
if @chk_closeDate is not null    
begin    
 select 'ERROR' Status,-1 invoice_no,'You are not allowed to enter voucher before the Book Close dated:'+ @chk_closeDate MSGID    
 return    
end    
    
 declare @invoice_no int, @agent_balance_id int,@status varchar(50)      
      
      
select @status=case when round(sum(dr),0)=round(SUM(Cr),0) then 'Success' else 'Error' end   from (      
select sum(case when mode='dr' then dollar_rate else 0 end) DR, sum(case when mode='cr' then dollar_rate else 0 end)  CR      
from temp_agent_voucher       
where session_id=@session_id      
group by mode      
) l       
if @status='Error'       
begin      
  select 'ERROR','1000','Dollar amount Dr and Cr must be equal !!!'      
  return      
end      
      
--select @invoice_no=max(cast(invoiceNo as int)) from agentbalance where isNumeric(invoiceNo)=1      
--      
-- if @invoice_no is null       
--  set @invoice_no=1001      
-- else      
--  set @invoice_no=@invoice_no+1      
begin transaction      
 set @invoice_no=ident_current('agentbalance') + 1      
 set @voucher_date=@voucher_date +' '+ convert(varchar,getdate(),108)       
 insert agentbalance(invoiceNo,agentcode,CompanyName,Dot,amount,      
 currencyType,XRate,mode,Remarks,StaffId,dollar_Rate,fund_date,branch_code,deposit_id,ledger_effect_ccy)      
 select @invoice_no,t.agentcode,a.CompanyName,@voucher_date,t.amount,      
 t.currencyType,t.XRate,t.mode,@narration,@user_id,t.dollar_Rate,getdate(),t.branch_code,bank_code,ledger_effect_ccy      
 from  temp_agent_voucher t join agentdetail a on t.agentcode=a.agentcode       
 where session_id=@session_id      
      
 set @agent_balance_id=@@identity      
       
     
 delete temp_agent_voucher where session_id=@session_id      
 commit transaction      
 select 'SUCCESS',@invoice_no,@session_id      
      
      
end       
else if @flag='d'      
begin      
    
declare @inv_date datetime,@approve_by varchar(50),@enter_by varchar(50)    
select top 1 @inv_date=dot,@approve_by=replace(approved_by,'HO:',''),@enter_by=replace(staffId,'HO:','')   
from agentbalance where invoiceno=@del_invoice_id     
--if @enter_by=@user_id and @approve_by is not null    
--begin    
--select 'ERROR' Status,-1 invoice_no,'Created voucher and Delete Voucher Must be different' MSG    
--return    
--end    
    
select top 1 @chk_closeDate=CONVERT(varchar,close_date,101) from Account_Book_Close where close_date>=@inv_date    
order by close_date desc     
if @chk_closeDate is not null    
begin    
select 'ERROR' Status,-1 invoice_no,'You are not allowed to REMOVED voucher before the Book Close dated:'+ @chk_closeDate MSG    
return    
end    
    
 begin transaction     
-- select @approve_by    
 if @approve_by is not null    
 begin     
  update agentdetail      
  set currentBalance=case when t.mode='dr' then currentBalance-t.amount else currentBalance+t.amount end      
  from agentbalance t , agentdetail a where       
  t.agentcode=a.agentcode  and invoiceno=@del_invoice_id      
  and t.mode in ('dr','cr')      
       
  -- UPDATE FOR PAYOUT AGENT BALANCE      
  update AgentDetail       
  set payout_agent_balance= case when t.mode='dr' then isNull(payout_agent_balance,0)-t.amount else isNull(payout_agent_balance,0)+t.amount end      
  from agentbalance t , agentdetail a where       
  t.agentcode=a.agentcode  and invoiceno=@del_invoice_id      
  and t.mode in ('dr','cr')      
       
  update agentbranchdetail      
  set currentBalance=case when t.mode='dr' then currentBalance-t.amount else currentBalance+t.amount end      
  from agentbalance t , agentbranchdetail a where       
  t.branch_code=a.agent_branch_code  and invoiceno=@del_invoice_id      
  and t.mode in ('dr','cr')      
  end     
 Delete agent_fund_detail where invoice_no=@del_invoice_id and invoice_type in ('f','r')      
       
 update agentbalance set staffid='Delby:'+@user_id,update_ts=getdate() where invoiceno=@del_invoice_id      
      
 delete agentbalance where invoiceno=@del_invoice_id      
 commit transaction      
 select 'SUCCESS',@invoice_no,'Removed'      
end      
      
end try      
begin catch      
      
if @@trancount>0       
 rollback transaction      
      
 declare @desc varchar(1000)      
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'      
       
       
 INSERT INTO [error_info]      
           ([ErrorNumber]      
           ,[ErrorDesc]      
           ,[Script]      
           ,[ErrorScript]      
           ,[QueryString]      
           ,[ErrorCategory]      
           ,[ErrorSource]      
           ,[IP]      
           ,[error_date])      
 select -1,@desc,'Invoice','SQL',@desc,'SQL','SP',@user_id,getdate()      
      
 select 'ERROR','1012','Error Please try again'      
      
end catch    
GO



/****** Object:  StoredProcedure [dbo].[spa_GetWireTransferReport]    Script Date: 03/11/2014 12:32:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--spa_GetWireTransferReport '2014-01-01','2014-03-22','a',NULL,'United States'    
CREATE procedure [dbo].[spa_GetWireTransferReport]        
( @fromdate varchar(50) = null,        
 @todate varchar(50) = null,        
 @reporttype varchar(10) = null,        
 @bankcode varchar(30) = null ,    
 @country varchar(50)=NULL    
)        
as         
set nocount on        
--declare @fromdate varchar(50),@todate varchar(50),@reporttype varchar(10),@bankcode varchar(30) ,@country varchar(50)      
--set @fromdate='2014-01-01'        
--set @todate='2014-03-28'        
--set @reporttype='a'        
----set @country='Bangladesh'    
--drop table #temp_incoming        
--drop table #temp_outgoing        
begin        
        
declare @BankGroup varchar(100)        
set @BankGroup='20100002'        
  
create table   #temp_incoming(  
 InvoiceNo varchar(50)  
)      
 if @reporttype = 'i' or @reporttype = 'a'        
 begin        
      insert #temp_incoming(InvoiceNo)  
 select distinct InvoiceNo   
 from agentbalance b join agentDetail a on b.agentcode=a.agentCode     
 where invoiceno in (    
  select invoiceNo from agentbalance b join agentDetail a on b.agentcode=a.agentCode   
  where mode='dr' and branch_code=isNUll(@bankcode,b.branch_code)  
  and a.external_ledgerID='Bank Ledger'  
  and dot between @fromdate and @todate + ' 23:59:59'  and approved_by is not null      
 ) and mode='cr' and a.country=isNULL(@country,a.country)    
  
  select agentCode,CompanyName,sum(Amount) Amount,AgentType,'i' Mode,Ledger_Type from (        
  select isNUll(b.branch_code,b.agentCode) agentCode,isNUll(ba.branch,b.CompanyName) CompanyName,dollar_rate Amount,'a'     
  AgentType, case when b.branch_code is null then 'a' else 'b' end Ledger_Type from #temp_incoming i join agentbalance b        
  on i.InvoiceNo=b.InvoiceNo    
  left outer join agentbranchdetail ba on ba.agent_branch_code=b.branch_code       
  where mode='cr'     
  union all        
  select a.branch_code,b.branch,dollar_rate Amount,'b' AgentType,'b' Ledger_Type from #temp_incoming i join agentbalance a        
  on i.InvoiceNo=a.InvoiceNo         
  join agentbranchdetail b on b.agent_branch_code=a.branch_code        
  where mode='dr'        
  ) l group by agentCode,CompanyName,AgentType ,Ledger_Type       
        
 end        
 if @reporttype = 'o' or @reporttype = 'a'        
 begin        
        
 select distinct InvoiceNo into #temp_outgoing   
 from agentbalance b join agentDetail a on b.agentcode=a.agentCode     
  where invoiceno in (    
    select invoiceNo from agentbalance b join agentDetail a on b.agentcode=a.agentCode where mode='cr'   
    and branch_code=isNUll(@bankcode,b.branch_code)      
    and dot between @fromdate and @todate + ' 23:59:59'  and approved_by is not null     
    and a.external_ledgerID='Bank Ledger'   
  ) and mode='dr' and a.country=isNULL(@country,a.country)    
  and InvoiceNo not in (select InvoiceNo from #temp_incoming)  
  
      
  select agentCode,CompanyName,sum(Amount) Amount,AgentType,'o' Mode,Ledger_Type from (        
  select isNUll(b.branch_code,b.agentCode) agentCode,isNUll(ba.branch,b.CompanyName) CompanyName,    
 dollar_rate Amount,'a' AgentType,case when b.branch_code is null then 'a' else 'b' end Ledger_Type from #temp_outgoing i join agentbalance b        
  on i.InvoiceNo=b.InvoiceNo     
 left outer join agentbranchdetail ba on ba.agent_branch_code=b.branch_code        
 where mode='dr'        
  union all        
  select  a.branch_Code,b.branch,dollar_rate Amount,'b' AgentType,'b' Ledger_Type from #temp_outgoing i join agentbalance a        
  on i.InvoiceNo=a.InvoiceNo         
  join agentbranchdetail b on b.agent_branch_code=a.branch_code        
  where mode='cr'        
  ) l group by agentCode,CompanyName,AgentType,Ledger_Type      
        
 end        
        
end         
        
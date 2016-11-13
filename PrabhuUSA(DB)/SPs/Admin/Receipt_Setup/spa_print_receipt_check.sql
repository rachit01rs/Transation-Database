
/****** Object:  StoredProcedure [dbo].[spa_print_receipt_check]    Script Date: 02/04/2013 10:22:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_print_receipt_check '9168#######','20100003'   
CREATE proc [dbo].[spa_print_receipt_check]    
@refno varchar(50),    
@agentid varchar(50)    
as    
    
if exists (Select m.tranno from moneysend_check m join Partner_Agents a    
 on m.paid_agent_id=a.Ext_AgentCode where refno=dbo.encryptdb(@refno) and agentid=@agentid)    
 begin    
 Select m.*,COALESCE(b.ext_branch_group,a.Ext_AgentName,pa.CompanyName)  PayoutAgent,b.Ext_BranchAddress agentbranchAddress,b.Ext_branchcity agentbranchcity,    
b.Ext_branchtelephone agentBranchTelephone from moneysend_check m join     
      agentDetail pa on m.expected_payoutagentid=pa.agentCode      
      left outer join Partner_Agents a    
 on m.paid_agent_id=a.Ext_AgentCode    
left outer join Partner_branch b on b.Ext_Agent_Branch_code=m.c2c_receiver_code and b.Ext_AgentCode=a.Ext_AgentCode     
where refno=dbo.encryptdb(@refno) and transStatus<>'Cancel'    
 end    
 else    
 begin    
Select m.*,a.CompanyName PayoutAgent,b.address agentbranchAddress,b.city agentbranchcity,    
b.telephone agentBranchTelephone from moneysend_check m left outer join agentdetail a    
 on m.expected_payoutagentid=a.agentcode    
left outer join agentbranchdetail b on b.agent_branch_code=m.rBankid     
where refno=dbo.encryptdb(@refno) and transStatus<>'Cancel'    
end
GO



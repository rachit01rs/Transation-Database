/*  
** Database    : PrabhuUSA
** Object      : Table agent_branch_commission_audit
** Purpose     : add amount_currency_type forMIn and Max CCY Type 
** Author      : Sunita Shrestha 
** Date        : 29 April 2014  
*/ 

 IF COL_LENGTH('agent_branch_commission_audit','paidValueCCY') IS NULL
	ALTER TABLE agent_branch_commission_audit ADD paidValueCCY char(1)
GO
IF COL_LENGTH('agent_branch_commission_audit','sendAgentCode') IS NULL
	ALTER TABLE agent_branch_commission_audit ADD sendAgentCode VARCHAR(50)
GO
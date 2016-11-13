/*  
** Database    : PrabhuUSA
** Object      : Table agent_branch_commission
** Purpose     : add amt_currency_Type for MIn and Max CCY Type 
** Author      : Sunita Shrestha 
** Date        : 28 April 2014  
*/ 

 IF COL_LENGTH('agent_branch_commission','paidValueCCY') IS NULL
	ALTER TABLE agent_branch_commission ADD paidValueCCY char(1)
GO
IF COL_LENGTH('agent_branch_commission','sendAgentCode') IS NULL
	ALTER TABLE agent_branch_commission ADD sendAgentCode VARCHAR(50)
GO
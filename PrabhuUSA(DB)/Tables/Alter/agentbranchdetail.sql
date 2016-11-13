/*  
** Database    : PrabhuUSA
** Object      : Table agentbranchdetail
** Purpose     : alter table agentbranchdetail
** Author      : Sunita Shrestha 
** Date        : 15th july 2014  
*/ 

 IF COL_LENGTH('agentbranchdetail','hide_branch') IS NULL
	ALTER TABLE agentbranchdetail ADD hide_branch char(1)
GO
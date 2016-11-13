/*  
** Database    : PrabhuUSA
** Object      : Table agentbranchdetail
** Purpose     : alter table agentdetail
** Modified    : Paribesh Jung Karki (adding if statement)
** Date        : 18th November 2014  
*/ 
IF COL_LENGTH('agentdetail','STATE') IS NULL
	ALTER TABLE dbo.agentDetail ADD STATE VARCHAR(50)
GO

IF COL_LENGTH('agentDetail_audit','STATE') IS NULL
	ALTER TABLE dbo.agentDetail_audit ADD STATE VARCHAR(50)
GO


/*  
** Database    : PrabhuUSA
** Object      : Table agentbranchdetail
** Purpose     : alter table agentdetail
** Author      : Paribesh Jung Karki 
** Date        : 18th November 2014  
*/ 

 IF COL_LENGTH('agentdetail','send_txn_without_balance') IS NULL
	ALTER TABLE agentdetail ADD send_txn_without_balance char(1)
GO

 IF COL_LENGTH('agentDetail_audit','send_txn_without_balance') IS NULL
	ALTER TABLE agentDetail_audit ADD send_txn_without_balance char(1)
GO
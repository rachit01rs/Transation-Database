alter table  moneysend 
add SSN_Card_id varchar(50)
GO 
alter table  CustomerDetail 
add SSN_Card_id varchar(50)
GO
ALTER TABLE moneysend 
ADD sPaymentReceivedType VARCHAR(50) NULL,        
	sCheque_bank VARCHAR(200) NULL,
	sChequeno VARCHAR (100) NULL ,
	IssueAuthority VARCHAR (200) NULL
go
ALTER TABLE moneysend_audit 
ADD sPaymentReceivedType VARCHAR(50) NULL,        
	sCheque_bank VARCHAR(200) NULL,
	sChequeno VARCHAR (100) NULL ,
	IssueAuthority VARCHAR (200) NULL
go
ALTER TABLE dbo.moneysend_arch1
ADD sPaymentReceivedType VARCHAR(50) NULL,        
	sCheque_bank VARCHAR(200) NULL,
	sChequeno VARCHAR (100) NULL ,
	IssueAuthority VARCHAR (200) NULL
go
ALTER TABLE dbo.moneysend_arch1_audit
ADD sPaymentReceivedType VARCHAR(50) NULL,        
	sCheque_bank VARCHAR(200) NULL,
	sChequeno VARCHAR (100) NULL ,
	IssueAuthority VARCHAR (200) NULL
GO
ALTER TABLE dbo.delMoneysend
ADD sPaymentReceivedType VARCHAR(50) NULL,        
	sCheque_bank VARCHAR(200) NULL,
	sChequeno VARCHAR (100) NULL ,
	IssueAuthority VARCHAR (200) NULL
GO
ALTER TABLE dbo.cancelMoneySend
ADD sPaymentReceivedType VARCHAR(50) NULL,        
	sCheque_bank VARCHAR(200) NULL,
	sChequeno VARCHAR (100) NULL ,
	IssueAuthority VARCHAR (200) NULL
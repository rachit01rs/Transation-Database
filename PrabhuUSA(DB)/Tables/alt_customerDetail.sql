IF COL_LENGTH('customerdetail','is_locked') IS NULL
	ALTER TABLE customerdetail ADD is_locked CHAR(1)
go
IF COL_LENGTH('customerdetail','Remark') IS NULL
	ALTER TABLE dbo.customerDetail ADD Remark VARCHAR(1000)


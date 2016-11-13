IF OBJECT_ID ('dbo.customer_limit_check') IS NOT NULL
	DROP TABLE dbo.customer_limit_check
GO

CREATE TABLE dbo.customer_limit_check
	(
	sno            INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	customer_sno	INT not NULL,
	customer_id     VARCHAR (50) NULL,
	days_7_amount        MONEY NULL,
	days_15_amount        MONEY NULL,
	days_30_amount        MONEY NULL,
	days_90_amount        MONEY NULL,
	month_6_amount         MONEY NULL,
	year_1_amount         MONEY NULL,
	year_more_amount      MONEY NULL,
	days_7_count			int NULL,
	days_15_count        int NULL,
	days_30_count        int NULL,
	days_90_count        int NULL,
	month_6_count         int NULL,
	year_1_count         int NULL,
	year_more_count      int NULL,
	updated_date		DATETIME NULL,
	CONSTRAINT FK_customer_limit_check_customerDetail FOREIGN KEY (customer_sno) REFERENCES dbo.customerDetail (sno) ON DELETE CASCADE ON UPDATE CASCADE
	)
GO


CREATE TABLE dbo.APIPartner_Agent_Margin_Setup
	(
	sno               INT IDENTITY NOT NULL,
	API_Partner       VARCHAR (50) NULL,
	Send_AgentID      VARCHAR (50) NULL,
	Payout_Country    VARCHAR (50) NULL,
	ExRate_Margin     FLOAT NULL,
	ServiceFee_Margin MONEY NULL,
	Send_Commission   MONEY NULL,
	Payout_Commission MONEY NULL,
	update_by         VARCHAR (50) NULL,
	update_ts         DATETIME NULL,
	CONSTRAINT PK__APIPartn__DDDF644624885067 PRIMARY KEY (sno)
	)
CREATE TABLE [dbo].[soap_log](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[functionName] [varchar](50) NULL,
	[partnerId] [varchar](50) NULL,
	[tranId] [varchar](50) NULL,
	[partnerTranId] [varchar](50) NULL,
	[reqxml] [varchar](max) NULL,
	[resxml] [varchar](max) NULL,
	[createTs] [datetime] NULL,
	[userId] [varchar](50) NULL
) ON [PRIMARY]
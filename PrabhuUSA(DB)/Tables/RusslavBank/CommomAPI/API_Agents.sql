DROP TABLE [CIMB_Agents]
GO
CREATE TABLE [dbo].[API_Agents](
	[id] [int] IDENTITY(1,2) NOT NULL,
	[DestinationCountry] [varchar](50) NULL,
	[AgentId] [varchar](50) NULL,
	[AgentName] [varchar](100) NULL,
	[BranchName] [varchar](max) NULL,
	[BranchCode] [varchar](50) NULL,
	[org_code] [varchar](50) NULL,
	[Address1] [varchar](max) NULL,
	[Address2] [varchar](100) NULL,
	[PhoneNumber] [varchar](max) NULL,
	[FaxNumber] [varchar](max) NULL,
	[Email] [varchar](70) NULL,
	[State] [varchar](50) NULL,
	[stateCode] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[Transaction_limit] [varchar](50) NULL,
	[DestinationCurrency] [varchar](10) NULL,
	[is_anywhere] [char](1) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
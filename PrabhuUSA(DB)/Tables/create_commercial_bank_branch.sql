CREATE TABLE [dbo].[commercial_bank_branch](
	[sno] [int] IDENTITY(2,1) NOT NULL,
	[bankName] [varchar](200) NULL,
	[IFSC_Code] [varchar](50) NULL,
	[MICR_Code] [varchar](100) NULL,
	[BranchName] [varchar](200) NULL,
	[address] [varchar](500) NULL,
	[contact] [varchar](500) NULL,
	[city] [varchar](100) NULL,
	[district] [varchar](50) NULL,
	[state] [varchar](50) NULL,
	[country] [varchar](100) NULL,
	[Commercial_id] [int] NULL
) ON [PRIMARY]
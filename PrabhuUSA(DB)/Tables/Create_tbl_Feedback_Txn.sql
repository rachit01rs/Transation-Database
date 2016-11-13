CREATE TABLE [dbo].[tbl_Feedback_Txn](
	[SNo] [int] IDENTITY(1,1) NOT NULL,
	[Feedback_Status] [nvarchar](200) NOT NULL,
	[Ref_No] [nvarchar](100) NOT NULL,
	[Received_Date] [nvarchar](50) NULL,
	[Remarks] [nvarchar](500) NULL,
	[PayoutAgent] [nvarchar](50) NULL,
	[Extra_Column_1] [nvarchar](100) NULL,
	[Extra_Column_2] [nvarchar](100) NULL,
	[Extra_Column_3] [nvarchar](100) NULL,
	[Extra_Column_4] [nvarchar](100) NULL,
	[Extra_Column_5] [nvarchar](100) NULL,
	[IMPORTED_DATE] [datetime] NULL,
	[PROCESS_ID] [nvarchar](200) NULL,
	[SYSTEM_STATUS] [nvarchar](200) NULL,
	[Amount] [nvarchar](100) NULL,
	[TrackingNo] [nvarchar](50) NULL,
	[SenderName] [nvarchar](200) NULL,
 CONSTRAINT [PK_Feedback_Txn] PRIMARY KEY CLUSTERED 
(
	[SNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
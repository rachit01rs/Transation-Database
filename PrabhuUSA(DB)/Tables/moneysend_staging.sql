CREATE TABLE [dbo].[moneysend_staging](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[Tranno] [int] NOT NULL,
	[TransStatus] [varchar](50) NOT NULL,
	[create_ts] [datetime] NULL,
	[process_ts] [datetime] NULL,
	[status] [char](1) NULL
	)
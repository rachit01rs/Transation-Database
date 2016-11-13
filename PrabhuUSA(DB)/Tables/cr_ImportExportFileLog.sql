CREATE TABLE [dbo].[ImportExportFileLog](
	[sno] [int] IDENTITY(1,1) NOT NULL PRIMARY key,
	[FileName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[systemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Create_ts] [datetime] NULL,
	[FileType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

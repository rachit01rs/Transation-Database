GO
/****** Object:  Index [XI_FTP_import_file_DATA]    Script Date: 09/04/2013 18:26:11 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbl_FTP_Import_File_Data]') AND name = N'XI_FTP_import_file_DATA')
DROP INDEX [XI_FTP_import_file_DATA] ON [dbo].[tbl_FTP_Import_File_Data] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [XI_FTP_Import_file_Data1]    Script Date: 09/04/2013 18:26:11 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tbl_FTP_Import_File_Data]') AND name = N'XI_FTP_Import_file_Data1')
DROP INDEX [XI_FTP_Import_file_Data1] ON [dbo].[tbl_FTP_Import_File_Data] WITH ( ONLINE = OFF )

GO
/****** Object:  Index [XI_FTP_import_file_DATA]    Script Date: 09/04/2013 18:26:18 ******/
CREATE CLUSTERED INDEX [XI_FTP_import_file_DATA] ON [dbo].[tbl_FTP_Import_File_Data] 
(
	[Sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [XI_FTP_Import_file_Data1]    Script Date: 09/04/2013 18:26:18 ******/
CREATE NONCLUSTERED INDEX [XI_FTP_Import_file_Data1] ON [dbo].[tbl_FTP_Import_File_Data] 
(
	[ProcessId] ASC,
	[PINNO] ASC,
	[PartnerID] ASC,
	[DataInsertedInMoneySend] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
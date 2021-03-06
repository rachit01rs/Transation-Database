/****** Object:  Index [IX_commercial_bank]    Script Date: 06/25/2014 13:07:34 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[commercial_bank_branch]') AND name = N'IX_commercial_bank_branch')
DROP INDEX [IX_commercial_bank_branch] ON [dbo].[commercial_bank_branch] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_commercial_bank]    Script Date: 06/25/2014 13:07:38 ******/
CREATE NONCLUSTERED INDEX [IX_commercial_bank_branch] ON [dbo].[commercial_bank_branch] 
(
	[IFSC_Code] ASC,
	[Commercial_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
/****** Object:  Index [IX_TransactionNotes]    Script Date: 12/02/2011 01:01:41 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TransactionNotes]') AND name = N'IX_TransactionNotes')
DROP INDEX [IX_TransactionNotes] ON [dbo].[TransactionNotes] WITH ( ONLINE = OFF )
GO 
/****** Object:  Index [IX_TransactionNotes]    Script Date: 12/02/2011 01:00:55 ******/
CREATE NONCLUSTERED INDEX [IX_TransactionNotes_Refno] ON [dbo].[TransactionNotes] 
(
	[RefNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO 
CREATE NONCLUSTERED INDEX [IX_TransactionNotes_Tranno] ON [dbo].[TransactionNotes] 
(
	[Tranno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO 
CREATE NONCLUSTERED INDEX [IX_TransactionNotes_DatePosted] ON [dbo].[TransactionNotes] 
(
	[DatePosted] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


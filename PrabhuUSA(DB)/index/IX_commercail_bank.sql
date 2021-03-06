/****** Object:  Index [IX_commercail_bank]    Script Date: 06/25/2014 13:05:54 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[commercial_bank]') AND name = N'IX_commercail_bank')
DROP INDEX [IX_commercail_bank] ON [dbo].[commercial_bank] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_commercail_bank]    Script Date: 06/25/2014 13:06:00 ******/
CREATE NONCLUSTERED INDEX [IX_commercail_bank] ON [dbo].[commercial_bank] 
(
	[payout_agent_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
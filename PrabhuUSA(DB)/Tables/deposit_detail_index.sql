/****** Object:  Index [IX_deposit_detail]    Script Date: 12/02/2011 00:58:20 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[deposit_detail]') AND name = N'IX_deposit_detail')
DROP INDEX [IX_deposit_detail] ON [dbo].[deposit_detail] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_deposit_detail_Tranno]    Script Date: 12/02/2011 00:58:20 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[deposit_detail]') AND name = N'IX_deposit_detail_Tranno')
DROP INDEX [IX_deposit_detail_Tranno] ON [dbo].[deposit_detail] WITH ( ONLINE = OFF )
GO 
/****** Object:  Index [IX_deposit_detail]    Script Date: 12/02/2011 00:58:05 ******/
CREATE NONCLUSTERED INDEX [IX_deposit_detail] ON [dbo].[deposit_detail] 
(
	[BankCode] ASC,
	[depositDOT] ASC	
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_deposit_detail_Tranno]    Script Date: 12/02/2011 00:58:05 ******/
CREATE NONCLUSTERED INDEX [IX_deposit_detail_Tranno] ON [dbo].[deposit_detail] 
(
	[tranno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
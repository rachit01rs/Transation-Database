/****** Object:  Index [IX_agentBalance]    Script Date: 12/02/2011 00:53:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agentBalance]') AND name = N'IX_agentBalance')
DROP INDEX [IX_agentBalance] ON [dbo].[agentBalance] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_AgentBalance_AgentCode]    Script Date: 12/02/2011 00:53:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agentBalance]') AND name = N'IX_AgentBalance_AgentCode')
DROP INDEX [IX_AgentBalance_AgentCode] ON [dbo].[agentBalance] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_AgentBalance_Branch_code]    Script Date: 12/02/2011 00:53:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agentBalance]') AND name = N'IX_AgentBalance_Branch_code')
DROP INDEX [IX_AgentBalance_Branch_code] ON [dbo].[agentBalance] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_AgentBalance_DOT]    Script Date: 12/02/2011 00:53:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agentBalance]') AND name = N'IX_AgentBalance_DOT')
DROP INDEX [IX_AgentBalance_DOT] ON [dbo].[agentBalance] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_AgentBalance_InvoiceNo]    Script Date: 12/02/2011 00:53:01 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[agentBalance]') AND name = N'IX_AgentBalance_InvoiceNo')
DROP INDEX [IX_AgentBalance_InvoiceNo] ON [dbo].[agentBalance] WITH ( ONLINE = OFF )
GO 
/****** Object:  Index [IX_agentBalance]    Script Date: 12/02/2011 00:52:17 ******/
CREATE NONCLUSTERED INDEX [IX_agentBalance] ON [dbo].[agentBalance] 
(
	[mode] ASC,
	[money_id] ASC,
	[approved_ts] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AgentBalance_AgentCode]    Script Date: 12/02/2011 00:52:17 ******/
CREATE NONCLUSTERED INDEX [IX_AgentBalance_AgentCode] ON [dbo].[agentBalance] 
(
	[agentCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AgentBalance_Branch_code]    Script Date: 12/02/2011 00:52:17 ******/
CREATE NONCLUSTERED INDEX [IX_AgentBalance_Branch_code] ON [dbo].[agentBalance] 
(
	[branch_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AgentBalance_DOT]    Script Date: 12/02/2011 00:52:17 ******/
CREATE NONCLUSTERED INDEX [IX_AgentBalance_DOT] ON [dbo].[agentBalance] 
(
	[DOT] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AgentBalance_InvoiceNo]    Script Date: 12/02/2011 00:52:17 ******/
CREATE NONCLUSTERED INDEX [IX_AgentBalance_InvoiceNo] ON [dbo].[agentBalance] 
(
	[InvoiceNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
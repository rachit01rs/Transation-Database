
/****** Object:  Index [IX_moneySend_1]    Script Date: 12/02/2011 07:42:57 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[moneySend]') AND name = N'IX_moneySend_1')
DROP INDEX [IX_moneySend_1] ON [dbo].[moneySend] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Moneysend_AgentID]    Script Date: 12/02/2011 07:42:57 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[moneySend]') AND name = N'IX_Moneysend_AgentID')
DROP INDEX [IX_Moneysend_AgentID] ON [dbo].[moneySend] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Moneysend_ConfirmDate]    Script Date: 12/02/2011 07:42:57 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[moneySend]') AND name = N'IX_Moneysend_ConfirmDate')
DROP INDEX [IX_Moneysend_ConfirmDate] ON [dbo].[moneySend] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Moneysend_PaidDate]    Script Date: 12/02/2011 07:42:57 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[moneySend]') AND name = N'IX_Moneysend_PaidDate')
DROP INDEX [IX_Moneysend_PaidDate] ON [dbo].[moneySend] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Moneysend_rBankID]    Script Date: 12/02/2011 07:42:57 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[moneySend]') AND name = N'IX_Moneysend_rBankID')
DROP INDEX [IX_Moneysend_rBankID] ON [dbo].[moneySend] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Moneysend_receiveAgentID]    Script Date: 12/02/2011 07:42:57 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[moneySend]') AND name = N'IX_Moneysend_receiveAgentID')
DROP INDEX [IX_Moneysend_receiveAgentID] ON [dbo].[moneySend] WITH ( ONLINE = OFF )
go 
/****** Object:  Index [IX_moneySend_1]    Script Date: 12/02/2011 07:42:40 ******/
CREATE NONCLUSTERED INDEX [IX_moneySend_1] ON [dbo].[moneySend] 
(
	[ReceiverCountry] ASC,
	[TransStatus] ASC,
	[status] ASC,
	[paymentType] ASC,
	[lock_status] ASC,
	[Branch_code] ASC,
	[expected_payoutagentid] ASC,
	[CustomerId] ASC,
	[SenderName] ASC,
	[ReceiverName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_AgentID]    Script Date: 12/02/2011 07:42:40 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_AgentID] ON [dbo].[moneySend] 
(
	[agentid] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_ConfirmDate]    Script Date: 12/02/2011 07:42:40 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_ConfirmDate] ON [dbo].[moneySend] 
(
	[confirmDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_PaidDate]    Script Date: 12/02/2011 07:42:40 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_PaidDate] ON [dbo].[moneySend] 
(
	[paidDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_rBankID]    Script Date: 12/02/2011 07:42:40 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_rBankID] ON [dbo].[moneySend] 
(
	[rBankID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_receiveAgentID]    Script Date: 12/02/2011 07:42:40 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_receiveAgentID] ON [dbo].[moneySend] 
(
	[receiveAgentID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
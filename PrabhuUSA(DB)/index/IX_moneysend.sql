/****** Object:  Index [IX_moneySend]    Script Date: 03/19/2014 04:44:29 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_moneySend] ON [dbo].[moneySend] 
(
	[refno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 70) ON [PRIMARY]
GO
/****** Object:  Index [IX_moneySend_1]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_moneySend_1] ON [dbo].[moneySend] 
(
	[ReceiverCountry] ASC,
	[TransStatus] ASC,
	[status] ASC,
	[paymentType] ASC,
	[lock_status] ASC,
	[Branch_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_AgentID]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_AgentID] ON [dbo].[moneySend] 
(
	[agentid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_ConfirmDate]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_ConfirmDate] ON [dbo].[moneySend] 
(
	[confirmDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_moneySend_customerid]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_moneySend_customerid] ON [dbo].[moneySend] 
(
	[CustomerId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_expected_payoutagentid]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_expected_payoutagentid] ON [dbo].[moneySend] 
(
	[expected_payoutagentid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_local_dot]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_local_dot] ON [dbo].[moneySend] 
(
	[local_DOT] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_PaidDate]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_PaidDate] ON [dbo].[moneySend] 
(
	[paidDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_rBankACNo]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_rBankACNo] ON [dbo].[moneySend] 
(
	[rBankACNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_rBankID]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_rBankID] ON [dbo].[moneySend] 
(
	[rBankID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_ReceiverName]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_ReceiverName] ON [dbo].[moneySend] 
(
	[ReceiverName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_SenderAddress]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_SenderAddress] ON [dbo].[moneySend] 
(
	[SenderAddress] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_SenderMobile]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_SenderMobile] ON [dbo].[moneySend] 
(
	[sender_mobile] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Moneysend_SenderName]    Script Date: 03/19/2014 04:44:29 ******/
CREATE NONCLUSTERED INDEX [IX_Moneysend_SenderName] ON [dbo].[moneySend] 
(
	[SenderName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
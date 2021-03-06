/****** Object:  Index [IX_service_charge_setup_agent_id]    Script Date: 12/02/2011 00:55:35 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[service_charge_setup]') AND name = N'IX_service_charge_setup_agent_id')
DROP INDEX [IX_service_charge_setup_agent_id] ON [dbo].[service_charge_setup] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_service_charge_setup_payment_type]    Script Date: 12/02/2011 00:55:35 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[service_charge_setup]') AND name = N'IX_service_charge_setup_payment_type')
DROP INDEX [IX_service_charge_setup_payment_type] ON [dbo].[service_charge_setup] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_service_charge_setup_payout_agent_id]    Script Date: 12/02/2011 00:55:35 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[service_charge_setup]') AND name = N'IX_service_charge_setup_payout_agent_id')
DROP INDEX [IX_service_charge_setup_payout_agent_id] ON [dbo].[service_charge_setup] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_service_charge_setup_Rec_Country]    Script Date: 12/02/2011 00:55:35 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[service_charge_setup]') AND name = N'IX_service_charge_setup_Rec_Country')
DROP INDEX [IX_service_charge_setup_Rec_Country] ON [dbo].[service_charge_setup] WITH ( ONLINE = OFF )
GO 
/****** Object:  Index [IX_service_charge_setup_agent_id]    Script Date: 12/02/2011 00:55:03 ******/
CREATE NONCLUSTERED INDEX [IX_service_charge_setup_agent_id] ON [dbo].[service_charge_setup] 
(
	[agent_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_service_charge_setup_payment_type]    Script Date: 12/02/2011 00:55:03 ******/
CREATE NONCLUSTERED INDEX [IX_service_charge_setup_payment_type] ON [dbo].[service_charge_setup] 
(
	[payment_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_service_charge_setup_payout_agent_id]    Script Date: 12/02/2011 00:55:03 ******/
CREATE NONCLUSTERED INDEX [IX_service_charge_setup_payout_agent_id] ON [dbo].[service_charge_setup] 
(
	[payout_agent_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_service_charge_setup_Rec_Country]    Script Date: 12/02/2011 00:55:03 ******/
CREATE NONCLUSTERED INDEX [IX_service_charge_setup_Rec_Country] ON [dbo].[service_charge_setup] 
(
	[Rec_Country] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
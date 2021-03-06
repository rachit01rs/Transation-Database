/****** Object:  Index [IX_Sys_access_Log_Date]    Script Date: 12/02/2011 00:57:38 ******/
CREATE NONCLUSTERED INDEX [IX_Sys_access_Log_Date] ON [dbo].[sys_access] 
(
	[log_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Sys_access_Login_type]    Script Date: 12/02/2011 00:57:38 ******/
CREATE NONCLUSTERED INDEX [IX_Sys_access_Login_type] ON [dbo].[sys_access] 
(
	[login_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Sys_access_user_id]    Script Date: 12/02/2011 00:57:38 ******/
CREATE NONCLUSTERED INDEX [IX_Sys_access_user_id] ON [dbo].[sys_access] 
(
	[user_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
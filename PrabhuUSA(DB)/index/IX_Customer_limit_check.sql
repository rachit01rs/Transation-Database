/****** Object:  Index [IX_Customer_limit_check]    Script Date: 05/18/2014 18:54:29 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[customer_limit_check]') AND name = N'IX_Customer_limit_check')
DROP INDEX [IX_Customer_limit_check] ON [dbo].[customer_limit_check] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [IX_Customer_limit_check]    Script Date: 05/18/2014 18:54:39 ******/
CREATE NONCLUSTERED INDEX [IX_Customer_limit_check] ON [dbo].[customer_limit_check] 
(
	[updated_date] ASC,
	[customer_sno] ASC,
	[customer_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
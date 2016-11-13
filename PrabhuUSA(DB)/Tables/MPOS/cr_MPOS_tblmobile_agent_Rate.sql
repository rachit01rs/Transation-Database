
CREATE TABLE [dbo].[MPOS_tblmobile_agent_Rate](
	[agent_deno_sno] [int] IDENTITY(1,1) NOT NULL,
	[agent_id] [varchar](50) NULL,
	[mobile_demination_sno] [int] NULL,
	[selling_price] [money] NULL,
	[service_charge] [money] NULL,
	[agent_comission] [money] NULL,
	[discount] [money] NULL,
	[country_sno] [int] NULL,
 CONSTRAINT [PK_tblmobile_agent_Rate] PRIMARY KEY CLUSTERED 
(
	[agent_deno_sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[tblmobile_agent_Rate]  WITH CHECK ADD  CONSTRAINT [FK_tblmobile_agent_Rate_tbldenomination1] FOREIGN KEY([mobile_demination_sno])
REFERENCES [dbo].[tbldenomination] ([sno])
GO

ALTER TABLE [dbo].[tblmobile_Reseller_Rate] CHECK CONSTRAINT [FK_tblmobile_Reseller_Rate_tbldenomination1]
GO



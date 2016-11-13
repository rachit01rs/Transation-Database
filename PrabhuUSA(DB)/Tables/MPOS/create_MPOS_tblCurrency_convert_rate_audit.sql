/*  
** Database    : PrabhuUSA  
** Purpose     : Create Table [dbo].[MPOS_tblCurrency_convert_rate_audit]
** Author      : Bikash Giri
** Date        : 24th October 2013  

*/
CREATE TABLE [dbo].[MPOS_tblCurrency_convert_rate_audit](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[MPOS_tblCurrency_convert_rate_sno] [int] NULL,
	[Currency] [varchar](100) NULL,
	[USD_Rate] [money] NULL,
	[CreatedBy] [varchar](100) NULL,
	[Created_Date] [varchar](100) NULL,
	[UpdatedBy] [varchar](100) NULL,
	[Updated_Date] [datetime] NULL,
	[user_action] [varchar](50) NULL
)

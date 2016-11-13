GO

/****** Object:  Table [dbo].[user_credit_limit_log]    Script Date: 10/21/2013 16:28:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[user_credit_limit_log](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[user_login_id] [varchar](50) NULL,
	[updated_by] [varchar](50) NULL,
	[updated_ts] [varchar](50) NULL,
	[user_credit_limit] [money] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



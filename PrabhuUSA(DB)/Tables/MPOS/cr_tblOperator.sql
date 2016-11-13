/****** Object:  Table [dbo].[MPOS_tblOperator]    Script Date: 02/16/2014 13:00:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MPOS_tblOperator]') AND type in (N'U'))
DROP TABLE [dbo].[MPOS_tblOperator]
GO


/****** Object:  Table [dbo].[MPOS_tblOperator]    Script Date: 02/16/2014 13:00:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MPOS_tblOperator](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[country_name] [varchar](100) NOT NULL,
	[operator_name] [varchar](100) NULL,
	[IsEnable] [varchar](5) NULL,
	[actionKey] [varchar](20) NULL,
	[is_suspended] [char](1) NULL,
 CONSTRAINT [PK__tblOperator__2022C2A6] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



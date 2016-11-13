DROP TABLE [dbo].[temp_import_bankbranchDetail]
GO
CREATE TABLE [dbo].[temp_import_bankbranchDetail]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[BranchName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[District] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTCODE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTCODE1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[digital_id_sENDer] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_id] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

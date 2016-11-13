DROP TABLE [dbo].[temp_import_bankDetail]
go
CREATE TABLE [dbo].[temp_import_bankDetail]
(
[BankID] [int] NOT NULL IDENTITY(1, 1),
[Bank] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtBankID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[agent_country] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payingOutAgent] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[digital_id_sENDer] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_id] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

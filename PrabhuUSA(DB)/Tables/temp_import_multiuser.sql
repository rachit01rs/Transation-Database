CREATE TABLE [dbo].[temp_import_multiuser]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[User_login_Id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_pwd] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upload] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[agent_branch_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rights] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[limited_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lock_days] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_by] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_by] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_ts] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_remarks] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_integration_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[digital_id_sENDer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_post] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[roles] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

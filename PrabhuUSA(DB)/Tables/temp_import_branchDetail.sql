DROP TABLE [dbo].[temp_import_branchDetail]
go
CREATE TABLE [dbo].[temp_import_branchDetail]
(
[agentCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Branch] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Telephone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Group] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[digital_id_sENDer] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_id] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[branchcode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[agent_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_login_Id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_pwd] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_post] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[agent_branch_code] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL,
[upload] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rights] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[limited_date] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lock_days] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_by] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_by] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve_ts] [datetime] NULL,
[user_remarks] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enable_without_dc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extbranchcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO

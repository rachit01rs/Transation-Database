CREATE TABLE [dbo].[PaymentRule_Setup]
(
[sno] [int] NOT NULL IDENTITY(1, 1) PRIMARY KEY,
[agentType] [varchar] (200)  NULL,
[paymentType] [varchar] (200)  NULL,
[RequiredField1] [varchar] (200)  NULL,
[RequiredField2] [varchar] (200)  NULL,
[RequiredField3] [varchar] (200)  NULL,
[validation_msg] [varchar] (1000)  NULL,
[create_ts] [datetime] NULL,
[create_by] [varchar] (100)  NULL,
[update_by] [varchar] (100)  NULL,
[update_ts] [datetime] NULL,
[amount_if_more] [money] NULL,
[send_agent_country] [varchar] (150)  NULL,
[nos_of_days] [int] NULL
) 

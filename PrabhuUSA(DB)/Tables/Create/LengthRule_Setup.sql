/*
Date: 2011.Aug.24 Wed
*/

CREATE TABLE [dbo].[LengthRule_Setup]
(
[sno] [int] NOT NULL IDENTITY(1, 1) PRIMARY KEY,
[agentType] [varchar] (200)  NULL,
[paymentType] [varchar] (200)  NULL,
[RequiredField] [varchar] (200)  NULL,
[max_length] [varchar] (50)  NULL,
[min_length] [varchar] (50)  NULL,
[validation_msg] [varchar] (1000)  NULL,
[create_ts] [datetime] NULL,
[create_by] [varchar] (100)  NULL,
[update_ts] [datetime] NULL,
[update_by] [varchar] (100)  NULL
) 


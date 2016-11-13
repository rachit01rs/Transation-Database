/*
DATE : 2011.Aug.24 Wed
*/

CREATE TABLE [dbo].[Compliance_Setup]
(
[sno] [int] NOT NULL IDENTITY(1, 1) PRIMARY KEY,
[CountryName] [varchar] (150)  NULL,
[Block_Customer_Check_By] [varchar] (50)  NULL,
[Block_Max_TXN_AMT] [money] NULL,
[Block_Max_TXN_AMT_Days] [int] NULL,
[Block_CP_AMT_Sender] [char] (1)  NULL,
[Block_CP_AMT_Beneficiary] [char] (1)  NULL,
[Block_Max_TXN_No] [int] NULL,
[Block_Max_Txn_Nos_days] [int] NULL,
[Block_CP_No_Sender] [char] (1)  NULL,
[Block_CP_No_Beneficiary] [char] (1)  NULL,
[Max_App_Branch_Limit] [money] NULL,
[CP_If_TXN_Exceed_AMT] [money] NULL,
[Check_Dup1] [varchar] (50)  NULL,
[Check_Dup2] [varchar] (50)  NULL,
[Check_Dup3] [varchar] (50)  NULL,
[Check_Dup4] [varchar] (50)  NULL,
[Check_Dup5] [varchar] (50)  NULL,
[Hold_if_cash_date_ne_Txn_date] [char] (1)  NULL,
[Ofac_Enabled] [char] (1)  NULL,
[Disabled_Cust_info_Teller] [char] (1)  NULL,
[Max_po_amt_cash] [money] NULL,
[Max_po_amt_Deposit] [money] NULL,
[CP_Hold_PO_Cash] [money] NULL,
[CP_HOLD_PO_Deposit] [money] NULL,
[Created_By] [varchar] (50)  NULL,
[Created_ts] [datetime] NULL,
[Updated_By] [varchar] (50)  NULL,
[Updated_ts] [datetime] NULL,
[sender_nativeCountry_beneficiary_country_notsame] [varchar] (200)  NULL,
[require_security] [money] NULL,
[nos_of_branch_hold] [int] NULL,
[nos_of_branch_day] [int] NULL
) 


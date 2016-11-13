/*  
** Database    	: PrabhuUSA  
** Object     	: tbl_FTP_Import_File_Data  
** Purpose     	: Import data from different files and insert into tbl_FTP_Import_File_Data as dummy table using SSIS
** Author    	: Hari Saran Manandhar  
** Date     	: 25 July 2013  
** Modifications  :  
** Modified by	: Ranesh Ratna Shakya
** Date			: 25th Augest 2013
** desc			: Alter the table name and added few Column to handle Feedback txn . 
*/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT TABLE_CATALOG FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tbl_FTP_Import_File_Data') 
BEGIN
CREATE TABLE [dbo].[tbl_FTP_Import_File_Data](
	[Sno] [int] IDENTITY(1,1) NOT NULL,
	[PartnerID] [varchar](50) NULL,
	[PINNO] [varchar](20) NULL,
	[RemitterName] [varchar](100) NULL,
	[RemitterAddress] [varchar](200) NULL,
	[RemitterContact] [varchar](20) NULL,
	[RemitterCity] [varchar](100) NULL,
	[RemitterOccupation] [varchar](50) NULL,
	[RemitterCountry] [varchar](50) NULL,
	[RemitterIDType] [varchar](50) NULL,
	[RemitterIDNumber] [varchar](50) NULL,
	[Relationship] [varchar](50) NULL,
	[SourceOfFunds] [varchar](50) NULL,
	[PurposeOfRemittance] [varchar](50) NULL,
	[BeneficiaryName] [varchar](100) NULL,
	[BeneficiaryAddress] [varchar](200) NULL,
	[BeneficiaryContact] [varchar](20) NULL,
	[BeneficiaryIdType] [varchar](50) NULL,
	[BeneficiaryID] [varchar](50) NULL,
	[PayoutCountry] [varchar](50) NULL,
	[PayoutAMT] [money] NULL,
	[PayoutCCY] [char](3) NULL,
	[TransactionDate] [datetime] NULL,
	[LocationID] [varchar](50) NULL,
	[PaymentMode] [varchar](2) NULL,
	[BeneficiaryBankCode] [varchar](50) NULL,
	[BeneficiaryBankBranchCode] [varchar](50) NULL,
	[BeneficiaryBankBranchName] [varchar](100) NULL,
	[BankAccountNo] [varchar](50) NULL,
	[DataLoadDate] [datetime] NULL,
	[ProcessId] [varchar](200) NULL,
	[DataInsertedInMoneySend] [char](1) NULL,
	[FutureUse] [varchar](200) NULL,
	[FutureUse1] [varchar](200) NULL,
	[FutureUse2] [varchar](200) NULL,
	[Import_FileName] [varchar](100) NULL,
	[DataInsertedDate] [datetime] NULL,
	[Remarks] [varchar](200) NULL,	
	[Fg_txn_Status] [char](1) NULL
) ON [PRIMARY]

END

SET ANSI_PADDING OFF
GO



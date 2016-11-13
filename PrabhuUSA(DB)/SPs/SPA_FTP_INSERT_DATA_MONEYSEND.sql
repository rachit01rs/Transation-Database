IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[SPA_FTP_INSERT_DATA_MONEYSEND]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[SPA_FTP_INSERT_DATA_MONEYSEND]
GO
/*  
** Database    : PrabhuUSA  
** Object      : SPA_FTP_INSERT_DATA_MONEYSEND  
** Purpose     : Insert data to moneysend table from dummy table
** Author      : Hari Saran Manandhar  
** Date        : 28 July 2013  
** Modifications  :   
** Modified by : Ranesh Ratna Shakya
** Date        : 28 July 2013  

Flag
	i = just to validate the data which was imported from the file is according to our requirement or not.
	f = If the File Format is not correct and just to take the log.
	
*/
CREATE PROC SPA_FTP_INSERT_DATA_MONEYSEND
@flag CHAR(1),
@process_id VARCHAR(200)=NULL,
@filename VARCHAR(100)=NULL,
@PartnerID VARCHAR(50)=NULL
AS
DECLARE @totalcount INT
DECLARE @count INT,@tablename VARCHAR(100),@detail_errorMsg VARCHAR(200)

SET @tablename='tbl_FTP_Import_File_Data'       

IF @flag='i'
BEGIN
	--Create temporary table to log import status    
		 CREATE TABLE #import_status    
		  (    
		  temp_id int,    
		  process_id varchar(100),    
		  ErrorCode varchar(50),    
		  Module varchar(100),    
		  Source varchar(100),    
		  type varchar(100),    
		  [description] varchar(250),    
		  [nextstep] varchar(250)    
		  )    
-------------------- Total Count ---------------------------------------------------     
SELECT  @totalcount = COUNT(*),@filename=MAX(a.Import_FileName),@PartnerID=MAX(a.PartnerID)
FROM    dbo.[tbl_FTP_Import_File_Data] a WITH ( NOLOCK )
WHERE   DataInsertedInMoneySend IS NULL
        AND a.ProcessId = @process_id 
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--------------------- Validating Partner ID---------------------------------------------------
INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Partner Id is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND  RTRIM(LTRIM(ISNULL(PartnerID,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL

INSERT INTO #import_status    
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Partner ID invalid',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t ON a.Sno=t.temp_id
    LEFT OUTER JOIN dbo.static_values ad ON (a.PartnerID=ad.static_data AND ad.sno=501)
    WHERE a.DataInsertedInMoneySend IS NULL
    AND a.ProcessId=@process_id 
    AND t.temp_id IS NULL
    AND ad.sno IS NULL
    
INSERT INTO #import_status    
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Partner ID invalid',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t ON a.Sno=t.temp_id
    LEFT OUTER JOIN dbo.agentsub ad ON a.PartnerID=ad.agent_user_id
    WHERE a.DataInsertedInMoneySend IS NULL
    AND a.ProcessId=@process_id 
    AND t.temp_id IS NULL
    AND ad.agentCode IS NULL

-----------------------------------------------------------------------------------------------
 --- Payment mode check.
     INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payment Mode is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PaymentMode,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payment Mode is invalid',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(a.PaymentMode,''))) NOT IN ('C','B','D','E','N','H')
    AND a.ProcessId=@process_id AND a.DataInsertedInMoneySend IS NULL

		  
-----------------------------------------------------------------------------------------------
------------------------ start Validation -----------------------------------------------------------		     
--check for dublicate data in txn imported.
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Pin Number is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PINNO,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
  INSERT INTO #import_status 
  SELECT  min(a.sno),@process_id,'Error','Import Data','validate','Data Error',    
    'Duplicate data found in File Refno :'+ isnull(a.[pinno],'NULL'),    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id
     WHERE a.DataInsertedInMoneySend IS NULL
    AND a.ProcessId=@process_id 
    AND t.temp_id IS NULL
    GROUP BY a.[pinno]    
    HAVING count(*)>1 
  
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Duplicate data found in File Refno :'+ isnull(a.[pinno],'NULL'),    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN dbo.moneySend t WITH(NOLOCK)
    ON dbo.encryptDb(a.PINNO)=t.refno
     WHERE a.DataInsertedInMoneySend IS NULL
    AND a.ProcessId=@process_id 
    AND t.refno IS NOT NULL

--check for Mandotary Field in txn imported.
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter Name is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(RemitterName,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter Address is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(RemitterAddress,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter Country is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(RemitterCountry,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter ID Type is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(RemitterIDType,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter ID Number is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(RemitterIDNumber,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Beneficiary Name is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(BeneficiaryName,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Beneficiary Address is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(BeneficiaryAddress,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Beneficiary Contact is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(BeneficiaryContact,'')))=''
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL 
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout Country is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PayoutCountry,'')))='' 
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout Amount is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PayoutAMT,'')))='' 
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
    
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout Currency is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PayoutCCY,'')))=''
    AND a.ProcessId=@process_id  AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Transaction Date is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(TransactionDate,'')))='' 
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL
       
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout Branch ID is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(a.LocationID,'')))=''
    AND a.ProcessId=@process_id AND a.DataInsertedInMoneySend IS NULL
    AND RTRIM(LTRIM(ISNULL(a.PaymentMode,''))) NOT IN ('D','N')

    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout Currency or country is invalid.',    
    'Please check your data'     
    FROM dbo.tbl_FTP_Import_File_Data a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t ON a.Sno=t.temp_id 
    LEFT OUTER JOIN dbo.agentbranchdetail ab WITH(NOLOCK)  ON ab.agent_branch_Code=RTRIM(LTRIM(ISNULL(a.LocationID,'')))
    LEFT OUTER JOIN dbo.agentDetail ad WITH(NOLOCK) ON ad.agentCode=ab.agentCode  
    AND ad.Country = RTRIM(LTRIM(ISNULL(a.PayoutCountry,'')))
    AND  ad.CurrencyType = RTRIM(LTRIM(ISNULL(a.PayoutCCY,'')))   
    WHERE t.temp_id IS NULL AND ad.agentCode IS NULL
    AND a.ProcessId=@process_id AND a.DataInsertedInMoneySend IS NULL
 
  --check for Mandotary Field in txn imported FOR NEFT.
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Relationship is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(Relationship,'')))=''
    AND a.ProcessId=@process_id AND PaymentMode='N' AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Source Of Funds is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(SourceOfFunds,'')))=''
    AND a.ProcessId=@process_id AND PaymentMode='N' AND DataInsertedInMoneySend IS NULL
    
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Purpose Of Remittance is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PurposeOfRemittance,'')))=''
    AND a.ProcessId=@process_id AND PaymentMode='N' AND DataInsertedInMoneySend IS NULL
 
 --check for Mandotary Field in txn imported FOR ADTOB.
--  INSERT INTO #import_status 
--  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
--    'Beneficiary Bank Code is missing',    
--    'Please check your data'     
--    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
--    LEFT OUTER JOIN #import_status t
--    ON a.Sno=t.temp_id    
--    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(BeneficiaryBankCode,'')))=''
--    AND a.ProcessId=@process_id AND PaymentMode='D' AND DataInsertedInMoneySend IS NULL
--   INSERT INTO #import_status 
--  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
--    'Beneficiary Bank Name is missing',    
--    'Please check your data'     
--    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
--    LEFT OUTER JOIN #import_status t
--    ON a.Sno=t.temp_id    
--    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(a.BeneficiaryBankName,'')))=''
--    AND a.ProcessId=@process_id AND a.PaymentMode='D' AND a.DataInsertedInMoneySend IS NULL
    
    --check for Mandotary Field in txn imported FOR ADTOB,NEFT,BT. 
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Beneficiary Bank Branch Code is missing',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(a.BeneficiaryBankBranchCode,'')))=''
    AND a.ProcessId=@process_id AND a.PaymentMode='N' AND a.DataInsertedInMoneySend IS NULL
         
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'NFET Payment Type allowed only in country INDIA',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND RTRIM(LTRIM(ISNULL(PayoutCountry,'')))<>'INDIA'
    AND a.ProcessId=@process_id AND PaymentMode IN ('N') AND DataInsertedInMoneySend IS NULL
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Transaction Date is invalid Must be YYYY-MM-DD',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND ISDATE(a.TransactionDate) = 0
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL 
    
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout Amount must be numeric value',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id    
    WHERE t.temp_id IS NULL AND ISNUMERIC(a.PayoutAMT)=0
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL 
    
    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'PURPOSE OF REMITTANCE is didnot matched, please verify with the List',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id 
    LEFT OUTER JOIN static_values s WITH(NOLOCK)
    ON ( RTRIM(LTRIM(ISNULL(a.PurposeOfRemittance,'')))=s.static_data AND ISNULL(s.static_data,'')<>'' AND s.sno=15 
    AND RTRIM(LTRIM(ISNULL(a.PurposeOfRemittance,'')))<>'')
    WHERE t.temp_id IS NULL AND s.static_data IS NULL
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL 
    
  INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter ID Type is didnot matched, please verify with the List',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id 
    LEFT OUTER JOIN static_values s WITH(NOLOCK)  
    ON ( RTRIM(LTRIM(ISNULL(a.RemitterIDType,'')))=s.static_data AND ISNULL(s.static_data,'')<>'' AND s.sno=8 
    AND RTRIM(LTRIM(ISNULL(a.RemitterIDType,'')))<>'')
    WHERE t.temp_id IS NULL AND s.static_data IS NULL
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL 
    
   INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Remitter Occupation is didnot matched, please verify with the List',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id 
    LEFT OUTER JOIN static_values s WITH(NOLOCK)  
    ON (RTRIM(LTRIM(ISNULL(a.RemitterOccupation,'')))=s.static_data AND ISNULL(s.static_data,'')<>'' AND s.sno=31 
    AND RTRIM(LTRIM(ISNULL(a.RemitterOccupation,'')))<>'')
    WHERE t.temp_id IS NULL AND s.static_data IS NULL
    AND a.ProcessId=@process_id AND DataInsertedInMoneySend IS NULL 

    INSERT INTO #import_status 
  SELECT  a.sno,@process_id,'Error','Import Data','validate','Data Error',    
    'Payout BANK Code is invalid, please verify with the List',    
    'Please check your data'     
    FROM dbo.[tbl_FTP_Import_File_Data] a WITH(NOLOCK) 
    LEFT OUTER JOIN #import_status t
    ON a.Sno=t.temp_id 
    LEFT OUTER JOIN dbo.agentbranchdetail ab WITH(NOLOCK) ON ab.agent_branch_Code= a.LocationID
    LEFT OUTER JOIN commercial_bank C WITH(NOLOCK)  
    ON (RTRIM(LTRIM(ISNULL(a.BeneficiaryBankCode,'')))=C.Commercial_id 
    AND c.payout_agent_id=ab.agentCode)
    WHERE t.temp_id IS NULL AND c.Commercial_id IS NULL
    AND a.ProcessId=@process_id AND a.DataInsertedInMoneySend IS NULL AND a.PaymentMode='D'
   
------------------------ end Validation -----------------------------------------------------------		     
-----------------------------------------------------------------------------------------------------
			
--		IF @totrec > 0
--				INSERT INTO [moneySend]
--				   ([refno],[agentid],[SenderName],[SenderAddress],[SenderPhoneno],[SenderCity],[SenderCountry]
--				   ,[senderFax],[senderPassport],[ReceiverRelation],[source_of_income],[reason_for_remittance]
--				   ,[ReceiverName],[ReceiverAddress],[ReceiverPhone],[ReceiverIDDescription],[ReceiverID]
--				   ,[ReceiverCountry],[TotalRoundAmt],[paidCType],[DOT],[expected_payoutagentid],[rBankID]
--				   ,[paymentType],[ben_bank_id],[ben_bank_name],[ben_bank_branch_id]
--				   ,[rBankAcType],[rBankACNo],[process_id])
--				 SELECT 
--				   [PINNO],[PartnerID],[RemitterName],[RemitterAddress],[RemitterContact],[RemitterCity],[RemitterCountry]
--				  ,[RemitterIDType],[RemitterIDNumber],[Relationship],[SourceOfFunds],[PurposeOfRemittance]
--				  ,[BeneficiaryName],[BeneficiaryAddress],[BeneficiaryContact],[BeneficiaryIdType],[BeneficiaryID]
--				  ,[PayoutCountry],[PayoutAMT],[PayoutCCY],[TransactionDate],[PayoutAgentID],[PayoutBranchID]
--				  ,[PaymentMode],[BeneficiaryBankCode],[BeneficiaryBankName],[BeneficiaryBankBranchCode]
--				  ,[BeneficiaryBankBranchName],[BankAccountNo],[ProcessId]
--				 FROM [dbo].[tbl_FTP_Import_File_Data]
--				 WHERE DataInsertedInMoneySend IS NULL
				 
				 
	-----Info of txn error or Success.			 
	FinalStep: 
	 
	  set @count=(select count(distinct temp_id) from #import_status)    
	  if @count>0    
	  begin    
	   if @totalcount>0    
		select @detail_errorMsg = cast(@totalcount-@count as varchar(100))+' Data imported Successfully out of '+cast(@totalcount as varchar(100))+'. Some Error found while importing. Please review Errors'    
	   else    
		select @detail_errorMsg = cast(@totalcount as varchar(100))+' Data imported Successfully. Some Error found while importing. Please review Errors'    

		insert into data_import_status(process_id,code,module,source,    
		type,[description],recommendation)     
		select @process_id,'Error','Import Data',@tablename,@filename,@detail_errorMsg,@PartnerID 	       
	  end    
	  else    
	  begin    
	   select @detail_errorMsg = cast(ISNULL(@totalcount,0)-ISNULL(@count,0) as varchar(100))+' Data imported Successfully out of '+cast(ISNULL(@totalcount,0) as varchar(100))    
	       
	   insert into data_import_status(process_id,code,module,source,    
		type,[description],recommendation)     
		select @process_id,'Success','Import Data',@tablename,@filename,@detail_errorMsg,@PartnerID   
	  end  
	  
	   UPDATE   dbo.tbl_FTP_Import_File_Data
	   SET      DataInsertedInMoneySend = CASE WHEN m.temp_id IS NULL THEN 'P'
											   ELSE 'F'
										  END ,
				Remarks = CASE WHEN m.temp_id IS NULL
							   THEN 'SUCCESSFULLY IMPORTED.TXN IS IN PROCESS FOR NEXT STEP.'
							   ELSE m.[description]
						  END
	   FROM     tbl_FTP_Import_File_Data t
				LEFT OUTER JOIN #import_status m ON t.Sno = m.temp_id
	   WHERE    DataInsertedInMoneySend IS NULL
				AND ProcessId = @process_id 
	 EXEC spa_temp_FTP_moneysend
  
END
IF @flag='f'
	BEGIN	
	  SELECT    @detail_errorMsg = '0 Data imported Successfully out of 0. Invalid the File Format'    			 
	  INSERT    INTO data_import_status
				( process_id ,
				  code ,
				  module ,
				  source ,
				  TYPE ,
				  [description] ,
				  recommendation
				)
				SELECT  @process_id ,
						'Error' ,
						'Import Data' ,
						@tablename ,
						@filename ,
						@detail_errorMsg ,
						@PartnerID 	
			
	  INSERT    INTO dbo.tbl_FTP_Import_File_Data
				( PartnerID ,
				  ProcessId ,
				  DataInsertedInMoneySend ,
				  Import_FileName ,
				  DataLoadDate ,
				  Remarks 
			        
				)
	  VALUES    ( @partnerID ,
				  @process_id ,
				  'F' ,
				  @fileName ,
				  GETDATE() ,
				  'Invalid the File Format.Please check the data.'
				)
	END

IF @flag='s'				 
BEGIN
	SELECT * FROM tbl_FTP_Import_File_Data t WITH (NOLOCK) 
	WHERE CASE WHEN @PartnerID IS NULL THEN '1' ELSE PartnerID END =ISNULL(@PartnerID,'1')
	AND DataInsertedInMoneySend='P'
END


IF @flag='a'				 
BEGIN
	SELECT * FROM tbl_FTP_Import_File_Data t WITH (NOLOCK) 
	WHERE CASE WHEN @PartnerID IS NULL THEN '1' ELSE PartnerID END =ISNULL(@PartnerID,'1')
	AND DataInsertedInMoneySend='T'
END

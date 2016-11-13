IF OBJECT_ID('spa_Export_Indus_Bank','P') IS NOT NULL
DROP PROCEDURE	spa_Export_Indus_Bank
GO
/****** Object:  StoredProcedure [dbo].[spa_Export_Indus_Bank]    Script Date: 05/28/2013 16:24:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO    
/*    
** Database    : PrabhuUSA    
** Object     : spa_Export_Indus_Bank    
** Purpose     : Export To Indusind Bank    
** Author    : Hari Saran Manandhar    
** Date     : 25 May 2013    
** Modifications  :
	modified by : Ranesh Ratna Shakya
	added special character Replace funtion  
--  spa_Export_Indus_Bank null,'test','20100001',NULL,NULL,NULL,'342343:34543','234234324231sdfsd','test123','3334'
    
*/    
CREATE PROC [dbo].[spa_Export_Indus_Bank]        
 @check CHAR(1)=NULL,        
 @login_user_id VARCHAR(50) ,        
 @branch_id VARCHAR(50)=NULL ,        
 @fromdate VARCHAR(50),        
 @todate VARCHAR(50),        
 @ddDate VARCHAR(50),        
 @ditital_id VARCHAR(200) = NULL ,        
 @process_id VARCHAR(150) ,        
 @batch_Id VARCHAR(100) = NULL,        
 @agent_id VARCHAR(50)=NULL,         
    @status VARCHAR(50)=NULL ,        
    @paymentType VARCHAR(50) = NULL         
    AS         
    SET XACT_ABORT ON ;          
    BEGIN TRY          
          
        DECLARE @desc VARCHAR(max)          
        DECLARE @ledger_tabl VARCHAR(max) ,        
            @sql VARCHAR(MAX)          
          
        DECLARE @expected_payoutagentid VARCHAR(50) ,        
            @rBankID VARCHAR(50) ,        
            @rBankName VARCHAR(200) ,        
            @rBankBranch VARCHAR(200) ,        
            @GMT_Date DATETIME ,        
            @cover_fund MONEY ,        
            @payout_fund_limit CHAR(1),        
            @total_row INT,      
            @Principal_Exchange_ID VARCHAR(4),      
            @Origin_Country_Code VARCHAR(2),      
            @TellerUserId VARCHAR(10)    
  
        SELECT  @expected_payoutagentid = a.agentcode ,        
                @rBankID = b.agent_branch_code ,        
                @rBankName = a.companyName ,        
                @rBankBranch = b.Branch        
       
              --  @cover_fund = a.currentBalance - ISNULL(Account_No_IB,0)        
        FROM    agentdetail a        
                JOIN agentbranchdetail b ON a.agentcode = b.agentcode        
        WHERE   agent_branch_code = @branch_id          
                         
       --------------------------------------------------------------------------------------        
       SET @expected_payoutagentid='20100151'  ----- Prabhu UAT Server      
       SET @GMT_Date =dbo.getDateHO(GETUTCDATE())       
       SET @Principal_Exchange_ID = 'PRBH'      
       SET @Origin_Country_Code ='US'      
       SET @TellerUserId ='PRBHADM2'      
       --------------------------------------------------------------------------------------        
          
        BEGIN TRANSACTION  trans        
   SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @login_user_id,        
                                             @process_id)         
                      
       SET @sql = '        
  SELECT m.*,b.ext_branch_code INTO #TEMP          
  FROM moneysend m with(nolock)         
  LEFT OUTER JOIN agentbranchdetail b with(nolock) on m.rBankID=b.agent_branch_code
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid          
  WHERE expected_payoutagentid='''+@expected_payoutagentid+'''         
  AND Transstatus = ''Payment''        
  AND ISNULL(a.disable_payout,''n'')<>''y'''        
  IF @check='1'        
   BEGIN        
    SET @sql = @sql+' AND confirmDate BETWEEN         
     '''+@fromDate+''' AND '''+@toDate+''''        
    SET @sql = @sql+' AND is_downloaded IS NOT NULL AND status IN (''Post'')'        
   END        
  ELSE        
   BEGIN        
    SET @sql=@sql+' AND is_downloaded is null AND status =''Un-Paid'''        
   END        
          
  SET @sql=@sql+'        
  order by confirmDate        
            
 SELECT * INTO '+@ledger_tabl+' FROM (        
 SELECT ''1'' +''|''+--AS [Header Details Identifier],        
  LEFT(CAST(MAX(TRANNO) AS VARCHAR),8) +''|''+--AS [File/Batch number],        
  LEFT(CONVERT(VARCHAR(11),getdate(),110),10) +''|''+--AS [Upload Date/File Date/Batch Date],        
  Cast(count(*) as varchar) +''|'' [Records] --AS [Number of records in File excluding header]         
  FROM #temp        
  union all        
  SELECT ''2''    +''|''+--as [Header Details Identifier],      --MANDATORY        
  LEFT(CONVERT(VARCHAR(11),(isnull(confirmdate,'''')),110),10) +''|''+--as [Transaction Date],        
  LEFT(dbo.decryptdb(refno),15)   +''|''+--as [Exchange House Reference Number], --MANDATORY  BLANK        
  LEFT('''',20) +''|''+--as [Customer Code],        
  LEFT(ISNULL(senderName,''NA''),35) +''|''+--as [Customer Name ],                  --MANDATORY        
  LEFT(ISNULL(senderNativeCountry,''''),15) +''|''+--as [Customer Nationality],        
  LEFT(ISNULL([dbo].[FNAReplaceSpecialChars](senderAddress,'' ''),''NANANA''),35)     +''|''+--as [Customer Address 1],    --MANDATORY        
  LEFT(ISNULL([dbo].[FNAReplaceSpecialChars](senderAddress,'' ''),''NANANA''),35)    +''|''+--as [Customer Address 2],     --MANDATORY BLANK        
  LEFT(ISNULL(senderCity,''NA''),35) +''|''+--as [City],      --MANDATORY      
  LEFT(ISNULL(Sender_State,''NA''),35) +''|''+--as [State],        --MANDATORY        
  LEFT(ISNULL(senderCountry,''NA''),35) +''|''+--as [Country],       --MANDATORY        
  ''''     +''|''+--as [Zip Code],          --BLANK        
  LEFT(ISNULL(SenderPhoneno,''''),15)     +''|''+--as [Customer Telephone No.],        
  LEFT(ISNULL(SenderEmail,''''),50)  +''|''+--as [Customer E-mail],        
  LEFT(ISNULL(senderpassport,CustomerId),30)  +''|''+--as [Customer PIN (Personal Identification Number)],--MANDATORY        
  LEFT(ISNULL(senderfax,''Id Card''),20)   +''|''+--as [Type of PIN],      --MANDATORY        
  LEFT('''',35)   +''|''+--as [Place of Issue],        
  LEFT(CONVERT(VARCHAR(11),(isnull(ID_Issue_date,'''')),110),10)     +''|''+--as [Date of Issue],        
  LEFT(CONVERT(VARCHAR(11),dbo.getDateHO(GETUTCDATE())+5,110),10) +''|''+--as [Expiry Date],        --BLANK        
  CASE        
   WHEN reason_for_remittance IN (''INVESTMENT IN REAL ESTATE'',''INVESTMENT IN SECURITIES'') THEN ''P105''         
   WHEN reason_for_remittance IN (''INVESTMENT IN EQUITY SHARES'',''REPAYMENT OF LOANS'') THEN ''P104''  
   WHEN reason_for_remittance IN (''BUSINESS TRAVEL'',''INSURANCE PREMIUM'',''OTHER REMITTANCES'') THEN ''P103''         
   WHEN reason_for_remittance IN (''FAMILY MAINTENANCE/SAVINGS'',''INTEREST ON LOANS'',''REPATRIATION OF BUSINESS PROFITS'') THEN ''P101''  
   WHEN reason_for_remittance =''TRADE REMITTANCES'' THEN ''P110''         
   WHEN reason_for_remittance IN (''EDUCATIONAL EXPENSES'',''HOTEL EXPENSESS'') THEN ''P106''         
  ELSE ''P107'' END +''|''+--as [Purpose],--MANDATORY    
  ''''   +''|''+--as [Beneficiary Code],       --BLANK        
  LEFT(ISNULL(ReceiverName,''NA''),35) +''|''+--as [Beneficiary Name],    --MANDATORY        
  LEFT(ISNULL([dbo].[FNAReplaceSpecialChars](ReceiverAddress,'' ''),''NA''),75) +''|''+--as [Beneficiary Address 1],        
  ''''   +''|''+--as [Beneficiary Address 2],     --BLANK        
  LEFT('''',35)   +''|''+--as [Beneficiary City],        
  ''''   +''|''+--as [Beneficiary State],     --BLANK          
  LEFT(ISNULL(ReceiverCountry,''''),35)    +''|''+--as [Beneficiary Country],        
  ''''    +''|''+--as [Beneficiary Zip],    --BLANK        
  LEFT(ISNULL(ReceiverPhone,''''),15) +''|''+--as [Telephone],        
  LEFT(ISNULL(receiverEmail,''''),50) +''|''+--as [E-mail],        
  ISNULL(rBankACNo,''NA'')  +''|''+--as [Beneficiary Bank A/c Number],--MANDATORY      
  ''INDUSIND BANK''  +''|''+--as [Beneficiary Bank Name],      
  ''''    +''|''+--as [Beneficiary Bank Branch Name],      
  ''''    +''|''+--as [Beneficiary Bank City],   --BLANK        
  ''''   +''|''+--as [Beneficiary Bank State],   --BLANK        
  ''INDIA''    +''|''+--as [Beneficiary Bank Country], --BLANK       
  LEFT('''',75) +''|''+--as [Delivery Address 1],--MANDATORY        
  ''''  +''|''+--as [Delivery Address 2],--MANDATORY   --BLANK        
  LEFT('''',35) +''|''+--as [Delivery City],--MANDATORY        
  ''''  +''|''+--as [Delivery State],--MANDATORY    --BLANK        
  LEFT('''',35) +''|''+--as [Delivery Country],--MANDATORY        
  '''' +''|''+--as [Delivery Zip],--MANDATORY      --BLANK        
  LEFT('''',15) +''|''+--as [Delivery Telephone],        
  LEFT('''',50)   +''|''+--as [Delivery E-mail],        
  ''''   +''|''+--as [Delivery Landmark],     --BLANK        
  CASE        
   WHEN paymenttype=''RTGS'' THEN ''2''   
   WHEN paymenttype=''NEFT'' THEN ''3''         
  ELSE ''1'' END +''|''+--as [Product Type],--MANDATORY        
  LEFT(ISNULL(totalRoundamt,0),14) +''|''+--as [Origin. Amount],--MANDATORY    --2 for decimal  places included        
  ''0.00'' +''|''+--as [Origin. Charge],    --BLANK       
  ''INR''   +''|''+--as [Destination Currency Code],      
  LEFT(isnull(totalRoundamt,''''),14) +''|''+--as [Destination Amount],--MANDATORY 2 for decimal  places included        
  ''1.00''     +''|''+--as [Exchange Rate],        
  '''+@Principal_Exchange_ID +'''+''|''+--as [Principal Exchange ID],--MANDATORY  --BLANK        
  '''+@Origin_Country_Code +''' +''|''+--as [Origin. Country Code],--MANDATORY        
  ''''  +''|''+--as [Origin. Agent Code],  --BLANK         
  '''' +''|''+--as [Origin. Agent Branch Code],   --BLANK        
  '''+@TellerUserId +''' +''|''+--as [UserID],--MANDATORY        
  ''INR''  +''|''+--as [Origin. Currency Code] ,--MANDATORY  --BLANK         
  ''IN'' +''|''+--as [Destination Country Code],  
  '''' +''|''+--as [Correspondent Code],  
  '''' +''|''+--as [Correspondent Branch Code],        
  LEFT(CASE WHEN paymenttype=''Bank Transfer'' THEN ISNULL(ext_branch_code,''NA'')   
  Else ISNULL(rBankAcType,''NA'') end,11) +''|''+--as [IFSC Code],        
  '''' +''|''+--as [Delivery Location],        
  '''' +''|''--as [Delivery State]              
  FROM #temp) t        
    
  INSERT #temp_total_amount(total_amount,total_row) SELECT sum(totalroundamt),count(*) FROM #temp    
  UPDATE moneysend set status=''Post'',is_downloaded=''y'',downloaded_by='''+ @login_user_id + ''',downloaded_ts=dbo.getDateHO(GETUTCDATE())        
  FROM moneysend m with(nolock) JOIN #temp t  WITH (NOLOCK) ON m.Tranno=t.tranno 
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid    
  WHERE ISNULL(a.disable_payout,''n'')<>''y'''         
    
 DECLARE @total_amount MONEY          
 CREATE TABLE #temp_total_amount(total_amount MONEY,total_row int )  
    
  PRINT (@sql)         
   
  EXEC(@sql)         
  
print(@batch_id)  
  
  SELECT  @total_amount = total_amount,@total_row = total_row         
  FROM    #temp_total_amount          
          
  DECLARE @url_desc VARCHAR(500)          
  SET @url_desc = ''         
              
  SET @desc = '<strong><u>INDUS BANK DOWNLOAD</u></strong> '        
            + ' is completed.  TXN Found: <strong><u>'        
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong>  Total Amount: <strong><u>'        
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)+ '</u></strong>'        
  IF @check IS NOT NULL          
 BEGIN          
  SET @desc = @desc + ' from Time:' + @fromdate + ' To ' + @todate + ' (Re-Downloaded)'           
 END         
  ELSE          
    BEGIN          
  SET @desc = @desc + ' Local Time: ' + CONVERT(VARCHAR,@GMT_Date, 120)          
 END           
      
   EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc,        
            'c', @process_id, NULL, @url_desc          
     
 DROP TABLE #temp_total_amount         
       COMMIT TRANSACTION  trans        
    END TRY          
        
    BEGIN CATCH          
        IF @@trancount > 0         
           ROLLBACK TRANSACTION  trans        
          
        SET @desc = 'SQL Error found:  (' + ERROR_MESSAGE() + ')'          
           
        INSERT  INTO [error_info]        
                ( [ErrorNumber] ,        
                  [ErrorDesc] ,        
                  [Script] ,        
                  [ErrorScript] ,        
                  [QueryString] ,        
                  [ErrorCategory] ,        
                  [ErrorSource] ,        
                  [IP] ,        
                  [error_date]        
                )        
                SELECT  -1 ,        
                        @desc ,      
                        @batch_id ,      
                        'spa_Export_Indus_Bank' ,     
                        @desc ,      
                        'SQL' ,      
                        'SP' ,      
                        @ditital_id ,      
                        GETDATE()         
        SELECT  'ERROR' ,        
				'1050' ,        
                'Error Please try again'          
          
    END CATCH
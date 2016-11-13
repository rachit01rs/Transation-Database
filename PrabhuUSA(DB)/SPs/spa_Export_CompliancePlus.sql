IF OBJECT_ID('spa_Export_CompliancePlus', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.spa_Export_CompliancePlus
GO
--spa_Export_BankAsia 'Bank Transfer','2010-09-28 00:00:00:000','2011-09-28 23:59:59.999','1','AG:ranesh1','543sfsdfsdf1','Export_BankAsia','test=2&test=1'
CREATE PROCEDURE dbo.spa_Export_CompliancePlus
    @trn_type VARCHAR(50) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL ,
    @check CHAR(1) = NULL ,
    @login_user_id VARCHAR(50) = NULL ,
    @process_id VARCHAR(100) = NULL ,
    @batch_id VARCHAR(100) = NULL ,
    @url_desc VARCHAR(5000) = NULL
AS 
 SET NOCOUNT ON
    DECLARE @sql VARCHAR(MAX) ,
        @ledger_tabl VARCHAR(100) ,
        @expected_payoutagentid VARCHAR(50) ,
        @today VARCHAR(50) ,
        @msg_agenttype VARCHAR(200) ,
        @desc VARCHAR(5000),
        @total_amount MONEY,
        @total_row INT,@agent_name VARCHAR(100),@sequence VARCHAR(50),@MoneyTransferCode CHAR(4)
        SET @MoneyTransferCode='PGI'

	-----------------------------------------------
    SET @today = dbo.getDateHO(GETUTCDATE())
    SET @agent_name='Compliance Plus Export'
	-----------------------------------------------
	--------------------------------------------------
	------Creating the Temp Table Name----------------
    SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, REPLACE(@login_user_id,':','_'),
                                         @process_id)
	--------------------------------------------------

	
    SET @sql = '
    SELECT  
    '''+CAST(@MoneyTransferCode AS CHAR(4))+''' [MONEY TRANSMITTER CODE],
CAST(m.branch_code AS CHAR(15)) [AGENT CODE],
CAST(dbo.decryptDb(m.refno) AS CHAR(15)) [INVOICE NUMBER],
CASE WHEN status=''Paid'' THEN CAST(''A'' AS CHAR(10)) WHEN status IN (''Un-Paid'',''Post'') THEN CAST(''V'' AS CHAR(10))
ELSE CAST('''' AS CHAR(10)) END [INVOICE STATUS],
CAST('''' AS CHAR(15)) [Sender Internal Code],
CAST(ISNULL(m.SenderName,'''') AS CHAR(60)) [Sender Full Name],
CAST(REPLACE(ISNULL(m.SenderAddress,''''),''[t]'','''') AS CHAR(80)) [Sender Address],
CAST(ISNULL(m.SenderPhoneno,'''') AS CHAR(20)) [Sender Phone1],
CAST(ISNULL(m.sender_mobile,'''') AS CHAR(20)) [Sender Phone2],
CAST(ISNULL(m.SenderZipCode,'''') AS CHAR(5)) [Sendez Zip Code],
CAST(ISNULL(m.SenderCity,'''') AS CHAR(20)) [Sender City code],
CAST(ISNULL(m.Sender_State,'''') AS CHAR(20)) [Sender State code],
CAST(ISNULL(m.SenderCountry,'''') AS CHAR(20)) [Sender Country code],
CAST(ISNULL(m.senderFax,'''') AS CHAR(20)) [Sender type of ID-1],
CAST(ISNULL(m.senderPassport,'''') AS CHAR(20)) [Sender ID-1 Number],
CAST('''' AS CHAR(20)) [Sender Type of ID-2],
CAST('''' AS CHAR(20)) [Sender ID-2 Number],
CAST('''' AS CHAR(20)) [Receiver Internal Code],
CAST(ISNULL(m.ReceiverName,'''') AS CHAR(60)) [Receiver Full Name],
CAST(ISNULL(m.ReceiverAddress,'''') AS CHAR(80)) [Receiver Address],
CAST(ISNULL(m.ReceiverPhone,'''') AS CHAR(20)) [Receiver Phone1],
CAST(ISNULL(m.receiver_mobile,'''') AS CHAR(20)) [Receiver Phone2],
CAST(ISNULL('''','''') AS CHAR(5)) [Receiver Zip Code],
CAST(ISNULL(m.ReceiverCity,'''') AS CHAR(20)) [Receiver City Code],
CAST('''' AS CHAR(20)) [Receiver State Code],
CAST(ISNULL(m.ReceiverCountry,'''') AS CHAR(20)) [Receiver Country Code],
CONVERT(CHAR(10), m.confirmDate, 101) [INVOICE DATE],
dbo.FNAAddFrontSpecialCharFormatAlfaNumeric(TotalRoundAmt,15,'''') [AMOUNT SENT],
CASE WHEN m.paymentType IN ('''') THEN CAST(''Deposit'' AS CHAR(10))
WHEN m.paymentType='''' THEN CAST(''Office'' AS CHAR(10))
WHEN m.paymentType='''' THEN CAST(''delivery'' AS CHAR(10))
ELSE CAST(''Deposit'' AS CHAR(10)) END [PAYMENT MODE],
CAST(''Agent IS'' AS CHAR(15)) [CORRESPONDENT ID],
CASE WHEN m.paymentType=''Bank Transfer'' THEN CAST(m.rBankName AS CHAR(60))
WHEN m.paymentType=''Account Deposit to Other Bank'' THEN CAST(m.ben_bank_name AS CHAR(60))
ELSE CAST('''' AS CHAR(60)) END [BANK NAME],
CAST(ISNULL(rBankACNo,'''') AS CHAR(30)) [ACCOUNT NUMBER],
CAST(ISNULL(SenderCity,'''') AS CHAR(60)) [Sender City Name],
CAST(ISNULL(Sender_State,'''') AS CHAR(60)) [Sender State Name],
CAST(ISNULL(SenderCountry,'''') AS CHAR(60)) [Sender Country Name],
CAST(ISNULL(ReceiverCity,'''') AS CHAR(60)) [Receiver City Name],
CAST(ISNULL('''','''') AS CHAR(60)) [Receiver State Name],
CAST(ISNULL(ReceiverCountry,'''')  AS CHAR(60)) [Receiver Country Name],
CAST(ISNULL(a.Branch,'''') AS CHAR(60)) [Agent Name],
CAST(ISNULL(a.Address,'''') AS CHAR(80)) [Agent Address1],
CAST(ISNULL(a.City,'''') AS CHAR(60)) [Agent City Name],
CAST(ISNULL(a.state_branch,'''') AS CHAR(60)) [Agent State Name],
CAST(ISNULL(a.Country,'''') AS CHAR(60)) [Agent Country Name],
CAST('''' AS CHAR(20)) [Agent Zip],
CAST(ISNULL(a.district_code,'''') AS CHAR(20)) [Agent Phone1],
CAST('''' AS CHAR(20)) [Agent Phone2]
    INTO    ' + @ledger_tabl
        + '
    FROM    moneysend m WITH (NOLOCK)
            JOIN dbo.agentbranchdetail a WITH (NOLOCK) ON m.Branch_code=a.agent_branch_Code
            JOIN dbo.agentDetail ad WITH(NOLOCK) ON m.agentid=ad.agentCode  
    WHERE  (a.is_compliancePlus=''y'' or ad.is_compliancePlus=''y'') AND Transstatus = ''Payment'''
           IF @expected_payoutagentid IS NOT NULL
				 SET @sql = @sql + ' and expected_payoutagentid = ''' + @expected_payoutagentid +''''
             SET @sql = @sql + ' AND m.confirmDate BETWEEN ''' + @fromDate
                + ''' AND ''' + @toDate + ''''
     
         SET @sql = @sql + ' INSERT #temp_total_amount(total_amount,total_row) SELECT sum(cast([AMOUNT SENT] as money)),count(*) FROM ' + @ledger_tabl
        CREATE TABLE #temp_total_amount(total_amount MONEY,total_row int )  
		
 --PRINT(@sql)            
    EXEC (@sql)

  SELECT  @total_amount = total_amount,@total_row = total_row           
  FROM    #temp_total_amount 
  
	SET @msg_agenttype=' '
	--SET @url_desc=ISNULL(@url_desc,'Null')
           
   -- IF @check IS NOT NULL
	--	BEGIN
 			--SET @sequence='ReDownloaded'
			SET @msg_agenttype = ' From: ' + @fromDate + ' To: ' + @toDate --+ ' (Re-Downloaded)'    	
	--	END 
    --ELSE
	--	BEGIN
	--		SET @msg_agenttype = ' Till ' + @today
	--		SELECT @sequence=dbo.FNAExportSequenceNumber(@expected_payoutagentid)
	--	END
	---SET @url_desc='Sequence=' + @sequence+ '&TotalAmount='+CAST(@total_amount AS VARCHAR(20))+'&TxnDate='+REPLACE(CONVERT(VARCHAR(10),GETDATE(),103),'-','/')+'&'  
            
    SET @desc = '<strong><u>'+@agent_name+' DOWNLOAD</u></strong> '          
            + ' is completed.  TXN Found: <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong>  Total Amount: <strong><u>'          
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)+ '</u></strong> '  + @msg_agenttype 

    --PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
    --    '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, @url_desc
------------------------------------------------------------------------------------------------
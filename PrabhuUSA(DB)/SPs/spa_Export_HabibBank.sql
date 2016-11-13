IF OBJECT_ID('spa_Export_HabibBank', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.spa_Export_HabibBank
GO
--spa_Export_BankAsia 'Bank Transfer','2010-09-28 00:00:00:000','2011-09-28 23:59:59.999','1','AG:ranesh1','543sfsdfsdf1','Export_BankAsia','test=2&test=1'
CREATE PROCEDURE dbo.spa_Export_HabibBank
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
    BEGIN TRY 
    DECLARE @sql VARCHAR(MAX) ,
        @ledger_tabl VARCHAR(100) ,
        @expected_payoutagentid VARCHAR(50) ,
        @today VARCHAR(50) ,
        @msg_agenttype VARCHAR(200) ,
        @desc VARCHAR(5000),
        @total_amount MONEY,
        @total_row INT,@sequence VARCHAR(50)
	-----------------------------------------------
    SET @expected_payoutagentid = '20100003'--'20100098'--Local--'20100135'--UAT--'20100270'--LIVE
    SET @today = dbo.getDateHO(GETUTCDATE())
	-----------------------------------------------
	--------------------------------------------------
	------Creating the Temp Table Name----------------
   begin transaction TXN 
    SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, REPLACE(@login_user_id,':','_'),
                                         @process_id)
	--------------------------------------------------
	
    SET @sql = '
    SELECT  '':10:''+''PRABHU'' [Company_Code],
'':20:''+ISNULL(dbo.decryptDB(refno),'''') [Reference_No],
LTRIM(RTRIM('':32A:''+ISNULL(CAST(REPLACE(CONVERT(VARCHAR(10),confirmDate,103),''/'','''') AS VARCHAR),''''))) [Value_Date],
LTRIM(RTRIM('':32B:''+ISNULL(receiveCType,''''))) [Currency_Code],
'':32C:''+CAST(CONVERT(DECIMAL(12,2),TotalRoundAmt) AS VARCHAR) [Amount],
'':50:''+LEFT(SenderName,35)[Remitter_Name],
LTRIM(RTRIM('':57A:''+ISNULL(case when LOWER(paymentType)=''account deposit to other bank'' THEN ben_bank_name 
when LOWER(paymentType)=''bank transfer'' THEN rBankName ELSE '''' END ,''N/A''))) [Beneficiary_Bank_Name],
LTRIM(RTRIM('':57B:''+ISNULL(case when LOWER(paymentType)=''account deposit to other bank'' THEN rBankAcType 
	when LOWER(paymentType)=''bank transfer'' THEN rBankBranch ELSE '''' END ,''N/A''))) [Beneficiary_Branch_Address],
LTRIM(RTRIM('':57C:''+ISNULL(case when LOWER(paymentType)=''account deposit to other bank'' THEN cbb.[address]
	when LOWER(paymentType)=''bank transfer'' THEN b.ADDRESS ELSE ''''  END ,''N/A''))) [Beneficiary_Branch_Address2],
LTRIM(RTRIM('':57D:''+ISNULL(case when LOWER(paymentType)=''account deposit to other bank'' THEN cbb.city 
	when LOWER(paymentType)=''bank transfer'' THEN b.City ELSE ''''  END ,''N/A''))) [Beneficiary_Branch_Address3],
LTRIM(RTRIM('':57E:''+ISNULL(NULL,''''))) [Beneficiary_Branch_Code],
'':59A:''+LEFT(ReceiverName,35) [Beneficiary_Name],
LTRIM(RTRIM('':59B:''+ISNULL(NULL,''''))) [CNIC_ID],
LTRIM(RTRIM('':59C:''+ISNULL(CAST(receiver_mobile AS VARCHAR),''''))) [Mobile_Number],
LTRIM(RTRIM('':59E:''+ISNULL(CAST(rBankACNo AS VARCHAR),''''))) [Account_Number],
'':70:''+case when LOWER(paymentType)=''cash pay'' THEN ''Fast Cash''
when LOWER(paymentType)=''bank transfer'' THEN ''Fast Credit''
when LOWER(paymentType)=''account deposit to other bank'' THEN ''Fast Draft'' ELSE '''' END [paymentType],
LTRIM(RTRIM('':71A:''+ISNULL(NULL,''''))) [Other_Details],
LTRIM(RTRIM('':72A:''+ISNULL(NULL,''''))) [Other_Details2]    INTO    ' + @ledger_tabl
        + '
    FROM    moneysend m WITH ( NOLOCK )
            LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) ON m.rBankID = b.agent_branch_code LEFT OUTER JOIN 
commercial_bank cb WITH ( NOLOCK ) ON m.ben_bank_id = cb.external_bank_id AND m.ben_bank_name=cb.Bank_name LEFT OUTER JOIN 
commercial_bank_branch cbb  WITH ( NOLOCK ) ON cb.Commercial_id=cbb.Commercial_id AND m.rBankAcType=cbb.BranchName
JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
    WHERE  ISNULL(a.disable_payout,''n'')<>''y'' AND  expected_payoutagentid = ''' + @expected_payoutagentid + '''
            AND Transstatus = ''Payment'' '
            /*AND Tranno in (''1878482'',''1884139'',''1879313'',''1885241'',''1893076'')*/ 
      IF @trn_type IS NOT NULL 
        SET @sql = @sql + ' AND m.paymentType=''' + @trn_type + ''''
--    ELSE
--		 SET @sql = @sql + ' AND m.paymentType not in (''Cash Pay'')'
    IF @check IS NOT NULL 
        BEGIN
            SET @sql = @sql + ' AND m.confirmDate BETWEEN ''' + @fromDate
                + ''' AND ''' + @toDate + '''
							AND m.status=''Post'''
        END     
    ELSE 
        BEGIN
            SET @sql = @sql + ' AND m.status=''Un-Paid'' 
		
						UPDATE  dbo.moneySend
						SET     status = ''Post'' ,
								is_downloaded = ''y'' ,
								downloaded_by = ''' + @login_user_id + ''' ,
								downloaded_ts = ''' + @today + '''
						FROM    moneysend m WITH (NOLOCK)
								JOIN ' + @ledger_tabl
							+ ' t ON m.refno = dbo.encryptDb(Replace(t.[Reference_No],'':20:'',''''))
							JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
					WHERE ISNULL(a.disable_payout,''n'')<>''y'' '
        END 
         SET @sql = @sql + ' INSERT #temp_total_amount(total_amount,total_row) SELECT sum(totalroundamt),count(*) FROM moneysend m WITH (NOLOCK)
								JOIN ' + @ledger_tabl
							+ ' t ON m.refno = dbo.encryptDb(Replace(t.[Reference_No],'':20:'',''''))
							JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
					WHERE ISNULL(a.disable_payout,''n'')<>''y'' '
        CREATE TABLE #temp_total_amount(total_amount MONEY,total_row int )  
		
    PRINT @sql            
    EXEC (@sql)
 COMMIT transaction  TXN 
    
  --  RETURN   
------------------------------------------------------------------------------------------------
  SELECT  @total_amount = total_amount,@total_row = total_row           
  FROM    #temp_total_amount 
    
	SET @msg_agenttype=' '
	--SET @url_desc=ISNULL(@url_desc,'Null')
            
    IF @check IS NOT NULL 
		BEGIN
			SET @msg_agenttype = ' From: ' + @fromDate + ' To: ' + @toDate + ' (Re-Downloaded)' 
			SET @sequence='ReDownloaded'
		END
    ELSE
    BEGIN
		--------------------------------------------------------------------------------------------  
   -- PIC Update to Post
		  
            DECLARE @remote_db VARCHAR(200) ,  
                @sql1 VARCHAR(MAX) ,  
                @paidDate VARCHAR(50) ,  
                @partneragentcode VARCHAR(50)  
  
            IF EXISTS ( SELECT  sno  
                        FROM    static_values  
                        WHERE   sno = 200  
                                AND static_value = 'Prabhu MY' )   
                BEGIN  
                    SELECT  @remote_db = additional_value ,  
                            @partneragentcode = static_data  
                    FROM    static_values  
                    WHERE   sno = 200  
                            AND static_value = 'Prabhu MY'  
  
					SET @sql1 = ' insert into ' + @remote_db  
					   + 'tbl_status_moneysend_paid(refno,status)  
						SELECT m.REFNO,''Post'' FROM    moneysend m WITH (NOLOCK)
								JOIN ' + @ledger_tabl
							+ ' t ON m.refno = dbo.encryptDb(Replace(t.[Reference_No],'':20:'',''''))
							JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
							WHERE ISNULL(a.disable_payout,''n'')<>''y'' AND  m.agentid='''+@partneragentcode+''''
					EXEC(@sql1)  
                END  
 
  --------------------------------------------------------------------------------------------
  
    	SET @msg_agenttype = ' Till ' + @today
    	SELECT @sequence=dbo.FNAExportSequenceNumber(@expected_payoutagentid)
    END
		SET @url_desc='Sequence=' + @sequence+ '&'	 
            
    SET @desc = '<strong><u>HABIB BANK LTD. DOWNLOAD</u></strong> '          
            + ' is completed.  Payment Type: <strong><u>'+isNull(@trn_type,'ALL') 
            +' </u></strong> TXN Found: <strong><u>'          
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '</u></strong>  Total Amount: <strong><u>'          
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)+ '</u></strong> '  + @msg_agenttype 

    PRINT 'spa_message_board ''u'', '''+@login_user_id+''', NULL,'''+ @batch_id+''','''+ @desc+''', ''c'',
        '''+@process_id+''', NULL,'+ ISNULL(@url_desc,'Null')
    EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc, 'c',
        @process_id, NULL, @url_desc
        Drop table #temp_total_amount
 end try  
------------------------------------------------------------------------------------------------
begin catch  
  
--if @@trancount>0   
 rollback transaction  TXN
   ------------------------------------------------------------------------ 
  set @desc= 'Issues arised while exporting Please Try again after a while'  
   EXEC  spa_message_board 'u', @login_user_id,  
    NULL, @batch_id,  
    @desc, 'p', @process_id,null,@url_desc
   ---------------------------------------------------------------------  
   
 set @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'  
   
   
 INSERT INTO [error_info]  
   ([ErrorNumber]  
           ,[ErrorDesc]  
           ,[Script]  
           ,[ErrorScript]  
           ,[QueryString]  
           ,[ErrorCategory]  
           ,[ErrorSource]  
           ,[IP]  
           ,[error_date])  
 select -1,@desc,'export_HABIB_BANK','SQL',@desc,'SQL','SP','',getdate()  
 select 'ERROR','1050','Error Please try again'  
  
end catch
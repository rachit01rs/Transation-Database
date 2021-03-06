IF OBJECT_ID('spa_Export_JanataBank', 'P') IS NOT NULL 
    DROP PROC [dbo].[spa_Export_JanataBank]
GO
--spa_Export_JanataBank '20100004','Cash Pay','ranesh','30101265','350C9F7F_81CC_46D1_995B_1EEDCC8C1DA9','350C9F7F_81CC_46D1_995B_1EEDCC8C1DA9','JBBLCashPay','09/12/2010','09/30/2011'  
--spa_Export_JanataBank '20100001','Bank Transfer','shiva',NULL,':','1234555','JBBL'  
CREATE PROC [dbo].[spa_Export_JanataBank]  
    @agent_id VARCHAR(50) ,  
    @paymentType VARCHAR(50) = NULL ,  
    @login_user_id VARCHAR(50) ,  
    @branch_id VARCHAR(50) ,  
    @ditital_id VARCHAR(200) = NULL ,  
    @process_id VARCHAR(150) ,  
    @batch_Id VARCHAR(100) = NULL,  
    @fromDate VARCHAR(100) = NULL ,  
    @toDate VARCHAR(100) = NULL  
AS   
    SET XACT_ABORT ON ;  
    BEGIN TRY  
  
        DECLARE @desc VARCHAR(1000)  
        DECLARE @ledger_tabl VARCHAR(100) ,  
            @sql VARCHAR(5000) ,  
            @total_row INT  
  
        DECLARE @expected_payoutagentid VARCHAR(50) ,  
            @rBankID VARCHAR(50) ,  
            @rBankName VARCHAR(200) ,  
            @rBankBranch VARCHAR(200) ,  
            @GMT_Date DATETIME ,  
            @cover_fund MONEY ,  
            @payout_fund_limit CHAR(1)  
        SELECT  @expected_payoutagentid = a.agentcode ,  
                @rBankID = b.agent_branch_code ,  
                @rBankName = a.companyName ,  
                @rBankBranch = b.Branch ,  
                @GMT_Date = DATEADD(mi, ISNULL(gmt_value, 345), GETUTCDATE()) ,  
                @cover_fund = a.currentBalance - ISNULL(Account_No_IB, 0)  
        FROM    agentdetail a  
                JOIN agentbranchdetail b ON a.agentcode = b.agentcode  
        WHERE   agent_branch_code = @branch_id  
          
        IF @toDate IS NOT NULL   
   SET @toDate=@toDate+' 23:59:59.998'  
  
        BEGIN TRANSACTION  
  
        SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @login_user_id,  
                                             @process_id)  
        IF @paymentType = 'Bank Transfer' OR @paymentType = 'Account Deposit to Other Bank'  
            BEGIN  
                SET @sql = '  
       CREATE TABLE ' + @ledger_tabl  
                    + '(  
        [remittance_no] varchar(20),  
        [remitter_name] varchar(100),  
        [benifi_name] [varchar] (100),  
        [benifi_acc_type] [varchar](10),  
        [benifi_acc_no] varchar (50) NULL,  
        [bank_code] varchar(10) NULL ,  
        [bank_name] varchar(100) NULL,  
        [branch_code] varchar(10) NULL,   
        [branch_name_address] varchar(150) NULL,  
        [benifi_phone] varchar(100) NULL,  
        [issue_date] varchar(40) NULL,  
        [amount] money NULL,  
        [remark] varchar(300) NULL  
       ) ON [PRIMARY]'  
                PRINT ( @sql )  
                EXEC (@sql)  
     
                SET @sql = ' INSERT ' + @ledger_tabl  
                    + '([remittance_no],[remitter_name],[benifi_name],[benifi_acc_type],[benifi_acc_no],  
      [bank_code],[bank_name],[branch_code],[branch_name_address],[benifi_phone],  
      [issue_date],[amount],[remark])  
      SELECT dbo.decryptdb(refno),senderName,receiverName,''SB'',rBankACNo,  
      CASE WHEN paymentType=''Bank Transfer'' THEN ''1200000'' ELSE ben_bank_id END ,  
      CASE WHEN paymentType=''Bank Transfer'' THEN ''Janata Bank Limited'' ELSE ben_bank_name END ,b.ext_branch_code,b.branch,  
      isNULL(receiverPhone,'''')+'',''+isNULL(receiver_mobile,''''),  
      convert(varchar,confirmDate,101),totalRoundAmt,reason_for_remittance'  
      
            END  
        ELSE   
            BEGIN  
--Payment Type = 'Cash Pay'  
                SET @sql = '  
       CREATE TABLE ' + @ledger_tabl  
                    + '(  
        [TranNo] varchar(20),  
        [Control_No] varchar(100),  
        [Sender_Name] [varchar] (100),  
        [Sender_Address] [varchar](200),  
        [Sender_Mobile] varchar (100) NULL,  
        [Sender_ID_No] varchar(100) NULL ,  
        [Issue_Date] varchar(50) NULL ,  
        [Receiver_Name] varchar(100) NULL,  
        [Receiver_Address] varchar(200) NULL,   
        [Receiver_City] varchar(100) NULL,  
        [Receiver_Country] varchar(100) NULL,  
        [Receiver_Contact] varchar(100) NULL,  
        [Payout_Amount] MONEY NULL,  
        [Payout_Currency] varchar(5) NULL,  
        [Payment_Type] varchar(50) NULL,  
        [Payment_Date] varchar(50) NULL,  
        [Bank_ID] varchar(50) NULL,  
        [Bank_Detail] varchar(200) NULL,  
        [Branch_Code] varchar(50) NULL,  
        [Branch_Name] varchar(100) NULL,  
        [Remarks] varchar(500) NULL  
       ) ON [PRIMARY]'  
                PRINT ( @sql )  
                EXEC (@sql)  
     
                SET @sql = ' INSERT ' + @ledger_tabl  
                    + '([TranNo],[Control_No],[Sender_Name],[Sender_Address],[Sender_Mobile],  
     [Sender_ID_No],[Issue_Date],[Receiver_Name],[Receiver_Address],[Receiver_City],  
     [Receiver_Country],[Receiver_Contact],[Payout_Amount],[Payout_Currency],[Payment_Type],  
     [Payment_Date],[Bank_ID],[Bank_Detail],[Branch_Code],[Branch_Name],[Remarks])  
  
    SELECT tranno,dbo.decryptdb(refno),senderName,senderAddress,sender_mobile,senderPassport,  
    convert(varchar,ConfirmDate,101),ReceiverName,ReceiverAddress,ReceiverCity,ReceiverCountry,  
    ISNULL(ReceiverPhone,'''')+''/''+ISNULL(receiver_mobile,''''),TotalRoundAmt,receiveCType,  
    paymentType,convert(varchar,paidDate,101),''1200000'',''Janata Bank Limited'',  
    b.ext_branch_code,b.branch,reason_for_remittance '  
   
            END  
  
  
        SET @sql = @sql  
            + ' FROM moneysend m  WITH ( NOLOCK )   
     LEFT OUTER JOIN agentbranchdetail b WITH ( NOLOCK ) on m.rBankID=b.agent_branch_code
       JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid   
     WHERE ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid=''' + @agent_id  
            + '''  AND (lock_status=''unlocked'' OR lock_status IS NULL)   
     AND Transstatus = ''Payment''  '  
  IF @paymentType IS NOT NULL   
            SET @sql = @sql + ' AND paymentType = ''' + @paymentType + ''''  
        IF @paymentType = 'Bank Transfer' OR @paymentType = 'Account Deposit to Other Bank'  
        BEGIN  
            SET @sql = @sql + ' AND status=''Un-Paid'' AND is_downloaded is null'  
            SET @sql = @sql + ' ORDER BY confirmDate'  
        END  
        ELSE   
        BEGIN  
            SET @sql = @sql + ' AND status=''Paid'' 
								AND (is_downloaded is null or is_downloaded=''y'')'  
            IF @fromDate IS NOT NULL AND @toDate IS NOT NULL  
    SET @sql = @sql + ' AND paidDate BETWEEN ''' +@fromDate+ ''' AND ''' +@toDate+ ''''  
    SET @sql = @sql + ' ORDER BY paidDate'  
        END  
          
        PRINT ( @sql )  
        EXEC(@sql)  
  
        SET @total_row = @@rowcount  
          
        DECLARE @total_amount MONEY  
        CREATE TABLE #temp_total_amount ( total_amount MONEY )  
          
        IF @paymentType = 'Bank Transfer' OR @paymentType = 'Account Deposit to Other Bank'  
            BEGIN  
                SET @sql = '  
      INSERT #temp_total_amount(total_amount)  
      SELECT sum(amount) FROM ' + @ledger_tabl  
                    + ''  
            END   
        ELSE   
            BEGIN  
                SET @sql = '  
      INSERT #temp_total_amount(total_amount)  
      SELECT sum(Payout_Amount) FROM '  
                    + @ledger_tabl + ''  
            END  
        EXEC(@sql)  
          
        SELECT  @total_amount = total_amount  
        FROM    #temp_total_amount  
  
        DECLARE @total_row_pending INT ,  
            @total_amount_pending MONEY  
--  
--create table #temp_cover_fund(  
-- sno int identity(1,1),  
-- refno varchar(20),  
-- totalroundamt money)  
--  
--create table #total_row_pending(  
-- total_row int,  
-- totalroundamt money  
-- )  
--  
--create table #total_row_apply(  
-- total_row int  
--)  
--  
--if @payout_fund_limit='y'  
--begin  
--  
--set @sql='  
-- insert #temp_cover_fund(refno,totalroundamt)  
-- select [Unique Reference Number],Amount from '+ @ledger_tabl+'   
-- order by Remittance_Date,Amount'  
--exec(@sql)  
--  
-- select refno into #temp_TXN_apply  
-- from #temp_cover_fund t  
-- where (select sum(totalroundamt) from #temp_cover_fund where sno<=t.sno) <= @cover_fund  
--  
--set @sql='   
-- insert #total_row_pending(total_row,totalroundamt)  
-- select count(*),sum(Amount)  
-- from '+ @ledger_tabl+'  t left outer join #temp_TXN_apply a  
-- on t.[Unique Reference Number]=a.refno  
-- where a.refno is NULL'  
--exec(@sql)  
-- select @total_row_pending=total_row,@total_amount_pending=totalroundamt from #total_row_pending  
--set @sql='  
-- delete  '+ @ledger_tabl+'  
-- from  '+ @ledger_tabl+'  t left outer join #temp_TXN_apply a  
-- on t.[Unique Reference Number]=a.refno  
-- where a.refno is NULL'  
--exec(@sql)  
--set @sql='  
-- insert #total_row_apply(total_row)  
-- select count(*) from '+ @ledger_tabl+''  
--exec(@sql)  
-- select @total_row=total_row from #total_row_apply  
--end  
----set @total_row=@@rowcount  
  
----############  
COMMIT TRANSACTION  
        DELETE  [temp_trn_csv_pay]  
        WHERE   digital_id_payout = @ditital_id  
        IF @paymentType = 'Bank Transfer' OR @paymentType = 'Account Deposit to Other Bank'  
            BEGIN  
                SET @sql = 'INSERT INTO [temp_trn_csv_pay]  
    ([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
    [rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
    select m.tranno,m.refno,m.receiverName,m.totalRoundAmt,'''  
                    + CONVERT(VARCHAR, @GMT_Date, 120) + ''','''  
                    + @login_user_id + ''',''' + @agent_id + ''','''  
                    + @rBankID + ''',''' + @rBankName + ''',''' + @rBankBranch  
                    + ''',''' + @ditital_id + ''' FROM ' + @ledger_tabl  
                    + ' t WITH ( NOLOCK ) JOIN moneysend m WITH (NOLOCK) ON '  
                    + ' dbo.encryptDB(t.[remittance_no])=m.refno   JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y'''  
 --  ELSE  
--   SET @sql=@sql + ' dbo.encryptDB(t.[Control_No])=m.refno'  
    
                PRINT @sql  
                EXEC(@sql)  
   
                PRINT ( 'spa_make_bulk_payment_csv ''' + @ditital_id  
                        + ''',NULL,''y''' )  
                EXEC ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
            END  
              
              
        DECLARE @url_desc VARCHAR(500)  
        SET @url_desc = 'paymentType=' + ISNULL(@paymentType, '')  
        SET @desc = 'JANATA BANAK LIMITED  Download <u>' + ISNULL(@paymentType,  
                                                              'ALL')  
            + '</u> is completed.  TXN Found:'  
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '  Total Amount: '  
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)  
        SET @desc = @desc + ' Local Time:' + CONVERT(VARCHAR, @GMT_Date, 120)  
        IF @fromDate IS NOT NULL AND @toDate IS NOT NULL   
   SET @desc = @desc + '<br>Date Range between '+@fromDate+ ' and ' +@toDate  
  
        IF @total_row_pending IS NOT NULL  
            AND @total_amount_pending IS NOT NULL   
            SET @desc = @desc + '<br><i>Cover fund not enough(Pending:'  
                + CAST(@total_row_pending AS VARCHAR) + ' AMT:'  
                + CAST(@total_amount_pending AS VARCHAR) + ')</i>'  
  
        PRINT @desc  
        EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc,  
            'c', @process_id, NULL, @url_desc  
  
          
    END TRY  
    BEGIN CATCH  
  
        IF @@trancount > 0   
            ROLLBACK TRANSACTION  
  
   
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
                        'export_Janata_BANK' ,  
                        'SQL' ,  
                        @desc ,  
                        'SQL' ,  
                        'SP' ,  
                        @ditital_id ,  
                        GETDATE()  
        SELECT  'ERROR' ,  
                '1050' ,  
 'Error Please try again'  
  
    END CATCH  
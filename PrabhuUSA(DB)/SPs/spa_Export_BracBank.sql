IF OBJECT_ID('spa_Export_BracBank', 'p') IS NOT NULL 
    DROP PROC [dbo].[spa_Export_BracBank]  
GO
--spa_Export_BracBank '20100029','Cash Pay','anoop','30106362','dc','2s2dddd2','BracBank'  
CREATE PROC [dbo].[spa_Export_BracBank]
    @agent_id VARCHAR(50) ,
    @paymentType VARCHAR(50) = NULL ,
    @login_user_id VARCHAR(50) ,
    @branch_id VARCHAR(50) ,
    @ditital_id VARCHAR(200) = NULL ,
    @process_id VARCHAR(150) ,
    @batch_Id VARCHAR(100) = NULL
AS 
    SET XACT_ABORT ON ;  
    BEGIN TRY  
        DECLARE @desc VARCHAR(1000)  
        DECLARE @ledger_tabl VARCHAR(100) ,
            @sql VARCHAR(5000)  
  
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
                @cover_fund = a.currentBalance - ISNULL(Account_No_IB, 0) ,
                @payout_fund_limit = payout_fund_limit
        FROM    agentdetail a
                JOIN agentbranchdetail b ON a.agentcode = b.agentcode
        WHERE   agent_branch_code = @branch_id  
  
        BEGIN TRANSACTION  
  
        SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @login_user_id,
                                             @process_id)  
        SET @sql = '  
CREATE TABLE ' + @ledger_tabl + '(  
 strTTRefNo varchar(50) ,  
 strBeneficiaryName varchar(100) NULL ,  
 strBeneficiaryIdentityDetail varchar(150) NULL ,  
 strBeneficiaryPhoneNo varchar(50) NULL,  
 strBeneficiaryACNo [varchar] (50)  NULL ,  
 BankName varchar(150) NULL ,  
 BranchName varchar(150) NULL ,  
 DistrictName varchar(150) NULL ,  
 Branch_Code varchar(50) NULL ,  
 strCollectionPoint varchar(50),  
 numTTAmount money,  
 dtTTDate varchar(50),  
 strSenderName varchar(100),  
 strSenderAddress varchar(250),  
 CountryName varchar(100)  
) ON [PRIMARY]'  
        PRINT ( @sql )  
        EXEC (@sql)  
        DECLARE @total_row INT  
        SET @sql = ' insert ' + @ledger_tabl
            + '(strTTRefNo,strBeneficiaryName,strBeneficiaryIdentityDetail,strBeneficiaryPhoneNo,strBeneficiaryACNo,  
BankName,BranchName,DistrictName,Branch_Code,strCollectionPoint,numTTAmount,dtTTDate,strSenderName,strSenderAddress,CountryName)  
select dbo.decryptdb(refno) as [strTTRefNo], ReceiverName as [strBeneficiaryName],  
case when paymentType=''Cash Pay'' then isNULL(ReceiverIDDescription,'''')+'': ''+isNULL(ReceiverID,'''') else NULL END as [strBeneficiaryIdentityDetail],  
isNULL(receiverphone,'''') +''; ''+isNULL(receiver_mobile,'''') as [strBeneficiaryPhoneNo],  
case when paymentType=''Cash Pay'' then NULL else rBankACNo END as [strBeneficiaryACNo],  
case when paymentType in (''Bank Transfer'') then ''BRAC BANK LTD'' else case when paymentType in (''Cash Pay'') then case when b.branchcodeChar=''BDP'' then ''BRAC BDP'' else ''BRAC BANK LTD'' end else ben_bank_name end end [BankName],  
case when paymentType in (''Cash Pay'',''Bank Transfer'') then isNULL(rBankBranch,'''') else rBankAcType end [Branch Name],  
case when paymentType in (''Cash Pay'',''Bank Transfer'') then isNULL(b.city,'''') else receivercity end [DistrictName],  
b.ext_branch_code [Branch Code],  
case when paymentType in (''Cash Pay'') then isNULL(rBankBranch,'''') else NULL end [strCollectionPoint],  
totalRoundAmt [numTTAmount],  
convert(varchar,cast(confirmDate as datetime),101) as [dtTTDate],  
senderName as [strSenderName],  
senderAddress as [strSenderAddress],  
sendercountry as [CountryName]  
from moneysend m WITH(NOLOCK) left outer join agentbranchdetail b WITH(NOLOCK) on m.rBankID=b.agent_branch_code  
JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
WHERE ISNULL(a.disable_payout,''n'')<>''y'' AND expected_payoutagentid=''' + @agent_id
            + ''' and status=''Un-Paid'' and Transstatus = ''Payment'' and is_downloaded is null '  
        IF @paymentType IS NOT NULL 
            SET @sql = @sql + ' and paymentType = ''' + @paymentType + ''''  
        SET @sql = @sql + ' order by confirmDate'  
        PRINT ( @sql )  
        EXEC(@sql)  
        SET @total_row = @@rowcount  
  
        DECLARE @total_row_pending INT ,
            @total_amount_pending MONEY  
  
        CREATE TABLE #temp_cover_fund
            (
              sno INT IDENTITY(1, 1) ,
              refno VARCHAR(20) ,
              totalroundamt MONEY
            )  
  
        CREATE TABLE #total_row_pending
            (
              total_row INT ,
              totalroundamt MONEY
            )  
  
        CREATE TABLE #total_row_apply ( total_row INT )  
  
        IF @payout_fund_limit = 'y' 
            BEGIN  
  
                SET @sql = '  
 insert #temp_cover_fund(refno,totalroundamt)  
 select strTTRefNo,numTTAmount from ' + @ledger_tabl + '   
 order by dtTTDate,numTTAmount'  
                EXEC(@sql)  
  
                SELECT  refno
                INTO    #temp_TXN_apply
                FROM    #temp_cover_fund t
                WHERE   ( SELECT    SUM(totalroundamt)
                          FROM      #temp_cover_fund
                          WHERE     sno <= t.sno
                        ) <= @cover_fund  
  
                SET @sql = '   
 insert #total_row_pending(total_row,totalroundamt)  
 select count(*),sum(numTTAmount)  
 from ' + @ledger_tabl + '  t left outer join #temp_TXN_apply a  
 on t.strTTRefNo=a.refno  
 where a.refno is NULL'  
                EXEC(@sql)  
                SELECT  @total_row_pending = total_row ,
                        @total_amount_pending = totalroundamt
                FROM    #total_row_pending  
                SET @sql = '  
 delete  ' + @ledger_tabl + '  
 from  ' + @ledger_tabl + '  t left outer join #temp_TXN_apply a  
 on t.strTTRefNo=a.refno  
 where a.refno is NULL'  
                EXEC(@sql)  
                SET @sql = '  
 insert #total_row_apply(total_row)  
 select count(*) from ' + @ledger_tabl + ''  
                EXEC(@sql)  
                SELECT  @total_row = total_row
                FROM    #total_row_apply  
            END  
--set @total_row=@@rowcount  
        DELETE  [temp_trn_csv_pay]
        WHERE   digital_id_payout = @ditital_id  
  
        SET @sql = 'INSERT INTO [temp_trn_csv_pay]  
([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
select tranno,refno,receiverName,totalRoundAmt,'''
            + CONVERT(VARCHAR, @GMT_Date, 120) + ''',''' + @login_user_id
            + ''',  
''' + @agent_id + ''',''' + @rBankID + ''',''' + @rBankName + ''','''
            + @rBankBranch + ''',''' + @ditital_id + '''   
from ' + @ledger_tabl
            + ' t join moneysend m with (nolock) on dbo.encryptDB(t.strTTRefNo)=m.refno JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid WHERE ISNULL(a.disable_payout,''n'')<>''y'''  
        PRINT @sql  
        EXEC(@sql)  
  
        EXEC ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
        DECLARE @url_desc VARCHAR(500)  
        SET @url_desc = 'paymentType=' + ISNULL(@paymentType, '')  
        SET @desc = @rBankName + ' Download <u>' + ISNULL(@paymentType, 'ALL')
            + '</u> is completed.  TXN Found:'
            + CAST(ISNULL(@total_row, 0) AS VARCHAR)  
        SET @desc = @desc + ' Local Time:' + CONVERT(VARCHAR, @GMT_Date, 120)  
  
        IF @total_row_pending IS NOT NULL
            AND @total_amount_pending IS NOT NULL 
            SET @desc = @desc + '<br><i>Cover fund not enough(Pending:'
                + CAST(@total_row_pending AS VARCHAR) + ' AMT:'
                + CAST(@total_amount_pending AS VARCHAR) + ')</i>'  
  
  
        EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc,
            'c', @process_id, NULL, @url_desc  
  
        COMMIT TRANSACTION  
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
                        'export_bracBank' ,
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
  
IF OBJECT_ID('spa_Export_MercantileBank','P') IS NOT NULL
DROP PROC [dbo].[spa_Export_MercantileBank]

go
--spa_Export_MercantileBank '20100001','Bank Transfer','deepen',NULL,':','1234555','PBBL'    
CREATE PROC [dbo].[spa_Export_MercantileBank]  
    @agent_id VARCHAR(50) ,  
    @paymentType VARCHAR(50) = NULL ,  
    @login_user_id VARCHAR(50) ,  
    @branch_id VARCHAR(50) ,  
    @digital_id VARCHAR(200) = NULL ,  
    @process_id VARCHAR(150) ,  
    @batch_Id VARCHAR(100) = NULL  
AS   
    SET XACT_ABORT ON ;    
    BEGIN TRY    
  IF @digital_id=':'  
   SET @digital_id=REPLACE(NEWID(),'-','_')  
     
        DECLARE @desc VARCHAR(1000)    
        DECLARE @ledger_tabl VARCHAR(100) ,  
            @sql VARCHAR(max)    
    
        DECLARE @expected_payoutagentid VARCHAR(50) ,  
            @rBankID VARCHAR(50) ,  
            @rBankName VARCHAR(200) ,  
            @rBankBranch VARCHAR(200) ,  
            @GMT_Date DATETIME ,  
            @cover_fund MONEY ,  
            @payout_fund_limit CHAR(1),  
            @total_row INT     
        SELECT  @expected_payoutagentid = a.agentcode ,  
                @rBankID = b.agent_branch_code ,  
                @rBankName = a.companyName ,  
                @rBankBranch = b.Branch ,  
                @GMT_Date =dbo.getDateHO(GETUTCDATE()) ,  
                @cover_fund = a.currentBalance - ISNULL(Account_No_IB, 0)  
        FROM    agentdetail a with(nolock) 
                JOIN agentbranchdetail b with(nolock) ON a.agentcode = b.agentcode  
        WHERE   agent_branch_code = @branch_id    
    
        BEGIN TRANSACTION  trans  
         
    
        SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @login_user_id,  
                                             @process_id)   
                                               
       SET @sql = '  
       select row_number() over (ORDER BY m.Tranno) [SL NO.],  
     dbo.decryptdb(refno) as [Order No / Ref No],  
     ReceiverName as [Beneficiary Name],'  
  if @paymentType='Cash Pay'   
   SET @sql = @sql + 'ReceiverID as [ID],'  
  else  
   SET @sql = @sql + '''AC-''+rBankACNo as [Account No.],'  
    
  SET @sql = @sql +'  
   CASE WHEN paymentType in (''Cash Pay'',''Bank Transfer'') then rBankName else ben_bank_name end [Bank Name],  
   CASE WHEN paymentType in (''Cash Pay'',''Bank Transfer'') then isNULL(rBankBranch,'''') else rBankAcType end as [Branch Name],  
   CASE WHEN paymentType in (''Cash Pay'',''Bank Transfer'') then isNULL(rBankBranch,b.city) else rBankAcType end as [District],  
   ReceiverPhone as [Telephone No],  
   senderName as [Remitter Name],  
   totalRoundAmt [Amount],'  
    
  if @paymentType='Cash Pay'   
   SET @sql = @sql +' dbo.decryptdb(refno) as [PIN/Secret NO],'  
  else  
   SET @sql = @sql +' senderPhoneNo as [sTelephone No],'  
    
  SET @sql = @sql +' ag.currencyType   
   INTO '+@ledger_tabl+'  
   FROM moneysend m with(nolock)   
   LEFT OUTER JOIN agentbranchdetail b with(nolock) on m.rBankID=b.agent_branch_code   
   LEFT OUTER JOIN agentdetail ag with(nolock) on ag.agentCode=b.agentCode   
   where (expected_payoutagentid='''+@agent_id+''' or paid_agent_id='''+@agent_id+''')  
   and Transstatus = ''Payment'' and   
   status=''Un-Paid''  and   
   is_downloaded is null  
   '  
  IF @paymentType IS NOT NULL   
            SET @sql = @sql + ' and paymentType = ''' + @paymentType + ''''    
        SET @sql = @sql + '   
          
           
      UPDATE moneysend set    
     is_downloaded=''y'',  
     status=''Post'',    
     downloaded_ts=dbo.getDateHO(GETUTCDATE()),    
     downloaded_by='''+@login_user_id+'''    
      FROM moneysend m with (nolock) JOIN '+@ledger_tabl+' t    
       ON m.refno=dbo.encryptdb(t.[Order No / Ref No])    
        '    
           
        PRINT ( @sql )    
        EXEC(@sql)    
    
        SET @total_row = @@rowcount    
    
        DECLARE @total_amount MONEY    
        CREATE TABLE #temp_total_amount ( total_amount MONEY )    
    
        SET @sql = '    
    insert #temp_total_amount(total_amount)    
    select sum([Amount]) from ' + @ledger_tabl + ''    
        EXEC(@sql)    
    
        SELECT  @total_amount = total_amount  
        FROM    #temp_total_amount   
        DECLARE @total_row_pending INT ,  
    @total_amount_pending MONEY     
     IF @paymentType<>'Cash Pay'  
     BEGIN  
   DELETE  [temp_trn_csv_pay]  
   WHERE   digital_id_payout = @digital_id    
     
   SET @sql = 'INSERT INTO [temp_trn_csv_pay]    
  ([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],    
  [rBankID],[rBankName],[rBankBranch],[digital_id_payout])    
  select   
   tranno,refno,receiverName,totalRoundAmt,'''+ CONVERT(VARCHAR, @GMT_Date, 120) + ''',''' + @login_user_id+ ''',    
 ''' + @agent_id + ''',''' + @rBankID + ''',''' + @rBankName + ''','''+ @rBankBranch + ''',''' + @digital_id + '''     
   from ' + @ledger_tabl+ ' t   
   JOIN moneysend m with (nolock) on dbo.encryptDB(t.[Order No / Ref No])=m.refno'    
   PRINT @sql    
   EXEC(@sql)    
     
   PRINT ( 'spa_make_bulk_payment_csv ''' + @digital_id + ''',NULL,''y''' )    
   EXEC ('spa_make_bulk_payment_csv '''+@digital_id+''',NULL,''y''')  
       END     
    
        DECLARE @url_desc VARCHAR(max)    
        SET @url_desc = 'paymentType=' + ISNULL(@paymentType, '')    
        SET @desc = 'MERCANTILE BANK  Download <strong><u>' + ISNULL(@paymentType,  
                                                              'ALL')  
            + '</u></strong> is completed.  TXN Found:'  
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '  Total Amount: '  
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)    
        SET @desc = @desc + ' Local Time:' + CONVERT(VARCHAR, @GMT_Date, 120)    
    
        IF @total_row_pending IS NOT NULL  
            AND @total_amount_pending IS NOT NULL   
            SET @desc = @desc + '<br><i>Cover fund not enough(Pending:'  
                + CAST(@total_row_pending AS VARCHAR) + ' AMT:'  
                + CAST(@total_amount_pending AS VARCHAR) + ')</i>'    
    
        PRINT @desc    
        EXEC spa_message_board 'u', @login_user_id, NULL, @batch_id, @desc,  
            'c', @process_id, NULL, @url_desc    
    
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
                        @batch_Id ,  
                        'SQL' ,  
                        @desc ,  
                        'SQL' ,  
                        'SP' ,  
                        left(@digital_id,20) ,  
                        GETDATE()    
        SELECT  'ERROR' ,  
                '1050' ,  
                'Error Please try again'    
    
    END CATCH    
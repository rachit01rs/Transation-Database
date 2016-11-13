    
/****** Object:  StoredProcedure [dbo].[spa_Batch_FileGeneration_HNB]    Script Date: 11/12/2009 13:17:10 ******/    
--spa_Batch_FileGeneration_HNB '32400129','Cash Pay','testuser','0541433423456789','45532233433334','test'    
Alter PROC [dbo].[spa_Batch_FileGeneration_HNB]    
    @destination_agent VARCHAR(50) ,    
    @trn_type VARCHAR(50) = NULL ,    
    @downloadBy VARCHAR(50) = NULL ,    
    @ditital_id VARCHAR(200) = NULL ,    
    @process_id VARCHAR(150) ,    
    @batch_Id VARCHAR(100) = NULL      
--    ,@fromDate VARCHAR(50) = NULL ,    
--    @toDate VARCHAR(50) = NULL ,    
--    @check CHAR(1) = NULL    
AS     
    DECLARE @sql VARCHAR(MAX) ,    
        @BeneficiaryBank VARCHAR(10) ,    
        @BeneficiaryBranch VARCHAR(10) ,    
        @HNBAccount VARCHAR(50) ,    
        @ledger_tabl VARCHAR(500) ,    
        @total_row INT ,    
        @desc VARCHAR(1000) ,    
        @total_amount MONEY ,    
        @total_row_pending INT ,    
        @total_amount_pending MONEY ,    
        @url_desc VARCHAR(500)    
       
--    IF @fromDate IS NULL     
--        SET @fromDate = GETDATE()    
--    IF @toDate IS NULL     
--        SET @toDate = GETDATE()    
----------------------------------------------------------------------------        
    SET @BeneficiaryBank = '7083'        
    SET @BeneficiaryBranch = '054'        
    --SET @destination_agent = '20100080' --20100080 HATTON NATIONAL BANK PLC(UAT)           
           --30107746  HEAD OFFICE (UAT)           
    SET @HNBAccount = '054010067317'        
----------------------------------------------------------------------------     
    BEGIN TRY    
        BEGIN TRANSACTION TRANS    
 ---------------------TEMP TABLE CREATION--------------------------------    
        SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @downloadBy,    
                                             @process_id)    
        SET @sql = '    
       CREATE TABLE ' + @ledger_tabl+ '(    
        [Reference Number] [varchar] (30)  NULL,    
        [Account Number] [varchar] (20)  NULL,    
        [Amount] [varchar] (20)  NULL,    
        [Currency] [varchar] (3)  NULL,    
        [Remittance Type] [varchar] (1)  NULL,    
        [Charge From] [varchar] (1)  NULL,    
        [Remitter Name] [varchar] (55)  NULL,    
        [Remitter E-mail Address] [varchar] (30)  NULL,    
        [Remitter Telephone (Mobile)] [varchar] (20)  NULL,    
        [Details] [varchar] (60)  NULL,    
        [Beneficiary Name] [varchar] (55)  NULL,    
        [Beneficiary Address] [varchar] (100)  NULL,    
        [Beneficiary Telephone(land)] [varchar] (20)  NULL,    
        [Beneficiary ID Number] [varchar] (30)  NULL,    
        [Beneficiary E-mail Address] [varchar] (30)  NULL,    
        [Beneficiary’s Telephone(Mobile)] [varchar] (20)  NULL,    
        [Beneficiary Account Number] [varchar] (20)  NULL,    
        [Beneficiary Bank] [varchar] (4)  NULL,    
        [Beneficiary Branch] [varchar] (3)  NULL,    
        [Bank To Bank Information] [varchar] (40)  NULL,    
        [Exchange Rate] [varchar] (7)  NULL,    
        [Deposit Amount] [varchar] (20)  NULL,    
        [Commission] [varchar] (20)  NULL,    
        [Other Charges] [varchar] (20)  NULL,    
        [User Id] [varchar] (6)  NULL,    
        [Transaction Date] [varchar] (10)  NULL,    
        [Value date] [varchar] (10)  NULL,    
        [Transaction Time] [varchar] (8)  NULL,    
        [Approved Id] [varchar] (6)  NULL    
       ) ON [PRIMARY]'    
        PRINT ( @sql )    
        EXEC (@sql)    
 ------------------------------------------------------------------------    
      
        SET @sql = 'INSERT INTO ' + @ledger_tabl + '     
        ([Reference Number],[Account Number],[Amount],[Currency],[Remittance Type],    
 [Charge From],[Remitter Name],[Remitter E-mail Address],    
 [Remitter Telephone (Mobile)],[Details],[Beneficiary Name],    
 [Beneficiary Address],[Beneficiary Telephone(land)],[Beneficiary ID Number],    
 [Beneficiary E-mail Address],[Beneficiary’s Telephone(Mobile)],    
 [Beneficiary Account Number],[Beneficiary Bank],[Beneficiary Branch],    
 [Bank To Bank Information],[Exchange Rate],[Deposit Amount],[Commission],[Other Charges],[User Id],    
 [Transaction Date],[Value date],[Transaction Time],[Approved Id])    
SELECT dbo.decryptdb(refno) [Reference Number],''' + @HNBAccount + ''' [Account Number],cast(totalroundAmt as varchar) [Amount],    
 receiveCType [Remittance Type],    
 CASE WHEN paymentType=''Cash Pay'' then ''C''     
 WHEN paymentType=''Bank Transfer'' then ''A'' ELSE ''O'' END,''S'' [Charge From],    
 LEFT(isnull(senderName,'' ''),55) [Remitter Name],LEFT(isNULL(senderEmail,'' ''),30) [Remitter E-mail Address],    
 RIGHT(isNULL(sender_mobile,'' ''),30) [Remitter Telephone (Mobile)],    
 LEFT(isnull(reason_for_remittance,'' ''),60) [Details],LEFT(receiverName,55) [Beneficiary Name],    
 LEFT(isNull(receiverAddress,'' ''),100) [Beneficiary Address],    
 RIGHT(isNULL(receiverPhone,'' ''),20) [Beneficiary Telephone(land)],    
 LEFT(isNULL(receiverIDDescription,'' '')+isNULL(ReceiverID,'' ''),30) [Beneficiary ID Number],    
 LEFT(isNULL(receiverEmail,'' ''),30) [Beneficiary E-mail Address],    
 RIGHT(isNULL(receiver_mobile,'' ''),20) [Beneficiary’s Telephone(Mobile)],    
 LEFT(isNULL(REPLACE(rBankACNo,''-'',''''),'' ''),20) [Beneficiary Account Number],    
 CASE WHEN (paymentType=''Cash Pay'' OR paymentType=''Bank Transfer'') THEN '''+ @BeneficiaryBank + '''    
 ELSE LEFT(isNull(ben_bank_id,'' ''),4) end [Beneficiary Bank],    
 IsNull(CASE WHEN paymentType=''Cash Pay'' then ''' + @BeneficiaryBranch + '''     
 WHEN paymentType=''Bank Transfer'' then LEFT(REPLACE(LTRIM(RTRIM(rBankACNo)),''-'',''''),3)    
 ELSE RIGHT(ben_bank_id,3) end,'' '') [Beneficiary Branch],    
 LEFT(isNULL(ReciverMessage,'' ''),40) [Bank To Bank Information],    
 isNull(cast(agent_settlement_rate as varchar),'' '') [Exchange Rate],cast(totalroundAmt as varchar) [Deposit Amount],cast(IsNull(sCharge,'' '') as varchar) [Commission],    
 cast(isNULL(otherCharge,'' '') as varchar) [Other Charges],cast(LEFT(SEmpID,6) as varchar) [User Id],    
 isNull(replace(convert(varchar,cast(confirmDate as datetime),103),''/'',''''),'' '') [Transaction Date],    
 isNull(replace(convert(varchar,cast(confirmDate as datetime),103),''/'',''''),'' '') [Value date],    
 cast(isNull(dotTime,'' '') as varchar) [Transaction Time],LEFT(isNull(m.approve_by,'' ''),6) [Approved Id]    
 FROM moneysend m WITH (NOLOCK) JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid    
 LEFT OUTER JOIN agentbranchdetail b WITH (NOLOCK) on m.rBankID=b.agent_branch_code    
 WHERE expected_payoutagentid=''' + @destination_agent + ''' and     
 Transstatus = ''Payment'' AND status=''Un-Paid'' AND ISNULL(a.disable_payout,''n'')<>''y'''     
        IF @trn_type IS NOT NULL     
            SET @sql = @sql + ' AND paymentType=''' + @trn_type + ''''    
        
--    IF @check = '1'     
--        BEGIN     
--            SET @sql = @sql + ' and confirmDate between ''' + @fromDate    
--                + ''' and ''' + @toDate + ''''    
--        END    
--    ELSE     
--        BEGIN    
        SET @sql = @sql + ' AND is_downloaded IS NULL'     
--        END    
        
        PRINT @sql    
        --RETURN    
        EXEC (@sql)    
    
    
-------------------------------------------------------------------------------------------------------------    
-----------------------------------For locking the record for Avoiding repeat download------------------------    
-------------------------------------------------------------------------------------------------------------    
    
        SET @total_row = @@rowcount    
        SET @sql = 'UPDATE moneysend       
    SET status=''Post'',      
    is_downloaded=''y'',      
    downloaded_ts=dbo.getDateHO(getutcdate()),      
         downloaded_by=''' + @downloadBy + '''    
   FROM moneysend m JOIN ' + @ledger_tabl + ' t    
   ON m.refno=dbo.encryptDB(t.[Reference Number])'    
  print @sql    
        EXEC (@sql)    
        
        CREATE TABLE #temp_total_amount ( total_amount MONEY )    
            
        SET @sql = '    
    INSERT #temp_total_amount(total_amount)    
    SELECT sum(CAST([Deposit Amount] AS MONEY)) FROM ' + @ledger_tabl    
            + ''    
        EXEC(@sql)    
            
        SELECT  @total_amount = total_amount    
        FROM    #temp_total_amount    
    
----############ AUTO PAID PROCESS---------------------------------------------    
    
--        DELETE  [temp_trn_csv_pay]    
--        WHERE   digital_id_payout = @ditital_id    
--        IF @paymentType = 'Bank Transfer'     
--            BEGIN    
--                SET @sql = 'INSERT INTO [temp_trn_csv_pay]    
--    ([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],    
--    [rBankID],[rBankName],[rBankBranch],[digital_id_payout])    
--    select m.tranno,m.refno,m.receiverName,m.totalRoundAmt,'''    
--                    + CONVERT(VARCHAR, @GMT_Date, 120) + ''','''    
--                    + @login_user_id + ''',''' + @agent_id + ''','''    
--                    + @rBankID + ''',''' + @rBankName + ''',''' + @rBankBranch    
--                    + ''',''' + @ditital_id + ''' FROM ' + @ledger_tabl    
--                    + ' t JOIN moneysend m WITH (NOLOCK) ON '    
--                    + ' dbo.encryptDB(t.[remittance_no])=m.refno'    
-- --  ELSE    
----   SET @sql=@sql + ' dbo.encryptDB(t.[Control_No])=m.refno'    
--      
--                PRINT @sql    
--                EXEC(@sql)    
--    
--                PRINT ( 'spa_make_bulk_payment_csv ''' + @ditital_id    
--                        + ''',NULL,''y''' )    
--                EXEC ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')    
--            END    
------############## -----------------------------------------------------------------               
     
        SET @url_desc = 'paymentType=' + ISNULL(@trn_type, '')    
        SET @desc = 'HATTON NATIONAL BANK PLC Download <u>' + ISNULL(@trn_type,    
                                                              'ALL')    
            + '</u> is completed.  TXN Found:'    
            + CAST(ISNULL(@total_row, 0) AS VARCHAR) + '  Total Amount: '    
            + CAST(ISNULL(@total_amount, 0) AS VARCHAR)    
        SET @desc = @desc + ' Local Time: '    
            + CONVERT(VARCHAR, dbo.getDateHO(GETUTCDATE()), 120)    
--        IF @fromDate IS NOT NULL AND @toDate IS NOT NULL     
--   SET @desc = @desc + '<br>Date Range between '+@fromDate+ ' and ' +@toDate    
    
        IF @total_row_pending IS NOT NULL    
            AND @total_amount_pending IS NOT NULL     
            SET @desc = @desc + '<br><i>Cover fund not enough(Pending:'    
                + CAST(@total_row_pending AS VARCHAR) + ' AMT: '    
                + CAST(@total_amount_pending AS VARCHAR) + ')</i>'    
    
        PRINT @desc    
        EXEC spa_message_board 'u', @downloadBy, NULL, @batch_id, @desc, 'c',    
            @process_id, NULL, @url_desc    
    
           
            
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
      
     SET @sql1 = ' insert into TransPaidStatus_OUT(refno,status)    
      SELECT m.refno,''Post'' FROM ' + @ledger_tabl + ' t  
      JOIN moneysend m WITH (NOLOCK) on m.refno=dbo.encryptDB(t.[Reference Number])  
      WHERE m.agentid='''+@partneragentcode+''''    
     EXEC(@sql1)      
                END      
  --------------------------------------------------------------------------------------------    
 COMMIT TRANSACTION TRANS      
    END TRY    
    BEGIN CATCH    
    
        IF @@trancount > 0     
            ROLLBACK TRANSACTION TRANS    
    
     
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
                        'spa_Batch_FileGeneration_HNB' ,    
                        'SQL' ,    
                        @desc ,    
                        'SQL' ,    
                        'SP' ,    
                        LEFT(@ditital_id,20) ,    
                        GETDATE()    
        SET @desc = @@IDENTITY    
        SELECT  'ERROR' ,    
                @desc ,    
                'Error Please try again'    
    END CATCH
IF OBJECT_ID('spa_Export_Bexmoney','P') IS NOT NULL
DROP PROCEDURE	spa_Export_Bexmoney
GO
/*
** Database			: prabhuUSA
** Object 			: spa_Export_Bexmoney
**
** Purpose 			: Transaction report generation for prabhuUSA
**
** Author			:  Anonymous
** MODIFIED Author	:  Rajan Gauchan
** Date				:  24 JAN 2013, FRI
**
** Modifications	:

*   i)Currency Code,FC Amount,	Remitter F Name,	
*   Remitter M Name,Remitter L Name,Remitter Address,	
*   Remiter Tel No,	Id No,	Id Issue Dt(dd/MMM/yyyy),Id Exp Dt(dd/MMM/yyyy),Bene First Name,Bene Middle Name,	
*   Bene Last Name,	Bene Address,Bene Tel No,Bene Bank Name,Bene Bank A/c No,Bene Bank Branch,Bene City were 
*   added on JAN 27,13 in the sql query ie output section
*  ii)Standard format applied to the existing proc	
** Execute Examples :
** spa_Export_Bexmoney '20100001','Bank Transfer','deepen',NULL,':','1234555','PBBL' 
*/
 create PROC [dbo].[spa_Export_Bexmoney]
    @agent_id VARCHAR(50) ,
    @status VARCHAR(50),
    @paymentType VARCHAR(50) = NULL ,
    @login_user_id VARCHAR(50) ,
    @branch_id VARCHAR(50) ,
    @fromdate VARCHAR(50),
	@todate VARCHAR(50),
	@ddDate VARCHAR(50),
    @ditital_id VARCHAR(200) = NULL ,
    @process_id VARCHAR(150) ,
    @batch_Id VARCHAR(100) = NULL

    AS 
    SET XACT_ABORT ON ;  
    BEGIN TRY  
  
        DECLARE @desc VARCHAR(5000)  
        DECLARE @ledger_tabl VARCHAR(100) ,
            @sql VARCHAR(MAX)  
  
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
        FROM    agentdetail a
                JOIN agentbranchdetail b ON a.agentcode = b.agentcode
        WHERE   agent_branch_code = @branch_id  
  
        BEGIN TRANSACTION  trans
			SET @ledger_tabl = dbo.FNAProcessTbl(@batch_id, @login_user_id,
                                             @process_id)   
              
       SET @sql = '
       SELECT	   
				   paidCtype [Currency Code],
				   paidAmt [FC Amount],
				   dbo.FNAFristMiddleLastName(''f'',SenderName) as [Remitter F Name],
				   dbo.FNAFristLastName(''m'',SenderName) as [Remitter M Name],
				   dbo.FNAFristLastName(''l'',SenderName) as [Remitter L Name],
				   ISNULL(SenderAddress,'''') as [Remitter Address],
				   ISNULL(SenderPhoneno,'''') as [Remiter Tel No],
				   ISNULL(SenderPassport,'''') as [Id No],
				   convert(varchar(15),ID_Issue_date,103)	as [Id Issue Dt],
				   convert(varchar(15),senderVisa,103)		as [Id Exp Dt],
				   dbo.FNAFristMiddleLastName(''f'',ReceiverName) as [Bene First Name],
				   dbo.FNAFristLastName(''m'',ReceiverName) as [Bene Middle Name],
				   dbo.FNAFristLastName(''l'',ReceiverName) as [Bene lastname Name],
				   ISNULL(ReceiverAddress,'''') as [Bene Address],
				   ISNULL(ReceiverPhone,'''') as [Bene Tel No],
				   CASE  WHEN  paymentType in (''Cash Pay'') then '''' 
						 WHEN paymentType in (''Bank transfer'')  then rbankname
						 ELSE ben_bank_name  
						 END as [Bene Bank Name],
				   ISNULL(rBankACNo,'''')as [Bene Bank A/c No], 
				   CASE  WHEN  paymentType in (''Cash Pay'') then '''' 
				    	 WHEN paymentType in (''Bank Transfer'') then isNULL(rBankBranch,'''') else rBankAcType end as [Bene Bank Branch],
				   ISNULL(ReceiverCity,'''') as [Bene City]
			INTO '+@ledger_tabl+'
			FROM moneysend m with(nolock) 
			LEFT OUTER JOIN agentbranchdetail b with(nolock) on m.rBankID=b.agent_branch_code 
			WHERE agentid='''+@agent_id+''' 
			AND Transstatus = ''Payment''
			AND '+@ddDate+' BETWEEN '''+@fromdate+''' AND '''+@todate+''''
			
		IF @paymentType IS NOT NULL 
            SET @sql = @sql + ' and paymentType = ''' + @paymentType + ''''  
        IF @status IS NOT NULL 
            SET @sql = @sql + ' and status = ''' + @status + ''''  
        
        SET @sql = @sql + ' order by confirmDate
        '  
         
        PRINT ( @sql ) 
		--RETURN
		PRINT 'here'
        EXEC(@sql)  
		PRINT 'here1'
        SET @total_row = @@rowcount  
  
        DECLARE @total_amount MONEY  
        CREATE TABLE #temp_total_amount ( total_amount MONEY )  
       -- SELECT * FROM  #temp_total_amount   return
		
        SET @sql = '  
				insert #temp_total_amount(total_amount)  
				select sum([FC Amount]) from ' + @ledger_tabl + ''  
				
        EXEC(@sql)  
        
          
        SELECT  @total_amount = total_amount
        FROM    #temp_total_amount  
  
        DECLARE @total_row_pending INT ,
            @total_amount_pending MONEY  
		
--        DELETE  [temp_trn_csv_pay]
--        WHERE   digital_id_payout = @ditital_id  
  
--        SET @sql = 'INSERT INTO [temp_trn_csv_pay]  
--	([tranno],[refno],[ReceiverName],[TotalRoundAmt],[paidDate],[paidBy],[expected_payoutagentid],  
--	[rBankID],[rBankName],[rBankBranch],[digital_id_payout])  
--	select 
--		tranno,refno,receiverName,totalRoundAmt,'''+ CONVERT(VARCHAR, @GMT_Date, 120) + ''',''' + @login_user_id+ ''',  
--''' + @agent_id + ''',''' + @rBankID + ''',''' + @rBankName + ''','''+ @rBankBranch + ''',''' + @ditital_id + '''   
--		from ' + @ledger_tabl+ ' t 
--		JOIN moneysend m with (nolock) on dbo.encryptDB(t.[Order No / Ref No])=m.refno
--		WHERE m.paymentType<>''Cash Pay'''  
--        PRINT @sql  
--        EXEC(@sql)  
  
--        PRINT ( 'spa_make_bulk_payment_csv ''' + @ditital_id + ''',NULL,''y''' )  
        --EXEC ('spa_make_bulk_payment_csv '''+@ditital_id+''',NULL,''y''')  
  
        DECLARE @url_desc VARCHAR(500)  
        SET @url_desc = 'paymentType=' + ISNULL(@paymentType, '')
        SET @desc = 'BEXMONEY DOWNLOAD <strong><u>' + ISNULL(@paymentType,
                                                              'ALL')
            + '</u> '+ ISNULL(@status,'ALL')+'</strong> From:'+@fromdate+' To:'+@todate
            + ' is completed.  TXN Found:'
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
                        @batch_id ,
                        'spa_Export_Bexmoney' ,
                        @desc ,
                        'SQL' ,
                        'SP' ,
                        @ditital_id ,
                        GETDATE()  
        SELECT  'ERROR' ,
                '1050' ,
                'Error Please try again'  
  
    END CATCH  

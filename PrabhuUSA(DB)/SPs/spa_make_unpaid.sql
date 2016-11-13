DROP PROCEDURE [dbo].[spa_make_unpaid]
go 
CREATE PROCEDURE [dbo].[spa_make_unpaid]
    @flag CHAR(1) ,
    @tran_no INT = NULL ,
    @control_no VARCHAR(50) = NULL ,
    @user VARCHAR(50) = NULL ,
    @digi_info VARCHAR(100) = NULL ,
    @remarks VARCHAR(200) = NULL ,
    @rBankID VARCHAR(50) = NULL ,
    @invoice_no VARCHAR(50) = NULL ,
    @amend_type VARCHAR(50) = NULL ,
    @sno INT = NULL ,
    @change_date VARCHAR(50) = NULL
AS 
    IF @flag = 'u' 
        BEGIN TRY   
            BEGIN TRANSACTION  
            DECLARE @sql VARCHAR(3000) ,
                @trans_mode CHAR(1) ,
                @txt_sql VARCHAR(2000) ,
                @tranno INT ,
                @tran_note VARCHAR(2000) ,
                @refno VARCHAR(100) ,
                @branch_id VARCHAR(50) ,
                @receiveagentid VARCHAR(50) ,
                @totalroundamt MONEY ,
                @receivingComm MONEY ,
                @ag VARCHAR(200)  
  
            SELECT  @tranno = tranno ,
                    @refno = refno ,
                    @trans_mode = UPPER(trans_mode) ,
                    @branch_id = rBankID ,
                    @receiveagentid = receiveagentid ,
                    @totalroundamt = totalroundamt ,
                    @receivingComm = receiverCommission
            FROM    moneySend WITH (NOLOCK)
            WHERE   refno = dbo.encryptDb(@control_no)  
            SET @sql = 'update moneysend set  
								status=''Un-Paid'',  
								paidBy=NULL,  
								paidDate=NULL,  
								paidTime=NULL,  
								PODDate=NULL'  
  
            IF @trans_mode IS NULL 
                BEGIN  
                    SET @sql = @sql + ', receiverCommission=0.00'  
                END  
  
            SET @sql = @sql + ' where tranno=' + CAST(@tranno AS VARCHAR)  
--print(@sql)  
--return  
            EXEC(@sql)  
  
            SET @tran_note = 'insert into transactionnotes(refno,Comments,DatePosted,PostedBy,uploadBy,noteType,tranno)   
values(''' + @refno + ''',''----Transaction Made Un-Paid by HO:' + @user
                + '----'',''' + CONVERT(VARCHAR, GETDATE()) + ''',  
''' + ISNULL(@user, ':') + ''',''A'',''7'',''' + CONVERT(VARCHAR, @tranno)
                + ''')'  
  
--print(@tran_note)  
            EXEC(@tran_note)  
  
            UPDATE  transaction_amendment
            SET     approve_by = @user ,
                    approve_date = GETDATE() ,
                    Approved_DG_INFO = @digi_info
            WHERE   tranno = @tran_no
                    AND sno = @sno  
  
  
--Update agentBranchDetail set currentBalance=isNull(currentBalance,0)+(@totalroundamt)  
--where agent_branch_code=@branch_id   
  
            UPDATE  agentDetail
            SET     currentBalance = ISNULL(currentBalance, 0)
                    + ( @totalroundamt )
            WHERE   agentcode = @receiveagentid  
  
            DELETE  agentbalance
            WHERE   remarks = 'Commission Gain:' + @control_no + ''  
  
  
  
--Update PrabhuCash.dbo.agentDetail set currentBalance=isNull(currentBalance,0)+(@totalroundamt)  
--where agentcode=@receiveagentid  
		DECLARE @lsname VARCHAR(100)
		SELECT @lsname=additional_value FROM dbo.static_values WHERE sno =200
           SET @sql=' UPDATE  '+@lsname+'moneysend
            SET     status = ''Un-Paid'' ,
                    paidBy = NULL ,
                    paidDate = NULL ,
                    paidTime = NULL ,
                    PODDate = NULL
            WHERE   refno ='''+ dbo.encryptDb(@control_no) +''''
  
			EXEC (@sql)
  
            SELECT  'SUCCESS' ,
                    'The Transation has been made Un-Paid Successfully'  
            COMMIT TRANSACTION  
        END TRY    
        BEGIN CATCH    
            ROLLBACK TRANSACTION    
    
            DECLARE @desc VARCHAR(1000) ,
                @error_id INT    
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
                            'spa_make_unpaid' ,
                            'SQL' ,
                            @desc ,
                            'SQL' ,
                            'SP' ,
                            @digi_info ,
                            GETDATE()    
            SET @error_id = IDENT_CURRENT('error_info')  
            SELECT  'ERROR' ,
                    @error_id ,
                    'Error Occured While Processing Your Request<br>Please Try Again Later'    
    
        END CATCH  
  
    IF @flag = 'i' -- fro make unpaid request sumbit  
        BEGIN  
            IF EXISTS ( SELECT  tranno
                        FROM    transaction_amendment
                        WHERE   tranno = @tran_no
                                AND approve_by IS NULL ) 
                BEGIN  
                    SELECT  'ERROR' ,
                            '1002' ,
                            'This Trasaction is Already Requested for Amendments'    
                    RETURN    
                END  
            INSERT  transaction_amendment
                    ( tranno ,
                      amend_type ,
                      requested_user ,
                      requested_date ,
                      Requested_DG_INFO ,
                      remarks
                    )
            VALUES  ( @tran_no ,
                      @amend_type ,
                      @user ,
                      GETDATE() ,
                      @digi_info ,
                      'Unpaid:' + dbo.decryptdb(@control_no) + ':' + @rBankID
                      + '<br>' + @remarks
                    )  
            SELECT  'SUCCESS' ,
                    'Request has been submitted'  
        END  
  
    IF @flag = 'd'  -- for paid date change request sumbit  
        BEGIN  
            IF EXISTS ( SELECT  tranno
                        FROM    transaction_amendment
                        WHERE   tranno = @tran_no
                                AND approve_by IS NULL ) 
                BEGIN  
                    SELECT  'ERROR' ,
                            '1003' ,
                            'This Trasaction is Already Requested for Amendments '    
                    RETURN    
                END  
  
            INSERT  transaction_amendment
                    ( tranno ,
                      amend_type ,
                      requested_user ,
                      Requested_DG_INFO ,
                      remarks ,
                      requested_date ,
                      podDate
                    )
            VALUES  ( @tran_no ,
                      'CHANGE PAID DATE' ,
                      @user ,
                      @digi_info ,
                      'ChangePaidDate:' + @control_no + +' To '
                      + CONVERT(VARCHAR(10), @change_date, 101) + '<br>'
                      + @remarks ,
                      GETDATE() ,
                      @change_date
                    )  
            SELECT  'SUCCESS' ,
                    'Request has been submitted'  
        END  
  
    IF @flag = 'c'  -- fro paid date request approve  
        BEGIN  
            DECLARE @actual_date VARCHAR(50) ,
                @trn_no INT  
            SELECT  @actual_date = podDate ,
                    @trn_no = tranno
            FROM    transaction_amendment
            WHERE   tranno = @tran_no
                    AND sno = @sno  
  
            UPDATE  moneysend
            SET     paidDate = @actual_date ,
                    PODDate = @actual_date
            WHERE   tranno = @trn_no  
  
  
            UPDATE  agentbalance
            SET     DOT = @actual_date ,
                    update_ts = @actual_date ,
                    fund_date = @actual_date
            WHERE   remarks = 'Commission Gain:' + @control_no + ''  
  
            UPDATE  transaction_amendment
            SET     approve_by = @user ,
                    approve_date = GETDATE() ,
                    Approved_DG_INFO = @digi_info
            WHERE   tranno = @tran_no
                    AND sno = @sno  
  
            SET @tran_note = 'insert into transactionnotes(comments,DatePosted,PostedBy,tranno,RefNo,digi_info,uploadBy,noteType)   
values(''----Paid Date Changed by HO:' + @user + '----'','''
                + CONVERT(VARCHAR, GETDATE()) + ''',''' + ISNULL(@user, ':')
                + ''',''' + CONVERT(VARCHAR, @tran_no) + ''','''
                + dbo.encryptdb(@control_no) + ''',''' + ISNULL(@digi_info,
                                                              ':')
                + ''',''A'',''7'')'  
  
--print(@tran_note)  
            EXEC(@tran_note)  
        END  
  
    IF @flag = 'g'   --for invoice delete request  
        BEGIN  
            IF EXISTS ( SELECT  tranno
                        FROM    transaction_amendment
                        WHERE   tranno = @invoice_no
                                AND approve_by IS NULL ) 
                BEGIN  
                    SELECT  'ERROR' ,
                            '1004' ,
                            'This Invoice Number has been Already Requested for Removal'    
                    RETURN    
                END  
            INSERT  transaction_amendment
                    ( tranno ,
                      amend_type ,
                      requested_user ,
                      Requested_date ,
                      Requested_DG_INFO ,
                      remarks ,
                      invoice_no 
                    )
            VALUES  ( @invoice_no ,
                      @amend_type ,
                      @user ,
                      GETDATE() ,
                      @digi_info ,
                      'Invoice Delete:' + @invoice_no + '<br>' + @remarks ,
                      @invoice_no  
                    )  
  
            SELECT  'SUCCESS' ,
                    'Invoice Removal Request has been submitted'  
        END  
  
    IF @flag = 'f' 
        BEGIN  
            DELETE  agentbalance
            WHERE   invoiceNo = CAST(@tran_no AS VARCHAR)  
  
            UPDATE  transaction_amendment
            SET     approve_by = @user ,
                    approve_date = GETDATE() ,
                    Approved_DG_INFO = @digi_info
            WHERE   tranno = @tran_no
                    AND sno = @sno  
  
            SELECT  'SUCCESS' ,
                    'Invoice has been Successfully Removed'  
        END   
  
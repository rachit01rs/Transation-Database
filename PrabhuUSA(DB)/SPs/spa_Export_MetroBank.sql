IF OBJECT_ID('spa_Export_MetroBank', 'P') IS NOT NULL 
    DROP PROC [dbo].[spa_Export_MetroBank]
GO 
CREATE PROC [dbo].[spa_Export_MetroBank]  
    @flag CHAR(1) ,  
    @ftFilename VARCHAR(50) = NULL ,  
    @userName VARCHAR(50) = NULL  
/*  
@flag value  
 s   = select all records from the moneysend  
 c   = count the records from the moneysend  
*/  
AS   
    DECLARE @txt_sql VARCHAR(MAX) ,  
        @PHP_MetroBank_agent VARCHAR(50) ,  
        @USD_MetroBank_agent VARCHAR(50) ,  
        @FtBankCode VARCHAR(50)  
------------------------------------------------------------------  
    SET @PHP_MetroBank_agent = '20100161'  
    SET @USD_MetroBank_agent = '        '  
    SET @FtBankCode = 'PMTRUS01'  
------------------------------------------------------------------  
    IF @flag = 's'   
        BEGIN  
            SELECT  *  
            INTO    #TEMP  
            FROM    ( SELECT    @FtBankCode FtBankCode ,           --1  
                                @FtBankCode ftSendingBank ,           --2  
                                dbo.decryptDb(refno) FtReferenceNo ,        --3  
                                LEFT(ISNULL(senderName, ''), 35) FtRemitter ,      --4  
                                LEFT(ISNULL(sender_mobile, '') + '/'  
                                     + ISNULL(senderPhoneNo, ''), 40) FtRemMobileTel ,    --5  
                                LEFT(ISNULL(SenderAddress, senderfax), 40) FtRemAddr1 ,    --6  
                                '' FtRemAddr2 ,              --7  
                                LEFT(SenderCity, 20) FtRemCity ,         --8  
                                LEFT(Branch, 20) ftRemState ,          --9  
                                'US' ftRemCountry ,             --10  
                                '' ftRemGender ,             --11  
                                '' ftRemDateofBirth ,            --12  
                                'I' ftRemType ,              --13  
                                '' ftRemSourceofFunds ,            --14  
                                '' ftRemOccupation ,            --15  
                                '01' ftRemPaymentType ,            --16  
                                LEFT(ISNULL(reason_for_remittance, 'Personal'),  
                                     50) ftRemPurpose ,            --17   
                                LEFT(ReceiverRelation, 50) ftRemRelationshiptoBnf ,     --18  
                                LEFT(ReciverMessage, 35) ftMessagetoBeneficiary1 ,     --19  
                                '' ftMessagetoBeneficiary2 ,          --20  
                                '' ftMessagetoBeneficiary3 ,          --21  
                                '' ftIDQuestion ,             --22  
                                '' ftIDAnswer ,              --23  
                                LEFT(ReceiverName, 40) ftBnfName ,         --24  
                                '' ftBNFGender ,             --25  
                                'I' ftBnfType ,              --26  
                                LEFT(ISNULL(ReceiverAddress, ReceiverFax), 40) FtBnfAddr1 ,   --27  
                                '' FtBnfAddr2 ,              --28  
                                LEFT(ReceiverCity, 20) ftBnfCity ,         --29  
                                LEFT(rBankBranch, 20) ftBnfState ,         --30  
                                '' ftBnfZipCode ,             --31  
                                LEFT(ISNULL(receiver_mobile, '') + '/'  
                                     + ISNULL(ReceiverPhone, ''), 40) FtBnfMobileTel ,    --32  
                                '' ftBnfEmailAddress ,            --33  
                                REPLACE(CONVERT(VARCHAR, ConfirmDate, 101),  
                                        '/', '') FdRemittedDate ,         --34  
                                '' FnOrgAmt ,              --35  
                                '' FtOrgCcy ,              --36  
                                '' fnExchangeRate ,             --37  
                                SCharge fnTransactionFee ,           --38  
                                PaidCtype ftTranFeeCcy ,           --39  
                                TotalRoundAmt fnNetAmt ,           --40  
                                receiveCType ftNetCcy ,            --41  
                                LEFT(CASE WHEN paymentType = 'Account Deposit to Other Bank'  
                                          THEN ben_bank_name  
                                          ELSE 'METROBANK'  
                                     END, 30) ftBankName ,           --42  
                                CASE WHEN paymentType = 'Metrobank World Cash Card'  
                                     THEN '799'  
                                     ELSE ben_bank_id  
                                END ftBank1 ,              --43  
                                '' ftLocation ,              --44  
                                rBankACNo FtAccountNo ,            --45  
                                '' ftRemACNo ,              --46  
                                '' ftDocRefNo ,              --47  
                                CASE WHEN paymentType = 'Cash Pay - MetroBank'  
                                     THEN 'CPU01'  
                                     WHEN paymentType = 'Cash Pay'  
                                     THEN 'CPU41'  
                                     WHEN paymentType = 'Bank Transfer'  
                                     THEN 'DDM01'  
                                     WHEN paymentType = 'Metrobank World Cash Card'  
                                     THEN 'DDM21'  
                                     WHEN paymentType = 'Account Deposit to Other Bank' AND ben_bank_id<>'5027' ---PSBANK ID 5027  
                                     THEN 'DDO01'  
                                     WHEN paymentType = 'Account Deposit to Other Bank' AND ben_bank_id='5027' ---PSBANK ID 5027  
                                     THEN 'DDO11'  
                                END ftTranType ,             --48  
                                LEFT(senderPassport, 20) ftRemPIN ,         --49  
                                LEFT(ReceiverID, 20) ftBnfID ,          --50  
                                '' ftBillerCode ,             --51  
                                '' ftSubscriber ,             --52  
                                '' ftSubscriberNo ,             --53  
                                '' ftPayeeName ,             --54  
                                '' ftPaymentType ,             --55  
                                '' fdPayPeriod1 ,             --56  
                                '' fdPayPeriod2 ,             --57  
                                '' ftD2DAreaCode ,             --58  
                                '' ftRemarks ,              --59  
                                @ftFilename ftFilename ,           --60  
                                '' ftReverse ,              --61  
                                dbo.decryptDb(refno) ftOrigRefNo         --62  
                      FROM      moneysend m WITH ( NOLOCK )  
                      JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
                      WHERE     expected_payoutagentid = @PHP_MetroBank_agent  
                                AND Transstatus = 'Payment'  
                                AND is_downloaded IS NULL  
                                AND status = 'Un-Paid'  
                                AND ISNULL(a.disable_payout,'n')<>'y'
                      UNION ALL  
                      SELECT    @FtBankCode FtBankCode ,           --1  
                                @FtBankCode ftSendingBank ,           --2  
                                dbo.decryptDb(refno) FtReferenceNo ,        --3  
                                LEFT(ISNULL(senderName, ''), 35) FtRemitter ,      --4  
                                LEFT(ISNULL(sender_mobile, '') + '/'  
                                     + ISNULL(senderPhoneNo, ''), 40) FtRemMobileTel ,    --5  
                                LEFT(ISNULL(SenderAddress, senderfax), 40) FtRemAddr1 ,    --6  
                                '' FtRemAddr2 ,              --7  
                                LEFT(SenderCity, 20) FtRemCity ,         --8  
                         LEFT(Branch, 20) ftRemState ,          --9  
                                'US' ftRemCountry ,             --10  
                                '' ftRemGender ,             --11  
                                '' ftRemDateofBirth ,            --12  
                                'I' ftRemType ,              --13  
                                '' ftRemSourceofFunds ,            --14  
                                '' ftRemOccupation ,            --15  
                                '01' ftRemPaymentType ,            --16  
                                LEFT(ISNULL(reason_for_remittance, 'Personal'),  
                                     50) ftRemPurpose ,            --17   
                                LEFT(ReceiverRelation, 50) ftRemRelationshiptoBnf ,     --18  
                                LEFT(ReciverMessage, 35) ftMessagetoBeneficiary1 ,     --19  
                                '' ftMessagetoBeneficiary2 ,          --20  
                                '' ftMessagetoBeneficiary3 ,          --21  
                                '' ftIDQuestion ,             --22  
                                '' ftIDAnswer ,              --23  
                                LEFT(ReceiverName, 40) ftBnfName ,         --24  
                                '' ftBNFGender ,             --25  
                                'I' ftBnfType ,              --26  
                                LEFT(ISNULL(ReceiverAddress, ReceiverFax), 40) FtBnfAddr1 ,   --27  
                                '' FtBnfAddr2 ,              --28  
                                LEFT(ReceiverCity, 20) ftBnfCity ,         --29  
                                LEFT(rBankBranch, 20) ftBnfState ,         --30  
                                '' ftBnfZipCode ,             --31  
                                LEFT(ISNULL(receiver_mobile, '') + '/'  
                                     + ISNULL(ReceiverPhone, ''), 40) FtBnfMobileTel ,    --32  
                                '' ftBnfEmailAddress ,            --33  
                                REPLACE(CONVERT(VARCHAR, ConfirmDate, 101),  
                                        '/', '') FdRemittedDate ,         --34  
                                '' FnOrgAmt ,              --35  
                                '' FtOrgCcy ,              --36  
                                '' fnExchangeRate ,             --37  
                                SCharge fnTransactionFee ,           --38  
                                PaidCtype ftTranFeeCcy ,           --39  
                                TotalRoundAmt fnNetAmt ,           --40  
                                receiveCType ftNetCcy ,            --41  
                                LEFT(CASE WHEN paymentType = 'Account Deposit to Other Bank'  
                                          THEN ben_bank_name  
                                          ELSE 'METROBANK'  
                                     END, 30) ftBankName ,           --42  
                                CASE WHEN paymentType = 'Account Deposit to Other Bank'  
                                     THEN ben_bank_id  
                                END ftBank1 ,              --43  
                                '' ftLocation ,              --44  
                                rBankACNo FtAccountNo ,            --45  
                                '' ftRemACNo ,              --46  
                                '' ftDocRefNo ,              --47  
                                CASE WHEN paymentType = 'Cash Pay'  
                                     THEN 'CPU02'  
                                     WHEN paymentType = 'Bank Transfer'  
                                     THEN 'DDM02'  
                                     WHEN paymentType = 'Account Deposit to Other Bank' AND ben_bank_id<>'5027' ---PSBANK ID 5027  
                                     THEN 'DDO05'  
                                     WHEN paymentType = 'Account Deposit to Other Bank' AND ben_bank_id='5027' ---PSBANK ID 5027  
                                     THEN 'DDO12'  
                                END ftTranType ,             --48  
                                LEFT(senderPassport, 20) ftRemPIN ,         --49  
                                LEFT(ReceiverID, 20) ftBnfID ,          --50  
                                '' ftBillerCode ,             --51  
                                '' ftSubscriber ,             --52  
                                '' ftSubscriberNo ,             --53  
                                '' ftPayeeName ,             --54  
                                '' ftPaymentType ,             --55  
                                '' fdPayPeriod1 ,             --56  
                                '' fdPayPeriod2 ,             --57  
                                '' ftD2DAreaCode ,             --58  
                                '' ftRemarks ,              --59  
                                @ftFilename ftFilename ,           --60  
                                '' ftReverse ,              --61  
                                dbo.decryptDb(refno) ftOrigRefNo         --62  
                      FROM      moneysend m WITH ( NOLOCK ) 
                      JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid  
                      WHERE     expected_payoutagentid = @USD_MetroBank_agent  
                                AND Transstatus = 'Payment'  
                                AND is_downloaded IS NULL  
                                AND status = 'Un-Paid'  
                                AND ISNULL(a.disable_payout,'n')<>'y'
                    ) TEMP  
     
   UPDATE moneysend     
    SET status='Post',    
      is_downloaded='y',    
      downloaded_ts=dbo.getDateHO(getutcdate()),    
      downloaded_by=@userName   
      FROM moneysend m JOIN #temp t  
       ON m.refno=dbo.encryptDB(t.FtReferenceNo) 
       JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
       WHERe ISNULL(a.disable_payout,'n')<>'y'
 
   
   --------------------------------------------------------------------------------------------
   -- PIC Update to Post
   UPDATE prabhuCash.dbo.moneysend     
    SET status='Post',    
      is_downloaded='y',    
      downloaded_ts=dbo.getDateHO(getutcdate()),    
      downloaded_by='USA: '+@userName   
      FROM prabhuCash.dbo.moneysend m JOIN #temp t  
       ON m.refno=dbo.encryptDB(t.FtReferenceNo)  
   --------------------------------------------------------------------------------------------
  
            SELECT  *  
            FROM    #temp  
  
        END  
  
  
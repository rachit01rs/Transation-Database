drop  PROCEDURE [dbo].[spa_MPOS_BalanceTransfer]     
go 
CREATE  PROCEDURE [dbo].[spa_MPOS_BalanceTransfer]                              
    (                              
      @flag VARCHAR(2) ,                              
      @MobileNr VARCHAR(20) ,                              
   @user_login_id VARCHAR(50)=NULL,            
      @mobile_deno_sno INT=NULL ,          
      @operator_sno INT=NULL,  
      @sendingCountry VARCHAR(100)=NULL,  
      @receivingCountry VARCHAR(100)=NULL,  
      @agentCode VARCHAR(20)=NULL,  
      @agentBranchCode VARCHAR(20)=NULL ,  
      @customerId VARCHAR(20)=NULL,  
      @customerName VARCHAR(200)=NULL,  
      @senderIdType VARCHAR(20)=NULL,  
      @senderIdDescription VARCHAR(200)=NULL,  
      @senderMobile VARCHAR(20)=NULL,  
      @sno INT=NULL,  
      @refno VARCHAR(20) =NULL,  
      @pending_TxnId INT=NULL,  
      @balance MONEY=NULL,  
      @SettCCY VARCHAR(5)=NULL,                  
      @status VARCHAR(50) = NULL ,                  
      @DLR_Response VARCHAR(150) = NULL  
   )                              
AS              
BEGIN            
          
      
    DECLARE  @InvoiceNO VARCHAR(100),@money_id VARCHAR(50),@MPOS_Acc VARCHAR(50),@MPOS_Comm_Acc VARCHAR(50),@MPOS_COST_COMM FLOAT,  
    @row_count INT,  
 @gmtDate VARCHAR(30)    
  SELECT @money_id=money_id FROM dbo.money_transfer WHERE MoneyTransfer='MPOS'    
  select @MPOS_Acc=static_value from static_values where sno=505 and description = 'MPOS'              
   SET @gmtDate=dbo.getDateHO(GETUTCDATE())    
     
                   
   IF @flag = 'i'                               
        BEGIN    
          
        DECLARE            
   @denomination MONEY ,        
      @DenoCCY VARCHAR(3) ,        
       @SendingCurrency VARCHAR(3) ,    
      @gross_sending_amount MONEY ,        
      @total_charge MONEY ,        
      @agent_commission MONEY,  
      @denomination_usd MONEY,  
      @actionkey VARCHAR(10),       
      @Operator_name VARCHAR(100),       
      @roundby INT ,  
      @errormsg VARCHAR(1000),  
      @tranno VARCHAR(20),  
      @dRate_sendingCCY MONEY,  
      @dRate_ReceivingCCY MONEY,  
      @trannoref VARCHAR(10),  
   @process_id VARCHAR(100),  
   @refno_seed VARCHAR(20),  
   @rnd_id varchar(4),  
   @rnd_id1 varchar(4)   
                                                               
          SELECT   
    @denomination=denomination,  
    @DenoCCY=DenoCCY,  
    @SendingCurrency=SendingCurrency,  
    @gross_sending_amount=gross_sending_amount,  
    @total_charge=total_charge,  
    @agent_commission=agent_commission,  
    @denomination_usd=denomination_usd,  
    @actionkey=actionkey,  
    @Operator_name=Operator_name,  
    @roundby=roundby,  
    @dRate_sendingCCY=dRate_SendCCY,  
    @dRate_ReceivingCCY=dRate_ReceivingCCY   
   FROM dbo.FNAExGetDenoRate(@agentCode,@sendingCountry,@mobile_deno_sno,@operator_sno,@receivingCountry)     
     
   
                    
           IF ISNULL (@gross_sending_amount, '' ) = ''          
    SET @errormsg = ' User Selling Price with respect to currency Not defined <br>'          
                     
           IF ISNULL (@SendingCurrency,'' ) = ''          
    SET @errormsg = @errormsg + ' User Currency Not defined <br>'          
                     
           IF ISNULL (@denomination,'' ) = ''         
    SET @errormsg = @errormsg + ' Face value  Not defined <br>'          
                     
           IF ISNULL (@DenoCCY,'' ) = ''          
    SET @errormsg = @errormsg + ' Face value Currency  Not defined <br>'          
                     
           IF ISNULL (@dRate_sendingCCY,'' ) = ''          
    SET @errormsg = @errormsg + ' Exchange rate is not defined for sending Currenct <br>'      
      
               IF ISNULL (@dRate_ReceivingCCY,'' ) = ''          
    SET @errormsg = @errormsg + ' Exchange rate is not defined for Receiving Currenct <br>'        
            
    IF ISNULL (@agent_commission,'' ) = ''          
    SET @errormsg = @errormsg + ' User commission  Not defined <br>'           
               
             
  --SELECT @user_balance =  dbo.FNAGetBalanceAgent( @User_Id)           
            
            
  --IF @SellingPriceCCY > @user_balance          
  -- SET @errormsg = @errormsg + ' The available balance is less than the Top-up Balance.Please contact support team. Your available balance is '            
  --      + CAST (@user_balance AS VARCHAR(20))   
             
  IF  @errormsg <> ''          
  BEGIN          
   SELECT 1000 code ,'ERROR' STATUS, @errormsg MSG  ,-1 tranno ,  -1 refno          
   RETURN          
  END           
    
     SET @rnd_id=left(abs(checksum(newid())),2)                      
     
 SET @rnd_id1=left(abs(checksum(newid())),2)   
 set @trannoref=ident_current('MPOS_BalanceTransfer')+1       
 set @process_id=left(cast(abs(CHECKSUM(newid())) as varchar),6)                      
 set @refno_seed =[dbo].[FNARefno](@trannoref, @process_id)     
  
 SET @refno= '10'+ left(@rnd_id,1)+left(cast(@refno_seed as varchar),3)+right(@rnd_id,1)+right(@rnd_id1,1)+ substring(cast(@refno_seed as varchar),4,3) +  
 left(@rnd_id,1)  
               
     INSERT INTO dbo.MPOS_BalanceTransfer  
             ( refno ,  
    AgentCode ,  
               Agent_Branch_Code ,  
               Agent_User_login ,  
               MobileNo ,  
               DT_date ,  
               mobile_operator ,  
               denomination_sno ,  
               denomination ,  
               DenoCCY ,  
               SendingCurrency ,  
               gross_sending_amount ,  
               total_charge ,  
               agent_commission ,  
               denomination_usd ,  
               actionkey ,  
               Operator_name ,  
               roundby ,  
               sendingCountry ,  
               receivingCountry ,  
               customer_id ,  
               customer_name ,  
               senderId_type ,  
               senderId_description ,  
               sender_mobile,  
               dRate_SendCCY,  
               dRate_ReceivingCCY  
             )  
     VALUES  ( @refno,-- Refno - varchar(20)  
				@agentCode , -- AgentCode - varchar(50)  
               @agentBranchCode , -- Agent_Branch_Code - varchar(50)  
               @user_login_id , -- Agent_User_login - varchar(100)  
               @MobileNr , -- MobileNo - varchar(20)  
               @gmtDate , -- DT_date - datetime  
              @operator_sno , -- mobile_operator - int  
               @mobile_deno_sno , -- denomination_sno - int  
               @denomination , -- denomination - money  
               @DenoCCY , -- DenoCCY - varchar(3)  
               @SendingCurrency , -- SendingCurrency - varchar(3)  
               @gross_sending_amount , -- gross_sending_amount - money  
               @total_charge , -- total_charge - money  
               @agent_commission , -- agent_commission - money  
               @denomination_usd , -- denomination_usd - money  
               @actionkey , -- actionkey - varchar(10)  
               @Operator_name , -- Operator_name - varchar(100)  
               @roundby , -- roundby - int  
               @sendingCountry , -- sendingCountry - varchar(200)  
               @receivingCountry , -- receivingCountry - varchar(200)  
               @customerId , -- customer_id - varchar(10)  
               @customerName , -- customer_name - varchar(100)  
               @senderIdType , -- senderId_type - varchar(50)  
               @senderIdDescription , -- senderId_description - varchar(50)  
               @senderMobile, -- sender_mobile - varchar(50)  
               @dRate_sendingCCY,  
               @dRate_ReceivingCCY  
             )                     
             SET @tranno = @@IDENTITY      
             
             ----------------------------------------------Updating the balance------------------------------------------  
                UPDATE  AgentbranchDetail                  
                SET     CurrentBalance = ISNULL(CurrentBalance, 0)                  
                        + ( @gross_sending_amount )                  
                WHERE   agent_branch_code = @agentBranchCode    
                  
                UPDATE dbo.agentDetail SET   
                CurrentBalance=  ISNULL(CurrentBalance, 0)                  
                        + ( @gross_sending_amount )                  
                WHERE agentCode=@agentCode  
                  
                UPDATE dbo.agentsub SET   
                current_balance=  ISNULL(current_balance, 0)                  
                        + ( @gross_sending_amount )                  
                WHERE User_login_Id=@user_login_id  
                  
                --------------------Updating value on Transactional Head-------------  
                UPDATE  AgentbranchDetail                  
                SET     CurrentBalance = ISNULL(CurrentBalance, 0)                  
                        + (@denomination )                  
                WHERE   agent_branch_code = @MPOS_Acc  
                  
                --------------------Updating value on Ledger Account-------------  
                UPDATE dbo.agentDetail SET CurrentBalance=ISNULL(a.CurrentBalance, 0)                  
                        + (@denomination )    
                        FROM dbo.agentDetail a JOIN dbo.agentbranchdetail ab ON a.agentCode=ab.agentCode                
                WHERE   ab.agent_branch_code = @MPOS_Acc  
                  
             ------------------------------------------------------------------------------------------------------------   
             --create invoice as dr  
             
             declare @remarks varchar(500)
             set @remarks=@MobileNr +' '+ cast(@denomination as varchar)+' '+ @DenoCCY +' @ '+ cast(@total_charge as varchar) +' '+ @SendingCurrency + ' Agent Comm:'+ cast(@agent_commission as varchar)
             
                SET @InvoiceNO = 'MPOS:'                  
                    + CAST(IDENT_CURRENT('agentbalance') + 1 AS VARCHAR(100))                          
                IF @InvoiceNO IS NULL                   
                    SET @InvoiceNO = 1                                  
                    ---- DR Entry to AGent        
						
						INSERT  agentbalance                  
                        ( invoiceno ,                  
                          agentcode ,                  
                          CompanyName ,                  
                          Dot ,                  
                          amount ,                  
                          currencyType ,                  
                          XRate ,                  
                          Mode ,                  
						  Remarks ,                  
                          Staffid ,                  
                          dollar_rate ,                  
                          branch_code ,                  
                          fund_date ,                  
                          approved_by ,                  
                          approved_ts ,                  
							money_id                      
                        )                  
                        SELECT  @InvoiceNO ,                  
                                a.agentCode ,                  
                                a.CompanyName ,                  
                                @gmtDate ,                  
                                @gross_sending_amount ,                  
                                @SendingCurrency ,                  
                                @dRate_sendingCCY ,                  
                                'dr' ,                  
								 @remarks,                  
								@user_login_id ,                                
                                ROUND(@gross_sending_amount/ISNULL(@dRate_sendingCCY,1),ISNULL(@roundby,4)),                  
                                b.agent_branch_code ,                  
                                @gmtDate ,                  
								@user_login_id ,                  
                                @gmtDate ,                  
                                @money_id                 
                        FROM    agentbranchdetail b                  
      JOIN agentdetail a ON b.agentcode = a.agentcode                  
                        WHERE   b.agent_branch_code = @agentBranchCode                     
                         
                         
                      ---- CR Entry to MPOS - Inficare    
                       INSERT  agentbalance                  
                        ( invoiceno ,                  
                          agentcode ,                  
                          CompanyName ,                  
                          Dot ,                  
                          amount ,                  
                          currencyType ,                  
                          XRate ,                  
                          Mode ,                  
                          Remarks ,                  
                          Staffid ,                  
                          dollar_rate ,                  
                          branch_code ,                  
                          fund_date ,                  
                          approved_by ,                  
                          approved_ts ,                  
                          money_id                        
                        )                  
                        SELECT  @InvoiceNO ,                  
                                a.agentCode ,                  
                                a.CompanyName ,                  
                                @gmtDate ,                  
                                @denomination ,                  
                                @DenoCCY ,                  
                                @dRate_ReceivingCCY ,                  
                                'cr' ,                  
								@remarks ,                  
								 @user_login_id ,                  
                                ROUND(@denomination/ISNULL(@dRate_ReceivingCCY,1),ISNULL(@roundby,4)) ,                  
                                b.agent_branch_code ,                  
                                @gmtDate ,                  
								@user_login_id ,                  
                                @gmtDate ,                  
                                @money_id                  
                        FROM    agentbranchdetail b                  
							 JOIN agentdetail a ON b.agentcode = a.agentcode                  
                        WHERE   b.agent_branch_code = @MPOS_Acc     
                          
                         --record the invoice number                  
                UPDATE  dbo. MPOS_BalanceTransfer                 
                SET     InvoiceNO = @InvoiceNO                  
                WHERE   sno = @tranno        
                          
                          
               
                                                               
      SELECT 0000 code , 'SUCCESS' STATUS, @errormsg MSG , @tranno tranno ,  @refno refno                                           
 END  
   
   
 IF @flag='u'  
 BEGIN  
   
 UPDATE dbo.MPOS_BalanceTransfer SET Status=@status, P2N_pending_TxnId=@pending_TxnId,  
 P2N_remaining_balance=@balance,P2N_settlement_currency=@SettCCY   
 WHERE refno=@refno AND sno=@sno AND Status IS NULL AND MobileNo=@MobileNr  
 SELECT 0000 code , 'SUCCESS' STATUS, @errormsg MSG , @tranno tranno ,  @refno refno  
  
 END              
   
 IF @flag ='pf' --confirmation from pay2nepal; Got error  while inserting to  pay2nepal pending table                  
        BEGIN         
    
   --step taken to prohibit double submit of page that results into double refund entries!    
              --this occured for 3 txns previously    
                IF EXISTS ( SELECT  'x'    
                            FROM    dbo.MPOS_BalanceTransfer WITH ( NOLOCK )    
                            WHERE   Status IN ( 'Fail', 'Refund' )    
                                    AND refno = @refno )     
                    BEGIN    
                        RETURN     
                    END    
               --End         
              
    UPDATE  dbo.MPOS_BalanceTransfer                  
                SET  status=@status,                  
                DLR_Response =  @DLR_Response                    
                WHERE   refno = @refno           
      
      
        
    SELECT  @gross_sending_amount = gross_sending_amount ,                  
                        @InvoiceNO = InvoiceNO ,                  
                        @MobileNr = MobileNo,        
      @agentBranchCode = agent_branch_code,  
      @denomination=denomination ,      
      @agentCode= AgentCode            
                FROM    dbo.MPOS_BalanceTransfer  
                WHERE refno=@refno    
                  
                 ----------------------------------------------Updating the balance------------------------------------------  
                UPDATE  AgentbranchDetail                  
                SET     CurrentBalance = ISNULL(CurrentBalance, 0)                  
                        - ( @gross_sending_amount )                  
                WHERE   agent_branch_code = @agentBranchCode    
                  
                UPDATE dbo.agentDetail SET   
                CurrentBalance=  ISNULL(CurrentBalance, 0)                  
                        - ( @gross_sending_amount )                  
                WHERE agentCode=@agentCode  
                  
                UPDATE dbo.agentsub SET   
                current_balance=  ISNULL(current_balance, 0)                  
                        - ( @gross_sending_amount )                  
                WHERE User_login_Id=@user_login_id  
                  
                --------------------Updating value on Transactional Head-------------  
                UPDATE  AgentbranchDetail                  
                SET     CurrentBalance = ISNULL(CurrentBalance, 0)                  
                        - (@denomination )                  
                WHERE   agent_branch_code = @MPOS_Acc  
                  
                --------------------Updating value on Ledger Account-------------  
                UPDATE dbo.agentDetail SET CurrentBalance=ISNULL(a.CurrentBalance, 0)                  
                        - (@denomination )    
                        FROM dbo.agentDetail a JOIN dbo.agentbranchdetail ab ON a.agentCode=ab.agentCode                
                WHERE   ab.agent_branch_code = @MPOS_Acc  
                  
             ------------------------------------------------------------------------------------------------------------                
                     
                              
--create adjustment voucher as cr for refunded cases                  
                INSERT  agentbalance                  
                        ( invoiceno ,                  
                          agentcode ,                  
                         CompanyName ,                  
       Dot ,                  
                          amount ,                  
                          currencyType ,                  
                          XRate ,                  
                          Mode ,                  
                          Remarks ,                  
                          Staffid ,                  
                          dollar_rate ,                  
                          branch_code ,                  
                          fund_date ,                  
                          approved_by ,                  
                          approved_ts ,                  
                          money_id                        
                        )                  
                        SELECT  invoiceno ,                  
                                agentcode ,                  
                                CompanyName ,                  
                                @gmtDate ,                  
                                amount ,                  
                                currencyType ,                  
                                XRate ,                  
                                CASE WHEN mode='cr' THEN 'dr' ELSE 'cr' end ,                  
                                'MPOS:Failed Mobile ' + @MobileNr ,                  
                                Staffid ,                  
                                dollar_rate ,                  
                                branch_code ,                  
                                @gmtDate ,                  
                                approved_by ,                  
                                @gmtDate ,                  
                                money_id                  
                        FROM    dbo.agentBalance                  
                        WHERE   InvoiceNo = @InvoiceNO                  
                                       
      SELECT 0000 code , 'SUCCESS' STATUS, @errormsg MSG , @tranno tranno ,  @refno refno  
                             
        END                  
                          
                
                          
        IF @flag = 'c' -- success case from Pay2nepal after the transaction hits the MPOS server                      
            BEGIN                                      
                        
                UPDATE  dbo.MPOS_BalanceTransfer                  
                SET     DLR_Response = @DLR_Response ,                  
                        status = @status,          
      P2N_TxnId=@sno       
                WHERE   refno = @refno                    
                        --AND sim_log_id IS NULL                
                                                         
                SET @row_count = @@ROWCOUNT                                
                                 
                IF @status = 'Success'                  
                    AND @row_count > 0                   
                    BEGIN                                 
                        SELECT  @InvoiceNO = InvoiceNO ,                  
                                @DLR_Response = DLR_Response                
                        FROM    dbo.MPOS_BalanceTransfer                  
                        WHERE   refno = @refno  
                                             
                                               
                                
                        --update voucher remarks on success case only           
                        UPDATE  dbo.agentBalance                  
                        SET     remarks = 'MPOS:' + @DLR_Response                  
                        WHERE   InvoiceNo = @InvoiceNO                  
                    END    
                    SELECT 0000 code , 'SUCCESS' STATUS, @errormsg MSG , @tranno tranno ,  @refno refno                          
            END                   
                          
        IF @flag = 'uf'                   
 BEGIN                  
                   --Fail case   or Refund case          
    
     --step taken to prohibit double submit of page that results into double refund entries!    
              --this occured for 3 txns previously    
                IF EXISTS ( SELECT  'x'    
                            FROM    dbo.MPOS_BalanceTransfer WITH ( NOLOCK )    
                            WHERE   Status IN ( 'Fail', 'Refund' )    
                                    AND refno = @refno )     
                    BEGIN    
                        RETURN     
                    END    
               --End       
                DECLARE @failmsg VARCHAR(200)             
                UPDATE  dbo.MPOS_BalanceTransfer                  
                SET     DLR_Response = @DLR_Response ,                  
                        Status = @status ,        
                        P2N_TxnId=@sno                      
                WHERE   refno = @refno                      
                                     
                 SELECT  @gross_sending_amount = gross_sending_amount ,                  
                        @InvoiceNO = InvoiceNO ,                  
                        @MobileNr = MobileNo,        
      @agentBranchCode = agent_branch_code,  
       @denomination=denomination,       
       @agentCode= agentCode            
                FROM    dbo.MPOS_BalanceTransfer    
                WHERE refno=@refno  
                 ----------------------------------------------Updating the balance------------------------------------------  
                UPDATE  AgentbranchDetail                  
                SET     CurrentBalance = ISNULL(CurrentBalance, 0)                  
                        - ( @gross_sending_amount )                  
                WHERE   agent_branch_code = @agentBranchCode    
                  
                UPDATE dbo.agentDetail SET   
                CurrentBalance=  ISNULL(CurrentBalance, 0)                  
                        - ( @gross_sending_amount )                  
                WHERE agentCode=@agentCode  
                  
                UPDATE dbo.agentsub SET   
                current_balance=  ISNULL(current_balance, 0)                  
                        - ( @gross_sending_amount )                  
                WHERE User_login_Id=@user_login_id  
                  
                --------------------Updating value on Transactional Head-------------  
                UPDATE  AgentbranchDetail                  
                SET     CurrentBalance = ISNULL(CurrentBalance, 0)                  
                        - (@denomination )                  
                WHERE   agent_branch_code = @MPOS_Acc  
                  
                --------------------Updating value on Ledger Account-------------  
                UPDATE dbo.agentDetail SET CurrentBalance=ISNULL(a.CurrentBalance, 0)                  
                        - (@denomination )    
                        FROM dbo.agentDetail a JOIN dbo.agentbranchdetail ab ON a.agentCode=ab.agentCode                
                WHERE   ab.agent_branch_code = @MPOS_Acc  
                  
             ------------------------------------------------------------------------------------------------------------                
                                       
                        
                                    
                  IF @status = 'Fail'    
     SET @failmsg = 'Failed Mobile ' + @MobileNr    
         
      IF @status = 'Refund'    
     SET @failmsg = 'Refunded for Mobile ' + @MobileNr     
                                              
                  
   --create adjustment voucher as cr for refunded cases                  
                INSERT  agentbalance                  
                        ( invoiceno ,                  
                          agentcode ,                  
                         CompanyName ,                  
                          Dot ,                  
                          amount ,                  
                          currencyType ,                  
                          XRate ,                  
                          Mode ,                  
                          Remarks ,                  
                          Staffid ,                  
                          dollar_rate ,                  
                          branch_code ,                  
                          fund_date ,                  
                          approved_by ,                  
                          approved_ts ,                  
                          money_id                        
                        )                  
                        SELECT  invoiceno ,                  
                                agentcode ,                  
                                CompanyName ,                  
                                @gmtDate ,                  
                                amount ,                  
                                currencyType ,                  
                                XRate ,                  
                                CASE WHEN mode='cr' THEN 'dr' ELSE 'cr' end ,                  
        'MPOS:' + @failmsg,                  
                                Staffid ,                  
                                dollar_rate ,                  
                                branch_code ,                  
                                @gmtDate ,                  
                                approved_by ,                  
                                @gmtDate ,                  
                                money_id                  
                        FROM    dbo.agentBalance                  
                        WHERE   InvoiceNo = @InvoiceNO                  
                                            
              SELECT 0000 code , 'SUCCESS' STATUS, @failmsg MSG , @tranno tranno ,  @refno refno        
            END                         
  
END  
          
                  
        
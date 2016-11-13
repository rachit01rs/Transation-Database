--spa_ticketedit 'u' , NULL,'KKLLKKJJ','DOT','12/1/2009 1:45:10 PM'      
--spa_ticketedit 'u' , NULL,'KKLLKKJJ','exchangeRate','2'      
--spa_ticketedit 'u' ,NULL,'RQJJQPPQQLQ','senderName','Fuaya Tamang' ,'ReceiverName ReceiverName RENAME to RECEIVER ASFASFASF','HO:admin','A',1,'i'      
----spa_ticketedit 'u' ,NULL,'RQJJQPPQQLQ','senderName','Fuaya Tamang' ,'ReceiverName ReceiverName RENAME to RECEIVER ASFASFASF','HO:admin','A',1,'i'      
CREATE PROC [dbo].[spa_ticketedit]      
 @flag CHAR(1),      
 @tranno VARCHAR(50) = NULL,      
 @refno VARCHAR(50) = NULL,      
 @columnName VARCHAR(50) = NULL,      
 @columnValue VARCHAR(50) = NULL,      
 @Comments VARCHAR(200) = NULL,      
 @PostedBy VARCHAR(50) = NULL,      
 @uploadBy VARCHAR(50) = NULL,      
 @noteType VARCHAR(50) = NULL,      
 @agentid VARCHAR(50) = NULL,      
 @isRemote VARCHAR(100) = NULL      
      
      
AS       
DECLARE @receiverCountry  VARCHAR(100),  
        @status           VARCHAR(50)  
      
IF @flag = 't'  
BEGIN  
    SELECT agentid  
    FROM   moneysend  
    WHERE  tranno = @tranno  
END      
      
IF @flag = 'c'  
BEGIN  
    SELECT *  
    FROM   ContactInfo  
    WHERE  AgentCode IN (@agentid)  
           AND isTicket = 'y'  
END      
      
IF @flag = 's'  
BEGIN  
    SELECT *  
    FROM   ContactInfo  
    WHERE  AgentCode IN ('HQ')  
           AND isTicket = 'y'  
END      
      
IF @flag = 'u'  
BEGIN  
    --if @tranno is NULL      
    SELECT @tranno = tranno,  
           @receiverCountry = receiverCountry,  
           @status = transStatus  
    FROM   moneysend  
    WHERE  refno = @refno      
      
    IF @columnName IS NOT NULL  
        EXEC ('      
 UPDATE moneysend set ' + @columnName + '=''' + @columnValue + '''      
 where tranno=' + @tranno + ' and refno=''' + @refno + ''''  
             )  
      
    PRINT (  
        '      
 UPDATE moneysend set ' + @columnName + '=''' + @columnValue + '''      
 where tranno=' + @tranno + ' and refno=''' + @refno + ''''  
    )      
    IF @isRemote IS NULL  
        SELECT 'Success' STATUS,  
               'Ticket Updated Successfully..' MESSAGE  
END        
      
IF @flag = 'i'  
BEGIN  
    --if @tranno is NULL      
    SELECT @tranno = tranno,  
           @receiverCountry = receiverCountry,  
           @status = transStatus  
    FROM   moneysend  
    WHERE  refno = @refno  
      
    INSERT INTO TransactionNotes  
      (  
        refno,  
        Comments,  
        DatePosted,  
        PostedBy,  
        uploadBy,  
        noteType,  
        tranno  
      )  
    VALUES  
      (  
        @refno,  
        @Comments,  
        GETDATE(),  
        @PostedBy,  
        @uploadBy,  
        @noteType,  
        @tranno  
      )      
    IF @isRemote IS NULL  
        SELECT 'Success' STATUS,  
               'Ticket Added Successfully..' MESSAGE  
END  
    
IF @flag = 'i'  
   OR @flag = 'u'  
BEGIN  
  
    DECLARE @PartnerAgentCode        VARCHAR(50),  
            @sendAgent               VARCHAR(50)  
      
    DECLARE @remote_db               VARCHAR(200)      
    DECLARE @payout_agentid          VARCHAR(50),  
            @enable_update_remoteDB  CHAR(1)  
      
    SELECT @tranno = tranno,  
           @receiverCountry = receiverCountry,  
           @sendAgent = agentid,  
           @payout_agentid = expected_payoutagentid  
    FROM   moneysend  
    WHERE  refno = @refno   
                 
    DECLARE @DBName VARCHAR(50)  
    IF @receiverCountry = 'Nepal'  
       AND @status = 'Payment'  
    BEGIN  
          IF @payout_agentid='20100115' --- PFCL   
          BEGIN  
            SET @DBName='PrabhuFinance'             
          END   
          else IF @payout_agentid='20100003' --- PMT NEpal   
          BEGIN  
            SET @DBName='PrabhuNet'  
          END  
                EXEC('Prabhu_MY.'+@DBName+'.dbo.spa_IntegrationAPITickets   
            @Refno='''+ @refno +''',  
            @comments='''+@Comments +''',  
            @postedBy=''A:'+@PostedBy+'''')  
              
            RETURN   
    END   
         
     IF EXISTS(  
           SELECT sno  
           FROM   tbl_interface_setup  
           WHERE  agentcode = @payout_agentid  
                  AND mode = 'Send'  
       )  
        SELECT @remote_db = remote_db,  
               @enable_update_remoteDB = enable_update_remote_DB,  
               @PartnerAgentCode = PartnerAgentCode  
        FROM   tbl_interface_setup  
        WHERE  agentcode = @payout_agentid  
               AND mode = 'Send'  
    ELSE   
    IF EXISTS(  
           SELECT sno  
           FROM   tbl_interface_setup  
           WHERE  agentcode = @sendAgent  
                  AND mode = 'Pay'  
    )  
    BEGIN  
       SELECT @remote_db = remote_db,  
               @enable_update_remoteDB = enable_update_remote_DB,  
               @PartnerAgentCode = agentcode  
        FROM   tbl_interface_setup  
        WHERE  agentcode = @sendAgent  
               AND mode = 'Pay'   
     END     
     
    --else  
    --select @remote_db=remote_db,@enable_update_remoteDB=enable_update_remote_DB,  
    --@PartnerAgentCode=PartnerAgentCode  
    -- from tbl_interface_setup  
    --where payoutcountry=@receiverCountry and mode='Send'      
      
    IF @enable_update_remoteDB = 'y'  
    BEGIN  
        EXEC spa_integration_partner_cancel_ticket 't',  
             NULL,  
             @refno,  
             'tickets',  
             @columnName,  
             @columnValue,  
             @PostedBy,  
             @uploadBy,  
             @Comments  
    END  
END
DROP PROC [dbo].[spa_reconsile_transaction_new]  
GO
--spa_reconsile_transaction 'status','confirmDate','2009-01-02','2009-08-29'    
CREATE PROC [dbo].[spa_reconsile_transaction_new]    
 @reconsileBy varchar(50)=NULL,    
 @dateType varchar(50)=NULL,    
 @toDate varchar(50) =NULL,  
 @login_user_id varchar(50)=NULL,        
 @process_id VARCHAR(200) = NULL ,    
 @summary_batch_Id VARCHAR(100) = NULL ,    
 @detail_batch_Id VARCHAR(100) = NULL      
AS    
BEGIN    
DECLARE @remote_db varchar(100),@sql varchar(MAX),@reconcile_system VARCHAR(50),@msg_agenttype VARCHAR(100) ,    
            @desc VARCHAR(1000),@receiveAgentId VARCHAR(50)  
  
--SELECT @remote_db=remote_db FROM tbl_setup    
SELECT @remote_db=additional_value,@reconcile_system=sv.static_value  
  FROM static_values sv WHERE sno=200 AND sv.static_value='PRABHU MY'  
    
              SET @msg_agenttype = ' PRABHU USA Vs '+ @reconcile_system     
  
        CREATE TABLE #remote_reconcile_moneysend      
        (      
            sno INT IDENTITY(1, 1) ,      
      Rrefno VARCHAR(50),  
      Rstatus VARCHAR(50),  
      rTransStatus VARCHAR(50)  
        
        )     
        
        CREATE TABLE #local_reconcile_moneysend      
        (      
            sno INT IDENTITY(1, 1) ,      
			refno VARCHAR(50),  
			agentID VARCHAR(50),  
			agentName VARCHAR(200),  
			Branch_code VARCHAR(50),  
			branch VARCHAR(50),  
			senderName VARCHAR(50),  
			expected_payoutagentid VARCHAR(50),  
			receiverName VARCHAR(200),  
			[status] VARCHAR(50),  
			transStatus VARCHAR(50) 
        )            
  -----  
SET @sql='INSERT INTO #remote_reconcile_moneysend(Rrefno,Rstatus,rTransStatus)  
SELECT r.refno Rrefno,r.status Rstatus,r.TransStatus rTransStatus from '+@remote_db+'moneysend r with(NOLOCK) WHERE 1=1 and r.isIRH_trn IS NOT NULL'   
 IF @dateType IS NOT NULL    
SET @sql=@sql+' and dbo.CTGetdate(r.'+@dateType+')='''+ @toDate +''''    
    
							PRINT @sql    
    
EXEC (@sql)    
SET @sql='INSERT INTO #local_reconcile_moneysend(refno,agentID,agentName,Branch_code,branch,senderName,expected_payoutagentid,receiverName,status,transStatus)  
   SELECT refno,agentid,agentname,Branch_code,Branch,SenderName,expected_payoutagentid,ReceiverName,status,TransStatus FROM moneySend m with(nolock) JOIN  
 tbl_interface_setup t ON m.expected_payoutagentid=t.agentcode WHERE t.mode=''Send'' AND t.enable_update_remote_DB=''y'''  
 IF @dateType IS NOT NULL    
SET @sql=@sql+' and dbo.CTGetdate(m.'+@dateType+')='''+ @toDate +'''' 
    
							PRINT @sql    
    
EXEC (@sql)  
  
         DECLARE @temptablename VARCHAR(300)  ,@processName  VARCHAR(200)   
         set @temptablename=dbo.FNAProcessTBl(@summary_batch_Id, @login_user_id, @process_id)      
              SET @SQL = 'CREATE TABLE ' + @temptablename + '(        
     sno INT IDENTITY (1,1),  
     [SYSTEM] VARCHAR(50), 
     total_txn INT       
     )'    
     EXEC(@SQL)  
							   PRINT(@SQL)  
      SET @SQL = '   
       INSERT INTO ' + @temptablename + '([SYSTEM],total_txn)  
       SELECT '''+UPPER(@reconcile_system +' System')+''',COUNT(*) FROM #remote_reconcile_moneysend m  with(nolock)  
  UNION  
   SELECT ''PRABHU USA SYSTEM'',COUNT(*) FROM #local_reconcile_moneysend l with(nolock)'   
  EXEC(@SQL)     
							 PRINT(@SQL)  
							SET @SQL =' SELECT * FROM '+@temptablename  
							   EXEC(@SQL)    
							  PRINT(@SQL) 
          SET @desc = UPPER(@summary_batch_Id) + ' ' + @msg_agenttype + ' is completed of date: ' + @toDate  
          update message_board       
   set type='c',      
   description=@desc      
   where job_name = @process_id and user_login_id=@login_user_id AND [source]= @summary_batch_Id               
     
     
        -------------------------------------------------------------------------------------------------------------    
    SET @temptablename=dbo.FNAProcessTBl(@detail_batch_Id, @login_user_id, @process_id)            
                                                        
     SET @SQL = 'CREATE TABLE ' + @temptablename + '(        
            sno INT IDENTITY(1, 1) ,      
      Mrefno VARCHAR(50),  
      MagentID VARCHAR(50),  
      MagentName VARCHAR(200),  
      Mbranchcode VARCHAR(50),  
      Mbranch VARCHAR(50),  
      MsenderName VARCHAR(50),  
      MpayoutAgt VARCHAR(50),  
      MreceiverName VARCHAR(200),  
      Mstatus VARCHAR(50),  
      MtransStatus VARCHAR(50),  
      Rstatus VARCHAR(50),  
      rTransStatus VARCHAR(50),
      [Message] VARCHAR(50)    
 )'  
											--PRINT(@SQL)  
       EXEC(@SQL)  
        
    SET @SQL ='    
        INSERT INTO ' + @temptablename + '(Mrefno,MagentID,MagentName,Mbranchcode,Mbranch,MsenderName,MpayoutAgt,MreceiverName,Mstatus,MtransStatus,Rstatus,rTransStatus,[Message])             
      SELECT CASE WHEN refno IS NULL THEN dbo.decryptDB(Rrefno) ELSE dbo.decryptDB(refno) END refno,agentid,agentname,Branch_code,Branch,SenderName,expected_payoutagentid,ReceiverName,status,TransStatus,Rstatus,rTransStatus,''Missing in Malaysia System'' FROM #local_reconcile_moneysend m WITH(NOLOCK) 
 LEFT OUTER JOIN  #remote_reconcile_moneysend r WITH(NOLOCK) on m.refno=r.Rrefno 
      WHERE  (r.Rrefno IS NULL OR m.refno IS NULL)'
SET @sql=@sql+' UNION ALL 
 SELECT CASE WHEN refno IS NULL THEN dbo.decryptDB(Rrefno) ELSE dbo.decryptDB(refno) END refno,agentid,agentname,Branch_code,Branch,SenderName,expected_payoutagentid,ReceiverName,status,TransStatus,Rstatus,rTransStatus,''Missing in USA System''  FROM  #remote_reconcile_moneysend r with(NOLOCK) 
     LEFT OUTER JOIN  #local_reconcile_moneysend m WITH(NOLOCK) on m.refno=r.Rrefno 
 WHERE 1=1 AND m.refno IS NULL  
     UNION ALL   
  SELECT CASE WHEN refno IS NULL THEN dbo.decryptDB(Rrefno) ELSE dbo.decryptDB(refno) END refno,agentid,agentname,Branch_code,Branch,SenderName,expected_payoutagentid,ReceiverName,status,TransStatus,Rstatus,rTransStatus,''Status Difference'' FROM #remote_reconcile_moneysend r WITH(NOLOCK) 
LEFT OUTER JOIN  #local_reconcile_moneysend m WITH(NOLOCK) on m.refno=r.Rrefno 
WHERE 1=1 AND  m.status<>r.Rstatus   
   UNION ALL  
 SELECT CASE WHEN refno IS NULL THEN dbo.decryptDB(Rrefno) ELSE dbo.decryptDB(refno) END refno,agentid,agentname,Branch_code,Branch,SenderName,expected_payoutagentid,ReceiverName,status,TransStatus,Rstatus,rTransStatus,''Transaction Status is Different'' FROM #remote_reconcile_moneysend r WITH(NOLOCK) 
LEFT OUTER JOIN  #local_reconcile_moneysend m WITH(NOLOCK) on m.refno=r.Rrefno 
 WHERE 1=1 AND  m.TransStatus<>r.rTransStatus'    
													--PRINT(@SQL) 
        EXEC(@SQL)   
     
												--	  SET @SQL =' SELECT * FROM '+@temptablename    
												--  PRINT(@SQL)   
												--EXEC(@SQL)            
										    
        SET @desc = UPPER(@detail_batch_Id) + ' ' + @msg_agenttype + ' is completed of date: '+ @toDate       
        update message_board       
   set type='c',      
   description=@desc      
   where job_name = @process_id and user_login_id=@login_user_id AND [source]= @detail_batch_Id  
     
  
    
END 
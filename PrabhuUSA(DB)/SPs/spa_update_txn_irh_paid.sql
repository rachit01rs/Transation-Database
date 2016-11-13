DROP proc [dbo].[spa_update_txn_irh_paid]    
Go    
-- alter table tbl_status_moneysend_paid alter column process_status varchar(200)    
CREATE proc [dbo].[spa_update_txn_irh_paid]    
AS    
DECLARE @process_id VARCHAR(150)    
SET @process_id=REPLACE(newid(),'-','_')    
    
UPDATE tbl_status_moneysend_paid SET process_status=@process_id    
    
SELECT t.*,m.tranno,m.transStatus,m.status CurrentStatus,expected_payoutagentid,totalroundamt,SenderCountry,paymentType INTO #temp_moneysend FROM moneysend m WITH (NOLOCK)     
RIGHT OUTER join tbl_status_moneysend_paid t  WITH (NOLOCK) on m.refno=t.refno    
WHERE  t.process_status=@process_id    
    
 INSERT dbo.data_import_status_detail(Process_id,source,TYPE,description)    
 SELECT @process_id,dbo.decryptDb(t.refno),'Integration-'+status,'TXN not Found'     
 FROM #temp_moneysend t    
 where tranno IS NULL     
    
 INSERT dbo.data_import_status_detail(Process_id,source,TYPE,description)    
 SELECT @process_id,dbo.decryptDb(t.refno),'Integration-'+status,'TXN Current Status is:' + CurrentStatus    
 FROM #temp_moneysend t    
 where CASE WHEN CurrentStatus='Post' THEN 'Un-Paid' ELSE CurrentStatus END <>'Un-Paid' AND status='Paid'    
 AND tranno IS not NULL     
    
 INSERT dbo.data_import_status_detail(Process_id,source,TYPE,description)    
 SELECT @process_id,dbo.decryptDb(t.refno),'Integration-'+status,'TXN Current Status is:' + transStatus    
 FROM #temp_moneysend t    
 where transStatus<>'Payment' AND status='Paid' AND tranno IS not NULL     
     
 IF EXISTS(SELECT Process_id FROM data_import_status_detail WHERE process_id=@process_id)    
 BEGIN     
  INSERT data_import_status(Process_id,code,module,source,TYPE,description,create_ts)    
  SELECT @process_id,'Error','Integration','Integration','Paid','Error found while importing TXN from Integration',GETDATE()    
 END     
  
     
 UPDATE #temp_moneysend set agent_receiverCommission=0.00,agent_receiverComm_Currency=null
  
 UPDATE #temp_moneysend SET agent_receiverCommission=c.commission_value,agent_receiverComm_Currency=c.comm_currency_type  
 FROM #temp_moneysend m LEFT OUTER JOIN agent_branch_commission c  WITH(NOLOCK)
 ON m.expected_payoutagentid=c.agent_code   
 and totalroundamt between min_amount and max_amount  
 WHERE c.payment_mode ='Default'  
 AND c.country='ALL'  
  
 UPDATE #temp_moneysend SET agent_receiverCommission=c.commission_value,agent_receiverComm_Currency=c.comm_currency_type  
 FROM #temp_moneysend m LEFT OUTER JOIN agent_branch_commission c WITH(NOLOCK) 
 ON m.expected_payoutagentid=c.agent_code AND c.country=m.SenderCountry  
 and totalroundamt between min_amount and max_amount  
 WHERE c.payment_mode ='Default'  
    
 UPDATE #temp_moneysend SET agent_receiverCommission=c.commission_value,agent_receiverComm_Currency=c.comm_currency_type  
 FROM #temp_moneysend m LEFT OUTER JOIN agent_branch_commission c  WITH(NOLOCK)
 ON m.expected_payoutagentid=c.agent_code   
 and totalroundamt between min_amount and max_amount   
 AND c.payment_mode=m.paymentType  
 WHERE c.payment_mode <> 'Default'  
 AND c.country='ALL'  
   
 UPDATE #temp_moneysend SET agent_receiverCommission=c.commission_value,agent_receiverComm_Currency=c.comm_currency_type  
 FROM #temp_moneysend m LEFT OUTER JOIN agent_branch_commission c  WITH(NOLOCK)
 ON m.expected_payoutagentid=c.agent_code   
 and totalroundamt between min_amount and max_amount   
 AND c.payment_mode=m.paymentType   
 AND c.country=m.SenderCountry  
 WHERE c.payment_mode <> 'Default'  
  
      
 DELETE #temp_moneysend WHERE tranno IS NULL     
     
 Update MoneySend set rBankId=t.rBankId,    
 rBankName=t.rBankName,    
 rBankBranch=t.rBankBranch,paidBy=t.paidBy,    
 paidDate=t.paidDate,podDate=t.podDate,paidTime=t.paidTime,    
 status=t.status,  
 transstatus='Payment',  
 digital_id_payout=t.digital_id_payout ,    
 agent_receiverCommission=t.agent_receiverCommission,    
 agent_receiverComm_Currency=t.agent_receiverComm_Currency,    
 lock_status=t.lock_status,    
 paid_agent_id=t.paid_agent_id,    
 paid_date_usd_rate=t.paid_date_usd_rate    
 from moneysend m WITH(NOLOCK) join #temp_moneysend t on m.tranno=t.tranno     
 where m.transStatus in ('Payment','Pay Processing') and m.Status in ('Un-Paid','Post')    
AND t.process_status=@process_id AND t.status='Paid'    
      
 delete tbl_status_moneysend_paid FROM tbl_status_moneysend_paid p WITH(NOLOCK) JOIN #temp_moneysend t ON t.refno=p.refno    
 WHERE t.process_status=@process_id AND t.status='Paid'    
     
 Update MoneySend set status=t.status,transstatus='Payment'   
 from moneysend m WITH(NOLOCK) join #temp_moneysend t on m.tranno=t.tranno     
 where m.Status='Un-Paid' AND t.process_status=@process_id AND t.status='Post'    
      
 delete tbl_status_moneysend_paid FROM tbl_status_moneysend_paid p  JOIN #temp_moneysend t ON t.refno=p.refno    
 WHERE t.process_status=@process_id AND t.status='Post'      
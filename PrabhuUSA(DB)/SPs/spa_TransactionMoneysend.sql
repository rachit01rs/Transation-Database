/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 1/6/2015 10:19:17 AM
 ************************************************************/

/****** Object:  StoredProcedure [dbo].[spa_TransactionMoneysend]    Script Date: 12/31/2014 16:12:32 ******/
IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_TransactionMoneysend]')
              AND TYPE IN (N'P' ,N'PC')
   )
    DROP PROCEDURE [dbo].[spa_TransactionMoneysend]
GO

/****** Object:  StoredProcedure [dbo].[spa_TransactionMoneysend]    Script Date: 12/31/2014 16:12:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[spa_LSlink_downloadAccount_Remote]    Script Date: 12/28/2014 17:07:04 ******/  
  /*
** Database : PrabhuuUsa
** Object : spa_TransactionMoneysend
**
** Purpose : To PUSH  Account Deposite to Another Bank txn 
**
** Author:  Sunita Shrestha
** Date:    02/12/2014
*/
----spa_TransactionMoneysend 's','PMT'        
--SELECT dbo.decryptDb(refno),* FROM TransactionNotes tn where refno=dbo.encryptDB('111011374311') ORDER BY tn.RefNo     
CREATE PROC [dbo].[spa_TransactionMoneysend]        
@flag CHAR(1) = 's',    
@CallFrom Varchar(50),  
@process_id varchar(150)=null    
AS        
  
    
SELECT  t.*,b.ext_branch_code,  
case when paymentType='Account Deposit to Other Bank' then ben_bank_name else rbankname end PayoutBankName,  
case when paymentType='Account Deposit to Other Bank' then rBankAcTYpe else rbankBranch end PayoutBranchName   
 INTO #temp  FROM  moneysend t left outer join agentbranchdetail b     
on t.rBankID=b.agent_branch_code       
WHERE t.Status='un-paid'     
AND receivercountry='Nepal'      
AND transStatus='payment' AND trans_mode is NULL      
AND paymenttype in('Bank Transfer','Account Deposit to Other Bank')    
AND case when @CallFrom='PrabhuBank' then paymenttype else 'Bank Transfer' end = 'Bank Transfer'    
AND case when @CallFrom='PMT' then paymenttype else 'Account Deposit to Other Bank' end = 'Account Deposit to Other Bank'    
And downloaded_ts is null  
  
    UPDATE moneySend    
    SET STATUS='Post',is_downloaded ='y',downloaded_ts = GETDATE(),downloaded_by=@process_id    
    FROM #temp t JOIN moneysend m    
    ON t.tranno=m.Tranno    
  
select 'Success' statusMsg,* from #temp  
  
  
  
--    
--DECLARE @XML XML     
--IF @flag = 's'        
--BEGIN        
-- SET NOCOUNT ON;    
--    SET @XML =     
--    (    
--     SELECT (      
--               SELECT          
--     t.Refno AS 'Column/refno',        
--     t.tranno AS 'Column/tranno',           
--     t.SenderName AS 'Column/SenderName',   
--     t.SenderAddress AS 'Column/SenderAddress',     
--     t.senderPhoneno AS 'Column/senderPhoneno',   
--     t.sender_mobile AS 'Column/sender_mobile',        
--     t.senderCity AS 'Column/senderCity',  
--     t.senderFax AS 'Column/senderFax',    
--     t.senderPassport AS 'Column/senderPassport',                              
--     t.senderCountry AS 'Column/senderCountry',       
--     t.receiverName AS 'Column/receiverName',    
--     t.ReceiverAddress AS 'Column/ReceiverAddress',   
--     t.receiverPhone AS 'Column/receiverPhone',   
--     t.receiver_mobile AS 'Column/receiver_mobile',    
--     t.ReceiverID AS 'Column/ReceiverID',   
--     t.ReceiverCity AS 'Column/ReceiverCity',  
--     t.ReceiverCountry AS 'Column/ReceiverCountry',   
--     t.Approve_By AS 'Column/Approve_By' ,    
--     t.ConfirmDate AS 'Column/DOT',        
--     t.paidAmt AS 'Column/paidAmt',        
--     t.paidCType AS 'Column/paidCType',    
--     t.receiveAmt AS 'Column/receiveAmt' ,     
--     t.TotalRoundAmt AS 'Column/TotalRoundAmt',      
--     t.receiveCType AS 'Column/receiveCType',     
--     t.ExchangeRate AS 'Column/ExchangeRate',     
--     t.Today_dollar_Rate AS 'Column/Today_dollar_Rate',      
--     t.Dollar_amt AS 'Column/Dollar_amt',     
--     t.Scharge AS 'Column/Scharge',    
--     t.ho_dollar_rate AS 'Column/ho_dollar_rate',    
--     t.PaymentType AS 'Column/PaymentType',     
--     t.transStatus AS 'Column/transStatus',        
--     t.receiveAgentID AS 'Column/receiveAgentID',        
--     t.ext_branch_code AS 'Column/rbankid',    
--     t.rBankName AS 'Column/rBankName',                   
--     t.rBankAcType AS 'Column/rBankBranch',     
--     t.ben_bank_id  AS 'Column/ben_bank_id',    
--     t.ben_bank_name  AS 'Column/ben_bank_name',        
--     t.rBankACNo AS 'Column/rBankACNo',      
--     t.expected_payoutagentId AS 'Column/expected_payoutagentId'  
--     FROM   #temp t        
--      ORDER BY t.Tranno         
--                      FOR XML PATH('DataRow'),        
--                      TYPE        
--           )        
--           FOR XML PATH('Root')    
--    )    
--    SELECT @XML;    
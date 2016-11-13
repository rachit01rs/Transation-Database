IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rw_HubReport]') AND TYPE in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rw_HubReport]
GO
/****** Object:  StoredProcedure [dbo].[spa_rw_HubReport]    Modification Date: 09/18/2014 11:02:12 ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[spa_rw_HubReport]    Modification Date: 09/18/2014 11:02:12 ******/
/*
** Database :		PrabhuUSA
** Object :			spa_rw_HubReport
** Purpose :		Search By Amount Summary
** Modified by:		Sudaman Shrestha
** Modified Date:	09/18/2014
** Modification:	added this logic ('&islessthan100='+CASE WHEN @viewLessThenAmount IS NOT NULL THEN  'no' ELSE 'yes' END) 
					in third last line of the stored procedure to correct error mentioned by the client.
** Execute Examples :spa_rw_HubReport '20100000','20100003','01/01/2010','09/17/2014'	

*/
CREATE PROC spa_rw_HubReport        
@agentId VARCHAR(50),        
@expected_payoutAgentId VARCHAR(50),        
@fromDate VARCHAR(50),        
@toDate VARCHAR(50),    
@viewLessThenAmount CHAR(1)=null       
AS        
IF ISDATE(@fromDate)=0        
BEGIN         
 SELECT 'ERROR','INVALID FROM DATE '+ISNULL(@fromDate,'')+', PLEASE PROVIDE VALID DATE'        
 RETURN        
END        
IF ISDATE(@toDate)=0         
BEGIN         
 SELECT 'ERROR','INVALID TO DATE '+ISNULL(@fromDate,'')+', PLEASE PROVIDE VALID DATE'        
 RETURN        
END        
    
SET @viewLessThenAmount=UPPER(@viewLessThenAmount)    
        
SELECT         
  TRANNO,REFNO,agentid,agentname,expected_payoutagentid,rbankname, paidDate        
  ,paidamt,paidCtype,scharge        
  ,CASE WHEN payout_settle_usd=0 THEN 1         
   WHEN payout_settle_usd IS NULL THEN 1        
   ELSE  payout_settle_usd END payout_settle_usd        
  ,totalroundamt,receiveCtype,receiverCountry,rBankId         
INTO #TEMP_HUB_RECORDS        
FROM moneysend WITH(NOLOCK)         
WHERE [status]='Paid' AND transstatus='Payment' AND paiddate BETWEEN @fromDate AND @toDate +' 23:59:59.998'        
AND CASE WHEN @agentId IS NULL THEN 'X' ELSE agentId END=ISNULL(@agentId,'X')        
AND CASE WHEN @expected_payoutAgentId IS NULL THEN 'X' ELSE expected_payoutAgentId END=ISNULL(@expected_payoutAgentId,'X')        
AND (CASE WHEN @viewLessThenAmount IS NOT NULL THEN  1  ELSE round((totalroundamt/ISNULL(payout_settle_usd,1)),2) END)<    
(CASE WHEN @viewLessThenAmount IS NOT NULL THEN 2 ELSE 100 END)      
    
        
DECLARE @COUNT_TRANSACTION INT        
SELECT @COUNT_TRANSACTION=COUNT(TRANNO) FROM #TEMP_HUB_RECORDS 

     
IF @COUNT_TRANSACTION<=0        
BEGIN   
 SELECT 'NO TRANSACTION FOUND' result  
 RETURN  
END        
 UPDATE #TEMP_HUB_RECORDS SET paidDate=DBO.CTGETDATE(paidDate)        
        
 SELECT         
 paidDate,  
 MAX(rBankName) rBankName,  
 MIN(rBankId) rBankId,         
 COUNT(*) TotNos,          
 SUM(paidAmt) AS paidAmt,        
 paidCtype paidCtype,  
 MIN(receiveCtype) receiveCtype,        
 SUM(sCharge) AS sCharge,  
 SUM(totalRoundamt) totalRoundamt,        
 AVG(round(payout_settle_usd,2)) payout_settle_usd,        
 SUM(round((totalroundamt/ISNULL(payout_settle_usd,1)),2)) USDAmountBYPayoutRate,  
 MAX(receiverCountry) receiverCountry  
  INTO #TEMP_HUB_RECORDS_NEW  
  FROM #TEMP_HUB_RECORDS          
  GROUP BY paidDate,paidCtype       
  
SELECT   
  paidDate [PAID DATE]  
 ,rBankName [RECEIVER AGENT]  
 ,TotNos [TOTAL NO. OF TRANACTION]   
 ,CAST(paidAmt AS VARCHAR)+' '+paidCtype [COLLECTED AMOUNT]             
 ,CAST(sCharge AS VARCHAR)+' '+paidCtype [Service Charge]  
 ,CAST(totalRoundamt AS VARCHAR)+' '+receiveCtype [PAYOUT AMOUT]  
 ,ROUND(payout_settle_usd,2) [PAYOUT SETTLE USD]  
 ,ROUND(USDAmountBYPayoutRate,2) [USD Amount BY Payout Rate]  
 ,'<a href=''../Transaction_rep/branchResultDetail.asp?senderAgent='+ISNULL(@agentId,'')+'&receiveCountry='+receiverCountry  
 +'&cmbReceivingBank='+@expected_payoutAgentId+'&statusType=Paid&searchBy=senderName&dateType=paidDate&fromDate='
 +CONVERT(VARCHAR,paidDate,101)+'&toDate='+CONVERT(VARCHAR,paidDate,101)+'&islessthan100='+CASE WHEN @viewLessThenAmount IS NOT NULL THEN  'no' ELSE 'yes' END +'&ReportType=BranchWise''>Transaction List</a>' Link  
FROM #TEMP_HUB_RECORDS_NEW  
ORDER BY paidDate 
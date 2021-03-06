IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_statisticalReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_statisticalReport]
go

/** DataBase : PrabhuUSA
** Object : [spa_statisticalReport]
** 
** purpose : Search report by country and its states within specified time period
** Modified By : Ashok Pandey
** Date : 2013-04-26
** 
** Execute Samples
** spa_statisticalReport s, 'United States',NULL,'2011-04-25','2013-04-25' 
*/

CREATE PROCEDURE [dbo].[spa_statisticalReport]      
@flag CHAR(1)=NULL,      
@country VARCHAR(50)=NULL,      
@state VARCHAR(50)=NULL,      
@fromDate VARCHAR(50)=NULL,      
@toDate VARCHAR(50)=NULL      
      
AS      
SET NOCOUNT ON;      
IF @flag='s'      
BEGIN      
DECLARE @sql VARCHAR(MAX)      
          
 SET @sql='      
 SELECT      
  CONVERT(VARCHAR, [Date], 111) [Date] ,        
  SUM(NoOfTxn_Collect) NoOfTxn_Collect ,      
  SUM(TotalAmt_Collect)    TotalAmt_Collect ,      
  SUM(NoOfTxn_Cancel)    NoOfTxn_Cancel ,      
  SUM(TotalAmt_Cancel)    TotalAmt_Cancel ,      
  SUM(NoOfTxn_Paid)    NoOfTxn_Paid ,         
  SUM(TotalAmt_Paid)    TotalAmt_Paid ,      
  case 
  when (SUM(NoOfTxn_Collect)- SUM(NoOfTxn_Cancel)) >SUM(NoOfTxn_Paid) then SUM(NoOfTxn_Collect)-SUM(NoOfTxn_Paid)- SUM(NoOfTxn_Cancel)  
  else 0 end  NoOfTxn_Obligation ,      
  case 
  when (SUM(TotalAmt_Collect)-SUM(TotalAmt_Cancel) )>SUM(TotalAmt_Paid) then SUM(TotalAmt_Collect)-SUM(TotalAmt_Paid)-SUM(TotalAmt_Cancel)  
  else 0 end TotalAmt_Obligation,
  CurrencyType  
  
 FROM              
 ( SELECT    CONVERT(VARCHAR, confirmDate, 111) [Date]  ,      
    COUNT(*) NoOfTxn_Collect ,      
    SUM(PaidAmt) TotalAmt_Collect ,        
    0 NoOfTxn_Cancel ,      
   0 TotalAmt_Cancel ,      
   0 NoOfTxn_Paid ,         
    0 TotalAmt_Paid ,      
   0 NoOfTxn_Obligation ,      
    0 TotalAmt_Obligation, 
    m.paidCType     CurrencyType
   FROM      moneysend m WITH(NOLOCK)      
   LEFT OUTER JOIN   agentdetail a  WITH(NOLOCK)      
   ON a.agentCode=m.agentid      
   WHERE     TransStatus NOT IN (''OFAC'',''Hold'',''Compliance'') '      
         
   IF @country IS NOT NULL      
  SET @SQL=@SQL+'  AND a.country='''+@country+''''      
  IF @state IS NOT NULL      
  SET @SQL=@SQL+'  AND a.state='''+@state+''''      
       
 SET @SQL=@SQL+'      
   GROUP BY  CONVERT(VARCHAR, confirmDate, 111),m.paidCType      
  -- ORDER BY  CONVERT(VARCHAR, confirmDate, 111) DESC      
   UNION   ALL      
   SELECT     CONVERT(VARCHAR, cancel_Date, 111) [Date],      
    0 TotalAmt_Collect ,        
    0 NoOfTxn_Collect ,      
    COUNT(*) NoOfTxn_Cancel ,      
    SUM(PaidAmt) TotalAmt_Cancel ,      
               
   0 NoOfTxn_Paid ,         
    0 TotalAmt_Paid ,      
     0 NoOfTxn_Obligation ,      
    0 TotalAmt_Obligation , 
    m.paidctype     CurrencyType     
   FROM   moneysend m WITH(NOLOCK)      
   LEFT OUTER JOIN   agentdetail a  WITH(NOLOCK)      
   ON a.agentCode=m.agentid      
   WHERE     TransStatus =''Cancel'''      
         
    IF @country IS NOT NULL      
  SET @SQL=@SQL+'  AND a.country='''+@country+''''      
  IF @state IS NOT NULL      
  SET @SQL=@SQL+'  AND a.state='''+@state+''''      
        
 SET @SQL=@SQL+' GROUP BY  CONVERT(VARCHAR, cancel_Date, 111),m.paidCType      
   UNION ALL      
   SELECT          
     CONVERT(VARCHAR, paidDate, 111) [Date]   ,      
       0 TotalAmt_Collect ,        
    0 NoOfTxn_Collect ,      
     0 NoOfTxn_Cancel ,      
     0 TotalAmt_Cancel ,      
    COUNT(*) NoOfTxn_Paid ,      
    SUM(PaidAmt) TotalAmt_Paid ,              
     0 NoOfTxn_Obligation ,      
    0 TotalAmt_Obligation  , 
    m.paidctype     CurrencyType    
   FROM       moneysend m WITH(NOLOCK)      
   LEFT OUTER JOIN   agentdetail a  WITH(NOLOCK)      
   ON a.agentCode=m.agentid      
   WHERE     TransStatus =''Payment''      
    AND status =''Paid'''      
 IF @country IS NOT NULL      
  SET @SQL=@SQL+'  AND a.country='''+@country+''''      
  IF @state IS NOT NULL      
  SET @SQL=@SQL+'  AND a.state='''+@state+''''      
        
-- SET @SQL=@SQL+' GROUP BY  CONVERT(VARCHAR, paidDate, 111)      
--   UNION ALL      
--   SELECT      
--    CONVERT(VARCHAR, confirmDate, 111) [Date]   ,       
--      0 TotalAmt_Collect ,        
--    0 NoOfTxn_Collect ,       
--     0 NoOfTxn_Cancel ,      
--     0 TotalAmt_Cancel ,      
--   0 NoOfTxn_Paid ,      
--    0 TotalAmt_Paid,       
--    COUNT(*) NoOfTxn_Obligation ,      
--    SUM(PaidAmt) TotalAmt_Obligation       
--              
--   FROM       moneysend m WITH(NOLOCK)      
--   LEFT OUTER JOIN   agentdetail a  WITH(NOLOCK)      
--   ON a.agentCode=m.agentid      
--   WHERE     TransStatus IN (''Payment'', ''Block'' )      
--    AND status IN ( ''Un-Paid'', ''Post'' )'      
-- IF @country IS NOT NULL      
--  SET @SQL=@SQL+'  AND a.country='''+@country+''''      
--  IF @state IS NOT NULL      
--  SET @SQL=@SQL+'  AND a.state='''+@state+''''      
        
 SET @SQL=@SQL+' GROUP BY  CONVERT(VARCHAR, paidDate, 111),m.paidCType
 )  t      
      
 WHERE CONVERT(DATETIME,[date]) BETWEEN '''+@fromDate +''' AND '''+@toDate+' 23:59:59.990''       
        
 GROUP BY CONVERT(VARCHAR, [Date], 111) ,CurrencyType      
 ORDER BY [Date] DESC ' 
      
 --PRINT(@SQL)      
 EXEC(@SQL)      
END          
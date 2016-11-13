IF OBJECT_ID('spa_Export_SampathBank','P') IS NOT NULL
	DROP PROC [dbo].[spa_Export_SampathBank]    
GO
CREATE PROC [dbo].[spa_Export_SampathBank]     
@fromDate   VARCHAR(50)=NULL,  
@toDate		VARCHAR(50)=NULL,  
@check		VARCHAR(50)=NULL,  
@user_id	VARCHAR(50)=NULL  
  
AS
DECLARE @txt_sql VARCHAR(MAX),
		@destination_agent VARCHAR(50)  
----------------------------------------------
SET @destination_agent = '33300143'  
----------------------------------------------
SET @txt_sql='SELECT dbo.decryptdb(refno) [Reference Number],  
  convert(varchar,cast(confirmDate as datetime),111) as [Transaction Date],  
  receiveCType as [Currency],  
  totalRoundAmt [Transaction Amount],  
  substring(senderName,0,50) as [Remitter’s Name],  
  substring(senderPassport,0,40) as [Remitter’s ID],  
  isNULL(SenderPhoneno,sender_mobile) as [Remitter’s Contact no],  
  substring(isNULL(SenderAddress,'''')+'',''+isNULL(SenderCity,'''')+'',''+SenderCountry,0,200) as [Remitter’s Address],  
  substring(ReceiverName,0,50) as [Beneficiary’s Name],  
  substring(ReceiverID,0,40) as [Beneficiary’s ID],  
  isNULL(ReceiverPhone,receiver_mobile) as [Beneficiary’s Contact No],  
  substring(isNULL(ReceiverAddress,'''')+'',''+isNULL(ReceiverCity,''''),0,200) as [Beneficiary’s Address],  
  substring(CASE WHEN RIGHT(RTRIM(ReciverMessage),1)=''/'' THEN LEFT(ReciverMessage, LEN(ReciverMessage)-1) ELSE ReciverMessage END,0,200) as [Message],  
  b.ext_branch_code as [Pay out branch code],  
  substring(b.branch,0,100) as [Pay out branch name],  
  CASE WHEN paymentType=''Bank Transfer'' THEN ''7278'' ELSE NULL END as [Pay out bank Code],  
  substring(rBankName,0,50) as [Pay out bank Name],  
  rBankACNo as [Account Number], 
  case when paymentType=''Cash Pay'' then ''POI'' when paymentType=''Bank Transfer'' then ''SBA''   
  when paymentType=''Account Deposit to Other Bank'' then ''SLI'' end  [Remittance Type]  
 INTO #temp  
 FROM moneysend m WITH (nolock)  
    LEFT OUTER JOIN agentbranchdetail b on m.rBankID=b.agent_branch_code    
 WHERE  expected_payoutagentid='''+@destination_agent+'''  
  AND Transstatus = ''Payment'''  

  
if @check='1'  
  SET @txt_sql = @txt_sql+' AND status = ''Post'' AND confirmDate BETWEEN   
   '''+@fromDate+''' AND '''+@toDate+' 23:59:59'''  
ELSE  
 BEGIN  
  SET @txt_sql=@txt_sql+' AND status = ''Un-Paid'' AND is_downloaded IS NULL'  
  SET @txt_sql=@txt_sql +'  
   UPDATE moneysend   
    SET status=''Post'',  
     is_downloaded=''y'',  
     downloaded_ts=getdate(),  
     downloaded_by='''+@user_id+'''  
      FROM moneysend m JOIN #temp t  
       ON m.refno=dbo.encryptdb(t.[Reference Number])  
    '  
 END  
  
SET @txt_sql=@txt_sql +'  
    SELECT * FROM #temp  
    '  
--PRINT @txt_sql  
EXEC (@txt_sql)
GO

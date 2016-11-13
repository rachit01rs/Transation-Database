drop PROC [dbo].[spa_EOD_Calc_Commission]
/****** Object:  StoredProcedure [dbo].[spa_EOD_Calc_Commission]    Script Date: 06/08/2014 00:53:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[spa_EOD_Calc_Commission]
@as_of_date VARCHAR(20)=NULL 
AS

if @as_of_date is NULL 
SET @as_of_date=CONVERT(VARCHAR,GETDATE()-1,112)  --- 2009-11-24

DECLARE @expected_payoutagentid VARCHAR(50),@send_agent_id VARCHAR(50)
--SET @expected_payoutagentid='10100000'
SET @send_agent_id='20100180'


SELECT refno,agentid,CONVERT(VARCHAR,confirmdate,101) DOT,
CASE WHEN ReceiverCountry='Pakistan' THEN 0 
WHEN ReceiverCountry='India' AND paymentType='Cash Pay' THEN 4
ELSE 3 END USD_COMM,
CASE WHEN ReceiverCountry='Pakistan' THEN 0 
WHEN ReceiverCountry='India' AND paymentType='Cash Pay' THEN 4 * ExchangeRate
ELSE 3 * ExchangeRate END Local_COMM,
ExchangeRate XRate  INTO #temp
FROM moneysend ms WITH(NOLOCK) WHERE 
ms.agentid=@send_agent_id
AND CONVERT(VARCHAR,confirmdate,112)=@as_of_date
and TransStatus not in ('OFAC','Compliance','Hold') 


DECLARE @invoice_no INT 
set @invoice_no=ident_current('agentbalance') + 1
INSERT dbo.agentBalance (
	InvoiceNo,
	agentCode,
	companyName,
	DOT,
	Amount,
	CurrencyType,
	XRate,
	mode,
	Remarks,
	staffId,
	dollar_rate,
	money_id,
	fund_date,
	approved_by,
	approved_ts
) 
SELECT @invoice_no,a.agentCode,a.CompanyName,CAST(@as_of_date+ ' 23:59:59' AS DATETIME),Local_COMM,a.CurrencyType,
t.XRate,'dr','Commission TXN:'+dbo.decryptDB(t.refno) +' @ '+ CAST(t.XRate AS VARCHAR) +' '+ a.CurrencyType,
'system',
USD_COMM,NULL,CAST(@as_of_date+ ' 23:59:59' AS DATETIME),'system',CAST(@as_of_date+ ' 23:59:59' AS DATETIME)
 FROM #temp t JOIN dbo.agentDetail a WITH(NOLOCK) ON t.agentid=a.agentcode 


SELECT refno,agentid,CONVERT(VARCHAR,confirmdate,101) DOT,
CASE WHEN ReceiverCountry='Pakistan' THEN 0 
WHEN ReceiverCountry='India' AND paymentType='Cash Pay' THEN 4 
ELSE 3 END USD_COMM,
CASE WHEN ReceiverCountry='Pakistan' THEN 0 
WHEN ReceiverCountry='India' AND paymentType='Cash Pay' THEN 4 * ExchangeRate
ELSE 3 * ExchangeRate END Local_COMM,
ExchangeRate XRate  INTO #temp_cancel
FROM moneysend ms WITH(NOLOCK) WHERE 
ms.agentid=@send_agent_id
AND CONVERT(VARCHAR,cancel_date,112)=@as_of_date
and TransStatus='Cancel' 

set @invoice_no=ident_current('agentbalance') + 1
INSERT dbo.agentBalance (
	InvoiceNo,
	agentCode,
	companyName,
	DOT,
	Amount,
	CurrencyType,
	XRate,
	mode,
	Remarks,
	staffId,
	dollar_rate,
	money_id,
	fund_date,
	approved_by,
	approved_ts
) 
SELECT @invoice_no,a.agentCode,a.CompanyName,CAST(@as_of_date+ ' 23:59:59' AS DATETIME),Local_COMM,a.CurrencyType,
t.XRate,'cr','Cancel Commission TXN:'+dbo.decryptDB(t.refno) +' @ '+ CAST(t.XRate AS VARCHAR) +' '+ a.CurrencyType,
'system',USD_COMM,NULL,CAST(@as_of_date+ ' 23:59:59' AS DATETIME),'system',CAST(@as_of_date+ ' 23:59:59' AS DATETIME)
 FROM #temp_cancel t JOIN dbo.agentDetail a WITH(NOLOCK) ON t.agentid=a.agentcode 
 


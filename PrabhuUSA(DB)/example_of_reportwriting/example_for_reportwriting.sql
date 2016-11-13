--//Example for FNADrillReport//

Select dbo.FNADrillReport(ReceiverCountry,406,''##FromDate=''+@fromDate+'';##toDate=''+@toDate+'';##ReceiverCountry=''+ReceiverCountry+'';##branch_code=''+isnull(@agent_branch_id,''null'')) ReceiverCountry,
count(*) TXN, Sum(PaidAmt) PaidAMT,Sum(SCharge) FEE from MOneySend where confirmDate between @fromDate and @toDate +'' 23:59:59'' and dbo.FNAISNULL(@agent_branch_id,branch_code)=isNull(@agent_branch_id,''1'')
Group by ReceiverCountry

--Here 406 is report_id (id of report which you want to link)

--//End//



--//Example for FNADrillRefno//

Select PaidDate,[dbo].[FNADrillRefno](''r'',dbo.DecryptDB(refno)) PINNO,rBankName PayoutLocation,
rBankBranch PayoutBranch,TotalRoundAmt PayoutAmt, receiveCType CCY,paidBy PaidUser  from Moneysend 
where Status=''Paid'' and paidDate between @fromdate and @todate
order by rBankName 


--//end//




--//Example for Report in Agentpanel//

SELECT SenderCountry [Sending Country],agentname [Sending Partner],ReceiverCountry [Payout Country],
rBankName [Receiving Partner],local_DOT [TXN Date],  Tranno [Transaction No.],paidAmt [Collected Amount],
TotalRoundAmt [Receive Amount],Branch,cast(DATEDIFF(D,local_DOT,GETDATE()) as VARCHAR) +'' day/s'' [UnClaim For]  
FROM moneySend WITH (NOLOCK) WHERE [status] IN (''Post'',''Un-Paid'') AND TransStatus=''Payment'' 
AND agentid=isNULL(@Agent_id,agentid) AND Branch_code=isNULL(@agent_branch_id,Branch_code)
  

--YOU MUST DEFINE VARIABLE @Agent_id  and  @agent_branch_id AS session
--//end//
drop PROC [dbo].[spa_SSIS_ExportFile]   
go     
--spa_SSIS_ExportFile '2012-05-01','2012-05-01'      
CREATE PROC [dbo].[spa_SSIS_ExportFile]      
@from_date VARCHAR(20),      
@to_date VARCHAR(20),      
@date_type varchar(20)='ConfirmDate',      
@agent_id VARCHAR(50)=NULL,      
@payout_country VARCHAR(100)=NULL,      
@payout_agent_id varchar(50)=NULL,  
@sender_country varchar(50) =NULL       
as      
select Tranno,dbo.decryptDB(refno) PINNO,
AgentName,
Branch,      
SenderName,
ms.senderFax Sender_ID_Type,
ms.SenderPassport Sender_ID_No,
ms.ID_Issue_date,
ms.senderVisa ID_Expire_Date,
ms.SenderAddress,
ms.SenderCity,
ms.Sender_State,
ms.sender_mobile,
ms.SSN_Card_ID,
ms.Date_of_Birth SenderDOB,
ms.SenderCountry,
senderNativeCountry SenderNativeCountry,      
ReceiverName BeneficiaryName,
receiver_mobile BeneficiaryMobile, 
ReceiverAddress,
ReceiverCity,      
ReceiverCountry,
ReceiverRelation BeneficiaryRelation,      
Paidamt CollectedAMT,
ms.SCharge ServiceCharge,      
today_dollar_rate CustomerRate,      
TotalRoundAMT PayoutAMT,
ReceiveCType PayoutCCY,PaymentType,      
convert(varchar,confirmDate,106) ApproveDate,      
convert(varchar,confirmDate,108) ApproveTime,      
rBankName PayoutAgent,
CustomerID,      
case when ms.TransStatus='Cancel' THEN 'Cancel' ELSE ms.[status] END STATUS,      
ms.ExchangeRate SendCCYUSDRate,      
ms.ho_dollar_rate PayoutCCyUSDRate,      
ms.agent_settlement_rate CustomerRateCost,      
convert(varchar,ms.paidDate ,106)   PaidDate,
convert(varchar,ms.paidDate ,108)   PaidTime,      
ms.agent_receiverSCommission PayoutCommissionSendCCY,      
ms.agent_receiverCommission PayoutCommission,      
ms.agent_receiverComm_Currency PayoutCommissionCCY,      
ms.paid_date_usd_rate PaidDateUSDRatePayoutCCY,      
--ms.PaidDate_CustRate PaidDate_CustRate,    
ms.reason_for_remittance PurposeOfRemittance,
ms.SEmpID TellerID
from moneysend ms left outer join agentDetail pa
on ms.expected_payoutagentid=pa.agentCode
where case when @date_type='PaidDate' then PaidDate else ConfirmDate end      
between @from_date and @to_date+ ' 23:59:59.990'        
and case when @agent_id is null then '1' else ms.agentid end = isNUll(@agent_id,'1')      
and case when @payout_country is null then '1' else ms.receiverCountry end = isNUll(@payout_country,'1')      
and case when @payout_agent_id is null then '1' else ms.expected_payoutagentid end = isNUll(@payout_agent_id,'1')      
and case when @sender_country is null then '1' else ms.SenderCountry end = isNUll(@sender_country,'1')      
      
      
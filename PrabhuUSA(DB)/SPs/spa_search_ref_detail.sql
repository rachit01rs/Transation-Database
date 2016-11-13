/****** Object:  StoredProcedure [dbo].[spa_search_ref_detail]    Script Date: 01/22/2015 14:23:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[spa_search_ref_detail]  
@tranno int=null,  
@refno varchar(50)=null,  
@agent_id int=null,  
@branch_code int=null,  
@payout_agent_id int=null,  
@payout_branch_id int=null,  
@payout_country varchar(150)=null,  
@paymenttype varchar(100)=NULL,  
@TransStatus varchar(100)=NULL  
as  
declare @sql varchar(5000)  
declare @row_found int,@table_name varchar(100),@enc_refno varchar(50)  
IF @refno IS NOT NULL  
 SET @enc_refno=dbo.encryptDB(@refno)  
  
if exists (select tranno from moneysend where   
tranno=@tranno or refno=@enc_refno)  
begin  
 set @table_name='MoneySend'  
end  
else  
begin  
 set @table_name='MoneySend_Arch1'  
end  
  
set @sql='select m.*,a.city BranchCity,a.CompanyName PayoutAgent,z.Zone_Name,'''+@table_name + ''' table_name,  
case when isNull(agent_receiverComm_currency,''l'')=''l'' then receiveCType else ''USD'' end agent_receiverComm_currency,  
isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end ,0)  
total_pc_flat_comm_local,  
isNull(case when isNull(agent_receiverComm_Currency,''l'')=''d'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) / isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end,0)   
total_pc_flat_comm_usd,  
isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) Payout_partner_USD_by_paidDate,  
(SCharge - (senderCommission + isNUll(agent_receiverSCommission,0))) HOSC_local,  
round((SCharge - (senderCommission + isNUll(agent_receiverSCommission,0)))/exchangeRate,4) HOSC_USD,  
isNull(case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0)* isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end   
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)),0)  total_pc_gain,  
isNull(round((case when isNull(agent_receiverComm_Currency,''l'')=''l'' then isNull(agent_receiverCommission,0) else isNull(agent_receiverCommission,0) * isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) end   
+ (agent_settlement_rate * isNull(agent_receiverSCommission,0)))/isNull(paid_date_usd_rate,exchangeRate * agent_settlement_rate) ,4),0)   
total_pc_gain_usd,ISNULL(dbo.FNAGMTDateValue(m.Local_DOT,m.agentid),'''') newConfirmDate,
ISNULL(dbo.FNAGMTDateValue(m.confirmDate,m.agentid),'''') newApproveDate,
isnull(dbo.FNAGMTDateValue(m.paidDate,m.expected_payoutagentid),'''') newPaidDate,
replace(SenderAddress + isNull('', ''+ SenderCompany,''''),''[t]'','' '') + isnull('', ''+SenderCity,'''') SenderFullAddress  
 from   
'+ @table_name +' m  WITH(NOLOCK) join agentdetail a  WITH(NOLOCK) on m.expected_payoutagentid=a.agentcode   
left outer join agentbranchdetail b  WITH(NOLOCK) on b.agent_branch_code=m.rBankid   
left outer join zone_detail z  WITH(NOLOCK) on z.zone_id=b.district_code   
where 1=1 '  
if @tranno is not null  
 set @sql=@sql+' and tranno='+ cast(@tranno as varchar)  
if @refno is not null  
 set @sql=@sql+' and refno='''+ @enc_refno +''''  
if @agent_id is not null  
 set @sql=@sql+' and agentid='+ cast(@agent_id as varchar)  
if @branch_code is not null  
 set @sql=@sql+' and branch_code='+ cast(@branch_code as varchar)  
if @payout_agent_id is not null  
 set @sql=@sql+' and paid_agent_id='+ cast(@payout_agent_id as varchar)  
if @payout_country is not null  
 set @sql=@sql+' and receiverCountry='''+ @payout_country  +''''  
if @paymenttype is not null  
 set @sql=@sql+' and paymenttype='''+ @paymenttype  +''''  
exec(@sql) 
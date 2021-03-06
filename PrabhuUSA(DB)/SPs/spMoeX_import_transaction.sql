/****** Object:  StoredProcedure [dbo].[spMoeX_import_transaction]    Script Date: 05/24/2011 09:58:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spMoeX_import_transaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spMoeX_import_transaction]
GO
--spa_add_menu 'i','admin',283,'MoeX Hold txn',NULL,'MoeX/holdtransAll.asp','Utilities'
--spa_add_menu 'i','admin',284,'MoeX Import txn',NULL,'MoeX/pendinglist.asp','Utilities'

--spMoeX_import_transaction 'i','deepen'
CREATE proc [dbo].[spMoeX_import_transaction]
	@flag char(1),
	@user_id varchar(50)
as

if @flag='s'
begin
SELECT [IdGiro],[FechaGiro],[HoraGiro],[NombreRte],[Apellido1Rte],[Apellido2Rte]
      ,[NombreBnf],[Apellido1Bnf],[Apellido2Bnf],[DirecciónBnf],[CiudadBnf],[PaisBnf],[TlfBnf1]
      ,[TlfBnf2],[Notas],[IdOfiCorresponsal],[OfiCorresponsal],[IdCorresponsal],[NombreCorresponsal]
      ,[PaisCorresponsal],[Total],[Moneda],[PagoBanco],[NombreBanco],[DireccionBanco]
      ,[NumeroCuenta],[ClaveValidacion],[ClavePago],[TipoDocBnf],[NumDocBnf],[CodigoOficina]
  FROM [MoeX_temp]
end
	
if @flag='i'
begin
	declare @agentid varchar(50)
	declare @agentname varchar(150)
	declare @Branch_code varchar(50)
	declare @branch varchar(150)
	declare @sendercountry varchar(50)
	declare @paidctype varchar(3)
	declare @cash_ledger_id int
	declare @exRateBy varchar(50)
	declare @sChargeBy varchar(50)
	declare @gmtdate datetime
	declare @ext_bank_id varchar(50)
	declare @ben_bank_name varchar(100)
	declare @cash_date varchar(20)
	declare @senderCity varchar(50)

	set @Branch_code='30106631'

--select @agentid=a.agentcode,@agentname=a.companyName,@branch=branch from agentbranchdetail b join agentdetail a on b.agentcode=a.agentcode where agent_branch_code=@Branch_code
-- SENDING AGENT DETAIL
select @agentid=a.agentcode,@agentname=a.companyName,@branch=b.branch,@sendercountry=a.country,@paidctype=currencyType,
@cash_ledger_id=cash_ledger_id,@exRateBy=exRateBy,@sChargeBy=sChargeBy,@senderCity=a.city,
@gmtdate=dateadd(mi,isNUll(gmt_value,345),getutcdate())
from agentdetail a join agentbranchdetail b on a.agentcode=b.agentcode
join agent_function f on agent_id=a.agentcode
where agent_branch_code=@branch_code

SELECT @gmtdate=dbo.getDateHO(getutcdate())
SET @cash_date=@gmtdate


--	declare @rBankId varchar(50)
--	declare @rBankBranch varchar(100)
--	declare @rBankName varchar(100)
--	declare @receiveAgentID  varchar(100)


create table #temp (refno varchar(50))
--select * from moneysend where refno in (select dbo.encryptdb(ltrim(rtrim(mt.IdGiro))) from MoeX_temp mt)
--delete moneysend where refno in (select dbo.encryptdb(ltrim(rtrim(mt.IdGiro))) from MoeX_temp mt)
--update [MoeX_temp] set tranno =NULL
if exists (select m.tranno from moneysend m join MoeX_temp mt on m.refno=dbo.encryptdb(ltrim(rtrim(mt.IdGiro))))
begin
	insert into #temp (refno) select ltrim(rtrim(mt.IdGiro)) from moneysend m join MoeX_temp mt 
	on m.refno=dbo.encryptdb(ltrim(rtrim(mt.IdGiro))) and mt.tranno is null
end
--select iso.country,total,* from MoeX_temp mt join ISO_3166_1_alfa_3 iso on mt.PaisBnf=iso.ISOCode

create table #temp_charge(refno varchar(50),country varchar(100),paidCtype varchar(3),
total money,scharge float,sendcomm float,paidcomm float,ExchangeRate float,NPRRate float,DollarRate float)
insert into #temp_charge(refno,country,paidCtype,total)
select ltrim(rtrim(mt.IdGiro)),iso.country,mt.Moneda,mt.Total from MoeX_temp mt join ISO_3166_1_alfa_3 iso on mt.PaisBnf=iso.ISOCode
left outer join #temp t on t.refno=ltrim(rtrim(mt.IdGiro)) where t.refno is null and mt.tranno is null

update #temp_charge set 
scharge=
case when (t.total between scs.min_amount and scs.max_amount and scs.service_charge_mode='f') then service_charge_flat 
else (service_charge_per*total)/100 end ,
sendComm=
case when (t.total between scs.min_amount and scs.max_amount and scs.send_commission_type='f') then send_commission 
else (send_commission*total)/100 end ,
paidComm=
case when (t.total between scs.min_amount and scs.max_amount and scs.paid_commission_type='f') then paid_commission 
else (paid_commission*total)/100 end 
 from #temp_charge t join service_charge_setup scs on t.country=scs.Rec_country
and t.total between scs.min_amount and scs.max_amount
where agent_id=@agentid

update #temp_charge set ExchangeRate=isNULL(r.ExchangeRate,1),
NPRRate=isNULL(r.NPRRate,1),DollarRate=isNULL(r.DollarRate,1) from #temp_charge t left outer join agentCurrencyRate r on
r.receiveCountry=t.country 
--or 
--t.paidCtype=r.receiveCType 
where r.agentid=@agentid
--select * from #temp_charge
--select * from agentCurrencyRate

INSERT INTO [moneySend]
([refno],[agentid],[agentname],[Branch_code],[Branch],[CustomerId],[SenderName],[SenderAddress],[SenderPhoneno],[senderSalary],
[senderFax],[SenderCity],[SenderCountry],[SenderEmail],[SenderCompany],[senderPassport],[senderVisa],[ReceiverName],[ReceiverAddress],
[ReceiverPhone],[ReceiverFax],[ReceiverCity],[ReceiverCountry],[ReceiverRelation],[ReceiverIDDescription],[ReceiverID],[DOT],[DOtTime],
[paidAmt],[paidCType],[receiveAmt],[receiveCType],[ExchangeRate],[Today_Dollar_rate],[Dollar_Amt],[SCharge],[ReciverMessage],
[TestQuestion],[TestAnswer],[amtSenderType],[SenderBankID],[SenderBankName],[SenderBankBranch],[SenderBankVoucherNo],[Amt_paid_date],
[paymentType],[rBankID],[rBankName],[rBankBranch],[rBankACNo],[rBankAcType],[otherCharge],[TransStatus],[status],[SEmpID],[bTno],
[imeCommission],[bankCommission],[TotalRoundAmt],[TransferType],[paidBy],[paidDate],[paidTime],[courierID],[PODDate],[senderCommission],
[receiverCommission],[approve_by],[receiveAgentID],[send_mode],[confirmDate],[lock_status],[lock_dot],[lock_by],[local_DOT],[sender_mobile],
[receiver_mobile],[fax_trans],[SenderNativeCountry],[receiverEmail],[ip_address],[agent_dollar_rate],[ho_dollar_rate],[bonus_amt],
[request_for_new_account],[trans_mode],[digital_id_sender],[digital_id_payout],[expected_payoutagentid],
[bonus_value_amount],[bonus_type],[bonus_on],[ben_bank_id],[ben_bank_name],[test_Trn],[paid_agent_id],[send_sms],[agent_settlement_rate],
[agent_ex_gain],[cancel_date],[cancel_by],[agent_receiverCommission],[agent_receiverSCommission],[door_to_door],[customer_sno],
[paid_date_usd_rate],[upload_trn],[PNBReferenceNo],[receiverID_placeOfIssue],[mileage_earn],[tds_com_per],[agent_receiverComm_Currency],
[paid_beneficiary_ID_type],[paid_beneficiary_ID_number],[source_of_income],[reason_for_remittance],[payout_settle_usd],[confirm_process_id],
[costValue_SC],[costValue_PC],[Send_Settle_USD],[c2c_receiver_code],[c2c_secure_pwd],[ofac_list],[ofac_app_by],[ofac_app_ts],[ho_cost_send_rate],
[ho_premium_send_rate],[ho_premium_payout_rate],[agent_customer_diff_value],[agent_sending_rate_margin],[agent_payout_rate_margin],
[agent_sending_cust_exchangerate],[agent_payout_agent_cust_rate],[ho_exrate_applied_type],[c2c_pin_no],[HO_confirmDate],[HO_paidDate],
[HO_cancel_Date],[sender_fax_no],[ID_Issue_date],[SSN_Card_ID],[Date_of_Birth],[Sender_State],[compliance_flag],[compliance_sys_msg],
[transfer_ts],[HO_ex_gain],[ext_sCharge],[xm_exRate],[ext_settlement_amt],[isIRH_trn],[is_downloaded],[downloaded_by],[downloaded_ts],
[ext_payout_amount])
-- [IdGiro],[FechaGiro],[HoraGiro],[NombreRte],[Apellido1Rte],[Apellido2Rte]
--      ,[NombreBnf],[Apellido1Bnf],[Apellido2Bnf],[DirecciónBnf],[CiudadBnf],[PaisBnf],[TlfBnf1]
--      ,[TlfBnf2],[Notas],[IdOfiCorresponsal],[OfiCorresponsal],[IdCorresponsal],[NombreCorresponsal]
--      ,[PaisCorresponsal],[Total],[Moneda],[PagoBanco],[NombreBanco],[DireccionBanco]
--      ,[NumeroCuenta],[ClaveValidacion],[ClavePago],[TipoDocBnf],[NumDocBnf],[CodigoOficina]

SELECT dbo.encryptdb(ltrim(rtrim([IdGiro]))) [refno],@agentid [agentid],@agentname [agentname],@Branch_code [Branch_code],@branch [Branch],
NULL [CustomerId],replace(ltrim(rtrim([NombreRte]))+' '+isNULL(ltrim(rtrim([Apellido1Rte])),'')+' '+isNULL(ltrim(rtrim([Apellido2Rte])),''),'  ',' ') [SenderName],
NULL [SenderAddress],NULL [SenderPhoneno],NULL [senderSalary],
NULL [senderFax],@senderCity [SenderCity],@sendercountry [SenderCountry],NULL [SenderEmail],NULL [SenderCompany],NULL [senderPassport],NULL [senderVisa],
replace(ltrim(rtrim([NombreBnf]))+' '+isNULL(ltrim(rtrim([Apellido1Bnf])),'')+' '+isNULL(ltrim(rtrim([Apellido2Bnf])),''),'  ',' ') [ReceiverName],
ltrim(rtrim([DirecciónBnf])) [ReceiverAddress],
ltrim(rtrim([TlfBnf1])) [ReceiverPhone],ltrim(rtrim([TlfBnf2])) [ReceiverFax],ltrim(rtrim([CiudadBnf])) [ReceiverCity],
t.country [ReceiverCountry],
NULL [ReceiverRelation],NULL [ReceiverIDDescription],NULL [ReceiverID],
substring([FechaGiro],5,2)+'/'+substring([FechaGiro],7,2)+'/'+substring([FechaGiro],1,4) [DOT],
substring([HoraGiro],1,2)+':'+substring([HoraGiro],3,2)+':00' [DOtTime],
mt.total/t.NPRRate [paidAmt],@paidctype [paidCType],
(mt.total/t.NPRRate-isNULL(t.scharge,0))*t.NPRRate [receiveAmt],t.paidCtype [receiveCType],
t.ExchangeRate [ExchangeRate],t.NPRRate [Today_Dollar_rate],(mt.total/t.NPRRate)/t.ExchangeRate [Dollar_Amt],
isNULL(t.scharge,0) [SCharge],
ltrim(rtrim([Notas]))+'/'+isNULL(ltrim(rtrim(NombreBanco)),'')+':'+isNULL(ltrim(rtrim(DireccionBanco)),'') [ReciverMessage],
NULL [TestQuestion],NULL [TestAnswer],NULL [amtSenderType],NULL [SenderBankID],NULL [SenderBankName],NULL [SenderBankBranch],
NULL [SenderBankVoucherNo],NULL [Amt_paid_date],
case when PagoBanco='N' then 'Cash Pay' when PagoBanco='S' then 'Bank Transfer' end [paymentType],
NULL [rBankID],NULL [rBankName],NULL [rBankBranch],ltrim(rtrim(NumeroCuenta)) [rBankACNo],
ltrim(rtrim(DireccionBanco)) [rBankAcType],NULL [otherCharge],
'Hold' [TransStatus],'Un-Paid' [status],'MoeX' [SEmpID],NULL [bTno],
NULL [imeCommission],NULL [bankCommission],mt.total [TotalRoundAmt],NULL [TransferType],NULL [paidBy],NULL [paidDate],NULL [paidTime],NULL [courierID],
NULL [PODDate],isNULL(t.sendcomm,0) [senderCommission],NULL [receiverCommission],NULL [approve_by],NULL [receiveAgentID],NULL [send_mode],NULL [confirmDate],
NULL [lock_status],NULL [lock_dot],NULL [lock_by],
@gmtdate [local_DOT],
NULL [sender_mobile],NULL [receiver_mobile],NULL [fax_trans],
NULL [SenderNativeCountry],NULL [receiverEmail],NULL [ip_address],NULL [agent_dollar_rate],NULL [ho_dollar_rate],NULL [bonus_amt],
NULL [request_for_new_account],NULL [trans_mode],NULL [digital_id_sender],NULL [digital_id_payout],NULL [expected_payoutagentid],
NULL [bonus_value_amount],NULL [bonus_type],NULL [bonus_on],NULL [ben_bank_id],ltrim(rtrim(NombreBanco)) [ben_bank_name],NULL [test_Trn],NULL [paid_agent_id],
NULL [send_sms],NULL [agent_settlement_rate],NULL [agent_ex_gain],NULL [cancel_date],
NULL [cancel_by],NULL [agent_receiverCommission],isNULL(paidcomm,0) [agent_receiverSCommission],
NULL [door_to_door],NULL [customer_sno],NULL [paid_date_usd_rate],NULL [upload_trn],NULL [PNBReferenceNo],
NULL [receiverID_placeOfIssue],NULL [mileage_earn],NULL [tds_com_per],NULL [agent_receiverComm_Currency],
ltrim(rtrim(TipoDocBnf)) [paid_beneficiary_ID_type],ltrim(rtrim(NumDocBnf)) [paid_beneficiary_ID_number],NULL [source_of_income],NULL [reason_for_remittance],
NULL [payout_settle_usd],NULL [confirm_process_id],NULL [costValue_SC],NULL [costValue_PC],NULL [Send_Settle_USD],
NULL [c2c_receiver_code],NULL [c2c_secure_pwd],NULL [ofac_list],NULL [ofac_app_by],NULL [ofac_app_ts],
NULL [ho_cost_send_rate],NULL [ho_premium_send_rate],NULL [ho_premium_payout_rate],NULL [agent_customer_diff_value],
NULL [agent_sending_rate_margin],NULL [agent_payout_rate_margin],NULL [agent_sending_cust_exchangerate],
NULL [agent_payout_agent_cust_rate],NULL [ho_exrate_applied_type],NULL [c2c_pin_no],NULL [HO_confirmDate],
NULL [HO_paidDate],NULL [HO_cancel_Date],NULL [sender_fax_no],NULL [ID_Issue_date],NULL [SSN_Card_ID],
NULL [Date_of_Birth],NULL [Sender_State],NULL [compliance_flag],NULL [compliance_sys_msg],NULL [transfer_ts],NULL [HO_ex_gain],
NULL [ext_sCharge],NULL [xm_exRate],NULL [ext_settlement_amt],NULL [isIRH_trn],NULL [is_downloaded],NULL [downloaded_by],NULL [downloaded_ts],
NULL [ext_payout_amount]
FROM [MoeX_temp] mt join #temp_charge t on ltrim(rtrim(mt.IdGiro))=t.refno where mt.tranno is null


update [MoeX_temp] set tranno=m.tranno from moneysend m join [MoeX_temp] mt on m.refno=dbo.encryptdb(ltrim(rtrim(mt.IdGiro)))
where mt.tranno is null

create table #ofac(tranno int,senderName varchar(100),receivername varchar(100),ofac char(1))
insert into #ofac(tranno,senderName,receivername,ofac)
select m.tranno,rtrim(ltrim(m.sendername)),m.receivername,o.*,case when o.sno is not null then 'y' else NULL end from moneysend m 
left outer join ofac_combined o on upper(o.name)=rtrim(ltrim(m.sendername)) where m.tranno=1895221
join MoeX_temp mt on m.tranno=mt.tranno 
update moneysend set ofac_list=o.ofac from moneysend m join #ofac o on m.tranno=o.tranno


end


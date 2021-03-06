drop proc [dbo].[spa_XM_GetStatusList]
go



--select top 100 * from moneysend where refno = dbo.encryptdb('9999910941054434')
--select * from agentbranchdetail where agentcode='20100019'
--spa_XM_GetStatusList '<?xml version=''1.0'' encoding=''UTF-8''?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><tns:getXMTxnStatusListResponse xmlns:tns="http://services.xm.org/xsd"><tns:result>	<tns:returnCode>100</tns:returnCode>	<tns:returnMsg>Success</tns:returnMsg></tns:result><tns:result>	<tns:txnStatus>Completed - Received by beneficiary</tns:txnStatus>	<tns:xpin>9999910941056046</tns:xpin></tns:result><tns:result>	<tns:txnStatus>Completed - Received by beneficiary</tns:txnStatus>	<tns:xpin>9999910941054434</tns:xpin></tns:result></tns:getXMTxnStatusListResponse></soapenv:Body></soapenv:Envelope>'

create proc [dbo].[spa_XM_GetStatusList]
@xmlValue varchar(8000)
as

DECLARE @sql VARCHAR(8000)
DECLARE @idoc int
DECLARE @doc varchar(1000)
set @xmlValue=replace(@xmlValue,'tns:','')
set @xmlValue=replace(@xmlValue,'soapenv:','')

exec sp_xml_preparedocument @idoc OUTPUT, @xmlValue
-----------------------------------------------------------------

SELECT * into #ztbl_xmlvalue
FROM   OPENXML (@idoc, 'Envelope/Body/getXMTxnStatusListResponse/result',2)
         WITH ( 
               txnStatus  varchar(100) 'txnStatus',
               xpin  VarcHAR(100) 'xpin'
	     
			)
exec sp_xml_removedocument @idoc

select m.senderName senderName,m.receiverName receiverName,xm.xpin xpin,
case 
when xm.txnStatus like '%Received%' and m.status='Post' and m.transStatus='Payment' then 'Paid Now' 
when xm.txnStatus like '%Received%' and m.status='Paid' then 'Paid Already' 
when xm.txnStatus like '%Received%' and m.status='Post' and m.transStatus='Block' then 'Cannot Pay Txn is Blocked in the system' 
else xm.txnStatus end txnStatus,m.receiverCountry receiverCountry
from #ztbl_xmlvalue xm left outer join moneysend m WITH (NOLOCK) on 
m.refno=dbo.encryptDb(xm.xpin) where txnStatus is not null

declare @MAIN_LEDGER_ID varchar(50)

select @MAIN_LEDGER_ID=headoffice_agent_id from tbl_setup
DECLARE @DIG_INFO varchar(200),@user_id varchar(100),@rbankid varchar(50),@xpress_id varchar(50),@rbankBranch varchar(200)
--set @xpress_id='20100019'
select @xpress_id=XM_agentid from tbl_setup
select top 1 @rbankid=agent_branch_code,@rbankBranch=branch from agentbranchdetail where agentcode=@xpress_id
set @user_id='System Payment'
set @DIG_INFO='System Payment'

set @sql='
	Update MoneySend set 
	rBankId='''+@rbankid+''',
	rBankBranch='''+@rbankBranch+''',
	paidBy='''+@user_id +''',
	paidDate=dateadd(mi,isNUll(a.gmt_value,345),getutcdate()),
	podDate=dateadd(mi,isNUll(a.gmt_value,345),getutcdate()),
	paidTime=convert(varchar,dateadd(mi,isNUll(a.gmt_value,345),getutcdate()),108),
	status=''Paid'', receiverCommission=isNUll(c.commission_value,0),
	receiveAgentID=b.agentcode,
	digital_id_payout='''+ @DIG_INFO  +''',
	agent_receiverCommission=isNUll(ac.commission_value,0),
	agent_receiverComm_Currency=ac.comm_currency_type,
	lock_status=''unlocked'',
	paid_agent_id=b.agentcode,
	paid_date_usd_rate=isNull(acr.DollarRate,1)
	from moneysend m join #ztbl_xmlvalue xm on dbo.decryptdb(m.refno)=xm.xpin
	join agentbranchdetail b 
	on isNULL(m.rBankId,'''+@rbankid+''')=b.agent_branch_code join agentdetail a
	on b.agentcode=a.agentcode 
	left outer join agent_branch_commission c 
	on b.agent_branch_code=c.agent_branch_code  and c.country=m.senderCountry
	left outer join agent_branch_commission ac  
	on ac.agent_code=m.expected_payoutagentid  and ac.country=m.senderCountry
	left outer join agentpayout_CurrencyRate acr on acr.agentid=m.agentid 
	and acr.payout_agent_id=m.expected_payoutagentid
	left outer join agentCurrencyRate cr on cr.agentid=m.agentid 
	and cr.receiveCountry=m.receiverCountry 
	where txnStatus is not null 
	and txnStatus like ''%Received%''
	and transStatus=''Payment'' 
	and Status=''Post'''
print (@sql)
exec (@sql)
set @sql='
	Update agentDetail set 
	currentBalance=isNull(currentBalance,0)-m.balance
	from (select expected_payoutagentid,sum(totalroundamt) Balance 
	from moneysend m join #ztbl_xmlvalue xm on dbo.decryptdb(m.refno)=xm.xpin where xm.txnStatus is not null 
	and xm.txnStatus like ''%Received%'' and transStatus=''Payment'' 
	and Status=''Post'' and receiverCommission > 0 group by expected_payoutagentid)	
m  join agentdetail a
	on m.expected_payoutagentid=a.agentcode '

print(@sql)
exec(@sql)

	declare @invoice_no int
	select @invoice_no=max(cast(invoiceNo as int)) from agentbalance where isNumeric(invoiceNo)=1

	if @invoice_no is null 
		set @invoice_no=1001
	else
		set @invoice_no=@invoice_no+1

declare @total_row int
set @sql='
insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,
Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)
select '''+ cast(@invoice_no as varchar) +''',a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),m.receiverCommission,a.CurrencyType,
c.usdRRate,''cr'',''Commission Gain:''+ dbo.decryptDB(m.refno),paidBy, cast(receiverCommission/c.usdRRate as money),b.agent_branch_code,
dbo.getDateHO(getutcdate()),paidBy,dbo.getDateHO(getutcdate())
from moneysend m join #ztbl_xmlvalue xm on dbo.decryptdb(m.refno)=xm.xpin 
join agentbranchdetail b on m.rBankId=b.comm_main_branch_id join agentdetail a on b.agentcode=a.agentcode join 
(select avg(DollarRate) usdRRate,receivecountry from CurrencyRate group by receivecountry) c 
on c.receivecountry=a.country where 
xm.txnStatus like ''%Received%'' and transStatus=''Payment'' and Status=''Paid''  and receiverCommission > 0 '
print 'Insert AgentBalnce '
exec (@sql)
--return
set @total_row=@@rowcount
--
if @total_row > 0
begin
	set @sql='
	insert agentbalance(invoiceno,agentcode,CompanyName,Dot,amount,currencyType,XRate,
	Mode,Remarks,Staffid,dollar_rate,branch_code,fund_date,approved_by,approved_ts)
	select '''+ cast(@invoice_no as varchar) +''',a.agentCode,a.CompanyName,dbo.getDateHO(getutcdate()),receiverCommission,a.CurrencyType,
	c.usdRRate,''dr'',''Commission Gain:'','''+@user_id +''', cast(m.receiverCommission/c.usdRRate as money),NULL,
	dbo.getDateHO(getutcdate()),'''+@user_id +''',dbo.getDateHO(getutcdate())
	from 
	(select expected_payoutagentid,sum(receiverCommission) receiverCommission 
	from moneysend ms join #ztbl_xmlvalue xm on dbo.decryptdb(ms.refno)=xm.xpin where xm.txnStatus is not null 
	and xm.txnStatus like ''%Received%'' and ms.transStatus=''Payment''

	 group by expected_payoutagentid)	
m  join agentdetail a on m.expected_payoutagentid=a.agentcode join 
	(select avg(DollarRate) usdRRate,receivecountry from CurrencyRate group by receivecountry ) c 
	on c.receivecountry=a.country '
	print 'Insert AgentBalnce Main Ledger'
	exec(@sql)

	set @sql='
	Update agentBranchDetail set currentBalance=isNull(currentBalance,0)-m.Balance
	from agentBranchDetail b join 
	(select rBankId,sum(receiverCommission) Balance 
	from moneysend ms join #ztbl_xmlvalue xm on dbo.decryptdb(ms.refno)=xm.xpin where xm.txnStatus is not null 
	and xm.txnStatus like ''%Received%'' and transStatus=''Payment'' 
	and Status=''Paid'' and receiverCommission > 0 group by rBankId)	
m on b.comm_main_branch_id=m.rBankId'
	
	print 'Update Branch Commission Balance'
	exec(@sql)

end



set @sql='
	Update agentBranchDetail set 
	currentBalance=isNull(currentBalance,0)-m.balance
	from (select rBankId,sum(totalroundamt+ case when receivercountry=''Nepal'' then 0 else receiverCommission end) Balance 
	from moneysend ms join #ztbl_xmlvalue xm on dbo.decryptdb(ms.refno)=xm.xpin where xm.txnStatus is not null 
	and xm.txnStatus like ''%Received%'' and transStatus=''Payment'' 
	and Status=''Paid'' and receiverCommission > 0 group by rBankId)	
m  join agentBranchDetail a
	on m.rBankId=a.agent_branch_code '
	
print 'Update Branch Balance'
exec(@sql)




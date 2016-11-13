drop proc [dbo].[spa_SSIS_Export_MEEZAN]
go

create proc [dbo].[spa_SSIS_Export_MEEZAN]
as
SET NOCOUNT ON
declare @ditital_id varchar(200),@expected_payoutagentid varchar(50),@rBankid varchar(50)
set @ditital_id = REPLACE(newid(),'-','_')    
set @expected_payoutagentid='20100081'
select top 1 @rBankid=agent_branch_code from agentbranchdetail where agentCode=@expected_payoutagentid

update moneysend set is_downloaded='p' FROM dbo.moneySend m WITH(NOLOCK)   JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
 where expected_payoutagentid=@expected_payoutagentid and Transstatus ='Payment' 
and is_downloaded is null and status='Un-Paid'  AND ISNULL(a.disable_payout,'n')<>'y'

select dbo.decryptdb(refno) as [Pin Number / Code],
		case when paymentType in ('Cash Pay') then '01' else case when paymentType in ('Bank Transfer') then '02' else '03'  end end [Payment Mode],
		totalRoundAmt [Local Currency Amount],
		receiveCType [Currency Id],
		'01' [Remittance Purpose Id],
		senderName as [Remitter Name],
		convert(varchar,cast(confirmDate as datetime),101) as [Remittance Date],
		ReceiverName as [Beneficiary Name],
		case when paymentType='Cash Pay' then NULL else rBankACNo END as [Beneficiary A/C No],
		case when paymentType in ('Bank Transfer','Cash Pay') then 'MBL' else ben_bank_id end [Beneficiary Bank Code],
		case when paymentType in ('Bank Transfer','Cash Pay') then 'Meezan Bank' else ben_bank_name end [Beneficiary Bank Name],
		b.ext_branch_code [Beneficiary Branch Code],
		case when paymentType in ('Bank Transfer','Cash Pay') then rBankBranch else rBankAcType end [Beneficiary Branch Name],
		case when paymentType in ('Bank Transfer','Cash Pay') then b.address else rBankAcType end [Beneficiary Branch Address],
		receiverAddress as [Beneficiary Address],		
		'' as [Beneficiary CNIC],
		receiverphone as [Beneficiary Phone],	
		receiver_mobile as [Beneficiary Mobile],
		'' as [Beneficiary E-Mail],
		sendercountry as [Remitter Country],
		'' as [Remitter E-Mail],
		sender_mobile as [Remitter Mobile],
		'' as [Message to Beneficiary]
from moneysend m with (nolock) left outer join agentbranchdetail b WITH(NOLOCK) on b.agent_branch_code=m.rBankID
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
where expected_payoutagentid=@expected_payoutagentid and Transstatus ='Payment'
and is_downloaded ='p' and status='Un-Paid'
 AND ISNULL(a.disable_payout,'n')<>'y'


INSERT  INTO [temp_trn_csv_pay]
        ( [tranno] ,
          [refno] ,
          [ReceiverName] ,
          [TotalRoundAmt] ,
          [paidDate] ,
          [paidBy] ,
          [expected_payoutagentid] ,
          [rBankID] ,
          [rBankName] ,
          [rBankBranch] ,
          [digital_id_payout]
        )
        SELECT  m.tranno ,
                m.refno ,
                m.receiverName ,
                m.totalRoundAmt ,
                CAST(dbo.getDateHO(getutcdate()) AS DATETIME),
                'SYSTEM' ,
                expected_payoutagentid ,
                isNULL(rBankID,@rBankid) ,
                rBankName ,
                isNULL(rBankBranch,b.branch) ,
                @ditital_id
        FROM    moneysend m WITH (NOLOCK) 
left outer join agentbranchdetail b WITH (NOLOCK) on b.agent_branch_code=isNULL(m.rBankID,@rBankid)
  JOIN agentdetail a WITH(NOLOCK) ON a.agentCode=m.agentid 
where expected_payoutagentid=@expected_payoutagentid and Transstatus ='Payment'
and is_downloaded ='p' and status='Un-Paid'  AND ISNULL(a.disable_payout,'n')<>'y'



-- PIC Update to Post
--update prabhuCash.dbo.moneysend set is_downloaded='y',downloaded_by='system',downloaded_ts=getdate(),status='Post'
--from moneysend u join prabhuCash.dbo.moneysend p
--on u.refno=p.refno where u.expected_payoutagentid=@expected_payoutagentid and u.Transstatus ='Payment' 
--and u.is_downloaded='p' and u.status='Un-Paid'

----USA Update to Post
--update moneysend set is_downloaded='y',downloaded_by='system',downloaded_ts=getdate(),status='Post'
--where expected_payoutagentid=@expected_payoutagentid and Transstatus ='Payment' 
--and is_downloaded='p' and status='Un-Paid'

-- payment Process run--------------
create table #temp(col1 varchar(100),col2 varchar(100),col3 varchar(100))
insert into #temp
EXEC spa_make_bulk_payment_csv @ditital_id,NULL,'y'


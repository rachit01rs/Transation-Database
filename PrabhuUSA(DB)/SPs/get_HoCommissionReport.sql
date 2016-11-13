
/****** Object:  StoredProcedure [dbo].[get_HoCommissionReport]    Script Date: 10/31/2014 16:12:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[get_HoCommissionReport]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[get_HoCommissionReport]
GO

/****** Object:  StoredProcedure [dbo].[get_HoCommissionReport]    Script Date: 10/31/2014 16:12:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
--get_HoCommissionReport '2008-01-01','2010-07-22'  
create procedure [dbo].[get_HoCommissionReport]  
@flag char(1),  
@from_date varchar(50),  
@to_date varchar(50),  
@agentid varchar(50)=NULL,  
@group_by char(1)='d'  
as  
declare @sql varchar(8000)  
if @group_by='d'  
begin  
 set @sql='select convert(varchar,confirmdate,101) DOT,  
 ''Send'' Mode,count(tranno) TotalTrn,  
 sum(case when paidCType=''USD'' then Scharge else Scharge/exchangerate end) Scharge_usd,  
 sum(case when paidCType=''USD'' then isnull(senderCommission,0) else isnull(senderCommission,0)/exchangerate end) sendingCOmm_USD,  
 sum(case when paidCType=''USD'' then isnull(agent_receiverScommission,0) else isnull(agent_receiverScommission,0)/exchangerate end) PayoutComm_USD,  
 sum(case when paidCType=''USD'' then (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) else (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0))/exchangerate end)  
 HO_Commission_USD  
 from moneysend m join agentdetail a on m.agentid=a.agentcode  
 left outer join agentdetail p on m.expected_payoutagentid=p.agentcode  
 where transstatus in(''Cancel'',''Payment'',''Block'',''OFAC'',''Compliance'') and confirmdate between'''+ @from_date+''' and '''+@to_date+' 23:59:59'''  
 if @agentid is not null  
  set @sql=@sql+' and agentid='''+@agentid+''''  
 set @sql=@sql+'  
 group by convert(varchar,confirmdate,101)  
 UNION ALL  
 select convert(varchar,cancel_date,101) DOT,  
 ''<font color="red">Cancel</font>'' Mode,count(tranno) TotalTrn,  
 -sum(case when paidCType=''USD'' then Scharge else Scharge/exchangerate end) Scharge_usd,  
 -sum(case when paidCType=''USD'' then isnull(senderCommission,0) else isnull(senderCommission,0)/exchangerate end) sendingCOmm_USD,  
 -sum(case when paidCType=''USD'' then isnull(agent_receiverScommission,0) else isnull(agent_receiverScommission,0)/exchangerate end) PayoutComm_USD,  
 -sum(case when paidCType=''USD'' then (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) else (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0))/exchangerate end)  
 HO_Commission_USD  
 from moneysend m join agentdetail a on m.agentid=a.agentcode  
 left outer join agentdetail p on m.expected_payoutagentid=p.agentcode  
 where transstatus =''Cancel'' and cancel_date between'''+ @from_date+''' and '''+@to_date+' 23:59:59'''  
 if @agentid is not null  
  set @sql=@sql+' and agentid='''+@agentid+''''  
 set @sql=@sql+'  
 group by convert(varchar,cancel_date,101)  
 order by DOT,mode desc'  
end  
if @group_by='s'  
begin  
 set @sql='select convert(varchar,confirmdate,101) DOT,a.agent_short_code Main_Agent,  
 ''Send'' Mode,count(tranno) TotalTrn,sum(Scharge) sCharge_Local,paidCType paidCType,  
 sum(case when paidCType=''USD'' then Scharge else Scharge/exchangerate end) Scharge_usd,sum(isnull(senderCommission,0)) sendingCOmm,  
 sum(case when paidCType=''USD'' then isnull(senderCommission,0) else isnull(senderCommission,0)/exchangerate end) sendingCOmm_USD,  
 sum(isnull(agent_receiverScommission,0)) PayoutComm,  
 sum(case when paidCType=''USD'' then isnull(agent_receiverScommission,0) else isnull(agent_receiverScommission,0)/exchangerate end) PayoutComm_USD,  
 sum(Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) HO_Commission,  
 sum(case when paidCType=''USD'' then (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) else (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0))/exchangerate end)  
 HO_Commission_USD  
 from moneysend m join agentdetail a on m.agentid=a.agentcode  
 left outer join agentdetail p on m.expected_payoutagentid=p.agentcode  
 where transstatus in(''Cancel'',''Payment'',''Block'',''OFAC'',''Compliance'') and confirmdate between'''+ @from_date+''' and '''+@to_date+' 23:59:59'''  
 if @agentid is not null  
  set @sql=@sql+' and agentid='''+@agentid+''''  
 set @sql=@sql+'  
 group by convert(varchar,confirmdate,101),a.agent_short_code,paidCType  
 UNION ALL  
 select convert(varchar,cancel_date,101) DOT,a.agent_short_code Main_Agent,  
 ''<font color="red">Cancel</font>'' Mode,count(tranno) TotalTrn,-sum(Scharge) sCharge_Local,paidCType paidCType,  
 -sum(case when paidCType=''USD'' then Scharge else Scharge/exchangerate end) Scharge_usd,-sum(isnull(senderCommission,0)) sendingCOmm,  
 -sum(case when paidCType=''USD'' then isnull(senderCommission,0) else isnull(senderCommission,0)/exchangerate end) sendingCOmm_USD,  
 -sum(isnull(agent_receiverScommission,0)) PayoutComm,  
 -sum(case when paidCType=''USD'' then isnull(agent_receiverScommission,0) else isnull(agent_receiverScommission,0)/exchangerate end) PayoutComm_USD,  
 -sum(Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) HO_Commission,  
 -sum(case when paidCType=''USD'' then (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) else (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0))/exchangerate end)  
 HO_Commission_USD  
 from moneysend m join agentdetail a on m.agentid=a.agentcode  
 left outer join agentdetail p on m.expected_payoutagentid=p.agentcode  
 where transstatus =''Cancel'' and cancel_date between'''+ @from_date+''' and '''+@to_date+' 23:59:59'''  
 if @agentid is not null  
  set @sql=@sql+' and agentid='''+@agentid+''''  
 set @sql=@sql+'  
 group by convert(varchar,cancel_date,101),a.agent_short_code,paidCType  
 order by Main_Agent,DOT,mode desc'  
end  
if @group_by='b'  
begin  
 set @sql='select convert(varchar,confirmdate,101) DOT,a.agent_short_code Main_Agent,isNull(p.agent_short_code,ReceiverCountry) Payout_Agent,  
 ''Send'' Mode,count(tranno) TotalTrn,sum(Scharge) sCharge_Local,paidCType paidCType,  
 sum(case when paidCType=''USD'' then Scharge else Scharge/exchangerate end) Scharge_usd,sum(isnull(senderCommission,0)) sendingCOmm,  
 sum(case when paidCType=''USD'' then isnull(senderCommission,0) else isnull(senderCommission,0)/exchangerate end) sendingCOmm_USD,  
 sum(isnull(agent_receiverScommission,0)) PayoutComm,  
 sum(case when paidCType=''USD'' then isnull(agent_receiverScommission,0) else isnull(agent_receiverScommission,0)/exchangerate end) PayoutComm_USD,  
 sum(Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) HO_Commission,  
 sum(case when paidCType=''USD'' then (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) else (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0))/exchangerate end)  
 HO_Commission_USD  
 from moneysend m join agentdetail a on m.agentid=a.agentcode  
 left outer join agentdetail p on m.expected_payoutagentid=p.agentcode  
 where transstatus in(''Cancel'',''Payment'',''Block'',''OFAC'',''Compliance'') and confirmdate between'''+ @from_date+''' and '''+@to_date+' 23:59:59'''  
 if @agentid is not null  
  set @sql=@sql+' and agentid='''+@agentid+''''  
 set @sql=@sql+'  
 group by convert(varchar,confirmdate,101),a.agent_short_code,isNull(p.agent_short_code,ReceiverCountry),paidCType  
 UNION ALL  
 select convert(varchar,cancel_date,101) DOT,a.agent_short_code Main_Agent,isNull(p.agent_short_code,ReceiverCountry) Payout_Agent,  
 ''<font color="red">Cancel</font>'' Mode,count(tranno) TotalTrn,-sum(Scharge) sCharge_Local,paidCType paidCType,  
 -sum(case when paidCType=''USD'' then Scharge else Scharge/exchangerate end) Scharge_usd,-sum(isnull(senderCommission,0)) sendingCOmm,  
 -sum(case when paidCType=''USD'' then isnull(senderCommission,0) else isnull(senderCommission,0)/exchangerate end) sendingCOmm_USD,  
 -sum(isnull(agent_receiverScommission,0)) PayoutComm,  
 -sum(case when paidCType=''USD'' then isnull(agent_receiverScommission,0) else isnull(agent_receiverScommission,0)/exchangerate end) PayoutComm_USD,  
 -sum(Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) HO_Commission,  
 -sum(case when paidCType=''USD'' then (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0)) else (Scharge-isnull(senderCommission,0)-isnull(agent_receiverScommission,0))/exchangerate end)  
 HO_Commission_USD  
 from moneysend m join agentdetail a on m.agentid=a.agentcode  
 left outer join agentdetail p on m.expected_payoutagentid=p.agentcode  
 where transstatus =''Cancel'' and cancel_date between'''+ @from_date+''' and '''+@to_date+' 23:59:59'''  
 if @agentid is not null  
  set @sql=@sql+' and agentid='''+@agentid+''''  
 set @sql=@sql+'  
 group by convert(varchar,cancel_date,101),a.agent_short_code,isNull(p.agent_short_code,ReceiverCountry),paidCType  
 order by Main_Agent,Payout_Agent,DOT,mode desc'  
end  
--print @sql  
exec(@sql)
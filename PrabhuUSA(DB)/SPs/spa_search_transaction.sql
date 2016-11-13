DROP procedure [dbo].[spa_search_transaction]
GO
/****** Object:  StoredProcedure [dbo].[spa_search_transaction]    Script Date: 06/07/2011 22:07:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- spa_search_transaction 'd','10100000','10100500','local_dot','1/19/2009','1/19/2009',NULL,NULL,NULL,NULL,'senderName',NULL,NULL,NULL,NULL,NULL  
--spa_search_transaction 'b','10100000','10100500','ConfirmDate','2007-11-18','2007-11-18',NULL,Null,Null,Null,Null,Null,'Nepal',Null,NULL   
-- spa_search_transaction 'd','10100000','10100500','local_dot','09/01/2007','2007-09-17',NULL,NULL,NULL,NULL,'senderName',NULL,'Nepal',null,'Paid'  
CREATE procedure [dbo].[spa_search_transaction]  
 @report_type varchar(2),  
 @agent_id varchar(50)=null,  
 @branch_id varchar(50)=null,  
 @date_type varchar(50)=null,  
 @from_date varchar(50),  
 @to_date varchar(50),  
 @depositType varchar(50)=null,  
 @search_by varchar(100)=null,  
 @search_text varchar(100)=null,  
 @trans_option char(1)=null,  
 @order_by varchar(250)='m.branch,sendername',  
 @display_multiple char(1)=NULL,  
 @reccountry varchar(50)=null,  
 @recagentid varchar(50)=null,  
 @trn_status varchar(50)=null,  
 @payment_type varchar(50)=null  
  
as  
 if @search_by is not null and @search_text is null  
 set @search_text=''  
  
declare @sqlstmt varchar(5000)  
declare @clm_name varchar(5000)  
set @clm_name='m.tranno,m.refno,m.branch,m.senderCommission,sendername,senderphoneno,receivername,receiverphone,rbankid,rbankname,rbankbranch,  
 local_dot,paiddate,paidamt,totalroundamt,sempid,senderbankvoucherno,transstatus,status,rbankactype,rbankacno,paymenttype,  
 senderCompany,scharge,receiveCType,a.agent_short_code,m.today_dollar_rate,exchangeRate,ho_dollar_rate,paidcType,confirmDate,receiverCountry,
 isNull(m.sPaymentReceivedType,''CASH'') sPaymentReceivedType,m.sCheque_bank,m.sChequeno '  
  
if @report_type='d'   
begin  
 set @sqlstmt='select * from ( select '+ @clm_name   
 
  set @sqlstmt=@sqlstmt+',NULL amtpaid '  
  set @sqlstmt=@sqlstmt+' from moneysend m with (nolock)  join agentdetail a  with (nolock)
on a.agentcode=m.expected_payoutagentid '  
   
  
 set @sqlstmt=@sqlstmt+' where m.transstatus <> ''cancel'' and  m.'+@date_type +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''  
 if @agent_id is not null  
  set @sqlstmt=@sqlstmt+' and m.agentid='+@agent_id   
 if @branch_id is not null  
  set @sqlstmt=@sqlstmt+' and m.branch_code='+@branch_id  
 
 ---------------------------------------------------------
 IF @depositType IS NOT NULL
	set @sqlstmt=@sqlstmt+' and isNull(m.sPaymentReceivedType,''CASH'')='''+@depositType +''''
 ---------------------------------------------------------- 
  
 if @reccountry is not null  
  set @sqlstmt=@sqlstmt+' and m.receiverCountry='''+@reccountry +''''  
 if @recagentid is not null  
  set @sqlstmt=@sqlstmt+' and m.expected_payoutagentid='''+@recagentid +''''  
  
 if @trans_option='h'  
  set @sqlstmt=@sqlstmt+' and m.transstatus=''Hold'''   
 if @trans_option='p'  
  set @sqlstmt=@sqlstmt+' and (  m.send_mode=''p'')'   
 if @trans_option='n'  
  set @sqlstmt=@sqlstmt+' and (m.send_mode=''d'' or m.send_mode is null)'   
 if @search_by is not null  
 begin  
  if @search_by='paidamt'  
    set @sqlstmt=@sqlstmt+' and '+ @search_by +' ='+@search_text   
  else if @search_by='customerid'  
   set @sqlstmt=@sqlstmt+' and '+ @search_by +' = '''+@search_text +''''  
  else  
    set @sqlstmt=@sqlstmt+' and '+ @search_by +' like '''+@search_text +'%'''  
 end  
  
 if @trn_status is not null   
  set @sqlstmt=@sqlstmt+' and m.status='''+@trn_status +''''  
 IF @payment_type IS NOT NULL  
  SET @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''  
 
 set @sqlstmt=@sqlstmt+'  
 union all   
 select '+ @clm_name   
  set @sqlstmt=@sqlstmt+',NULL amtpaid '  
  set @sqlstmt=@sqlstmt+' from moneysend_arch1 m with (nolock) join agentdetail a  with (nolock)
on a.agentcode=m.expected_payoutagentid '  
 
  
 set @sqlstmt=@sqlstmt+' where m.transstatus <> ''cancel'' and  m.'+@date_type +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''  
 if @agent_id is not null  
  set @sqlstmt=@sqlstmt+' and m.agentid='+@agent_id   
 if @branch_id is not null  
  set @sqlstmt=@sqlstmt+' and m.branch_code='+@branch_id   
  
 if @reccountry is not null  
  set @sqlstmt=@sqlstmt+' and m.receiverCountry='''+@reccountry +''''  
 if @recagentid is not null  
  set @sqlstmt=@sqlstmt+' and m.expected_payoutagentid='''+@recagentid +''''  
  
 if @trans_option='h'  
  set @sqlstmt=@sqlstmt+' and m.transstatus=''Hold'''   
 if @trans_option='p'  
  set @sqlstmt=@sqlstmt+' and (  m.send_mode=''p'')'   
 if @trans_option='n'  
  set @sqlstmt=@sqlstmt+' and (m.send_mode=''d'' or m.send_mode is null)'   
 if @search_by is not null  
 begin  
  if @search_by='paidamt'  
    set @sqlstmt=@sqlstmt+' and '+ @search_by +' ='+@search_text   
  else if @search_by='customerid'  
   set @sqlstmt=@sqlstmt+' and '+ @search_by +' = '''+@search_text +''''  
  else  
    set @sqlstmt=@sqlstmt+' and '+ @search_by +' like '''+@search_text +'%'''  
 end  
  
 if @trn_status is not null   
  set @sqlstmt=@sqlstmt+' and m.status='''+@trn_status +''''  
 IF @payment_type IS NOT NULL  
  SET @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''  
 if @depositType is not null  
  set @sqlstmt=@sqlstmt+' and m.sPaymentReceivedType ='''+ @depositType +''''
set @sqlstmt=@sqlstmt+') x  order by agent_short_code, '+@order_by  
 print @sqlstmt  
 exec(@sqlstmt)  
   
end  
--summary deposit report  
if @report_type='b'  
begin  
set @sqlstmt='select * from (  
 select m.branch_code,m.branch,d.bankcode,b.bankname,  
 count(case when d.pending_id is not null then d.amtpaid else NULL end ) as pending,  
 count(case when d.pending_id is  null then d.amtpaid else NULL end ) as normaldeposit,  
 count(distinct d.tranno) transsend,  
 sum(d.amtpaid) amtpaid,sum(d.amtpaid/m.exchangeRate) DollarAmt,  
 Sum((amtPaid/paidAmt) * SCharge ) ServiceCharge,  
 sum(d.amtpaid)-Sum((amtPaid/paidAmt) * SCharge )  PayableAmt,  
 Sum(((amtPaid/paidAmt) * SCharge)/m.exchangeRate ) ServiceChargeUSD,  
 sum(d.amtpaid/m.exchangeRate) -Sum(((amtPaid/paidAmt) * SCharge)/m.exchangeRate ) PayableAmtUSD  
 from moneysend as m with (nolock) join deposit_detail d   with (nolock)
 on m.tranno=d.tranno join bankagentsender b with (nolock)   
 on b.agentcode=d.bankcode  
 where m.transstatus not in(''cancel'') and  m.'+@date_type +'  between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''  
 if @agent_id is not null  
  set @sqlstmt=@sqlstmt+' and m.agentid='+@agent_id   
 if @branch_id is not null  
  set @sqlstmt=@sqlstmt+' and m.branch_code='+@branch_id   
 if @reccountry is not null  
  set @sqlstmt=@sqlstmt+' and m.receiverCountry='''+@reccountry +''''  
 if @recagentid is not null  
  set @sqlstmt=@sqlstmt+' and m.expected_payoutagentid='''+@recagentid +''''  
 if @trn_status is not null  
  set @sqlstmt=@sqlstmt+' and m.status='''+@trn_status +''''  
 IF @payment_type IS NOT NULL  
  SET @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''  
  
 set @sqlstmt=@sqlstmt+'  group by m.branch_code,m.branch,d.bankcode,b.bankname '   
set @sqlstmt=@sqlstmt +' union all  
 select m.branch_code,m.branch,d.bankcode,b.bankname,  
 count(case when d.pending_id is not null then d.amtpaid else NULL end ) as pending,  
 count(case when d.pending_id is  null then d.amtpaid else NULL end ) as normaldeposit,  
 count(distinct d.tranno) transsend,  
 sum(d.amtpaid) amtpaid,sum(d.amtpaid/m.exchangeRate) DollarAmt,  
 Sum((amtPaid/paidAmt) * SCharge ) ServiceCharge,  
 sum(d.amtpaid)-Sum((amtPaid/paidAmt) * SCharge )  PayableAmt,  
 Sum(((amtPaid/paidAmt) * SCharge)/m.exchangeRate ) ServiceChargeUSD,  
 sum(d.amtpaid/m.exchangeRate) -Sum(((amtPaid/paidAmt) * SCharge)/m.exchangeRate ) PayableAmtUSD  
 from moneysend_arch1 as m with (nolock) join deposit_detail_arch1 d  with (nolock)
 on m.tranno=d.tranno join bankagentsender b  with (nolock)  
 on b.agentcode=d.bankcode  
 where m.transstatus not in(''cancel'') and  m.'+@date_type +'  between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''  
 if @agent_id is not null  
  set @sqlstmt=@sqlstmt+' and m.agentid='+@agent_id   
 if @branch_id is not null  
  set @sqlstmt=@sqlstmt+' and m.branch_code='+@branch_id   
 if @reccountry is not null  
  set @sqlstmt=@sqlstmt+' and m.receiverCountry='''+@reccountry +''''  
 if @recagentid is not null  
  set @sqlstmt=@sqlstmt+' and m.expected_payoutagentid='''+@recagentid +''''  
 if @trn_status is not null  
  set @sqlstmt=@sqlstmt+' and m.status='''+@trn_status +''''  
 IF @payment_type IS NOT NULL  
  SET @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''  
  
 set @sqlstmt=@sqlstmt+'  group by m.branch_code,m.branch,d.bankcode,b.bankname) p  
 order by branch  
 '   
  
 print @sqlstmt  
 exec(@sqlstmt)  
end  
if @report_type='dd'  
--detail deposit report  
begin  
set @sqlstmt='select m.refno,m.senderbankvoucherno,d.* from deposit_detail d with (nolock) join moneysend m with (nolock) on m.tranno=d.tranno  
 where m.transstatus not in(''cancel'') and m.'+@date_type +'  between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''  
 if @agent_id is not null  
  set @sqlstmt=@sqlstmt+' and m.agentid='+@agent_id   
 if @branch_id is not null  
  set @sqlstmt=@sqlstmt+' and m.branch_code='+@branch_id   
  
 if @reccountry is not null  
  set @sqlstmt=@sqlstmt+' and m.receiverCountry='''+@reccountry +''''  
 if @recagentid is not null  
  set @sqlstmt=@sqlstmt+' and m.expected_payoutagentid='''+@recagentid +''''  
 if @trn_status is not null  
  set @sqlstmt=@sqlstmt+' and m.status='''+@trn_status +''''  
  
  if @depositType is not null  
  set @sqlstmt=@sqlstmt+' and m.sPaymentReceivedType ='''+ @depositType +''''  
  
  set @sqlstmt=@sqlstmt+'  order  by m.tranno asc'  
 print @sqlstmt  
 exec(@sqlstmt)  
end
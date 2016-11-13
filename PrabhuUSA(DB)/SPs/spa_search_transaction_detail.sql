IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_search_transaction_detail]') AND TYPE in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_search_transaction_detail]
GO
/****** Object:  StoredProcedure [dbo].[spa_search_transaction_detail]    Modification Date: 09/18/2014 11:02:12 ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[spa_search_transaction_detail]    Modification Date: 09/18/2014 11:02:12 ******/
/*
** Database :		PrabhuUSA
** Object :			spa_search_transaction_detail
** Purpose :		Search By Amount Summary
** Modified by:		Sudaman Shrestha
** Modified Date:	09/18/2014
** Modification:	added with(nolock) everywhere need and 
					added @lessthan100 varchar(10) = NULL
					added if @lessthan100 = 'yes' set @sqlstmt = @sqlstmt +' and m.totalroundamt/m.payout_settle_usd < 100' 
					
** Execute Examples :[spa_search_transaction_detail] 'd','10100000',NULL,'local_dot','03/06/2008','03/06/2008',NULL,NULL,NULL,NULL,'senderName',NULL,'Nepal',null,'Paid' 	

*/   
   
CREATE procedure [dbo].[spa_search_transaction_detail]    
 @report_type varchar(2),    
 @agent_id varchar(50)=null,    
 @branch_id varchar(50)=null,    
 @date_type varchar(50)=null,    
 @from_date varchar(50),    
 @to_date varchar(50),    
 @deposit_id varchar(50)=null,    
 @search_by varchar(100)=null,    
 @search_text varchar(100)=null,    
 @trans_option char(1)=null,    
 @order_by varchar(250)=NULL,    
 @display_multiple char(1)=NULL,    
 @reccountry varchar(50)=null,    
 @recagentid varchar(50)=null,    
 @trn_status varchar(50)=null,    
 @rBankId varchar(50)=null,    
 @payment_type varchar(50)=null,    
 @receiveAgentID VARCHAR(50)=NULL, ----dISTIRCT CODE OR bANKid    
 @sendCountry varchar(50)= NULL,
 ---------lines added by Sudaman---------------
 @lessthan100 varchar(10) = NULL
 ---------lines added by Sudaman---------------
   
as    
 if @search_by is not null and @search_text is null    
 set @search_text=''    
 IF @order_by IS NULL    
 SET @order_by= 'receivername'    
declare @sqlstmt varchar(5000)    
declare @clm_name varchar(5000)    
set @clm_name='m.tranno,m.refno,m.branch,sendername,senderphoneno,receivername,receiverphone,rbankid,a.companyname rbankname,rbankbranch,    
 local_dot,paiddate,paidamt,totalroundamt,sempid,senderbankvoucherno,transstatus,status,rbankactype,rbankacno,paymenttype,    
 senderCompany,scharge,receiveCType,a.agent_short_code,m.today_dollar_rate,exchangeRate,    
paidby,request_for_new_account,PaidcType,expected_payoutagentid receiveAgentID,receiverCommission  '    
if @report_type='d'     
begin    
 set @sqlstmt='Select * from ( select '+ @clm_name     
 if @deposit_id is not null    
 begin    
  set @sqlstmt=@sqlstmt+',sum(d.amtpaid) amtpaid '    
  set @sqlstmt=@sqlstmt+' from moneysend as m  with(nolock) left outer  join deposit_detail d with(nolock)   
  on m.tranno=d.tranno  join agentdetail a with(nolock)   
on a.agentcode=m.expected_payoutagentid  '    
 end    
 else    
 begin    
  set @sqlstmt=@sqlstmt+',NULL amtpaid '    
  set @sqlstmt=@sqlstmt+' from moneysend m with(nolock) join agentdetail a with(nolock)   
on a.agentcode=m.expected_payoutagentid '    
 end    
    
 set @sqlstmt=@sqlstmt+' where m.transstatus <> ''cancel'' and  m.'+@date_type +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
if @sendCountry is not null    
 set @sqlstmt=@sqlstmt +' and m.senderCountry='''+@sendCountry+''''
 
 ---------lines added by Sudaman---------------
if @lessthan100 = 'yes'
set @sqlstmt = @sqlstmt +' and m.totalroundamt/m.payout_settle_usd < 100'  
 ---------lines added by Sudaman---------------
  
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
  set @sqlstmt=@sqlstmt+' and ( m.send_mode=''p'')'     
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
    
 if @rBankId is not null     
  set @sqlstmt=@sqlstmt+' and m.rBankId='''+@rBankId +''''    
 if @payment_type is not null     
  set @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''    
    
 if @receiveAgentID is not null     
  set @sqlstmt=@sqlstmt+' and m.receiveAgentID='''+@receiveAgentID +''''    
 if @deposit_id is not null    
  set @sqlstmt=@sqlstmt+' and d.bankcode ='+@deposit_id     
 if @deposit_id is not null    
 begin    
  set @sqlstmt=@sqlstmt+' group by '+@clm_name    
  if @display_multiple='y'    
   set @sqlstmt=@sqlstmt+'  having count(m.tranno)>1 '     
 end    
 set @sqlstmt=@sqlstmt+' union all '     
    
-------###############Arch1     
set @sqlstmt=@sqlstmt+ 'select '+ @clm_name     
 if @deposit_id is not null    
 begin    
  set @sqlstmt=@sqlstmt+',sum(d.amtpaid) amtpaid '    
  set @sqlstmt=@sqlstmt+' from moneysend_arch1 as m with(nolock) left outer  join deposit_detail_arch1 d with(nolock)   
  on m.tranno=d.tranno  join agentdetail a with(nolock)    
on a.agentcode=m.expected_payoutagentid  '    
 end    
 else    
 begin    
  set @sqlstmt=@sqlstmt+',NULL amtpaid '    
  set @sqlstmt=@sqlstmt+' from moneysend_arch1  m with(nolock)  join agentdetail a with(nolock)    
on a.agentcode=m.expected_payoutagentid '    
 end    
    
 set @sqlstmt=@sqlstmt+' where m.transstatus <> ''cancel'' and  m.'+@date_type +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
if @sendCountry is not null    
 set @sqlstmt=@sqlstmt +' and m.senderCountry='''+@sendCountry+''''   
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
  set @sqlstmt=@sqlstmt+' and ( m.send_mode=''p'')'     
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
 if @rBankId is not null     
  set @sqlstmt=@sqlstmt+' and m.rBankId='''+@rBankId +''''    
 if @payment_type is not null     
  set @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''    
if @receiveAgentID is not null     
  set @sqlstmt=@sqlstmt+' and m.receiveAgentID='''+@receiveAgentID +''''    
 if @deposit_id is not null    
  set @sqlstmt=@sqlstmt+' and d.bankcode ='+@deposit_id     
 if @deposit_id is not null    
 begin    
  set @sqlstmt=@sqlstmt+' group by '+@clm_name    
  if @display_multiple='y'    
   set @sqlstmt=@sqlstmt+'  having count(m.tranno)>1 '     
 end    
set @sqlstmt=@sqlstmt+' ) l '    
 set @sqlstmt=@sqlstmt+'  order by receiveAgentID,rBankId, '+@order_by    
    
PRINT @sqlstmt    
    
 exec(@sqlstmt)    
     
end    
--summary deposit report    
if @report_type='b'    
begin    
set @sqlstmt='    
 select m.branch_code,m.branch,d.bankcode,b.bankname,m.branch_code,m.branch,    
 count(case when d.pending_id is not null then d.amtpaid else NULL end ) as pending,    
 count(case when d.pending_id is  null then d.amtpaid else NULL end ) as normaldeposit,    
 count(distinct d.tranno) transsend,    
 sum(d.amtpaid) amtpaid,sum(d.amtpaid/m.exchangeRate) DollarAmt,    
 Sum((amtPaid/paidAmt) * SCharge ) ServiceCharge,    
 sum(d.amtpaid)-Sum((amtPaid/paidAmt) * SCharge )  PayableAmt,    
 Sum(((amtPaid/paidAmt) * SCharge)/m.exchangeRate ) ServiceChargeUSD,    
 sum(d.amtpaid/m.exchangeRate) -Sum(((amtPaid/paidAmt) * SCharge)/m.exchangeRate ) PayableAmtUSD    
 from moneysend as m with(nolock) join deposit_detail d with(nolock)    
 on m.tranno=d.tranno join bankagentsender b with(nolock)     
 on b.agentcode=d.bankcode    
 where m.transstatus not in(''cancel'') and  m.'+@date_type +'  between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
if @sendCountry is not null    
 set @sqlstmt=@sqlstmt +' and m.senderCountry='''+@sendCountry+''''   
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
    
  set @sqlstmt=@sqlstmt+'  group by m.branch_code,m.branch,d.bankcode,b.bankname order by branch'     
 --print @sqlstmt    
 exec(@sqlstmt)    
end    
if @report_type='dd'    
--detail deposit report    
begin    
set @sqlstmt='select m.refno,m.senderbankvoucherno,d.* from deposit_detail d with(nolock) join moneysend m with(nolock) on m.tranno=d.tranno    
 where m.transstatus not in(''cancel'') and m.'+@date_type +'  between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
if @sendCountry is not null    
 set @sqlstmt=@sqlstmt +' and m.senderCountry='''+@sendCountry+''''   
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
    
 if @deposit_id is not null    
  set @sqlstmt=@sqlstmt+' and d.bankcode='+@deposit_id     
    
  set @sqlstmt=@sqlstmt+'  order  by m.tranno asc'    
 --print @sqlstmt    
 exec(@sqlstmt)    
end    
if @report_type='s'    
begin    
set @sqlstmt='select * from (    
select rBankID,a.CompanyName,isNull(b.branch,''Any Where'') as branch,sum(totalRoundAmt)as totalRoundAmt,    
count(tranno)as totTran from moneysend m with(nolock) left outer join agentbranchdetail b with(nolock)     
on m.rBankId=b.agent_branch_code left outer join agentDetail a with(nolock) on a.agentcode=b.agentcode '    
    
 set @sqlstmt=@sqlstmt+' where m.transstatus <> ''cancel'' and  m.'+@date_type +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
if @sendCountry is not null    
 set @sqlstmt=@sqlstmt +' and m.senderCountry='''+@sendCountry+''''   
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
  set @sqlstmt=@sqlstmt+' and ( m.send_mode=''p'')'     
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
 if @rBankId is not null     
  set @sqlstmt=@sqlstmt+' and m.rBankId='''+@rBankId +''''    
 if @payment_type is not null     
  set @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''    
if @receiveAgentID is not null     
  set @sqlstmt=@sqlstmt+' and m.receiveAgentID='''+@receiveAgentID +''''    
    
set @sqlstmt=@sqlstmt+'    
group by rBankID,a.CompanyName,isNull(b.branch,''Any Where'') '    
    
set @sqlstmt=@sqlstmt+ ' union all     
select rBankID,a.CompanyName,isNull(b.branch,''Any Where'') as branch,sum(totalRoundAmt)as totalRoundAmt,    
count(tranno)as totTran from moneysend_arch1 m with(nolock) left outer join agentbranchdetail b with(nolock)     
on m.rBankId=b.agent_branch_code left outer join agentDetail a with(nolock) on a.agentcode=b.agentcode '    
    
 set @sqlstmt=@sqlstmt+' where m.transstatus <> ''cancel'' and  m.'+@date_type +' between '''+ @from_date +''' and '''+ @to_date +' 23:59:59'''    
if @sendCountry is not null    
 set @sqlstmt=@sqlstmt +' and m.senderCountry='''+@sendCountry+''''   
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
  set @sqlstmt=@sqlstmt+' and ( m.send_mode=''p'')'     
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
 if @rBankId is not null     
  set @sqlstmt=@sqlstmt+' and m.rBankId='''+@rBankId +''''    
 if @payment_type is not null     
  set @sqlstmt=@sqlstmt+' and m.paymentType='''+@payment_type +''''    
if @receiveAgentID is not null     
  set @sqlstmt=@sqlstmt+' and m.receiveAgentID='''+@receiveAgentID +''''    
    
set @sqlstmt=@sqlstmt+'    
group by rBankID,a.CompanyName,isNull(b.branch,''Any Where'') )l     
order by companyname,branch '    
exec(@sqlstmt)    
end    
    
    
  
  
  
  
  
  
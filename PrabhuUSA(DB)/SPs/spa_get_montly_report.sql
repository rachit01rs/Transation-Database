drop PROCEDURE [dbo].[spa_get_montly_report]
go
--spa_get_montly_report NUL,NULL,'6','2012','confirmDate','d',NULL,'19ED68766_EA71_43C2_B3AC_EDB0EC155AE1','admin','monthly_rept',NULL,'United States','AL'  
--spa_get_montly_report NULL,NULL,NULL,'2009','confirmDate','d','Bangladesh','BCACAD51_1130_41BF_99F7_520F5A1CB801','admin','monthly_rept'    
create PROCEDURE [dbo].[spa_get_montly_report]    
@flag char(1)=Null,    
@agent_id varchar(50)=NULL,    
@sel_month int=NULL,    
@sel_year int=NULL,    
@date_type varchar(200)=NULL,    
@curr_type char(1)='l',    
@payout_country varchar(50)=null,    
@process_id varchar(200)=NULL,    
@login_user_id varchar(100),    
@batch_Id varchar(100),    
@payoutagent varchar(50)=NULL ,  
@sendercountry VARCHAR(50)=NULL,  
@sender_state VARCHAR(50)=NULL    
    
as    
      
    
DECLARE @temptablename varchar(200),@sql_table varchar(500)    
  set @temptablename=dbo.FNAProcessTBl(@batch_Id, @login_user_id, @process_id)    
--exec ('drop table '+@temptablename+'')    
    
    
  set @sql_table='create table '+@temptablename+'(    
  month_id int,    
  month_name varchar(50),    
  noOftrans int,    
  Total_Transfer money,    
  Paid money,    
  unpaid money,    
  commission  Money,    
  receiverCountry varchar(50),    
  ho_commission money,    
  Total_payout_curr money,    
  Paid_payout_curr money,    
  unpaid_payout_curr money,    
  noOf_blockTrans int,    
  payoutagent varchar(50),    
  payoutagentName varchar(100)    
  )'    
print (@sql_table)    
exec(@sql_table)    
--set @date_type='case when transStatus=''Cancel'' then cancel_date else confirmDate end'    
declare @sql varchar(5000),@calc_curr varchar(50),@s_comm as varchar(100),@from_date varchar(20),@to_date varchar(50),@sel_Label varchar(100)    
declare @ho_comm varchar(100)    
IF @sel_month IS NULL    
BEGIN    
 SET @from_date=cast(@sel_year AS varchar)+'-01-01'    
 SET @to_date=cast(@sel_year AS varchar)+'-12-31'    
 SET @sel_Label=cast(@sel_year AS varchar)    
end    
else     
begin    
set @from_date=cast(@sel_year AS varchar)+'-'+cast(@sel_month AS Varchar)+'-01'    
set @to_date=cast(@sel_year AS varchar)  +'-'+cast(@sel_month AS Varchar)+'-'+cast(dbo.FNALastDayInMonth(@from_date) as varchar)    
END     
if @curr_type='l'    
begin    
 set @calc_curr='paidAmt'    
 set @s_comm='senderCommission + isNull(agent_ex_gain,0)'    
 set @ho_comm='sCharge - senderCommission'    
end    
else    
begin    
 set @calc_curr='dollar_amt'    
 set @s_comm='(senderCommission + isNull(agent_ex_gain,0))/exchangerate'    
 set @ho_comm='(sCharge - senderCommission)/exchangerate'    
end    
set @sql='    
 insert '+ @temptablename +'(month_id,month_name,receiverCountry,    
 noOftrans,Total_Transfer,Paid,unpaid,commission,     
 ho_commission, Total_payout_curr, Paid_payout_curr,     
 unpaid_payout_curr, noOf_blockTrans'    
--if @payoutagent is not null    
set @sql=@sql+',payoutagent,payoutagentName'    
 set @sql=@sql+')    
 select t.month_id,t.month_name, m.receiverCountry,    
 sum(case when transStatus=''Payment'' then m.noOftrans else 0 end),    
 sum(Total_Transfer), sum(m.paid), sum(m.unpaid), sum(m.commission),    
 sum(m.ho_commission), sum(m.Total_payout_curr),     
 sum(m.Paid_payout_curr), sum(m.unpaid_payout_curr),    
 sum(case when transStatus=''Block'' then m.noOftrans else 0 end)'    
--if @payoutagent is not null    
set @sql=@sql+',m.expected_payoutagentid,m.companyName '    
set @sql=@sql+'    
 from(    
 SELECT month(confirmDate)as [month_id], year(confirmDate) as [Year],    
 receiverCountry, transStatus, count(*) as noOfTrans,     
    cast(sum('+@calc_curr +')as decimal(19,2)) as ''Total_Transfer'',    
 SUM(CASE status WHEN ''Paid'' THEN cast('+@calc_curr+' as decimal(19,2)) ELSE 0 END) AS ''Paid'',    
 SUM(CASE status WHEN ''Un-Paid'' THEN cast('+@calc_curr+' as decimal(19,2)) ELSE 0 END) AS ''UnPaid'',    
 cast(sum('+@s_comm+') as decimal(19,2)) as ''commission'',    
cast(sum('+@ho_comm+') as decimal(19,2)) as ''ho_commission'',    
SUM(totalroundAmt) AS ''total_payout_curr'',    
SUM(CASE status WHEN ''Paid'' THEN totalroundAmt ELSE 0 END) AS ''Paid_payout_curr'',    
SUM(CASE status WHEN ''Un-Paid'' THEN totalroundAmt ELSE 0 END) AS ''UnPaid_payout_curr'''    
--if @payoutagent is not null    
set @sql=@sql+',m.expected_payoutagentid,r.companyName '    
set @sql=@sql+' FROM moneysend m with (nolock) '    
--if @payoutagent is not null    
set @sql=@sql+' join agentdetail r with (nolock) on m.expected_payoutagentid=r.agentcode '   
set @sql=@sql+' join agentdetail s with (nolock) on m.agentid=s.agentcode '     
set @sql=@sql+' RIGHT OUTER join tbl_month t on t.month_id = month(confirmDate) '     
if @flag='y'    
 set @sql=@sql+'where transStatus in (''Payment'',''Block'') and      
 confirmDate BETWEEN '''+@from_date+''' AND '''+@to_date+' 23:59:59'''    
else    
 set @sql=@sql+' where transStatus=''Payment'' and      
 confirmdate BETWEEN '''+@from_date+''' AND '''+@to_date+' 23:59:59'''    
    
 if @agent_id is not null    
  set @sql=@sql + ' and agentid='+@agent_id    
 if @sendercountry IS NOT NULL        
  SET @sql= @sql+' and  m.sendercountry='''+ @sendercountry +''''  
 if @sender_state IS NOT NULL      
  SET @sql= @sql+' and s.state='''+ @sender_state +''''    
 if @payout_country is not null    
  set @sql=@sql + 'and receivercountry='''+@payout_country+''''  
 if @payout_country is not null    
  set @sql=@sql + 'and receivercountry='''+@payout_country+''''    
 if @payoutagent is not null    
 set @sql=@sql + 'and expected_payoutagentid='''+@payoutagent+''''    
    
 set @sql=@sql + ' GROUP BY month(confirmDate), year(confirmDate),    
 receiverCountry, transStatus '    
--if @payoutagent is not null    
set @sql=@sql+',m.expected_payoutagentid,r.companyName '    
set @sql=@sql+' ) m RIGHT OUTER join tbl_month t on t.month_id =m.month_id    
 where (year is null or year='+ cast(@sel_year as varchar)   +')'    
 if @sel_month is not null    
  set @sql=@sql + ' and t.month_id='+cast(@sel_month as varchar)      
 set @sql=@sql + ' group by t.month_id, t.month_name, m.receiverCountry'    
--if @payoutagent is not null    
set @sql=@sql+',m.expected_payoutagentid,m.companyName '    
set @sql=@sql+' order by t.month_id'    
--if @payoutagent is not null    
set @sql=@sql+',m.receiverCountry,m.companyName '    
print @sql    
--return    
exec(@sql)    
    
declare @msg_agenttype varchar(100),@url_desc varchar(200),    
@sender_agentname varchar(150),@payout_agentname varchar(150),@desc varchar(1000)    
    
set @msg_agenttype=''    
IF @agent_id IS NOT null    
BEGIN    
 SELECT @sender_agentname=companyName FROM agentdetail  WHERE agentcode=@agent_id    
 SET @msg_agenttype=' <b>Summary</b> Send Agent:'+ @sender_agentname    
END     
else    
BEGIN    
 SET @msg_agenttype=' <b>Summary</b> Send Agent:ALL'     
end    
IF @sendercountry  IS NOT NULL    
 SET @msg_agenttype=@msg_agenttype+ '/ sender Country: ' + @sendercountry    
IF @sender_state  IS NOT NULL    
 SELECT  @msg_agenttype=@msg_agenttype+ '/ sender state: ' + static_value FROM dbo.static_values WHERE sno=100 AND static_data= @sender_state  
IF @payout_country  IS NOT NULL    
 SET @msg_agenttype=@msg_agenttype+ '/ payout Country: ' + @payout_country    
    
     
set @url_desc='year='+cast(@sel_year  AS varchar)+'&month='+isNUll(cast(@sel_month AS varchar),'ALL')    
set @url_desc=@url_desc+'&msg='+@msg_agenttype+'&senderAgent='+isNull(@agent_id,'')+'&flag='+@flag    
    
 set @desc =upper(@batch_id)+' '+ @msg_agenttype +' is completed for Year:' + cast(@sel_year  AS varchar)     
 if @sel_month is not null    
 begin    
 set @desc=@desc+ ' Month:'+cast(@sel_month AS varchar)    
  end     
 if @flag='y'    
  set @desc=@desc+ ' <b>[<i>With Blocked TRNs</i>]</b>'    
    
 EXEC  spa_message_board 'u', @login_user_id,    
    NULL, @batch_id,    
    @desc, 'c', @process_id,null,@url_desc    
    
--exec ('select * from '+@temptablename)
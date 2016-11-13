DROP  PROCEDURE [dbo].[spa_get_montly_report_new]    
GO 
CREATE  PROCEDURE [dbo].[spa_get_montly_report_new]    
@agent_id varchar(50)=NULL,    
@sel_month int=NULL,    
@sel_year int=NULL,    
@date_type varchar(200)=NULL,    
@curr_type char(1)='l',    
@payout_country varchar(50)=null,    
@process_id varchar(200)=NULL,    
@login_user_id varchar(100),    
@batch_Id varchar(100),    
@SenderCountry varchar(100)=NUll,    
@pay_agent varchar(50)=NULL,  
@sender_state VARCHAR(50)=NULL     
as    
create table #TempResult(    
sno int identity(1,1)    
)    
create table #temp_source(    
month_id varchar(20),    
month_name varchar(50),    
agent_name varchar(100),    
tot_txn int    
)    
Declare @sql_txt varchar(8000)    
DECLARE @temptablename varchar(200)    
  set @temptablename=dbo.FNAProcessTBl(@batch_Id, @login_user_id, @process_id)    
    
--set @date_type='case when transStatus=''Cancel'' then cancel_date else confirmDate end'    
declare @sql varchar(5000),@calc_curr varchar(50),@s_comm as varchar(100),@from_date varchar(20),@to_date varchar(50),@sel_Label varchar(100)    
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
 set @s_comm='senderCommission'    
end    
else    
begin    
 set @calc_curr='dollar_amt'    
 set @s_comm='senderCommission/exchangerate'    
end    
set @sql_txt='    
 insert #temp_source(month_id,month_name,agent_name,tot_txn)    
 select t.month_id,t.month_name,agent_name,m.noOftrans from(    
 SELECT month(confirmDate)as [month_id], year(confirmDate) as [Year],agentid as agent_name,count(*) as noOfTrans    
 FROM moneysend m with (nolock)  
 RIGHT OUTER join tbl_month t with (nolock) on t.month_id = month(confirmDate)   
 join agentdetail a with (nolock) on a.agentcode=m.agentid'     
-- where transStatus=''Payment'' and  confirmdate BETWEEN '''+@from_date+''' AND '''+@to_date+' 23:59:59'''    
set @sql_txt=@sql_txt+' where transStatus in (''Payment'',''Block'') and      
 confirmDate BETWEEN '''+@from_date+''' AND '''+@to_date+' 23:59:59'' and a.agentType  in(''Sender Agent'',''Send and Pay'')'    
    
 IF @SenderCountry IS NOT NULL    
 SET @sql_txt=@sql_txt+ ' and SenderCountry='''+ @SenderCountry +''''   
 if @sender_state IS NOT NULL      
 SET @sql_txt= @sql_txt+' and a.state='''+ @sender_state +''''   
 if @agent_id is not null    
 set @sql_txt=@sql_txt + ' and agentid='+@agent_id    
 else    
    SET @sql_txt=@sql_txt+ ' and agentid not in(''97100059'')'    -- To exclude Almoudi Exchange since it send curreny is NPR    
 if @payout_country is not null    
  set @sql_txt=@sql_txt + 'and receivercountry='''+@payout_country+''''    
 if @pay_agent is not null    
  set @sql_txt=@sql_txt + 'and expected_payoutagentid='''+@pay_agent+''''    
     
set @sql_txt=@sql_txt + ' GROUP BY month(confirmDate),year(confirmDate),agentid ) m RIGHT OUTER join tbl_month t on t.month_id =m.month_id    
 where (year is null or year='+ cast(@sel_year as varchar)   +')'    
 if @sel_month is not null    
  set @sql_txt=@sql_txt + ' and t.month_id='+cast(@sel_month as varchar)      
    
print @sql_txt    
exec(@sql_txt)    
if exists (select top 1 agent_name from #temp_source)    
begin    
--set @sql_txt='sys_CrossTab ''#temp_source'',''month_id'',''month_name'',''month_name'',''agent_name'',''tot_txn'',    
-- ''#TempResult'',''sum'',0,NULL,0,''Total'',''''''Grand Total'''''',''agent_name'',''money'''    
set @sql_txt='sys_CrossTab ''#temp_source'',''month_name'',''month_name'',''2010-+''''''''+cast(month_id as varchar)+''''''''-1'',    
''tot_txn'',''agent_name'',''#TempResult'',''sum'',0,NULL,0,''Total'',null,''agent_name'',''money'''    
    
 print @sql_txt    
 exec(@sql_txt)    
alter table #TempResult    
 drop column sno    
    
--select * from #TempResult    
exec('select t.*,companyname,country into '+@temptablename+' from #TempResult t join agentdetail a on t.agent_name=a.agentcode order by country,companyname')    
    
end    
else    
begin    
 select 'Warring' Sno, 'No Transaction Found for the givien filter' Message    
end    
    
declare @msg_agenttype varchar(100),@url_desc varchar(500),    
@sender_agentname varchar(150),@payout_agentname varchar(150),@desc varchar(1000)    
    
set @msg_agenttype=''    
    
if @SenderCountry is not Null    
begin    
SET @msg_agenttype=' <b>Summary</b> Send Country: '+ @SenderCountry    
end    
else     
begin    
SET @msg_agenttype=' <b>Summary</b> Send Country: ALL'    
end    
IF @sender_state  IS NOT NULL    
 SELECT  @msg_agenttype=@msg_agenttype+ '/ sender state: ' + isNull(static_value,'') FROM dbo.static_values   
 WHERE sno=100 AND static_data= @sender_state       
IF @agent_id IS NOT null     
BEGIN    
 SELECT @sender_agentname=companyName FROM agentdetail  WHERE agentcode=@agent_id    
 SET @msg_agenttype=@msg_agenttype+'/ Send Agent: '+ @sender_agentname    
END     
else    
BEGIN    
 SET @msg_agenttype=@msg_agenttype+'/ Send Agent: ALL'     
end    
    
IF @payout_country  IS NOT NULL     
begin    
 SET @msg_agenttype=@msg_agenttype+ ' /Destination Country: ' + @payout_country    
end    
else     
begin    
 SET @msg_agenttype=@msg_agenttype+ '/ Destination Country: ALL'    
end    
    
IF @pay_agent IS NOT null    
BEGIN    
 SELECT @payout_agentname=companyName FROM agentdetail  WHERE agentcode=@pay_agent    
 SET @msg_agenttype=@msg_agenttype+'/ Payout Agent:'+ @payout_agentname    
END     
else    
BEGIN    
 SET @msg_agenttype=@msg_agenttype+'/ Payout Agent: ALL'     
end    
    
    
set @url_desc='year='+cast(@sel_year  AS varchar)    
set @url_desc=@url_desc+'&msg='+@msg_agenttype+'&senderAgent='+isNull(@sender_agentname,'')+'&senderCountry='+    
 isNull(@SenderCountry,'')+'&receiveAgent='+isNull(@payout_agentname,'')+'&receiveCountry='+isNull(@payout_country,'')    
 set @desc =upper(@batch_id)+' '+ @msg_agenttype +' is completed for the year:' + cast(@sel_year  AS varchar)     
 if @sel_month is not null    
 begin    
 set @desc=@desc+ ' Month:'+cast(@sel_month AS varchar)    
  end     
 EXEC  spa_message_board 'u', @login_user_id,    
    NULL, @batch_id,    
    @desc, 'c', @process_id,null,@url_desc 
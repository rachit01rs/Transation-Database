drop proc [dbo].[spa_get_agent_summary_report]
go
  
  
--spa_get_agent_summary_report '10100000','2008-04-09','2008-04-09','Nepal'      
create proc [dbo].[spa_get_agent_summary_report]      
@agent_code varchar(50)=NULL,      
@from_date varchar(20),      
@to_date varchar(20),      
@receiver_country varchar(150)=NULL,    
@sendCountry varchar(50)= NULL  ,  
@status varchar(50)=NULL ,
@agent_state VARCHAR(100)=NULL 
      
as      
      
CREATE TABLE #temp_summary(      
 [agentName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,      
 [branch] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,      
 [paidCtype] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,      
 [paidAmt] [money] NULL,      
 [Sender_Charge] [money] NULL,      
 [HO_Charge] [money] NULL,      
 [DollarRate] [money] NULL,      
 [ExRate] [money] NULL,      
 [dollar_amt] [money] NULL,      
 [NPR_Amt] [money] NULL,      
 [TotNos] [int] NULL,      
 [SCommDollar] [money] NULL,      
 [HOCommDollar] [money] NULL      
) ON [PRIMARY]      
      
      
declare @sql varchar(5000)      
set @sql='      
INSERT INTO #temp_summary      
           ([agentName]      
           ,[branch]      
           ,[paidCtype]      
           ,[paidAmt]      
           ,[Sender_Charge]      
           ,[HO_Charge]      
           ,[dollar_amt]      
   ,[DollarRate]      
   ,[ExRate]      
           ,[NPR_Amt]      
           ,[TotNos]      
           ,[SCommDollar]      
           ,[HOCommDollar])      
          
Select CASE WHEN (GROUPING(agentName) = 1) THEN '''' ELSE ISNULL(agentName, ''UNKNOWN'') END AS agentName,       
CASE WHEN (GROUPING(branch) = 1) THEN ''Total'' ELSE ISNULL(branch, ''UNKNOWN'') END AS branch,      
min(paidCtype) paidCtype, SUM(g.paidAmt) AS paidAmt,sum(Sender_Charge) Sender_Charge ,       
sum(HO_Charge) HO_Charge,sum(dollar_amt) dollar_amt,      
avg(DollarRate) DollarRate,avg(ExRate) ExRate,      
sum(NPR_Amt) NPR_Amt,sum(TotNos) TotNos,       
sum(SCommDollar) SCommDollar,       
sum(HOCommDollar) HOCommDollar      
from (      
SELECT m.agentName AS agentName,       
m.branch AS branch,      
min(m.paidCtype) paidCtype, SUM(m.paidAmt) AS paidAmt,sum(m.senderCommission) Sender_Charge ,       
sum(m.sCharge-m.senderCommission) HO_Charge,sum(m.dollar_amt) dollar_amt,      
avg(m.today_dollar_rate) DollarRate,avg(m.exchangeRate) ExRate,       
sum(m.TotalRoundAmt) NPR_Amt,count(*) TotNos,       
sum(m.senderCommission/m.exchangeRate) SCommDollar,       
sum((m.sCharge-m.senderCommission)/m.exchangeRate) HOCommDollar,      
branch_code      
FROM (      
select a.companyname agentName,branch_code,paidCtype,paidAmt,senderCommission,sCharge,dollar_amt,today_dollar_rate,      
exchangeRate,TotalRoundAmt,b.branch branch      
FROM moneysend m join agentdetail a on a.agentcode=m.agentid     
left outer join agentbranchdetail b on m.branch_code=b.agent_branch_code   
where confirmDate between '''+ @from_date +''' and '''+ @to_date+' 23:59:59''      
and Transstatus in(''Payment'',''Block'',''Cancel'')'      
if @agent_code is not null      
 set @sql=@sql +' and agentid='''+@agent_code+''''      
if @receiver_country is not null      
 set @sql=@sql +' and receiverCountry='''+@receiver_country+''''     
if @sendCountry is not null      
 set @sql=@sql +' and senderCountry='''+@sendCountry+''''  
if @agent_state is not null      
 set @sql=@sql +' and a.state='''+@agent_state+''''    
if @status is not null  
 set @sql=@sql+ ' and status='''+@status+''''  
      
if exists(select top 1 table_name from close_transaction where close_date >= @from_date)      
 begin      
 set @sql=@sql +' union all       
 select a.companyname agentName,branch_code,paidCtype,paidAmt,senderCommission,sCharge,dollar_amt,today_dollar_rate,      
exchangeRate,TotalRoundAmt,b.branch branch       
 from moneysend_arch1 m join agentdetail a on a.a gentcode=m.agentid     
left outer join agentbranchdetail b on m.branch_code=b.agent_branch_code where confirmDate between '''+@from_date +''' and '''+ @to_date +' 23:59:59''      
 and Transstatus in(''Payment'',''Block'',''Cancel'')'      
 if @agent_code is not null      
  set @sql=@sql +' and agentid='''+@agent_code+''''      
 if @receiver_country is not null      
  set @sql=@sql +' and receiverCountry='''+@receiver_country+''''     
if @agent_state is not null      
 set @sql=@sql +' and a.state='''+@agent_state+''''      
  if @status is not null  
 set @sql=@sql+ ' and status='''+@status+''''  
 end      
      
      
set @sql=@sql +' ) m       
GROUP BY m.agentName, m.branch_code,m.branch       
) g       
GROUP BY agentName, branch       
WITH ROLLUP'      
exec(@sql)      
      
set @sql='      
select agentName,branch,paidCtype,paidAmt,Sender_Charge,HO_Charge,dollar_amt,NPR_amt,TotNos,       
SCommDollar,[DollarRate],[ExRate],HOCommDollar from #temp_summary      
union all      
select       
m.agentName AS agentName,       
''Cancel'' AS branch,      
min(m.paidCtype) paidCtype, SUM(m.paidAmt) AS paidAmt,sum(m.senderCommission) Sender_Charge ,       
sum(m.sCharge-m.senderCommission) HO_Charge,sum(m.dollar_amt) dollar_amt,      
sum(m.TotalRoundAmt) NPR_Amt,count(*) TotNos,       
sum(m.senderCommission/m.exchangeRate) SCommDollar,       
avg(m.today_dollar_rate) DollarRate,avg(m.exchangeRate) ExRate,       
sum((m.sCharge-m.senderCommission)/m.exchangeRate) HOCommDollar      
 from cancelMoneySend m join agentdetail a      
on m.expected_payoutagentid=a.agentcode      
 where transStatus=''Payment'' and delDate between '''+ @from_date +''' and '''+ @to_date+' 23:59:59'''      
if @agent_code is not null      
 set @sql=@sql +' and agentid='''+@agent_code+''''      
if @receiver_country is not null      
 set @sql=@sql +' and a.country='''+@receiver_country+''''      
if @sendCountry is not null      
 set @sql=@sql +' and senderCountry='''+@sendCountry+''''
if @agent_state is not null      
 set @sql=@sql +' and a.state='''+@agent_state+''''           
if @status is not null  
 set @sql=@sql+ ' and status='''+@status+''''  
 set @sql=@sql +'      
GROUP BY agentName '      
exec(@sql)
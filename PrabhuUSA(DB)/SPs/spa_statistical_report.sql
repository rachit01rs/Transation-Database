drop proc [dbo].[spa_Statistical_Report] 
go 
--spa_Statistical_Report NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'txn_send_wise',NULL,'7/20/2011','7/19/2012',NULL              
--spa_Statistical_Report NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,'txn_send_wise' ,null,'2001-01-01','2012-03-01'              
--spa_Statistical_Report 'United States','20100313',NULL,NULL,NULL,NULL,NULL,NULL,'txn_send_wise',NULL,'10/01/2013','12/31/2013','NY'
CREATE proc [dbo].[spa_Statistical_Report]              
-- @flag char(1),              
 @orgCountry varchar(50)=NULL,              
 @orgAgent varchar(50)=NULL,              
 @orgBranch varchar(50)=NULL,              
 @year varchar(20)=NULL,              
 @month varchar(50)=NULL,              
 @show_country_wise char(1)=NULL,              
 @show_agent_wise char(1)=NULL,              
 @show_branch_wise char(1)=NULL,              
 @group_wise varchar(50)=NULL,              
 @exclude_agentid varchar(50)=NULL,              
 @fromDate varchar(50)=NULL,              
 @toDate varchar(50)=NULL,            
 @state VARCHAR(50)=NULL                           
as              
------  
--
------ Test
--declare @flag char(1),              
-- @orgCountry varchar(50),              
-- @orgAgent varchar(50),              
-- @orgBranch varchar(50),              
-- @year varchar(20),              
-- @month varchar(50),              
-- @show_country_wise char(1),              
-- @show_agent_wise char(1),              
-- @show_branch_wise char(1),              
-- @group_wise varchar(50),              
-- @exclude_agentid varchar(50),              
-- @fromDate varchar(50),              
-- @toDate varchar(50),            
-- @state VARCHAR(50)
--
--set @orgCountry='United States'
--set @orgAgent='20100313'    
--set @group_wise='txn_send_wise'
--set @fromDate='10/01/2013'
--set  @toDate='12/31/2013'
--set @state='NY'           
----drop table #temp              
----go              
create table #temp (              
 [country] varchar(50),              
 [AgentName] varchar(100),              
 [Agentcode] varchar(50),              
 [BranchName] varchar(100),              
 [BranchCode] varchar(50),              
 [Month_id] int,              
 [Month] varchar(50),              
 [Year] varchar(50),              
 [no_of_txn] int,              
 [dollar_amt] money,              
 [payoutCountry] varchar(50),              
 [payoutAgentName] varchar(100),              
 [payoutAgentCode] varchar(50),              
 [payoutBranchName] varchar(50),              
 [payoutBranchCode] varchar(50),              
 [AgentBranchName] varchar(200)              
)              
--              
--declare @orgCountry varchar(50),@orgAgent varchar(50),@orgBranch varchar(50),@show_country_wise char(1),              
-- @year varchar(20),@show_agent_wise char(1),@show_branch_wise char(1),@group_wise varchar(50)              
declare @sql varchar(8000)              
--set @show_country_wise='y'              
--set @show_agent_wise='y'              
--set @show_branch_wise='y'              
--set @group_wise='payout_agent_wise'              
              
--  Total txn send (ready for txn)            
              
if @show_branch_wise ='y'              
set @show_agent_wise='y'              
set @sql='insert into #temp([country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],              
 [no_of_txn],[dollar_amt],[payoutCountry],[payoutAgentName],[payoutAgentCode]              
-- ,[payoutBranchName],[payoutBranchCode]              
)'              
--set @sql=''              
set @sql=@sql+' select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,l.[Month],m.month_name,[Year],              
 [no_of_txn],[dollar_amt]              
,[payoutCountry],[payoutAgentName],[payoutAgentCode]              
--,[payoutBranchName],[payoutBranchCode]               
from (select               
case when '''+isNULL(@show_country_wise,'n')+''' =''n'' then NULL else max(senderCountry) end [country],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentName) end [AgentName],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentId) end [Agentcode],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(m.branch) end [BranchName],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(branch_code) end [BranchCode],              
case when '''+isNULL(@show_agent_wise,'n') +'''=''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then NULL              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then               
max(agentName) +''&raquo; All Branch ''              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' <>''n'' then               
max(agentName) +''&raquo;''+ max(branch)              
else NULL end [AgentBranchName],              
month(confirmDate) [Month],              
year(confirmDate) [Year],              
count(*) [no_of_txn],sum(dollar_Amt) [dollar_amt],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_country_wise'' then max(receiverCountry) else NULL end [payoutCountry],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then max(p.companyName) else NULL end [payoutAgentName],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then expected_payoutagentid else NULL end [payoutAgentCode]              
from moneysend m with(nolock) left outer join agentdetail p with(nolock) on m.expected_payoutagentid=p.agentcode          
JOIN agentdetail a with(nolock) on m.agentid=a.agentcode            
where TransStatus NOT IN (''Hold'')'              
if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''              
if @state is not NULL and @orgAgent is null         
 set @sql=@sql+' and a.state='''+ @state+''''             
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''              
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''              
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
if @year is not null              
set @sql=@sql+' and year(confirmDate)='''+@year+''''              
if @fromDate is not null and @todate is not null              
set @sql=@sql+' and confirmDate between '''+@fromDate+''' and '''+@todate+' 23:59:59'''              
              
set @sql=@sql+' group by month(confirmDate),year(confirmDate)'              
if @show_country_wise is not null              
set @sql=@sql+' ,senderCountry'              
if @show_agent_wise is not null              
set @sql=@sql+' ,agentid'              
if @show_branch_wise is not null              
set @sql=@sql+' ,branch_code'              
if @group_wise='payout_country_wise'              
set @sql=@sql+',[receiverCountry]'              
else if @group_wise='payout_agent_wise'              
set @sql=@sql+',expected_payoutagentid'              
set @sql=@sql+'              
)l join tbl_month m on l.[Month]=m.month_id              
order by '              
              
if @show_country_wise is not null              
set @sql=@sql+' [country],'              
if @show_agent_wise is not null              
set @sql=@sql+'[AgentName],'              
if @show_branch_wise is not null              
set @sql=@sql+'[BranchName],'              
              
              
set @sql=@sql+'[Year],[Month]'              
print (@sql)              
exec (@sql)              
              
--select * from #temp              
              
create table #temp_cancel (              
 [country] varchar(50),              
 [AgentName] varchar(100),              
 [Agentcode] varchar(50),              
 [BranchName] varchar(100),              
 [BranchCode] varchar(50),              
 [Month_id] int,              
 [Month] varchar(50),              
 [Year] varchar(50),              
 [no_of_txn_cancel] int,              
 [dollar_amt_cancel] money,              
 [payoutCountry] varchar(50),              
 [payoutAgentName] varchar(100),              
 [payoutAgentCode] varchar(50),              
 [payoutBranchName] varchar(50),              
 [payoutBranchCode] varchar(50),              
 [AgentBranchName] varchar(200)              
)              
              
              
--declare @sql varchar(8000)              
--set @show_country_wise='y'              
--set @show_agent_wise='y'              
--set @show_branch_wise='y'              
--set @group_wise='payout_agent_wise'              
              
--  TOTAL CANCEL TXN        
              
if @show_branch_wise ='y'              
set @show_agent_wise='y'              
              
set @sql=''              
set @sql='insert into #temp_cancel([country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],              
 [no_of_txn_cancel],[dollar_amt_cancel],[payoutCountry],[payoutAgentName],[payoutAgentCode]              
-- ,[payoutBranchName],[payoutBranchCode]              
)'              
--set @sql=''              
set @sql=@sql+' select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,l.[Month],m.month_name,[Year],              
 [no_of_txn],[dollar_amt]              
,[payoutCountry],[payoutAgentName],[payoutAgentCode]              
--,[payoutBranchName],[payoutBranchCode]               
from (select               
case when '''+isNULL(@show_country_wise,'n')+''' =''n'' then NULL else max(senderCountry) end [country],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentName) end [AgentName],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentId) end [Agentcode],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(m.branch) end [BranchName],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(branch_code) end [BranchCode],             
case when '''+isNULL(@show_agent_wise,'n') +'''=''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then NULL              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then               
max(agentName) +''&raquo; All Branch ''              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' <>''n'' then               
max(agentName) +''&raquo;''+ max(branch)              
else NULL end [AgentBranchName],              
month(confirmDate) [Month],              
year(confirmDate) [Year],              
count(*) [no_of_txn],sum(dollar_Amt) [dollar_amt],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_country_wise'' then max(receiverCountry) else NULL end [payoutCountry],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then max(p.companyName) else NULL end [payoutAgentName],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then expected_payoutagentid else NULL end [payoutAgentCode]              
from moneysend m WITH(NOLOCK) join agentdetail p WITH(NOLOCK) on m.expected_payoutagentid=p.agentcode           
LEFT OUTER JOIN agentdetail a with(nolock) on m.agentid=a.agentcode              
where transStatus=''Cancel'' and left(CONVERT(VARCHAR,cancel_date,112),6)=left(CONVERT(VARCHAR,confirmDate,112),6)   '          
if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''            
if @state is not NULL  and @orgAgent is null              
 set @sql=@sql+' and a.state='''+ @state+''''              
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''              
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''              
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
if @year is not null              
set @sql=@sql+' and year(confirmDate)='''+@year+''''              
if @fromDate is not null and @todate is not null              
set @sql=@sql+' and confirmDate between '''+@fromDate+''' and '''+@todate+' 23:59:59'''              
              
set @sql=@sql+' group by month(confirmDate),year(confirmDate)'              
if @show_country_wise is not null              
set @sql=@sql+' ,senderCountry'              
if @show_agent_wise is not null              
set @sql=@sql+' ,agentid'              
if @show_branch_wise is not null              
set @sql=@sql+' ,branch_code'              
if @group_wise='payout_country_wise'              
set @sql=@sql+',[receiverCountry]'              
else if @group_wise='payout_agent_wise'              
set @sql=@sql+',expected_payoutagentid'              
set @sql=@sql+'              
)l join tbl_month m on l.[Month]=m.month_id              
order by '              
              
if @show_country_wise is not null              
set @sql=@sql+' [country],'              
if @show_agent_wise is not null              
set @sql=@sql+'[AgentName],'              
if @show_branch_wise is not null              
set @sql=@sql+'[BranchName],'              
              
              
set @sql=@sql+'[Year],[Month]'              
print (@sql)              
exec (@sql)              
                       
  --Temp Paid            
  create table #temp_paid (              
 [country] varchar(50),              
 [AgentName] varchar(100),              
 [Agentcode] varchar(50),              
 [BranchName] varchar(100),              
 [BranchCode] varchar(50),              
 [Month_id] int,              
 [Month] varchar(50),              
 [Year] varchar(50),              
 [no_of_txn_paid] int,              
 [dollar_amt_paid] money,              
 [payoutCountry] varchar(50),              
 [payoutAgentName] varchar(100),              
 [payoutAgentCode] varchar(50),              
 [payoutBranchName] varchar(50),              
 [payoutBranchCode] varchar(50),              
 [AgentBranchName] varchar(200)              
)              
       
              
--declare @sql varchar(8000)              
--set @show_country_wise='y'              
--set @show_agent_wise='y'              
--set @show_branch_wise='y'              
--set @group_wise='payout_agent_wise'              
              
-- TOTAL PAID TXN              
              
if @show_branch_wise ='y'              
set @show_agent_wise='y'              
              
set @sql=''              
set @sql='insert into #temp_paid([country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],              
 [no_of_txn_paid],[dollar_amt_paid],[payoutCountry],[payoutAgentName],[payoutAgentCode]              
-- ,[payoutBranchName],[payoutBranchCode]              
)'              
--set @sql=''              
set @sql=@sql+' select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,l.[Month],m.month_name,[Year],              
 [no_of_txn],[dollar_amt]              
,[payoutCountry],[payoutAgentName],[payoutAgentCode]              
--,[payoutBranchName],[payoutBranchCode]               
from (select               
case when '''+isNULL(@show_country_wise,'n')+''' =''n'' then NULL else max(senderCountry) end [country],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentName) end [AgentName],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentId) end [Agentcode],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(m.branch) end [BranchName],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(branch_code) end [BranchCode],              
case when '''+isNULL(@show_agent_wise,'n') +'''=''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then NULL              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then               
max(agentName) +''&raquo; All Branch ''              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' <>''n'' then               
max(agentName) +''&raquo;''+ max(branch)              
else NULL end [AgentBranchName],              
month(paidDate) [Month],              
year(paidDate) [Year],              
count(*) [no_of_txn],sum(dollar_Amt) [dollar_amt],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_country_wise'' then max(receiverCountry) else NULL end [payoutCountry],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then max(p.companyName) else NULL end [payoutAgentName],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then expected_payoutagentid else NULL end [payoutAgentCode]              
from moneysend m WITH(NOLOCK) join agentdetail p WITH(NOLOCK) on m.expected_payoutagentid=p.agentcode              
LEFT OUTER JOIN agentdetail a with(nolock) on m.agentid=a.agentcode           
where  TransStatus =''Payment'' AND status =''Paid''             
AND left(CONVERT(VARCHAR,paidDate,112),6)=left(CONVERT(VARCHAR,confirmDate,112),6)'  --- change greater than to equal to      
if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''            
if @state is not NULL   and @orgAgent is null             
set @sql=@sql+' and a.state='''+ @state+''''              
             
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''           
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''              
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
if @year is not null              
set @sql=@sql+' and year(paidDate)='''+@year+''''              
if @fromDate is not null and @todate is not null              
set @sql=@sql+' and paidDate between '''+@fromDate+''' and '''+@todate+' 23:59:59'''              
              
set @sql=@sql+' group by month(paidDate),year(paidDate)'              
if @show_country_wise is not null              
set @sql=@sql+' ,senderCountry'              
if @show_agent_wise is not null              
set @sql=@sql+' ,agentid'              
if @show_branch_wise is not null              
set @sql=@sql+' ,branch_code'              
if @group_wise='payout_country_wise'          
set @sql=@sql+',[receiverCountry]'              
else if @group_wise='payout_agent_wise'              
set @sql=@sql+',expected_payoutagentid'              
set @sql=@sql+'              
)l join tbl_month m on l.[Month]=m.month_id              
order by '              
              
if @show_country_wise is not null              
set @sql=@sql+' [country],'              
if @show_agent_wise is not null              
set @sql=@sql+'[AgentName],'              
if @show_branch_wise is not null              
set @sql=@sql+'[BranchName],'              
              
              
set @sql=@sql+'[Year],[Month]'              
print (@sql)              
exec (@sql)             
  --Temp paid      
 --Temp1 Paid            
  create table #temp_paid1 (              
 [country] varchar(50),              
 [AgentName] varchar(100),              
 [Agentcode] varchar(50),              
 [BranchName] varchar(100),              
 [BranchCode] varchar(50),              
 [Month_id] int,              
 [Month] varchar(50),              
 [Year] varchar(50),              
 [no_of_txn_paid] int,              
 [dollar_amt_paid] money,              
 [payoutCountry] varchar(50),              
 [payoutAgentName] varchar(100),              
 [payoutAgentCode] varchar(50),              
 [payoutBranchName] varchar(50),              
 [payoutBranchCode] varchar(50),              
 [AgentBranchName] varchar(200)              
)              
       
              
--declare @sql varchar(8000)              
--set @show_country_wise='y'              
--set @show_agent_wise='y'              
--set @show_branch_wise='y'              
--set @group_wise='payout_agent_wise'              
              
-- TOTAL PAID TXN              
              
if @show_branch_wise ='y'              
set @show_agent_wise='y'              
              
set @sql=''              
set @sql='insert into #temp_paid1([country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],              
 [no_of_txn_paid],[dollar_amt_paid],[payoutCountry],[payoutAgentName],[payoutAgentCode]              
-- ,[payoutBranchName],[payoutBranchCode]              
)'              
--set @sql=''              
set @sql=@sql+' select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,l.[Month],m.month_name,[Year],              
 [no_of_txn],[dollar_amt]              
,[payoutCountry],[payoutAgentName],[payoutAgentCode]              
--,[payoutBranchName],[payoutBranchCode]               
from (select               
case when '''+isNULL(@show_country_wise,'n')+''' =''n'' then NULL else max(senderCountry) end [country],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentName) end [AgentName],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentId) end [Agentcode],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(m.branch) end [BranchName],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(branch_code) end [BranchCode],              
case when '''+isNULL(@show_agent_wise,'n') +'''=''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then NULL              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then               
max(agentName) +''&raquo; All Branch ''              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' <>''n'' then               
max(agentName) +''&raquo;''+ max(branch)              
else NULL end [AgentBranchName],              
month(paidDate) [Month],              
year(paidDate) [Year],              
count(*) [no_of_txn],sum(dollar_Amt) [dollar_amt],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_country_wise'' then max(receiverCountry) else NULL end [payoutCountry],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then max(p.companyName) else NULL end [payoutAgentName],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then expected_payoutagentid else NULL end [payoutAgentCode]              
from moneysend m WITH(NOLOCK) join agentdetail p WITH(NOLOCK) on m.expected_payoutagentid=p.agentcode              
LEFT OUTER JOIN agentdetail a with(nolock) on m.agentid=a.agentcode           
where  TransStatus =''Payment'' AND status =''Paid''             
AND left(CONVERT(VARCHAR,paidDate,112),6)>left(CONVERT(VARCHAR,confirmDate,112),6)'      
if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''            
if @state is not NULL  and @orgAgent is null              
set @sql=@sql+' and a.state='''+ @state+''''              
             
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''              
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''              
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
if @year is not null              
set @sql=@sql+' and year(paidDate)='''+@year+''''              
if @fromDate is not null and @todate is not null              
set @sql=@sql+' and paidDate between '''+@fromDate+''' and '''+@todate+' 23:59:59'''              
              
set @sql=@sql+' group by month(paidDate),year(paidDate)'              
if @show_country_wise is not null              
set @sql=@sql+' ,senderCountry'              
if @show_agent_wise is not null              
set @sql=@sql+' ,agentid'              
if @show_branch_wise is not null              
set @sql=@sql+' ,branch_code'              
if @group_wise='payout_country_wise'          
set @sql=@sql+',[receiverCountry]'              
else if @group_wise='payout_agent_wise'              
set @sql=@sql+',expected_payoutagentid'              
set @sql=@sql+'              
)l join tbl_month m on l.[Month]=m.month_id              
order by '              
              
if @show_country_wise is not null              
set @sql=@sql+' [country],'              
if @show_agent_wise is not null              
set @sql=@sql+'[AgentName],'              
if @show_branch_wise is not null              
set @sql=@sql+'[BranchName],'              
              
              
set @sql=@sql+'[Year],[Month]'              
print (@sql)              
exec (@sql)             
  --Temp paid1          
              
    --Temp obligation            
  create table #temp_obligation (            
[country] varchar(50),              
 [AgentName] varchar(100),              
 [Agentcode] varchar(50),              
 [BranchName] varchar(100),              
 [BranchCode] varchar(50),              
 [Month_id] int,              
 [Month] varchar(50),              
 [Year] varchar(50),              
 [no_of_txn_obligation] int,              
 [dollar_amt_obligation] money,              
 [payoutCountry] varchar(50),              
 [payoutAgentName] varchar(100),              
 [payoutAgentCode] varchar(50),              
 [payoutBranchName] varchar(50),              
 [payoutBranchCode] varchar(50),              
 [AgentBranchName] varchar(200),    
 [Total_UNPAID_number] int,    
 [Total_UnPaid_USD] money,    
 [no_of_txn_cancel_outstanding] int,    
 [dollar_amt_cancel_outstanding] money    
     
)              
              
              
--declare @sql varchar(8000)              
--set @show_country_wise='y'              
--set @show_agent_wise='y'              
--set @show_branch_wise='y'              
--set @group_wise='payout_agent_wise'              
              
--              
              
if @show_branch_wise ='y'              
set @show_agent_wise='y'              
              
set @sql=''              
set @sql='insert into #temp_obligation([country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],              
 [no_of_txn_obligation],[dollar_amt_obligation],[payoutCountry],[payoutAgentName],[payoutAgentCode]              
-- ,[payoutBranchName],[payoutBranchCode]              
)'              
--set @sql=''              
set @sql=@sql+' select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,l.[Month],m.month_name,[Year],              
 [no_of_txn],[dollar_amt]              
,[payoutCountry],[payoutAgentName],[payoutAgentCode]              
--,[payoutBranchName],[payoutBranchCode]               
from (select               
case when '''+isNULL(@show_country_wise,'n')+''' =''n'' then NULL else max(senderCountry) end [country],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentName) end [AgentName],              
case when '''+isNULL(@show_agent_wise,'n') +''' =''n'' then NULL else max(agentId) end [Agentcode],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(m.branch) end [BranchName],              
case when '''+isNULL(@show_branch_wise,'n') +'''=''n'' then NULL else max(branch_code) end [BranchCode],              
case when '''+isNULL(@show_agent_wise,'n') +'''=''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then NULL              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' =''n'' then               
max(agentName) +''&raquo; All Branch ''              
when '''+isNULL(@show_agent_wise,'n') +'''<>''n'' and '''+isNULL(@show_branch_wise,'n') +''' <>''n'' then               
max(agentName) +''&raquo;''+ max(branch)              
else NULL end [AgentBranchName],              
month(confirmDate) [Month],              
year(confirmDate) [Year],              
count(*) [no_of_txn],sum(dollar_Amt) [dollar_amt],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_country_wise'' then max(receiverCountry) else NULL end [payoutCountry],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then max(p.companyName) else NULL end [payoutAgentName],              
case when '''+ isNULL(@group_wise,'')+'''=''payout_agent_wise'' then expected_payoutagentid else NULL end [payoutAgentCode]              
from moneysend m WITH(NOLOCK) join agentdetail p WITH(NOLOCK) on m.expected_payoutagentid=p.agentcode           
LEFT OUTER JOIN agentdetail a with(nolock) on m.agentid=a.agentcode              
where  (        
(STATUS in (''Un-Paid'',''Post'') and TransStatus NOT IN (''Hold'',''Cancel''))   
OR left(CONVERT(VARCHAR,paidDate,112),6)>left(CONVERT(VARCHAR,confirmDate,112),6)  
OR (left(CONVERT(VARCHAR,cancel_date,112),6)>left(CONVERT(VARCHAR,confirmDate,112),6) and transStatus=''Cancel'')   
) '           
          
if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''            
if @state is not NULL   and @orgAgent is null             
set @sql=@sql+' and a.state='''+ @state+''''              
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''              
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''              
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
if @year is not null              
set @sql=@sql+' and year(confirmDate)='''+@year+''''              
if @fromDate is not null and @todate is not null              
set @sql=@sql+' and confirmDate between '''+@fromDate+''' and '''+@todate+' 23:59:59'''                
set @sql=@sql+' group by month(confirmDate),year(confirmDate)'              
if @show_country_wise is not null              
set @sql=@sql+' ,senderCountry'              
if @show_agent_wise is not null              
set @sql=@sql+' ,agentid'              
if @show_branch_wise is not null              
set @sql=@sql+' ,branch_code'       
if @group_wise='payout_country_wise'              
set @sql=@sql+',[receiverCountry]'              
else if @group_wise='payout_agent_wise'              
set @sql=@sql+',expected_payoutagentid'              
set @sql=@sql+'              
)l join tbl_month m on l.[Month]=m.month_id              
order by '              
      
if @show_country_wise is not null              
set @sql=@sql+' [country],'              
if @show_agent_wise is not null              
set @sql=@sql+'[AgentName],'              
if @show_branch_wise is not null              
set @sql=@sql+'[BranchName],'              
              
              
set @sql=@sql+'[Year],[Month]'              
print (@sql)              
exec (@sql)             
  --Temp obligation        
  --      
      
CREATE TABLE #temp_unpaid(      
 MONTH_ID INT,      
 YEAR INT,      
 Total_UNPAID_number INT,      
 Total_UnPaid_USD MONEY      
)      
      
SET @sql='insert #temp_unpaid(MONTH_ID,year,Total_UNPAID_number,Total_UnPaid_USD)      
SELECT t.[Month_id],t.Year,m.Total_UNPAID_number,m.Total_UnPaid_USD FROM #temp_obligation AS t       
Outer APPLY      
(      
 SELECT COUNT(*) Total_UNPAID_number,SUM(isnull(ms.Dollar_Amt,0)) Total_UnPaid_USD FROM moneysend  ms  with (nolock)     
 LEFT OUTER JOIN agentdetail a with(nolock) on ms.agentid=a.agentcode        
  WHERE ((        
 STATUS in (''Un-Paid'',''Post'') And         
left(CONVERT(VARCHAR,confirmDate,112),6)<cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR)       
  AND ms.TransStatus NOT IN (''Hold'',''Cancel''))      
 or (left(CONVERT(VARCHAR,PaidDate,112),6)>cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR)   
 and left(CONVERT(VARCHAR,confirmDate,112),6)<cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR))  
 or (left(CONVERT(VARCHAR,confirmDate,112),6)<cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR)       
  AND ms.TransStatus IN (''Cancel'')      
 and left(CONVERT(VARCHAR,cancel_date,112),6)>cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR)      
   ))  
 '      
       
    if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''            
if @state is not NULL and @orgAgent is null               
set @sql=@sql+' and a.state='''+ @state+''''              
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''              
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''      
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
      
set @sql=@sql+'       
) m      
'      
print(@sql)      
EXEC(@sql)     
 

   
CREATE TABLE #temp_cancel_outstanding(      
 MONTH_ID INT,      
 YEAR INT,      
 no_of_txn_cancel_outstanding INT,      
 [dollar_amt_cancel_outstanding] MONEY      
)      
      
SET @sql='insert #temp_cancel_outstanding(MONTH_ID,year,no_of_txn_cancel_outstanding,dollar_amt_cancel_outstanding)      
SELECT t.[Month_id],t.Year,m.no_of_txn_cancel_outstanding,m.[dollar_amt_cancel_outstanding] FROM #temp_obligation AS t       
Outer APPLY      
(      
 SELECT COUNT(*) no_of_txn_cancel_outstanding,SUM(isnull(ms.Dollar_Amt,0)) [dollar_amt_cancel_outstanding] FROM moneysend  ms with(nolock)      
 LEFT OUTER JOIN agentdetail a with(nolock) on ms.agentid=a.agentcode        
  WHERE     
left(CONVERT(VARCHAR,confirmDate,112),6)<cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR)       
  AND ms.TransStatus IN (''Cancel'')      
 and left(CONVERT(VARCHAR,cancel_date,112),6)=cast(t.YEAR AS VARCHAR)+case when len(cast(t.[Month_id] AS VARCHAR))=1 then ''0'' else '''' end + cast(t.[Month_id] AS VARCHAR) '      
       
    if @orgCountry is not NULL              
set @sql=@sql+' and senderCountry='''+ @orgCountry+''''            
if @state is not NULL and @orgAgent is null               
set @sql=@sql+' and a.state='''+ @state+''''              
if @orgAgent is not NULL              
set @sql=@sql+' and agentid='''+ @orgAgent+''''              
if @orgBranch is not NULL              
set @sql=@sql+' and branch_code='''+ @orgBranch+''''              
if @exclude_agentid is not null               
set @sql=@sql+' and agentid<>'''+@exclude_agentid+''''              
      
set @sql=@sql+'       
) m      
'      
print(@sql)      
EXEC(@sql)     
     
--      
--UPDATE #temp_obligation SET no_of_txn_obligation = isNUll(no_of_txn_obligation,0) + isNUll(u.Total_UNPAID_number,0),      
--dollar_amt_obligation=isNUll(dollar_amt_obligation,0)+isNull(u.Total_UnPaid_USD,0)      
--FROM #temp_obligation t , #temp_unpaid u      
--WHERE t.[Year]=u.[YEAR] AND t.Month_id=u.MONTH_ID     
UPDATE #temp_obligation SET Total_UNPAID_number = isNUll(u.Total_UNPAID_number,0),      
Total_UnPaid_USD=isNull(u.Total_UnPaid_USD,0)    
FROM #temp_obligation t , #temp_unpaid u     
WHERE t.[Year]=u.[YEAR] AND t.Month_id=u.MONTH_ID     
  
UPDATE #temp_obligation SET     
no_of_txn_cancel_outstanding = isNUll(c.no_of_txn_cancel_outstanding,0),      
[dollar_amt_cancel_outstanding]=isNull(c.[dollar_amt_cancel_outstanding],0)       
FROM #temp_obligation t ,#temp_cancel_outstanding c     
WHERE t.[Year]=c.[YEAR] AND t.Month_id=c.MONTH_ID    
      
create table #temp_net (              
 [country] varchar(50),              
 [AgentName] varchar(100),              
 [Agentcode] varchar(50),              
 [BranchName] varchar(100),              
 [BranchCode] varchar(50),              
 [Month_id] int,              
 [Month] varchar(50),       
 [Year] varchar(50),              
 [no_of_txn] int,              
 [no_of_txn_cancel] int,              
 [dollar_amt] money,              
 [dollar_amt_cancel] money,              
 [payoutCountry] varchar(50),              
 [payoutAgentName] varchar(100),              
 [payoutAgentCode] varchar(50),              
 [payoutBranchName] varchar(50),              
 [payoutBranchCode] varchar(50),              
 [AgentBranchName] varchar(200),            
 [no_of_txn_paid] INT,            
 [no_of_txn_obligation] INT,            
 [dollar_amt_paid] money,              
 [dollar_amt_obligation] money,    
 [no_of_txn_paid_other] INT,    
 [dollar_amt_other] money,     
 [Total_UNPAID_number] int,     
 [Total_UnPaid_USD] money,    
 [no_of_txn_cancel_outstanding] int,    
 [dollar_amt_cancel_outstanding] money            
)              
              
insert into #temp_net([country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]     
 ,[Month_id],[Month],[Year],[no_of_txn],              
 [no_of_txn_cancel],[dollar_amt],[dollar_amt_cancel],[payoutCountry],[payoutAgentName],[payoutAgentCode],            
   [no_of_txn_paid] ,[no_of_txn_obligation] ,[dollar_amt_paid],[dollar_amt_obligation],    
   [no_of_txn_paid_other],[dollar_amt_other] , [Total_UNPAID_number] , [Total_UnPaid_USD],[no_of_txn_cancel_outstanding],[dollar_amt_cancel_outstanding] )              
select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],sum(no_of_txn)[no_of_txn],              
 sum(no_of_txn_cancel) [no_of_txn_cancel],sum(dollar_amt) [dollar_amt],              
 sum(dollar_amt_cancel) [dollar_amt_cancel],[payoutCountry],[payoutAgentName],[payoutAgentCode]  ,            
 sum(no_of_txn_paid) [no_of_txn_paid],  sum(no_of_txn_obligation) [no_of_txn_obligation],sum(dollar_amt_paid) [dollar_amt_paid],  sum(dollar_amt_obligation) [dollar_amt_obligation] ,    
 SUM([no_of_txn_paid_other]) [no_of_txn_paid_other],SUM([dollar_amt_other]) [dollar_amt_other], SUM([Total_UNPAID_number]) [Total_UNPAID_number], SUM([Total_UnPaid_USD]) [Total_UnPaid_USD],    
 SUM([no_of_txn_cancel_outstanding]),SUM([dollar_amt_cancel_outstanding])    
from (              
select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],[no_of_txn],  0 [no_of_txn_cancel],[dollar_amt],0 [dollar_amt_cancel],            
 [payoutCountry],[payoutAgentName],[payoutAgentCode] ,            
 0 [no_of_txn_paid] ,0 [no_of_txn_obligation],0 [dollar_amt_paid],0  dollar_amt_obligation,    
 0 [no_of_txn_paid_other],0 [dollar_amt_other] ,0 [Total_UNPAID_number] ,0 [Total_UnPaid_USD],    
 0 [no_of_txn_cancel_outstanding],0 [dollar_amt_cancel_outstanding]             
from #temp              
union all              
select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],0 [no_of_txn], [no_of_txn_cancel],0 [dollar_amt], [dollar_amt_cancel],            
 [payoutCountry],[payoutAgentName],[payoutAgentCode] ,            
 0 [no_of_txn_paid] ,0 [no_of_txn_obligation],0 [dollar_amt_paid],0  dollar_amt_obligation ,    
 0 [no_of_txn_paid_other],0 [dollar_amt_other] ,0 [Total_UNPAID_number] ,0 [Total_UnPaid_USD],    
 0 [no_of_txn_cancel_outstanding],0 [dollar_amt_cancel_outstanding]              
from #temp_cancel        
union all              
select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],0 [no_of_txn],  0 [no_of_txn_cancel],0 [dollar_amt],0 [dollar_amt_cancel],[payoutCountry],[payoutAgentName],[payoutAgentCode] ,            
  [no_of_txn_paid] ,0 [no_of_txn_obligation], [dollar_amt_paid],0 dollar_amt_obligation,    
  0 [no_of_txn_paid_other],0 [dollar_amt_other] ,0 [Total_UNPAID_number] ,0 [Total_UnPaid_USD],    
  0 [no_of_txn_cancel_outstanding],0 [dollar_amt_cancel_outstanding]               
from #temp_paid     
union all              
select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],0 [no_of_txn],  0 [no_of_txn_cancel],0 [dollar_amt],0 [dollar_amt_cancel],[payoutCountry],[payoutAgentName],[payoutAgentCode] ,            
  0 [no_of_txn_paid] ,0 [no_of_txn_obligation],0 [dollar_amt_paid],0 dollar_amt_obligation,    
  [no_of_txn_paid] [no_of_txn_paid_other],[dollar_amt_paid] [dollar_amt_other] ,0 [Total_UNPAID_number] ,0 [Total_UnPaid_USD],    
  0 [no_of_txn_cancel_outstanding],0 [dollar_amt_cancel_outstanding]     
from #temp_paid1             
union all              
select [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],0 [no_of_txn], 0 [no_of_txn_cancel],0 [dollar_amt],0 [dollar_amt_cancel],            
 [payoutCountry],[payoutAgentName],[payoutAgentCode] ,            
 0 [no_of_txn_paid] , [no_of_txn_obligation],0 [dollar_amt_paid],dollar_amt_obligation,    
 0 [no_of_txn_paid_other],0 [dollar_amt_other] , [Total_UNPAID_number] ,[Total_UnPaid_USD],    
  [no_of_txn_cancel_outstanding], [dollar_amt_cancel_outstanding]     
from #temp_obligation               
)l group by [country],[AgentName],[Agentcode],[BranchName],[BranchCode],[AgentBranchName]              
 ,[Month_id],[Month],[Year],[payoutCountry],[payoutAgentName],[payoutAgentCode]              
              
              
select * from #temp_net order by [Year],[Month_id] 
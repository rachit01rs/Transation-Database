  drop proc [dbo].[spa_statement_funding_advice]   
  GO 
--spa_statement_funding_advice '1118','SummaryBalance','agentType desc,isNull(settlement_type,''l''),currencyType ,agent_name'       
--spa_statement_funding_advice '1131','SummaryBalance','agentType desc,isNull(settlement_type,''l''),currencyType ,agent_name'       
CREATE proc [dbo].[spa_statement_funding_advice]      
 @message_id int,      
 @call_from varchar(100)=NULL,      
 @order_by varchar(300)=NULL      
as      
      
create table #temp_tbl(      
 Branch varchar(100),      
 bankName varchar(100),      
 BankBranch varchar(100),      
 Account_no varchar(100),      
 stotCollect varchar(100),      
  Bank_Id varchar(100),      
 Agent_Id varchar(100),      
 Agent_Name varchar(100),      
 AgentType varchar(100),      
 CurrencyType varchar(100),      
 settlement_type varchar(100),      
 Dr money,      
 CR money,      
 isBlock char(1),      
 USD_Detail money,      
 USD_Amt money,      
 UnPaidAmt money,      
 Prefund_Dr money,      
 Prefund_CR money      
)      
      
insert into #temp_tbl       
exec spa_batch_report @message_id,@call_from,@order_by       
      
alter table #temp_tbl      
add exRate_countrywise money      
      
update #temp_tbl set exRate_countrywise=R.buyRate from #temp_tbl t left outer join agentdetail a on a.agentcode=t.agent_id      
left outer join Roster R on a.country=R.country where R.payoutagentid is NULL      
    
--update #temp_tbl set Prefund_Dr=Prefund_CR ,dr=cr     
--where Prefund_Dr=0 or Prefund_Dr is null   
update #temp_tbl set Prefund_Dr=Prefund_CR, dr=case when isnull(dr,0)=0 then cr else dr end    
where Prefund_Dr=0 or Prefund_Dr is null     
    
    
select isNULL(a.agent_short_code,companyName) [AGENT],isNULL(t.Dr,0)-isNULL(t.UnPaidAmt,0) [PAID BALANCE LC],      
isNULL(a.Account_No_IB,0) [Minimum COVER FUND LC],      
((isNULL(t.Dr,0)-isNULL(t.UnPaidAmt,0))-(isNULL(a.Account_No_IB,0))) [NET BALANCE LC],      
isNULL(R.buyRate,exRate_countrywise) [RATE],      
CAST(isNULL(((isNULL(t.Dr,0)-isNULL(t.UnPaidAmt,0))-(isNULL(a.Account_No_IB,0)))/isNULL(R.buyRate,exRate_countrywise),0) AS MONEY) [BALANCE USD],      
isNULL(t.Dr,0) [SOA REPORT BALANCE],isNULL(a.Further_Credit,0) [MiNIMUM COVER FUND USD],      
isNULL(t.Dr,0)-isNULL(a.Further_Credit,0) [NET BALANCE USD],      
CAST(isNULL((t.UnPaidAmt/isNULL(R.buyRate,t.exRate_countrywise)),0) AS MONEY) [UNPAID AMOUNT USD],      
isNULL(t.UnPaidAmt,0) [UNPAID AMOUNT Local],    
CAST(isNULL(t.Dr/isNULL(R.buyRate,exRate_countrywise),0) AS MONEY) [SOA REPORT BALANCE USD],    
CAST(isNULL((isNULL(t.Dr,0)-isNULL(t.UnPaidAmt,0))/isNULL(R.buyRate,exRate_countrywise),0)  AS MONEY) [PAID BALANCE USD]    
 from #temp_tbl t       
left outer join agentdetail a on a.agentcode=t.agent_id      
left outer join Roster R on t.agent_id=R.payoutagentid   
where isNULL(a.Account_No_IB,0) > 0  
  
drop proc [dbo].[spa_NotificationExRate] 
go      
CREATE proc [dbo].[spa_NotificationExRate]      
 @audit_process_id varchar(150)=NULL,      
 @costExchangeID varchar(max)=NULL      
as      
--declare @audit_process_id varchar(150)      
--set @audit_process_id='5A7C0D76_BE2D_41C4_85C2_C3A449E582B0'      
----DROP TABLE #temp    
----DROP TABLE #temp1     
SET NOCOUNT ON;      
    
SELECT * into #tempID FROM [SplitCommaSeperatedValues](@costExchangeID)    
      
-- Create #temp table for exchange rate approved      
select isNUll(pr.Customer_rate,r.Customer_rate) Customer_rate,    
isNUll(pr.ExchangeRate,r.ExchangeRate) ExchangeRate,    
isNUll(pr.dollarRate,r.dollarRate) dollarRate,    
isNUll(pr.agentid,r.agentid) agentid,isNull(pr.receiveCountry,r.receiveCountry) receiveCountry ,    
isnull(pr.receiveCType,r.receiveCType) receiveCType,    
isnull(pa.CurrencyType,a.CurrencyType) CurrencyType,    
isNUll(pa.companyName,a.companyName) companyName,isNUll(pa.Country ,a.Country) SendCountry,    
t.receiver PayoutAgent  into #temp    
 FROM   temp_forex_exchange t WITH(NOLOCK) JOIN #tempID tid  
 ON t.sno=tid.Item    
left outer join  agentcurrencyrate r WITH(NOLOCK)                      
 on r.currencyid=t.currencyid and t.idtype='c'     
 left outer join agentpayout_CurrencyRate pr on pr.currencyID=t.currencyID and t.idtype='p'     
 left outer join agentdetail a WITH(NOLOCK) on a.agentcode=r.agentid     
left outer join agentdetail pa WITH(NOLOCK) on pa.agentcode=pr.agentid      
 where t.session_id=@audit_process_id    
     
 DECLARE @id int,@agentid VARCHAR(50),@sendingCountry VARCHAR(100),@email_body varchar(5000),    
@receivingid VARCHAR(50),@receivingCountry VARCHAR(100),@address_book int,@sms_email_value VARCHAR(50)     
 DECLARE Partner_Agent CURSOR  FORWARD_ONLY READ_ONLY FOR    
    
 select id,agentid,sendingCountry,receivingid,receivingCountry,address_book,sms_email_value     
 from sms_notification WHERE sms_or_email='e'    
 OPEN Partner_Agent    
 FETCH NEXT FROM Partner_Agent into @id,@agentid,@sendingCountry,@receivingid,@receivingCountry,@address_book,@sms_email_value    
 WHILE @@FETCH_STATUS = 0    
 BEGIN    
  set @email_body=''    
  SELECT  @email_body=@email_body + '<tr><td>'+ companyName +' - '+  upper(receiveCountry) +' -' +upper(payoutagent) +'</td><td colspan=2>'+     
   case       
    when @sms_email_value ='customer_rate' then      
     '1 '+ currencyType +' = '+ cast(customer_rate as varchar)  +' '+ receiveCType       
     when @sms_email_value ='exchangerate' then      
     '1 USD = '+ cast(round(CAST(exchangerate AS MONEY),4,1)  as varchar) +' '+ currencyType        
        when @sms_email_value ='payout_agent_rate' then      
     '1 USD = '+ cast(dollarRate  as varchar) +' '+ receiveCType        
    else ''       
   end  +'</td></tr>' FROM #temp t where     
  isNull(@agentid,agentid)=t.agentid    
     and isNull(@sendingCountry,t.SendCountry)=t.SendCountry    
     AND isNull(@receivingCountry,t.receiveCountry)=t.receiveCountry    
    
  if len(@email_body)>10    
  begin    
   set @email_body='<Table border=1 cellspacing=0>  ' + @email_body +'</table>'    
   INSERT INTO [email_request]      
           (      
           [notes_subject]      
           ,[notes_text]      
           ,[send_from]      
           ,[send_to]      
           , send_cc      
           ,[send_status]      
           ,[active_flag]      
          )      
                
SELECT 'Exchange Rate Updated: '+ convert(varchar,getdate(),121),      
 @email_body,      
 '',      
    email_id,      
    '',      
    'n',      
    'y'      
FROM address_book ab WHERE ab.category_type=@address_book    
and email_id is not null      
      
  end     
    
  FETCH NEXT FROM Partner_Agent into @id,@agentid,@sendingCountry,@receivingid,@receivingCountry,@address_book,@sms_email_value    
 end    
 close Partner_Agent    
 deallocate Partner_Agent    
      
              
                 
exec spa_sendemail      
         
      
DROP PROC [dbo].[spa_Roster]    
go
  
create PROC [dbo].[spa_Roster]  
 @flag char(1),  
 @sno int=NULL,  
 @country varchar(50)=NULL,  
 @buyRate numeric(19, 10)=NULL,  
 @sellRate numeric(19, 10)=NULL,  
 @rateDiff numeric(19, 10)=NULL,  
 @currencyType varchar(3)=NULL,  
 @created_by varchar(50)=NULL,  
 @updated_by varchar(50)=NULL,   
 @buyLower numeric(19, 10)=NULL,  
 @buyUpper numeric(19, 10)=NULL,  
 @sellLower numeric(19, 10)=NULL,  
 @sellUpper numeric(19, 10)=NULL,  
 @payoutAgentID varchar(50)=NULL,  
 @log_id int=NULL  
AS    
declare @audit_record int  
select @audit_record=audit_record_no from tbl_setup  
if @flag='s'  
 select r.sno,isNull(r.country,a.country) Country,payoutAgentID,companyname [AgentName] ,  
 buyRate,buyLower,buyUpper,sellRate,sellLower,sellupper,rateDiff,r.currencyType ,  
 r.round_by,r.updated_ts,r.updated_by,  
-- case when a.agenttype in ('Send and Pay','RTAgent') then 'a'   
-- when a.agenttype='Sender Agent' then 's'  
-- else 'b' end sell_buy  
 'a' sell_buy,isNull(buy_sell_margin,0) buy_sell_margin ,ISNULL(t.enable_update_remote_DB,'n') [PIC_source_disabled]
 FROM Roster r WITH(NOLOCK)
 LEFT OUTER JOIN agentDetail a WITH(NOLOCK) ON r.payoutAgentID=a.agentcode   
 LEFT OUTER JOIN dbo.tbl_interface_setup t WITH(NOLOCK) ON (r.payoutagentid=t.agentcode AND t.mode='send')
 ORDER BY country,payoutAgentID  
if @flag='a'  
 select sno,country,buyRate,buyLower,buyUpper,sellRate,sellLower,sellupper,rateDiff,currencyType from Roster WITH(NOLOCK) where sno=@sno  
  
if @flag='i'  
BEGIN   
 IF  @payoutAgentID IS NOT NULL   
  BEGIN   
  DECLARE @agent_country varchar(50)  
  SELECT  @agent_country=companyName FROM agentdetail WHERE agentcode=@payoutAgentID      
   IF NOT EXISTS ( SELECT payoutAgentID FROM roster WHERE payoutAgentID=@payoutAgentID)  
    BEGIN      
     INSERT INTO Roster(country,buyRate,buyLower,buyUpper,sellRate,sellLower,sellUpper,rateDiff,currencyType,created_by,created_ts,payoutAgentID)  
   VALUES(@country,@buyRate,@buyLower,@buyUpper,@sellRate,@sellLower,@sellUpper,@rateDiff,@currencyType,@created_by,dbo.getDateHO(getutcdate()),@payoutAgentID)  
     select 'Success' status,'The Roster of '+@agent_country+' is sucessfully added' msg  
    END   
   ELSE   
    BEGIN   
     SELECT 'Error' status,'The Roster of '+@agent_country+' already exists' msg  
    END   
  END  
 ELSE   
  BEGIN   
  IF NOT EXISTS(select sno from Roster where country=@country AND payoutAgentID IS NULL)   
   BEGIN    
   INSERT INTO Roster(country,buyRate,buyLower,buyUpper,sellRate,sellLower,sellUpper,rateDiff,currencyType,created_by,created_ts)  
   VALUES(@country,@buyRate,@buyLower,@buyUpper,@sellRate,@sellLower,@sellUpper,@rateDiff,@currencyType,@created_by,dbo.getDateHO(getutcdate()))  
   SELECT 'Success' status,'The Roster of '+@country+' is sucessfully added' msg     
   END    
  ELSE   
   BEGIN   
   SELECT 'Error' status,'The Roster of '+@country+' already exists' msg  
   END   
  END   
END   
  
if @flag='u'  
begin   
 update Roster  
 set buyRate=@buyRate,  
  sellRate=@sellRate,  
  rateDiff=@rateDiff,  
  currencyType=@currencyType,  
  updated_by=@updated_by,  
  updated_ts=dbo.getDateHO(getutcdate())  
 where sno=@sno  
 select 'Success' status,'The Roster of '+@country+' is updated sucessfully' msg   
end  
  
  
if @flag='l'--Update Upper and Lower Limit  
begin   
 update Roster  
 set buyRate=@buyRate,  
  sellRate=@sellRate,  
  rateDiff=@rateDiff,  
  currencyType=@currencyType,  
  updated_by=@updated_by,  
  updated_ts=dbo.getDateHO(getutcdate()),  
  buyLower =@buyLower,  
  buyUpper=@buyUpper,  
  sellLower=@sellLower,  
  sellUpper=@sellUpper  
  where sno=@sno  
 select 'Success' status,'The Roster of '+@country+' is updated sucessfully' msg   
end  
  
  
if @flag='d'  
begin  
 delete Roster where sno=@sno  
 select 'Success' status,'The Roster selected is deleted permantly' msg  
end  
  
if @flag='r' --for audit report  
begin  
select top(@audit_record) * from Roster_Log where sno=@sno order by updated_ts desc  
end  
  
if @flag='w' --display audit report with log_ID  
begin  
  
 declare @session_id varchar(150),@updated_ts datetime  
 select @session_id=audit_process_id,@payoutAgentID=payoutAgentID,@country=country,  
 @updated_ts=updated_ts,@updated_by=updated_by  
  from Roster_Log where log_ID=@log_id  
    DELETE dbo.temp_forex_exchange WHERE session_id=@session_id  
 IF @payoutAgentID IS  NOT NULL  
 BEGIN   
  insert into dbo.temp_forex_exchange  
   (exType,sender,receiveCountry,receiver,OldBuyRate,NewBuyRate,OldSelRate,NewSelRate,CURRENT_SETTLEMENT,CURRENT_MARGIN,  
   CURRENT_CUSTOMER,ExchangeRate,margin_sending_agent, SENDING_CUST_EXCHANGERATE,SEND_VS_PAYOUT_SETTMENT,SEND_VS_PAYOUT_CUSTOMER,  
   SEND_VS_PAYOUT_MARGIN,OldEffRate,NewEffRate,currencyId,idType,effictiveCountry,session_id,  
   Payout_Currency_Code,roundby  
   )  
   (    
   select 'Buying' ExType,  
     a.companyName Sender,  
     receiveCountry,  
     p.companyName Receiver,  
     DollarRate [CurrentRate],  
     DollarRate+isNull(agent_premium_payout,0)  [Cost],  
     isNull(agent_premium_payout,0) agent_premium_payout,  
     DollarRate [SettlementRate],  
  
   DollarRate CURRENT_SETTLEMENT,  
   isNull(receiver_rate_diff_value,0) CURRENT_MARGIN,  
   Payout_agent_rate CURRENT_CUSTOMER,  
       ExchangeRate Alter_CURR_SETTLEMENT,    margin_sending_agent Alter_CURR_MARGIN,  
   SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
       NPRRate SEND_VS_PAYOUT_SETTMENT,  
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
  
   Customer_rate [Old Rate],  
   Customer_rate [Effective Rate]  
   ,currencyId,  
     
   'p' idType,@country,  
     
   @session_id session_id,  
   a.currencyType,roundby  
   from agentpayout_CurrencyRate_audit e join   
   agentdetail a on a.agentcode=e.agentid join agentdetail p  
    on p.agentcode=e.payout_agent_id  
   where e.payout_agent_id=@payoutAgentID  
   and  audit_process_id=@session_id  
  
union all  
  
 select 'Selling' ExType,  
   companyName Sender,  
   receiveCountry,  
   '-' Receiver,  
     
   ExchangeRate [Payout xRate],  
   ExchangeRate + isNull(agent_premium_send,0) [Cost],  
   isNull(agent_premium_send,0) agent_premium_send,  
   ExchangeRate [SettlementRate],  
  
   ExchangeRate CURRENT_SETTLEMENT,  
   isNull(margin_sending_agent,0) CURRENT_MARGIN,  
   SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,  
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,  
   payout_agent_rate Alter_CURR_CUSTOMER,  
       NPRRate SEND_VS_PAYOUT_SETTMENT,  
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
        
   Customer_rate [Old Rate],  
   Customer_rate [Effective Rate]  
   ,currencyId,  
     
   'c' idType,@country,  
     
   @session_id session_id,  
   receiveCtype,roundby  
  
   from agentCurrencyRate_audit e join   
   agentdetail a on a.agentcode=e.agentid  
   where  e.agentid=@payoutAgentID  
   and  audit_process_id=@session_id  
union all  
  
 select 'Selling' ExType,  
   a.companyName Sender,  
   receiveCountry,  
   p.companyName Receiver,  
     
   ExchangeRate [Payout xRate],  
   ExchangeRate + isNull(agent_premium_send,0) [Cost],  
   isNull(agent_premium_send,0) agent_premium_send,  
   ExchangeRate [SettlementRate],  
  
   ExchangeRate CURRENT_SETTLEMENT,  
   isNull(margin_sending_agent,0) CURRENT_MARGIN,  
   SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,  
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,  
   payout_agent_rate Alter_CURR_CUSTOMER,  
       NPRRate SEND_VS_PAYOUT_SETTMENT,  
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
        
   Customer_rate [Old Rate],  
   Customer_rate [Effective Rate]  
   ,currencyId,  
        
   'p' idType,@country,  
       
   @session_id session_id,  
   receiveCtype,roundby  
   from agentpayout_CurrencyRate_audit e join   
   agentdetail a on a.agentcode=e.agentid join agentdetail p  
    on p.agentcode=e.payout_agent_id  
   where e.agentid=@payoutAgentID  
   and  audit_process_id=@session_id  
  )   
 END  
 ELSE  
 BEGIN --------Country wise ExRate  
   insert into dbo.temp_forex_exchange  
   (  
   exType,sender,receiveCountry,receiver,  
     
   OldBuyRate,NewBuyRate,     
   OldSelRate,  
   NewSelRate,  
  
   CURRENT_SETTLEMENT,  
   CURRENT_MARGIN,  
   CURRENT_CUSTOMER,  
   ExchangeRate,  
   margin_sending_agent,  
   SENDING_CUST_EXCHANGERATE,  
  
   SEND_VS_PAYOUT_SETTMENT,  
   SEND_VS_PAYOUT_CUSTOMER,  
   SEND_VS_PAYOUT_MARGIN,  
  
   OldEffRate,   
   NewEffRate,  
   currencyId,  
  
   idType,  
   effictiveCountry,  
     
   session_id,  
   Payout_Currency_Code,  
   roundby  
    )   
  (  
   select 'Buying' ExType,   -- B:Buying  
   a.companyName Sender,  
   receiveCountry,  
   receiveCountry Receiver,  
    
   DollarRate [CurrentRate],  
   DollarRate+isNull(agent_premium_payout,0)  [Cost],  
   isNull(agent_premium_payout,0) agent_premium_payout,  
   DollarRate [SettlementRate],  
  
   DollarRate CURRENT_SETTLEMENT,  
   isNull(receiver_rate_diff_value,0) CURRENT_MARGIN,  
   Payout_agent_rate CURRENT_CUSTOMER,  
       ExchangeRate Alter_CURR_SETTLEMENT,    margin_sending_agent Alter_CURR_MARGIN,  
   SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
       NPRRate SEND_VS_PAYOUT_SETTMENT,  
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
  
   Customer_rate [Old Rate],  
   Customer_rate [Effective Rate]  
   ,currencyId,  
   'c' idType,@country,@session_id session_id,  
   a.currencyType,roundby  
   from agentCurrencyRate_audit e join agentdetail a on a.agentcode=e.agentid  
   where ReceiveCountry=@country  
   and  audit_process_id=@session_id  
union all  
  
 select 'Selling' ExType,  
   companyName Sender,  
   receiveCountry,  
   '-' Receiver,  
     
   ExchangeRate [Payout xRate],  
   ExchangeRate + isNull(agent_premium_send,0) [Cost],  
   isNull(agent_premium_send,0) agent_premium_send,  
   ExchangeRate [SettlementRate],  
  
   ExchangeRate CURRENT_SETTLEMENT,  
   isNull(margin_sending_agent,0) CURRENT_MARGIN,  
   SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,  
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,  
   payout_agent_rate Alter_CURR_CUSTOMER,  
       NPRRate SEND_VS_PAYOUT_SETTMENT,  
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
        
   Customer_rate [Old Rate],  
   Customer_rate [Effective Rate]  
   ,currencyId,  
     
   'c' idType,@country,  
     
   @session_id session_id,  
   receiveCtype,roundby  
  
   from agentCurrencyRate_audit e join   
   agentdetail a on a.agentcode=e.agentid  
   where   audit_process_id=@session_id  
union all  
  
 select 'Selling' ExType,  
   a.companyName Sender,  
   receiveCountry,  
   p.companyName Receiver,  
     
   ExchangeRate [Payout xRate],  
   ExchangeRate + isNull(agent_premium_send,0) [Cost],  
   isNull(agent_premium_send,0) agent_premium_send,  
   ExchangeRate [SettlementRate],  
  
   ExchangeRate CURRENT_SETTLEMENT,  
   isNull(margin_sending_agent,0) CURRENT_MARGIN,  
   SENDING_CUST_EXCHANGERATE CURRENT_CUSTOMER,  
    DollarRate Alter_CURR_SETTLEMENT,    isNUll(receiver_rate_diff_value,0) Alter_CURR_MARGIN,  
   payout_agent_rate Alter_CURR_CUSTOMER,  
       NPRRate SEND_VS_PAYOUT_SETTMENT,  
   Customer_rate SEND_VS_PAYOUT_CUSTOMER,  
   Customer_diff_value SEND_VS_PAYOUT_MARGIN,  
        
   Customer_rate [Old Rate],  
   Customer_rate [Effective Rate]  
   ,currencyId,  
        
   'p' idType,@country,  
       
   @session_id session_id,  
   receiveCtype,roundby  
   from agentpayout_CurrencyRate_audit e join   
   agentdetail a on a.agentcode=e.agentid join agentdetail p  
    on p.agentcode=e.payout_agent_id  
   where  audit_process_id=@session_id  
  
     
  )  
     
 end               
   select sno,ExType,Sender,receiveCountry,Receiver,   
     NewBuyRate [Cost],  
     OldSelRate [Preimum],NewSelRate [NewRate],currencyId,  
     CURRENT_SETTLEMENT,  
     CURRENT_MARGIN,  
     CURRENT_CUSTOMER,  
  
     ExchangeRate Alter_CURR_SETTLEMENT,      margin_sending_agent Alter_CURR_MARGIN,  
     SENDING_CUST_EXCHANGERATE Alter_CURR_CUSTOMER,  
  
     SEND_VS_PAYOUT_SETTMENT,  
     SEND_VS_PAYOUT_CUSTOMER,  
     SEND_VS_PAYOUT_MARGIN,  
     currencyId,idType,session_id,  
     Payout_Currency_Code,roundby,  
     @updated_ts updated_ts,@updated_by updated_by  
     from temp_forex_exchange where   
   session_id=@session_id   
   order by exType,receiveCountry,sender  
  
end  
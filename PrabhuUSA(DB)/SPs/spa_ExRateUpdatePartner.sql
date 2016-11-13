drop PROCEDURE [dbo].[spa_ExRateUpdatePartner] 
go 
CREATE PROCEDURE [dbo].[spa_ExRateUpdatePartner]                
@process_id  VARCHAR(max),      
@costExchangeID VARCHAR(max),                
@updated_by  VARCHAR(100)                
AS                
BEGIN                
 -- SET NOCOUNT ON added to prevent extra result sets from                
 -- interfering with SELECT statements.                
 SET NOCOUNT ON;                
 BEGIN TRY                     
   ----------   RETRIVING HOST ADDRESS,PIC DATABSE FROM STATIC TABLE ---------                
   DECLARE @HOST VARCHAR(50),@P_AGENTID VARCHAR(50),@PartnerAgentCode VARCHAR(50),@sql_agentCurrencyRate VARCHAR(MAX),@sql VARCHAR(MAX)                
 CREATE table #temp_agent(                
   agentid VARCHAR(50),                
   agent_cost FLOAT,                
   payout_country VARCHAR(100),      
   payout_agent varchar(100)  )    
           
 SET @sql='      
 select agentid,dollarRate,payout_country,payout_agent from (      
 SELECT agentid,dollarRate,r.receiveCountry payout_country,''NA'' payout_agent   
 FROM agentcurrencyrate r,temp_forex_exchange t      
  WHERE r.currencyid=t.currencyid and t.idtype=''c''     
  AND t.sno in ('+@costExchangeID+') and r.audit_process_id='''+@process_id+'''  
  AND t.session_id in('''+@process_id+''')       
  UNION ALL      
 SELECT agentid,dollarRate,r.receiveCountry payout_country,payout_agent_id payout_agent   
 FROM agentpayout_CurrencyRate r join temp_forex_exchange t      
  on r.currencyid=t.currencyid where  t.idtype=''p''  and r.audit_process_id='''+@process_id+'''  
  AND t.sno in ('+@costExchangeID+')     
  AND t.session_id in('''+@process_id+'''))l'      
  PRINT @sql     
  
 INSERT #temp_agent(agentid,agent_cost,payout_country,payout_agent)            
    EXEC(@sql)            
        
  DECLARE @check_agentid VARCHAR(50),@agent_cost FLOAT,@payout_country VARCHAR(100),@payout_agent varchar(100)             
            
   
 DECLARE AGENT_CUR CURSOR FORWARD_ONLY READ_ONLY FOR                
   
         
 SELECT t.agentid,t.agent_cost,t.payout_country,t.payout_agent FROM #temp_agent t   
 JOIN static_values sv ON t.agentid=sv.static_data AND sv.sno=200 AND sv.static_value='PRABHU MY'   
   where   t.payout_country <> 'Malaysia'    
 OPEN AGENT_CUR                
  FETCH NEXT FROM AGENT_CUR INTO @check_agentid,@agent_cost,@payout_country,@payout_agent           
   WHILE @@FETCH_STATUS = 0                
    BEGIN                
     SET @HOST = NULL                
     SELECT @HOST=additional_value,@P_AGENTID=static_data,@PartnerAgentCode=Description FROM static_values               
     WHERE SNO=200 and static_data=@check_agentid    
     IF @HOST IS NOT NULL                
     BEGIN                
      print(@payout_country)            
      SET @sql = @HOST + 'spa_PartnerExRateUpdate '+ CAST(@agent_cost AS VARCHAR(100))+','''+@payout_country+''',''P:'+@updated_by+''','''+@payout_agent+''','''+@PartnerAgentCode+''''    
      PRINT(@sql)               
      EXEC(@sql)                
     END               
     FETCH NEXT FROM AGENT_CUR INTO @check_agentid,@agent_cost,@payout_country,@payout_agent      
    END             
 CLOSE AGENT_CUR                
   DEALLOCATE AGENT_CUR            
               
 END TRY                                
 BEGIN CATCH               
  DECLARE @desc VARCHAR(1000)                                
  SET @desc='SQL Error found:  (' + ERROR_MESSAGE() + ')'              
  INSERT INTO [error_info]([ErrorNumber], [ErrorDesc], [Script], [ErrorScript], [QueryString], [ErrorCategory],                                
  [ErrorSource], [IP], [error_date])                                
  SELECT -1,@desc,'spa_ExRateUpdatePartner','SQL',@desc,'SQL','SP','',getdate()                                
  SELECT 'Error' status,'1050','Error!! while updating partner exchange rate.' msg                                
 END CATCH               
END       
  
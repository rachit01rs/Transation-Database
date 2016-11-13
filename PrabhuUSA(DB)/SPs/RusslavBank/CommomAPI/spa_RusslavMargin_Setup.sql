--spa_RusslavMargin_Setup 'c','Malaysia','Bangladesh','20100004','1000'            
            
CREATE PROCEDURE spa_RusslavMargin_Setup            
@flag CHAR,            
@send_country VARCHAR(50),            
@rCountry VARCHAR(50),            
@Send_Branch_ID VARCHAR(50),            
@total_collectAmt MONEY,            
@Payout_agentid VARCHAR(50)=NULL,        
@PaymentType VARCHAR(50)=NULL          
AS            
IF @flag='c' /* flag='c' i.e. collect*/             
BEGIN            
 if @total_collectAmt  is NULL  or @total_collectAmt=0              
  SET @total_collectAmt=1             
 DECLARE @send_AgentCode VARCHAR(50),        
   @ServiceCharge MONEY        
         
 SELECT @send_AgentCode=ad.agentcode         
  FROM agentdetail ad join agentbranchdetail abd         
 on ad.agentcode=abd.agentcode        
 WHERE abd.agent_branch_code=@Send_Branch_ID        
            
 if not exists( SELECT currencyid FROM             
       agentCurrencyRate acr with(NOLOCK)             
                WHERE acr.agentid=@send_AgentCode AND acr.receiveCountry=@rCountry            
      )            
 BEGIN            
  SELECT 'Error' msg,'ExRate/Service Charge not Defined for '+@rCountry+' !! Please Contact HeadOffice.' sts_msg          
  RETURN            
 END        
         
 /*-----------  get service charge ----------*/        
  create table #temp_charge(slab_id int,                              
  min_amount money,                              
  max_amount money,                              
  service_charge money,                              
  send_commission money,          
  paid_commission money                              
  )                              
  insert into #temp_charge(          
   slab_id,          
   min_amount,          
   max_amount,          
   service_charge,          
   send_commission,          
   paid_commission          
  )            
 exec spa_GetServiceCharge @send_AgentCode,@Payout_agentid,@total_collectAmt,@PaymentType,@Send_Branch_ID          
           
 SELECT @ServiceCharge= service_charge FROM #temp_charge         
         
/*-----------  get service charge ----------*/          
             
 DECLARE @cust_rate MONEY,            
   @payoutAmt MONEY,            
   @ex_Margin MONEY,            
   @ex_rate MONEY,            
   @sendCCY VARCHAR(5),            
   @PayoutCCY VARCHAR(5)            
             
 SELECT @cust_rate=ar.customer_rate,            
     @ex_Margin=s.ex_rate_margin,            
     @ex_rate= ar.ExchangeRate,            
     @sendCCY = ar.CurrencyType,            
     @PayoutCCY = ar.receiveCType            
 FROM agentCurrencyRate ar JOIN API_Country_setup s             
     ON s.country=ar.receiveCountry            
 WHERE ar.agentid=@send_AgentCode AND s.country=@rCountry/* AND s.enable_send='y'*/            
             
 SET @payoutAmt = (isnull(@total_collectAmt,1)-isnull(@ServiceCharge,0))/(isnull(@ex_rate,1)+isnull(@ex_Margin,0))            
             
 SELECT 'Success' msg,@total_collectAmt collect_Amt,            
     @send_country send_country,            
     @sendCCY sendCCY,            
     round(@payoutAmt,2,2)/*-isnull(@ServiceCharge,0)*/ payout_AMT,            
     @rCountry payout_Country,            
     @PayoutCCY PayoutCCY,            
     @ex_rate Ex_Rate,        
     @ServiceCharge servicecharge,            
     isnull(@ex_Margin,0) ExRate_Margin,            
     (isnull(@cust_rate,1)-isnull(@ex_Margin,0)) customerRate            
END 
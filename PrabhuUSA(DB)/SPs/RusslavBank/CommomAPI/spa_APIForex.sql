                            
CREATE proc [dbo].[spa_APIForex]                            
   @Send_Branch_ID varchar(50),                            
   @API_PayoutCOuntry varchar(50),                            
   @API_payinRate float=null,                            
   @API_payoutRate float=null,                            
   @API_payoutCCY varchar(5)=null,                            
   @user_id varchar(50),                            
   @API_Partner_ID varchar(50),                            
   @API_payoutAmt money=null,                            
   @API_payinAmt money=null,                            
   @API_Cust_Rate money=null,                            
   @API_Service_Fee Money=null,                            
   @PartnerLocationID varchar(50)=null,                            
   @Calc_by char(1)=null, --calc_by = c : send ccy/ p:  payout ccy                            
   @PaymentType varchar(50)=NULL,                          
   @API_PartnerCode VARCHAR(50)=NULL ,                      
   @API_send_sCharge_Margin FLOAT=NULL,                    
   @Prabhu_CustRate FLOAT =NULL,                    
   @Prabhu_ExRate FLOAT=NULL ,                    
   @SendAmt MONEY =NULL,        
   @Service_Fee_setup FLOAT=NULL                         
as                            
---- Send Agent Detail                            
 DECLARE @payinCountry varchar(50),@Send_AgentID varchar(50),@payinCCY varchar(5)                            
                           
 select @payinCountry=a.country,                          
        @Send_AgentID=a.agentCode,                          
        @payinCCY=a.CurrencyType                             
 from agentDetail a join agentbranchdetail b                            
 on a.agentCode=b.agentCode                            
 where b.agent_branch_Code=@Send_Branch_ID                            
                            
 DECLARE  @HO_ExRate_Margin money,              
    @Customer_Rate money,              
    @Collect_Amount Money,              
    @Service_Fee MONEY,                            
    @Agent_ExRate_Margin money,              
    @Agent_ServiceFee_Margin MONEY        
                    
 ---Send Agent Margin in Local Currency                                       
 ------------############# new added  Service Charge                                  
--  create table #temp_charge(slab_id int,                                  
--  min_amount money,                                  
--  max_amount money,                                  
--  service_charge money,                                  
--  send_commission money,              
--  paid_commission money                                  
--  )             
--  /*-----------  get service charge ----------*/                                 
--  insert into #temp_charge(              
--   slab_id,              
--   min_amount,              
--   max_amount,              
--   service_charge,              
--   send_commission,              
--   paid_commission              
--  )                
-- exec spa_GetServiceCharge @Send_AgentID,@API_Partner_ID,@Collect_Amount,@PaymentType,@Send_Branch_ID              
--               
-- SELECT @Service_Fee_setup= service_charge FROM #temp_charge              
/*-----------  get service charge ----------*/              
 SELECT @HO_ExRate_Margin=isNull(acs.ex_rate_margin,0),                          
        @Agent_ExRate_Margin=isnull(Agent_ex_rate_margin,0),                      
        @Agent_ServiceFee_Margin=ISNULL(scharge_margin,0)                           
 FROM API_Country_setup acs                           
 WHERE acs.country=@API_PayoutCOuntry AND acs.API_Agent=@API_Partner_ID                             
                            
---- RusslavBank API Integration in Local CCY vs Payout CCY                            
declare @apiID  varchar(50)                            
select @apiID=static_data from static_values where sno=500 and additional_value=@API_PartnerCode                          
              
if @API_Partner_ID=isNull(@apiID,'-1')                            
begin                            
 -- select  isnull(cust_rate,exrate) cust_rate,DESTINATION_COUNTRY,isNULL(rate_margin,0) rate_margin                             
 -- into #prabhu_branch_wise                             
 -- from tbl_prabhurate a                               
 -- where a.branch_id=@Send_Branch_ID and DESTINATION_COUNTRY=@API_PayoutCOuntry                              
 --                               
 -- select  isnull(cust_rate,exrate) cust_rate,DESTINATION_COUNTRY,isNULL(rate_margin,0) rate_margin                             
 -- into #prabhu_agent_wise from tbl_prabhurate a                               
 -- where a.branch_id is null and DESTINATION_COUNTRY=@API_PayoutCOuntry                              
 --                               
 -- select @HO_ExRate_Margin=coalesce(b.rate_margin,a.rate_margin,0)                              
 -- from #prabhu_agent_wise a left outer join #prabhu_branch_wise b                              
 -- on a.DESTINATION_COUNTRY=b.DESTINATION_COUNTRY                            
                             
 set @Customer_Rate = @API_Cust_Rate-(@HO_ExRate_Margin+@Agent_ExRate_Margin)                          
       
                             
 if @Calc_by='p'                            
  begin                            
   set @API_payinAmt=@API_payoutAmt/@Customer_Rate                            
   set @Service_Fee=@API_Service_Fee-ISNULL(@Agent_ServiceFee_Margin,0)                            
   set @Collect_Amount=@API_payinAmt+@Service_Fee                            
  end                            
 else                            
  begin                            
   set @Collect_Amount=@API_payinAmt                            
   set @Service_Fee=(@API_Service_Fee*@Prabhu_ExRate)+ISNULL(@Service_Fee_setup,0)+ISNULL(@Agent_ServiceFee_Margin,0)                                
   set @API_payinAmt=isnull(@Collect_Amount,0) - (isnull(@API_Service_Fee,0)*isnull(@Prabhu_ExRate,0))                          
   set @API_payoutAmt=@API_payinAmt * @Customer_Rate                            
  END      
      
 select @PartnerLocationID=sno from Partner_Branch where Ext_Agent_Branch_code=@PartnerLocationID                            
                             
end                            
declare @process_id varchar(150)                            
set @process_id=dbo.FNAGetNewID()                            
                            
insert tbl_apiforex(                            
   [payinCountry] -- Send Country                            
           ,[payoutCountry] -- Payout Country                            
           ,API_payinRate_USD --- Send CCY Rate vs USD                            
           ,API_payoutRate_USD ---API Payout CCY Rate vs USD                            
           ,API_ServiceFee                            
           ,[payinCCY]                            
           ,[payoutCCY]                            
           ,[created_by]                            
           ,[created_ts]                            
           ,[payoutAgentID]   --- API Partner ID                                  
           ,[process_id]                            
           ,[payoutAmt] --- Total Payout AMT                            
           ,[payinAmt]  --- Transfer AMOUNT Send CCY                            
           ,[custRate]  --- Customer Rate                            
           ,[Send_Branch_ID] -- Send BRanch ID                            
           ,[Service_Fee] -- Service FEE to Customer                            
           ,[PartnerLocationID]                             
           ,Collect_Amount                            
           ,HO_ExRate_Margin -- Head Office Margin in Send CCY                            
           ,Agent_ExRate_Margin                            
           ,Agent_ServiceFee_Margin                            
           ,API_Cust_Rate --- API Customer Rate with Send CCY                           
           ,isProceed,                            
           PaymentType,                      
           API_send_sCharge_Margin,                    
           Exrate,                    
           SendAmt,    
           partner_settle_amt    -- settlement Amt[USD] i.e. dollar amt                           
           )                            
values(                        
  @payinCountry,                        
  @API_PayoutCOuntry,                        
  @API_payinRate,                        
  @API_payoutRate,                        
  @API_Service_Fee,                            
  @payinCCY,                        
  @API_payoutCCY,                            
  @user_id,                        
  GETDATE(),                        
  @API_Partner_ID,                        
  @process_id,                        
  @API_payoutAmt /*@API_payoutAmt*/,                        
  @Collect_Amount/*@API_payinAmt*/,                        
  @Prabhu_CustRate,                            
  @Send_Branch_ID,                        
  @Service_Fee,                        
  @PartnerLocationID,                        
  @API_payoutAmt/*@Collect_Amount*/,                            
  @HO_ExRate_Margin,                        
  @Agent_ExRate_Margin,                        
  isnull(@Agent_ServiceFee_Margin,0),                        
  @API_Cust_Rate,                        
  'n',                        
  @PaymentType,                      
  isnull(@API_Service_Fee,0)-isnull(@API_send_sCharge_Margin,0),                    
  @Prabhu_ExRate ,                    
  @SendAmt ,    
  ROUND((@Collect_Amount/@Prabhu_ExRate),2,2)              
)                            
                            
select @process_id Process_Id,                    
  @Collect_Amount Collect_Amount,--sendAMT in USD                         
  @API_payinAmt PayinAmount,     --sendAMT with sCharge in USD         
  @API_payoutCCY PayoutAmountCCY,                   
  @Service_Fee ServiceFee,       --sCharge With margin in SendCCY                    
  @Customer_Rate Customer_Rate,                      
  @API_payoutAmt PayoutAmount,   --PAYOUT amt in USD         
  @API_payoutCCY PayoutAmountCCY,                  
  @Prabhu_ExRate Exrate,          --exrate defined in system[1USD =x sendCCY]                   
  @SendAmt sendAmt,        
  @payinCCY sendCCY
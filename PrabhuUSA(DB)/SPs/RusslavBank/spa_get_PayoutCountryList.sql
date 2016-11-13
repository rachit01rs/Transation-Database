    
    
    
--spa_get_Partner_PayoutCountryList '20100003'    
--spa_get_PayoutCountryList '20100003'    
--spa_get_PayoutCountryList '20100006','Cash Pay'          
alter proc [dbo].[spa_get_PayoutCountryList]          
@send_agent_id varchar(50),          
@payment_type varchar(50)=NULL          
as        
--agentCurrencyRate     
--agent_branch_rate     
    
-- case when isnull(restrict_anywhere_payment,'n')='y' then 'n' else 'y' end isAnyWhere    
if @payment_type='Cash Pay'          
begin          
 SELECT Distinct Rec_Country svalue,Rec_Country,'y' isAnyWhere,    
'n' enable_bonus,0 bonus_value         
 FROM service_charge_setup s LEFT OUTER JOIN agentdetail b        
 ON s.agent_id=b.agentcode AND s.Rec_Country=b.Country       
-- join Partner_ServiceCharge psc on psc.Ext_AgentCountry<>s.Rec_Country      
  where agent_id=@send_agent_id          
 and (payment_Type is NULL or Payment_Type='Cash Pay')          
 and Rec_Country is not null       
--and Rec_Country not in (select Country_Name from partner_country_route)      
 order by Rec_Country      
end          
ELSE  
/*--------- for ALL agent ----------*/          
-- SELECT Distinct Rec_Country svalue,Rec_Country,'n' isAnyWhere,        
-- 'n' enable_bonus,0 bonus_value        
-- FROM service_charge_setup s LEFT OUTER JOIN agentdetail b        
-- ON s.agent_id=b.agentcode AND s.Rec_Country=b.Country        
-- --join Partner_ServiceCharge psc on psc.Ext_AgentCountry<>s.Rec_Country       
-- where agent_id=@send_agent_id          
-- and Rec_Country is not null          
-- --and Rec_Country not in (select Country_Name from partner_country_route)      
-- order by Rec_Country      
 /*--------- for RUSSLAV agent ONLY----------*/          
  
 SELECT Distinct acs.country svalue,acs.country,'n' isAnyWhere,        
   'n' enable_bonus,0 bonus_value        
 FROM API_country_setup acs WHERE acs.enable_send='y'   
 AND acs.API_Agent='20100103'  
          
 
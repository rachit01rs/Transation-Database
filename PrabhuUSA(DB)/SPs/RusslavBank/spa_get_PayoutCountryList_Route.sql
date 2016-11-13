--spa_get_PayoutCountryList_Route '20100000',NULL,'30101296'    
      
alter  PROCEDURE  spa_get_PayoutCountryList_Route        
@send_agent_id varchar(50)=null,              
@payment_type varchar(50)=NULL,          
@branch_id VARCHAR(50)=NULL ,  
@PartnerID varchar(50)=null            
AS        
      
CREATE TABLE #temp2(svalue VARCHAR(50),        
     Rec_Country VARCHAR(50),        
     isAnyWhere CHAR(1),        
     enable_bonus CHAR(1),        
     bonus_value MONEY        
     --BranchWise char(1)        
)        
INSERT INTO #temp2(svalue,Rec_Country,isAnyWhere,enable_bonus,bonus_value)        
      
exec spa_get_PayoutCountryList @send_agent_id,@payment_type ,@PartnerID         
      
INSERT INTO #temp2(svalue,Rec_Country)        
SELECT country,country FROM API_Country_setup   
WHERE isNULL(enable_send,'n')='y' and API_agent=@PartnerID  
      
SELECT DISTINCT UPPER(Rec_Country) Rec_Country FROM #temp2 ORDER BY Rec_Country 
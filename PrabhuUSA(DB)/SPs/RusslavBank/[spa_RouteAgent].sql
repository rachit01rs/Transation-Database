      
alter PROCEDURE [dbo].[spa_RouteAgent]      
 @country VARCHAR(50),      
 @type VARCHAR(50)      
AS      
      
CREATE TABLE #temp(CompanyName VARCHAR(100),agentCode VARCHAR(50))      
      
DECLARE @default_agent VARCHAR(100)      
SELECT @default_agent=A.companyName FROM agentDetail A WITH(NOLOCK) JOIN tbl_setup T  WITH(NOLOCK) ON A.agentCode=T.headoffice_agent_id      
      
IF @default_agent IS NULL      
SET @default_agent='Normal'      
/*------- FOR CENTRALISE SEND -enable this -------------*/   
--IF EXISTS(SELECT A.agentcode FROM agentDetail A JOIN agentbranchdetail B ON A.agentcode=B.agentCode WHERE A.Country=@country)      
--BEGIN      
-- INSERT INTO #temp(CompanyName,agentCode)      
-- VALUES(@default_agent,'1')      
--END      
      
IF @type='pay'      
BEGIN      
 INSERT INTO #temp(CompanyName,agentCode)      
 SELECT A.CompanyName,A.agentcode FROM API_Country_setup C JOIN agentDetail A ON C.API_agent=A.agentCode       
 AND C.enable_send='y'      
 JOIN tbl_integrated_agents I ON A.agentCode=I.agentcode WHERE C.country=@country      
and isNUll(i.isEnable,'y')='y'    
END      
IF @type='send'      
BEGIN      
 INSERT INTO #temp(CompanyName,agentCode)      
 SELECT A.CompanyName,A.agentcode FROM API_Country_setup C JOIN agentDetail A ON C.API_agent=A.agentCode       
 AND C.enable_send='y'       
 JOIN tbl_integrated_agents I ON A.agentCode=I.agentcode WHERE C.country=@country AND I.send_url IS NOT NULL      
 and isNUll(i.isEnable,'y')='y'    
END      
IF @type='cancel'      
BEGIN      
 INSERT INTO #temp(CompanyName,agentCode)      
 SELECT A.CompanyName,A.agentcode FROM API_Country_setup C JOIN agentDetail A ON C.API_agent=A.agentCode       
 AND C.enable_send='y'      
 JOIN tbl_integrated_agents I ON A.agentCode=I.agentcode WHERE C.country=@country      
 and isNUll(i.isEnable,'y')='y'    
END      
      
SELECT DISTINCT CompanyName,agentCode FROM #temp 



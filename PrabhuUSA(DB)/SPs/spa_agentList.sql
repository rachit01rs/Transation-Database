drop PROC [dbo].[spa_AgentList]
go
create PROC [dbo].[spa_AgentList]
@flag VARCHAR(50)=null,
@flag_active VARCHAR(50)=null
as
IF @flag='a'
BEGIN
	SELECT  a.agentCode ID,CompanyName [AgentName],Address,City,NULL State,Country,Phone1,
		CASE WHEN a.Accessed <> 'Granted' THEN 'NOT Active' ELSE 'Active' End Status
		FROM agentdetail a 
		WHERE CASE WHEN @flag_active IS NULL THEN '1' ELSE @flag_active END= CASE WHEN @flag_active IS NULL THEN '1' ELSE 
		CASE WHEN a.Accessed <> 'Granted' THEN 'NOT Active' ELSE 'Active' End 
		END AND agentCan NOT IN ('Fund Account')		
		ORDER BY a.country,a.companyName
END
IF @flag='b'
BEGIN
	SELECT  b.agent_branch_Code ID,CompanyName AgentName,Branch,b.Address,b.City,NULL State,a.COuntry,b.Telephone,
	CASE WHEN b.block_branch='y' OR a.Accessed <> 'Granted' THEN 'NOT Active' ELSE 'Active' End Status
	FROM agentdetail a JOIN dbo.agentbranchdetail b
	ON a.agentcode=b.agentcode
	WHERE CASE WHEN @flag_active IS NULL THEN '1' ELSE @flag_active END= CASE WHEN @flag_active IS NULL THEN '1' ELSE 
	CASE WHEN b.block_branch='y' OR a.Accessed <> 'Granted' THEN 'NOT Active' ELSE 'Active' End 
	END AND agentCan NOT IN ('Fund Account')	
	ORDER BY a.country,a.companyName,b.Branch
END


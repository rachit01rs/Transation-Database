/****** Object:  StoredProcedure [dbo].[spa_getAPIAgent_LoginInfo]    Script Date: 02/23/2015 18:50:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getAPIAgent_LoginInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getAPIAgent_LoginInfo]
GO

/****** Object:  StoredProcedure [dbo].[spa_getAPIAgent_LoginInfo]    Script Date: 02/23/2015 18:50:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_getAPIAgent_LoginInfo]
(
	@PARTER_CODE VARCHAR(50)
)
AS
BEGIN
	SELECT TOP 1 
		s.agentCode,
		s.agent_branch_code,
		a.CompanyName,
		s.API_user_login_id,
		s.API_user_password,
		s.api_accesscode,
		t.api_url_wsdl,
		s.API_authenticationAgentCode,
		s.user_login_id,
		ISNULL(sv.helpdesk_detail,'d') payoutRateType 
	FROM agentsub s WITH (NOLOCK) 
	JOIN agentDetail a ON a.agentCode=s.agentCode 
	JOIN tbl_integrated_agents t ON t.agentcode=a.agentcode 
	JOIN static_values sv ON sv.static_data=a.agentcode AND sv.sno=500 
	WHERE t.PartnerCode=@PARTER_CODE AND allow_integration_user='y' AND t.isEnable = 'y'
END






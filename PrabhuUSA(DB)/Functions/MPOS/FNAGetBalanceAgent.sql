  DROP FUNCTION FNAGetBalanceAgent
  go
   
CREATE FUNCTION [dbo].[FNAGetBalanceAgent] ( @user_id VARCHAR(50) )  
RETURNS INT  
AS   
    BEGIN   
        DECLARE @agentbalance AS INT  
        SELECT  @agentbalance = ISNULL(ad.CurrentBalance, 0)  FROM dbo.agentDetail ad  WITH ( NOLOCK )JOIN
			dbo.agentbranchdetail a  WITH ( NOLOCK )ON a.agentCode=ad.agentCode JOIN
			dbo.agentsub ag  WITH ( NOLOCK )ON ag.agentCode=a.agentCode AND ag.agent_branch_code=a.agent_branch_Code WHERE
			ag.agent_user_id=@user_id 
        --FROM    agent_detail WITH ( NOLOCK )  
        --WHERE   agent_id = @agent_id  
        SELECT  @agentbalance = @agentbalance - ISNULL(SUM(ISNULL(paging_no, 1)  
                                                 * ISNULL(s.rate, 2)), 0)  
        FROM  dbo.MPOS_sms_pending s WITH ( NOLOCK )  
                JOIN dbo.agentsub ag WITH ( NOLOCK ) ON s.Agent_User_Id= ag.agent_user_id 
                JOIN dbo.agentbranchdetail a  WITH ( NOLOCK )ON ag.agent_branch_code=a.agent_branch_Code
                JOIN dbo.agentDetail ad WITH (NOLOCK) ON a.agentCode=ad.agentCode                  
        WHERE   ag.agent_user_id = @user_id  
                AND s.status IS NULL  
        RETURN ISNULL(@agentbalance,0)  
    END  
  
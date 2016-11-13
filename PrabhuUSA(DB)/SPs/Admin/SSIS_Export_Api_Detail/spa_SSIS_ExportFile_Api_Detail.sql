IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_SSIS_ExportFile_Api_Detail]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_SSIS_ExportFile_Api_Detail]
GO
/*  
** Database    : PrabhuUSA  
** Object      : spa_SSIS_ExportFile_Api_Detail  
** Purpose     : 
** Author      : Bikash 
** Date        : 10th september 2013  
    
*/
--spa_SSIS_ExportFile_Api_Detail '12345','admin','Export_Api_Detail','Nepal','cash_payment',null
 
CREATE proc [dbo].[spa_SSIS_ExportFile_Api_Detail]    
    
    @process_id varchar(150),
	@admin varchar(50),
	@batch_id varchar(50),
	@Payout_Country varchar(100),   
    @PAYMENTTYPE varchar(50),
	@url_desc VARCHAR (1000) = NULL  ,
	@agentCode varchar(50)=null      
AS

BEGIN
SET NOCOUNT ON  
SET FMTONLY OFF
CREATE TABLE #temp_list ( LocationID VARCHAR(1000),
Agent VARCHAR(1000),
Branch VARCHAR(1000),
ADDRESS VARCHAR(3000),
City	VARCHAR(1000),
Currency VARCHAR(1000),
[BankID] VARCHAR(1000),
[Bank_BranchID] VARCHAR(1000),
[Branch_State] VARCHAR(1000)
)
if @PAYMENTTYPE='Cash_Payment' OR @PAYMENTTYPE='Home_Delivery'  --- Cash PickUp  
BEGIN    
INSERT #temp_list(LocationID,Agent,Branch,[ADDRESS],City,Currency,[BankID],[Bank_BranchID],Branch_State)    
select Agent_Branch_Code LocationID,a.CompanyName Agent,Branch,[dbo].FNARemoveSpecialChar(LTRIM(RTRIM(b.Address))) Address,    
b.City,a.CurrencyType Currency,NULL [BankID],NULL [Bank_BranchID],isNUll(state_branch,Branch_group) [Branch_State]    
 from agentbranchdetail b WITH (NOLOCK)   
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode     
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)     
and AgentType in ('ExtAgent','Send and Pay') and AgentCan in ('Both','Receiver','SenderReceiver')    
 and accessed='Granted' AND CASE WHEN @agentCode is NOT NULL THEN a.agentcode ELSE 'a' END =ISNULL(@agentCode,'a')     
--and case when @states is not null then isNUll(state_branch,Branch_group) else 'a' end =isNUll(@states,'a')    
--and case when @bank_name is not null then a.CompanyName else 'a' end  like isNUll(@bank_name +'%','a')    
order by a.CompanyName,b.branch    
    
end    
else if @PAYMENTTYPE='Cash_Payment_BDP'  --- Extern Type PickUp  
BEGIN    
INSERT #temp_list(LocationID,Agent,Branch,[ADDRESS],City,Currency,[BankID],[Bank_BranchID],Branch_State)    
select Agent_Branch_Code LocationID,a.CompanyName Agent,Branch,[dbo].FNARemoveSpecialChar(LTRIM(RTRIM(b.Address))) Address,    
b.City,a.CurrencyType Currency,NULL [BankID],NULL [Bank_BranchID],isNUll(state_branch,Branch_group) Branch_State    
 from agentbranchdetail b WITH (NOLOCK)   
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode    
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)     
and AgentType in ('ExtAgent','Send and Pay') and AgentCan in ('Both','Receiver','SenderReceiver')    
 and accessed='Granted' and b.Branch_Type='External'   AND CASE WHEN @agentCode is NOT NULL THEN a.agentcode ELSE 'a' END =ISNULL(@agentCode,'a') 
--and case when @states is not null then  isNUll(state_branch,Branch_group) else 'a' end =isNUll(@states,'a')    
 --and case when @bank_name is not null then a.CompanyName else 'a' end  like isNUll(@bank_name +'%','a')    
   
order by a.CompanyName,b.branch    
    
end    
else if @PAYMENTTYPE='Account_Deposit'  --- Account Deposit  
BEGIN     
INSERT #temp_list(LocationID,Agent,Branch,[ADDRESS],City,Currency,[BankID],[Bank_BranchID],Branch_State)    
select Agent_Branch_Code LocationID,    
case when a.Country='Nepal' then Branch_group else a.CompanyName end  Agent,    
Branch,[dbo].FNARemoveSpecialChar(LTRIM(RTRIM(b.Address))) Address,b.City,a.CurrencyType Currency,NULL [BankID],NULL [Bank_BranchID],isNUll(state_branch,Branch_group) Branch_State    
 from agentbranchdetail b WITH (NOLOCK)  
 join agentdetail a WITH (NOLOCK) on b.agentcode=a.agentcode    
 where a.Country=@Payout_Country and (b.block_branch='n' or b.block_branch is NUll)  and AgentCan in ('Both','None')    
 and accessed='Granted' and AgentType in ('ExtAgent','Send and Pay') and     
case when a.Country='Nepal' then Branch_type else 'AC Deposit' END IN ('AC Deposit','Both')  AND CASE WHEN @agentCode is NOT NULL THEN a.agentcode ELSE 'a' END =ISNULL(@agentCode,'a')  
--and case when @states is not null then isNUll(state_branch,Branch_group) else 'a' end =isNUll(@states,'a')    
--and case when @bank_name is not null then a.CompanyName else 'a' end  like isNUll(@bank_name +'%','a')    
order by a.CompanyName,b.branch_group,b.branch    
END     
--else if upper(@PAYMENTTYPE)='D'  --- Account Deposit to Other Bank  
--BEGIN     
--SELECT distinct agent_branch_Code,agentCode INTO #agent FROM agentbranchdetail WITH (NOLOCK) WHERE isHeadOffice='y'    
--INSERT #temp_list(code,LocationID,Agent,Branch,Address,City,Currency,BankID,Branch_State)    
--SELECT 0 Code,a.agent_branch_code LocationID, cb.Bank_name Agent,    
--NULL Branch,NULL Address,NULL City,ad.CurrencyType Currency,  
--isNULL(cb.external_bank_id,cb.commercial_id) external_bank_id,  
--  FROM commercial_bank cb WITH (NOLOCK) JOIN #agent a     
--ON cb.payout_agent_id=a.agentcode   
--JOIN agentDetail ad WITH (NOLOCK) ON ad.agentCode=cb.payout_agent_id    
--WHERE cb.country=@Payout_Country --AND external_bank_id IS NOT NULL     
--order by  cb.Bank_name    
--END     
else if @PAYMENTTYPE in ('NEFT','Account_Deposit_to_Other_Bank')  --- NEFT  
BEGIN     
-- if @bank_name is null and @states is null and @PAYMENTTYPE='N'  
-- begin  
--   set @return_value='Must Provide BANK_NAME or BANK_BRANCH_STATE'    
--   select '5002' Code,@AGENT_REFID AGENT_REFID,@return_value MESSAGE    
--   RETURN   
-- end 
 SELECT distinct agent_branch_Code,agentCode INTO #agent1 FROM agentbranchdetail WITH (NOLOCK) WHERE isHeadOffice='y'   
 AND Country=@Payout_Country and Block_branch='n' 

   
INSERT #temp_list(LocationID,Agent,Branch,[ADDRESS],City,Currency,[BankID],[Bank_BranchID],Branch_State)     
 SELECT a.agent_branch_code LocationID,cb.Bank_name Agent,    
 [dbo].FNARemoveSpecialChar(cbb.BranchName) Branch,[dbo].FNARemoveSpecialChar(cbb.[address]) Address,[dbo].FNARemoveSpecialChar(isnull(cbb.city,cbb.district)) City,ad.CurrencyType Currency,  
 cb.commercial_id BankID,cbb.sno Bank_BranchID,cbb.state Branch_State  
 FROM commercial_bank cb WITH (NOLOCK) JOIN #agent1 a     
 ON cb.payout_agent_id=a.agentcode   
 JOIN agentDetail ad WITH (NOLOCK) ON ad.agentCode=cb.payout_agent_id    
 left outer JOIN commercial_bank_branch cbb ON cb.Commercial_id=cbb.Commercial_id  
 WHERE cb.country=@Payout_Country  AND CASE WHEN @agentCode is NOT NULL THEN a.agentcode ELSE 'a' END =ISNULL(@agentCode,'a') --AND external_bank_id IS NOT NULL   
-- and case when @states is not null then cbb.state else 'a' end =isNUll(@states,'a')    
-- and case when @bank_name is not null then   
--   case when @PAYMENTTYPE='N' then cbb.bankName else ad.Companyname end   
--  else 'a' end  like isNUll(@bank_name +'%','a')    
 order by cb.Bank_name,cbb.BranchName   
END  
SELECT * FROM #temp_list 
declare @desc varchar(500),@totcount VARCHAR(100)
set @totcount =  @@ROWCOUNT

set @desc='Export file completed:Total records exported= '+ @totcount
	IF (@Payout_Country IS NOT NULL)      
		SET @desc=@desc +' | Country='+ @Payout_Country
	IF (@PAYMENTTYPE IS NOT NULL)      
		SET @desc=@desc +' | Payment Type='+ @PAYMENTTYPE

EXEC  spa_message_board 'u', @admin,
				NULL, @batch_id,
				@desc, 'c', @process_id,null,@url_desc  
  
	
END  
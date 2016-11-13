IF OBJECT_ID('[spa_LsLink_unpaid_transaction_V2]','P') IS NOT NULL
DROP PROCEDURE	[spa_LsLink_unpaid_transaction_V2]
GO
/*
** Database : PrabhuCash
** Object : spa_LsLink_unpaid_transaction_V2
**
** Purpose : list unpaid transactions
**
** Author:  Mukta Dhungana
** Date:    03/15/2013
**
** Modifications:
**  - created new proc for listing unpaid txns 
**  --Kanchan Dahal-23 may 2013	-Added payment type and its concern Filtration 
**  
**  Examples:
**  ** spa_LsLink_unpaid_transaction_V2 's','sad','Bank Transfer','12313','313','1222','3321'
** spa_LsLink_unpaid_transaction_V2 's','sad','Account Deposit to Other Bank','12313','313','1222','3321'
** --SELECT CompanyName,* FROM dbo.agentDetail WHERE CompanyName LIKE '%prabhu%'
*/

CREATE PROC [dbo].[spa_LsLink_unpaid_transaction_V2]
@flag char(1),  
@receiverName varchar(50)=null,  
@paymentType varchar(50)=NULL,
@agent_id varchar(50)=NULL,
@benBankId varchar(50)=NULL,
@BankBranchId varchar(50)=NULL---

AS
BEGIN
	DECLARE @sql VARCHAR(2000),@PFCL_agentid VARCHAR(50),@PMT_agentid VARCHAR(50),@PCS_agentid VARCHAR(50)
	SET @PFCL_agentid='20100064'
	SET @PMT_agentid='30106741' --branch id under PFCL
	SET @PCS_agentid='30106740' --branch id under PFCL
	IF @flag='s'
	BEGIN 
		set @sql='Select m.receiverCountry,m.rBankName,m.rBankBranch,m.RefNo,dbo.decryptDB(m.RefNo)controlNumber,m.receiverName,m.local_dot,m.paymentType,m.sendercountry,  
  m.request_for_new_account,m.paymentType,m.totalRoundamt,m.status,sa.agent_short_code,m.rBankacNo,m.ben_bank_name,m.rBankAcType,m.LOCAL_DOT    
		FROM moneysend  m WITH(NOLOCK) 
		LEFT OUTER JOIN agentdetail sa WITH(NOLOCK) on m.agentid=sa.agentcode
		LEFT OUTER JOIN agentbranchdetail ab WITH(NOLOCK) on m.ben_bank_id=ab.ext_branch_code
		where  status=''Un-Paid'' and receivercountry=''Nepal'' and  transStatus=''payment'' and trans_mode is null '
			IF  @paymentType IS NOT NULL
			BEGIN
				--set @sql= @sql+' AND paymentType='''+@paymentType+''''
				IF LOWER(@paymentType) in (LOWER('Bank Transfer'),LOWER('Account Deposit to Cooperative')) AND @BankBranchId IS NOT NULL
					set @sql= @sql+' AND ab.ext_branch_code='''+@BankBranchId+''''
				IF LOWER(@paymentType)=LOWER('Account Deposit to Other Bank') AND @agent_id IS NOT NULL 
					BEGIN
						set @sql= @sql+' AND ben_bank_id='''+@agent_id+''''
						IF @BankBranchId IS NOT NULL
							set @sql= @sql+' AND ben_bank_branch_id='''+@BankBranchId+''''
					END			
			END 

			 SET @sql= @sql+' AND expected_payoutagentid='''+@PFCL_agentid+'''' 
			 IF @agent_id=@PFCL_agentid and @paymentType='Bank Transfer'				
				SET @sql= @sql+' AND paymentType in (''Bank Transfer'')'
			 ELSE IF (@agent_id=@PMT_agentid)	and @paymentType='Account Deposit to Other Bank'
				SET @sql= @sql+' AND paymentType in (''Account Deposit to Other Bank'')' 
			 ELSE IF (@agent_id=@PCS_agentid) and @paymentType='Account Deposit to Cooperative'
			SET @sql= @sql+' AND paymentType in (''Account Deposit to Cooperative'')' 
			 ELSE
				set @sql= @sql+' AND paymentType='' ''' 
				
			 IF  @receiverName IS NOT NULL 
			 set @sql= @sql+' AND receiverName='''+@receiverName+'''' 
			set @sql= @sql+' ORDER BY ISNULL(m.ben_bank_name,m.rBankName) ASC,m.LOCAL_DOT DESC'	
	END
	IF @flag='t'
	BEGIN
		set @sql='Select sum(totalRoundAmt) totalAmt from moneysend  m  WITH(NOLOCK) 
		LEFT OUTER JOIN agentdetail sa  WITH(NOLOCK) on m.agentid=sa.agentcode
		where  status=''Un-Paid'' and receivercountry=''Nepal''  and transStatus=''payment'' and paymentType=''Cash Pay'' 
		and trans_mode is null '
		IF  @agent_id IS NOT NULL 
				 set @sql= @sql+' AND expected_payoutagentid='''+@agent_id+'''' 
		IF  @receiverName IS NOT NULL 
				 set @sql= @sql+' AND receiverName='''+@receiverName+'''' 

	END
  EXEC(@sql)
 PRINT(@sql)
END
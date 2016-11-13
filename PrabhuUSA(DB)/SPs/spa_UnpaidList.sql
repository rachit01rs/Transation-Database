DROP proc [dbo].[spa_UnpaidList]      
Go
--spa_UnpaidList NULL,'Account Deposit to Other Bank',NULL,NULL,'20100039',NULL,20100265  
--spa_UnpaidList b,'Account Deposit to Other Bank',NULL,'30112200','30100000,32400143'   
--spa_UnpaidList 'b','Bank Transfer','y','31800100','31800000','1861894, 1861911'  
CREATE proc [dbo].[spa_UnpaidList]  
 @flag char(1),  
 @paymentType varchar(50)=NULL,  
 @isHeadOffice char(1)=NULL,  
 @rBankId varchar(50)=NULL,  
 @expected_payoutagentid varchar(50)=NULL,  
 @tranno varchar(2000)=NULL,  
 @login_branch varchar(50)=NULL  
  
AS  
SET NOCOUNT ON
 DECLARE @sql varchar(8000),@checkHO varchar(500),@orderBy varchar(500)  
--IF @flag='b'  
--BEGIN  
   
 SET @orderBy=' order by local_dot,rbankname,rbankbranch,receiverName'  
  
SET @sql='select m.*,a.agent_short_code,case when ben_bank_name is not NULL then   
''Ext Bank:'' + ben_bank_name +'' Branch:''+ isNULL(rBankAcTYpe,'''') +'' ''+ rBankAcNo  
else rBankAcNo end BankInfo  
 from moneysend m join agentdetail a on   
 m.agentid=a.agentcode where status=''Un-Paid'' and transStatus=''Payment''  
 and trans_mode is null and expected_payoutagentid in('+@expected_payoutagentid+')  
 and'  
if @flag is NULL  
 set @sql=@sql +' paymentType='''+@paymentType+''''  
else  
begin  
--set @sql=@sql+ ' (paymentType='''+@paymentType+''' OR paymentType IN  
-- (SELECT static_value FROM static_values WHERE sno=7 and additional_value='''+@flag+''')) '  
 set @sql=@sql+ ' paymentType='''+@paymentType+''' '  
end  
IF @isHeadOffice <> 'y' or @isHeadOffice is NUll  
BEGIN  
 if @rBankId is not null  
 begin  
  SET @sql=@sql + ' and rBankId='''+@rBankId+''''  
 end  
 else  
 begin  
  SET @sql=@sql + ' and (rBankId in (select reg_branch_id from agent_regional_branch  
where agent_branch_code='''+@login_branch+''') or rBankId='''+@login_branch+''' )'  
 end  
END   
  
  
IF @tranno IS NOT NULL  
BEGIN  
 SET @tranno=replace(@tranno,', ',',')  
 SET @sql=@sql+' and tranno in ('+ cast(@tranno AS varchar(2000)) +')'  
END  
SET @sql=@sql + @orderBy  
PRINT (@sql)  
  
EXEC(@sql)  
  
-- order by local_dot,rbankname,rbankbranch,receiverName'    
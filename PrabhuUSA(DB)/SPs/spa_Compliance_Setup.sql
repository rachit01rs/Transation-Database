--spa_Compliance_Setup 'a',null,'United Kingdom',NULL,NULL,'n','n',NULL,NULL,'n','n',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n','n','n',NULL,NULL,NULL,NULL,'admin','n',NULL  
/**
DATE : 2011.Aug.24 Wed
*/
IF OBJECT_ID('spa_Compliance_Setup','P') IS NOT NULL
DROP PROCEDURE spa_Compliance_Setup
GO
create PROCEDURE [dbo].[spa_Compliance_Setup]    
@flag CHAR(1)=NULL,    
@sno VARCHAR(200)=NULL,    
@countryname VARCHAR(200)=NULL,    
@max_txn_amt VARCHAR(200)=NULL,    
@max_txn_Days VARCHAR(200)=NULL,    
@CP_amt_sender CHAR(1)=NULL,    
@CP_amt_beneficiary CHAR(1)=NULL,    
@max_txn_no VARCHAR(200)=NULL,    
@max_txn_nos_days VARCHAR(200)=NULL,    
@CP_no_sender CHAR(1)=NULL,    
@CP_no_beneficiary CHAR(1)=NULL,    
@max_app_branch_limit VARCHAR(200)=NULL,    
@CP_txn_exceed_amt VARCHAR(200)=NULL,    
@check_dup1 VARCHAR(200)=NULL,    
@check_dup2 VARCHAR(200)=NULL,    
@check_dup3 VARCHAR(200)=NULL,    
@check_dup4 VARCHAR(200)=NULL,    
@check_dup5 VARCHAR(200)=NULL,    
@hold_cp_cash_txn_date_notsame CHAR(1)=NULL,    
@Ofac_enabled CHAR(1)=NULL,    
@disable_edit_remitter_info CHAR(1)=NULL,    
@max_po_amt_cash VARCHAR(200)=NULL,    
@max_po_amt_deposit VARCHAR(200)=NULL,    
@CP_hold_po_cash VARCHAR(200)=NULL,    
@CP_hold_po_deposit VARCHAR(200)=NULL,    
@create_by VARCHAR(200)=NULL,    
@updated_by VARCHAR(200)=NULL,    
@sender_nativeCountry VARCHAR(200)=NULL ,  
@require_security varchar(50)=NULL,  
@nos_of_branch_hold int=NULL,    
@nos_of_branch_day int=NULL   
    
AS    
SET NOCOUNT ON;    
    
DECLARE @customer_check_by VARCHAR(200)    
SET @customer_check_by='ID'    
    
IF @countryname IS NULL    
  SET @countryname='Default'    
  
IF @flag='s'    
BEGIN    
 SELECT     sno    
     ,CountryName    
     ,Block_Customer_Check_By    
     ,Block_Max_TXN_AMT    
     ,Block_Max_TXN_AMT_Days    
     ,Block_CP_AMT_Sender    
     ,Block_CP_AMT_Beneficiary    
     ,Block_Max_TXN_No    
     ,Block_Max_Txn_Nos_days    
     ,Block_CP_No_Sender    
     ,Block_CP_No_Beneficiary    
     ,Max_App_Branch_Limit    
     ,CP_If_TXN_Exceed_AMT    
     ,Check_Dup1    
     ,Check_Dup2    
     ,Check_Dup3    
     ,Check_Dup4    
     ,Check_Dup5    
     ,Hold_if_cash_date_ne_Txn_date    
     ,Ofac_Enabled    
     ,Disabled_Cust_info_Teller    
     ,Max_po_amt_cash    
     ,Max_po_amt_Deposit    
     ,CP_Hold_PO_Cash    
     ,CP_HOLD_PO_Deposit    
     ,Created_By    
     ,Created_ts    
     ,Updated_By    
     ,Updated_ts    
     ,sender_nativeCountry_beneficiary_country_notsame  
  ,require_security  
  ,nos_of_branch_hold  
  ,nos_of_branch_day  
 FROM Compliance_Setup    
 WHERE sno LIKE CASE WHEN @sno IS NOT NULL THEN @sno    
                        ELSE '%'    
       END    
  ORDER BY CountryName ASC    
END    
ELSE IF @flag='i'    
BEGIN    
 IF NOT EXISTS(SELECT 'x' FROM Compliance_Setup WHERE CountryName=@countryname)    
 BEGIN    
  INSERT INTO dbo.Compliance_Setup (    
           CountryName,     
           Block_Customer_Check_By,     
           Block_Max_TXN_AMT,     
           Block_Max_TXN_AMT_Days,     
           Block_CP_AMT_Sender,     
           Block_CP_AMT_Beneficiary,     
           Block_Max_TXN_No,     
           Block_Max_Txn_Nos_days,     
           Block_CP_No_Sender,     
           Block_CP_No_Beneficiary,     
           Max_App_Branch_Limit,     
           CP_If_TXN_Exceed_AMT,     
           Check_Dup1,     
           Check_Dup2,     
           Check_Dup3,     
           Check_Dup4,     
           Check_Dup5,     
           Hold_if_cash_date_ne_Txn_date,     
           Ofac_Enabled,     
           Disabled_Cust_info_Teller,     
           Max_po_amt_cash,     
           Max_po_amt_Deposit,     
           CP_Hold_PO_Cash,     
           CP_HOLD_PO_Deposit,     
           Created_By,     
           Created_ts,    
           sender_nativeCountry_beneficiary_country_notsame ,  
     require_security,  
     nos_of_branch_hold ,nos_of_branch_day  
           )    
       VALUES (    
           @countryname,    
           @customer_check_by,    
           @max_txn_amt,     
           @max_txn_Days,     
           @CP_amt_sender,     
           @CP_amt_beneficiary,     
           @max_txn_no,    
           @max_txn_nos_days,    
           @CP_no_sender,    
           @CP_no_beneficiary,    
           @max_app_branch_limit,     
           @CP_txn_exceed_amt,     
           @check_dup1,    
           @check_dup2,    
           @check_dup3,    
           @check_dup4,     
           @check_dup5,    
           @hold_cp_cash_txn_date_notsame,    
           @Ofac_enabled,    
           @disable_edit_remitter_info,    
           @max_po_amt_cash,    
           @max_po_amt_deposit,    
           @CP_hold_po_cash,    
           @CP_hold_po_deposit,    
           @create_by,    
           getdate(),    
           @sender_nativeCountry ,  
     @require_security,  
     @nos_of_branch_hold,  
     @nos_of_branch_day  
        )    
   SELECT 'SUCCESS' STATUS, 'Successfully inserted. ' MSG    
  END    
  ELSE    
  BEGIN    
   SELECT 'ERROR' STATUS, 'Same country can''t be defined again. ' MSG    
  END     
END    
ELSE IF @flag='d'    
BEGIN    
 DELETE FROM Compliance_Setup    
  WHERE sno=@sno    
END    
ELSE IF @flag='u'    
BEGIN    
 IF NOT EXISTS(SELECT 'x' FROM Compliance_Setup WHERE CountryName=@countryname AND sno<>@sno)    
 BEGIN    
   UPDATE Compliance_Setup    
      SET countryname=@countryname,    
     Block_Customer_Check_By=@customer_check_by,    
     Block_Max_TXN_AMT=@max_txn_amt,     
     Block_Max_TXN_AMT_Days=@max_txn_Days,     
     Block_CP_AMT_Sender=@CP_amt_sender,     
     Block_CP_AMT_Beneficiary=@CP_amt_beneficiary,     
     Block_Max_TXN_No=@max_txn_no,     
     Block_Max_Txn_Nos_days=@max_txn_nos_days,    
     Block_CP_No_Sender=@CP_no_sender,    
     Block_CP_No_Beneficiary=@CP_no_beneficiary,    
     Max_App_Branch_Limit=@max_app_branch_limit,     
     CP_If_TXN_Exceed_AMT=@CP_txn_exceed_amt,     
     Check_Dup1=@check_dup1,    
     Check_Dup2=@check_dup2,    
     Check_Dup3=@check_dup3,    
     Check_Dup4=@check_dup4,     
     Check_Dup5=@check_dup5,    
     Hold_if_cash_date_ne_Txn_date=@hold_cp_cash_txn_date_notsame,    
     Ofac_Enabled=@Ofac_enabled,    
     Disabled_Cust_info_Teller=@disable_edit_remitter_info,    
     Max_po_amt_cash=@max_po_amt_cash,    
     Max_po_amt_Deposit=@max_po_amt_deposit,    
     CP_Hold_PO_Cash=@CP_hold_po_cash,    
     CP_HOLD_PO_Deposit=@CP_hold_po_deposit,    
     Updated_By=@updated_by,    
     UPdated_ts= getdate(),    
     sender_nativeCountry_beneficiary_country_notsame=@sender_nativeCountry  ,  
  require_security=@require_security,  
  nos_of_branch_hold=@nos_of_branch_hold  
  ,nos_of_branch_day=@nos_of_branch_day  
    WHERE  sno=@sno    
     
   SELECT 'SUCCESS' STATUS, 'Successfully updated. ' MSG    
  END    
  ELSE    
  BEGIN    
   SELECT 'ERROR' STATUS, 'Same country can''t be defined again. ' MSG    
  END    
END    
ELSE IF @flag='a'  
BEGIN  
if exists(select sno from compliance_setup where countryname=@countryname)  
SELECT     sno    
     ,CountryName    
     ,Block_Customer_Check_By    
     ,Block_Max_TXN_AMT    
     ,Block_Max_TXN_AMT_Days    
     ,Block_CP_AMT_Sender    
     ,Block_CP_AMT_Beneficiary    
     ,Block_Max_TXN_No    
     ,Block_Max_Txn_Nos_days    
     ,Block_CP_No_Sender    
     ,Block_CP_No_Beneficiary    
     ,Max_App_Branch_Limit    
     ,CP_If_TXN_Exceed_AMT    
     ,Check_Dup1    
     ,Check_Dup2    
     ,Check_Dup3    
     ,Check_Dup4    
     ,Check_Dup5    
     ,Hold_if_cash_date_ne_Txn_date    
     ,Ofac_Enabled    
     ,Disabled_Cust_info_Teller    
     ,Max_po_amt_cash    
     ,Max_po_amt_Deposit    
     ,CP_Hold_PO_Cash    
     ,CP_HOLD_PO_Deposit    
     ,Created_By    
     ,Created_ts    
     ,Updated_By    
     ,Updated_ts    
     ,sender_nativeCountry_beneficiary_country_notsame  
  ,require_security,  
  nos_of_branch_hold ,nos_of_branch_day  
 FROM Compliance_Setup    
 WHERE CountryName=@CountryName  
else  
SELECT     sno    
     ,CountryName    
     ,Block_Customer_Check_By    
     ,Block_Max_TXN_AMT    
     ,Block_Max_TXN_AMT_Days    
     ,Block_CP_AMT_Sender    
     ,Block_CP_AMT_Beneficiary    
     ,Block_Max_TXN_No    
     ,Block_Max_Txn_Nos_days    
     ,Block_CP_No_Sender    
     ,Block_CP_No_Beneficiary    
     ,Max_App_Branch_Limit    
     ,CP_If_TXN_Exceed_AMT    
     ,Check_Dup1    
     ,Check_Dup2    
     ,Check_Dup3    
     ,Check_Dup4    
     ,Check_Dup5    
     ,Hold_if_cash_date_ne_Txn_date    
     ,Ofac_Enabled    
     ,Disabled_Cust_info_Teller    
     ,Max_po_amt_cash    
     ,Max_po_amt_Deposit    
     ,CP_Hold_PO_Cash    
     ,CP_HOLD_PO_Deposit    
     ,Created_By    
     ,Created_ts    
     ,Updated_By    
     ,Updated_ts    
     ,sender_nativeCountry_beneficiary_country_notsame  
  ,require_security,  
  nos_of_branch_hold ,nos_of_branch_day  
 FROM Compliance_Setup    
 WHERE CountryName='Default'  
END
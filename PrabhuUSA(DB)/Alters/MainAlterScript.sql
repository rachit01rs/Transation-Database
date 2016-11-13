/* 
** This script alters the column/s in the table/s if the column is available. 
** Execute 'CREATE SCRIPT' Before Executing this script.

** Purpose : Script to alter table columns (Drop Columns, Add Columns)
** Author:  Hari Saran Manandhar
** Date:    01/20/2004
**
** Modifications:
** 
*/
---------------------------------------------------------------------Drop Columns------------------------------------------------------------------
--------------------customerreceiverdetail-------------------------
--IF COL_LENGTH('customerreceiverdetail','paymentmode') IS NOT NULL 				ALTER TABLE customerreceiverdetail DROP COLUMN paymentmode
--IF COL_LENGTH('customerreceiverdetail','receivingbank') IS NOT NULL 			ALTER TABLE customerreceiverdetail DROP COLUMN receivingbank
--IF COL_LENGTH('customerreceiverdetail','bankbranch') IS NOT NULL 				ALTER TABLE customerreceiverdetail DROP COLUMN bankbranch
--IF COL_LENGTH('customerreceiverdetail','bank_name') IS NOT NULL 				ALTER TABLE customerreceiverdetail DROP COLUMN bank_name
--IF COL_LENGTH('customerreceiverdetail','branch_country') IS NOT NULL 			ALTER TABLE customerreceiverdetail DROP COLUMN branch_country
--IF COL_LENGTH('customerreceiverdetail','branch_IFSC') IS NOT NULL 				ALTER TABLE customerreceiverdetail DROP COLUMN branch_IFSC
--IF COL_LENGTH('customerreceiverdetail','branch_MIRC') IS NOT NULL 				ALTER TABLE customerreceiverdetail DROP COLUMN branch_MIRC


-----------------------------------------------------------------------Alter Columns------------------------------------------------------------------
----------------------------Account_Book_Balance---------------------------
--IF COL_LENGTH('Account_Book_Balance','UnPaidAmt') IS NULL 						ALTER TABLE Account_Book_Balance ADD  UnPaidAmt money
--IF COL_LENGTH('Account_Book_Balance','UnPaidAmtUSD') IS NULL 					ALTER TABLE Account_Book_Balance ADD  UnPaidAmtUSD money

----------------------------API_Country_setup---------------------------
--IF COL_LENGTH('API_Country_setup','PartnerCode') IS NULL 		  			ALTER TABLE API_Country_setup ADD  PartnerCode VARCHAR(50) 			

----------------------------agentdetail-----------------------------------
--IF COL_LENGTH('agentdetail','img_name') IS NULL 							ALTER TABLE agentdetail ADD  img_name VARCHAR(50)


--------------------------agentbranchdetail-----------------------------------
--IF COL_LENGTH('agentbranchdetail','enable_fund_account') IS NULL 							ALTER TABLE agentbranchdetail ADD  enable_fund_account CHAR(1)
--IF COL_LENGTH('agentbranchdetail','fund_account_branch_code') IS NULL 						ALTER TABLE agentbranchdetail ADD  fund_account_branch_code VARCHAR(50)


----------------------------agent_function-------------------
--IF COL_LENGTH('agent_function','update_ts') IS NULL 			  			ALTER TABLE agent_function ADD  update_ts DATETIME 					
--IF COL_LENGTH('agent_function','update_by') IS NULL 			  			ALTER TABLE agent_function ADD  update_by VARCHAR(50) 				
--IF COL_LENGTH('agent_function','print_header_receipt') IS NULL 	  			ALTER TABLE agent_function ADD  print_header_receipt CHAR(1)  		

----------------------------agentsub--------------------------
--IF COL_LENGTH('agentsub','User_IP_Allowed') IS NULL 			  			ALTER TABLE agentsub ADD  User_IP_Allowed VARCHAR(100) 				
--IF COL_LENGTH('agentsub','API_user_login_id') IS NULL 			  			ALTER TABLE agentsub ADD  API_user_login_id VARCHAR(50) 			
--IF COL_LENGTH('agentsub','API_user_password') IS NULL 			  			ALTER TABLE agentsub ADD  API_user_password VARCHAR(50) 			
--IF COL_LENGTH('agentsub','API_AccessCode') IS NULL 				  			ALTER TABLE agentsub ADD  API_AccessCode VARCHAR(50) 				
--IF COL_LENGTH('agentsub','API_authenticationAgentCode') IS NULL   			ALTER TABLE agentsub ADD  API_authenticationAgentCode VARCHAR(50) 	
--IF COL_LENGTH('agentsub','User_IP_Allowed') IS NULL 			  			ALTER TABLE agentsub ADD  User_IP_Allowed VARCHAR(100) 		

----------------------------agentcurrencyrate---------------------
--IF COL_LENGTH('agentcurrencyrate','max_premium_receiver') IS NULL 			ALTER TABLE agentcurrencyrate ADD  max_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentcurrencyrate','min_premium_receiver') IS NULL 			ALTER TABLE agentcurrencyrate ADD  min_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentcurrencyrate','max_premium_sender') IS NULL 			ALTER TABLE agentcurrencyrate ADD  max_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentcurrencyrate','min_premium_sender') IS NULL 			ALTER TABLE agentcurrencyrate ADD  min_premium_sender MONEY NOT NULL default '0.00' 				

----------------------------agentpayout_currencyRate-------------------
--IF COL_LENGTH('agentpayout_currencyRate','max_premium_receiver') IS NULL 	ALTER TABLE agentpayout_currencyRate ADD  max_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate','min_premium_receiver') IS NULL 	ALTER TABLE agentpayout_currencyRate ADD  min_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate','max_premium_sender') IS NULL 		ALTER TABLE agentpayout_currencyRate ADD  max_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate','min_premium_sender') IS NULL 		ALTER TABLE agentpayout_currencyRate ADD  min_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate','max_premium_Customer') IS NULL 	ALTER TABLE agentpayout_currencyRate ADD  max_premium_Customer MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate','min_premium_Customer') IS NULL 	ALTER TABLE agentpayout_currencyRate ADD  min_premium_Customer MONEY NOT NULL default '0.00' 				

----------------------------agent_branch_rate------------------------
--IF COL_LENGTH('agent_branch_rate','max_premium_receiver') IS NULL 	ALTER TABLE agent_branch_rate ADD  max_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agent_branch_rate','min_premium_receiver') IS NULL 	ALTER TABLE agent_branch_rate ADD  min_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agent_branch_rate','max_premium_sender') IS NULL 	ALTER TABLE agent_branch_rate ADD  max_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agent_branch_rate','min_premium_sender') IS NULL 	ALTER TABLE agent_branch_rate ADD  min_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agent_branch_rate','max_premium_Customer') IS NULL 	ALTER TABLE agent_branch_rate ADD  max_premium_Customer MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agent_branch_rate','min_premium_Customer') IS NULL 	ALTER TABLE agent_branch_rate ADD  min_premium_Customer MONEY NOT NULL default '0.00' 				

----------------------------agentpayout_currencyRate_branch--------------
--IF COL_LENGTH('agentpayout_currencyRate_branch','max_premium_receiver') IS NULL 	ALTER TABLE agentpayout_currencyRate_branch ADD  max_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate_branch','min_premium_receiver') IS NULL 	ALTER TABLE agentpayout_currencyRate_branch ADD  min_premium_receiver MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate_branch','max_premium_sender') IS NULL 		ALTER TABLE agentpayout_currencyRate_branch ADD  max_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate_branch','min_premium_sender') IS NULL 		ALTER TABLE agentpayout_currencyRate_branch ADD  min_premium_sender MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate_branch','max_premium_Customer') IS NULL 	ALTER TABLE agentpayout_currencyRate_branch ADD  max_premium_Customer MONEY NOT NULL default '0.00' 				
--IF COL_LENGTH('agentpayout_currencyRate_branch','min_premium_Customer') IS NULL 	ALTER TABLE agentpayout_currencyRate_branch ADD  min_premium_Customer MONEY NOT NULL default '0.00' 

----------------------------agent_branch_rate_audit--------------------------
--IF COL_LENGTH('agent_branch_rate_audit','max_premium_Customer') IS NULL 			ALTER TABLE agent_branch_rate_audit ADD  max_premium_Customer money 
--IF COL_LENGTH('agent_branch_rate_audit','min_premium_Customer') IS NULL 			ALTER TABLE agent_branch_rate_audit ADD  min_premium_Customer money 

----------------------------agentCurrencyRate_audit----------------------------
--IF COL_LENGTH('agentCurrencyRate_audit','receiver_bank_rate') IS NULL 				ALTER TABLE agentCurrencyRate_audit ADD  receiver_bank_rate money 	
--IF COL_LENGTH('agentcurrencyrate_audit','max_premium_Customer') IS NULL 			ALTER TABLE agentcurrencyrate_audit ADD  max_premium_Customer MONEY 
--IF COL_LENGTH('agentcurrencyrate_audit','min_premium_Customer') IS NULL 			ALTER TABLE agentcurrencyrate_audit ADD  min_premium_Customer MONEY 				

----------------------------agentpayout_currencyRate_branch_audit-----------------
--IF COL_LENGTH('agentpayout_currencyRate_branch_audit','max_premium_Customer') IS NULL 		ALTER TABLE agentpayout_currencyRate_branch_audit ADD  max_premium_Customer money 	
--IF COL_LENGTH('agentpayout_currencyRate_branch_audit','min_premium_Customer') IS NULL 		ALTER TABLE agentpayout_currencyRate_branch_audit ADD  min_premium_Customer money


----------------------------agentpayout_CurrencyRate_audit-------------------------
--IF COL_LENGTH('agentpayout_CurrencyRate_audit','receiver_bank_rate') IS NULL 	ALTER TABLE agentpayout_CurrencyRate_audit ADD  receiver_bank_rate money
--IF COL_LENGTH('agentpayout_currencyRate_audit','max_premium_Customer') IS NULL 	ALTER TABLE agentpayout_currencyRate_audit ADD  max_premium_Customer MONEY 
--IF COL_LENGTH('agentpayout_currencyRate_audit','min_premium_Customer') IS NULL 	ALTER TABLE agentpayout_currencyRate_audit ADD  min_premium_Customer MONEY  

----------------------------agentbalance-----------------------------------
--IF COL_LENGTH('agentbalance','Subsiquency_invoice') IS NULL 		ALTER TABLE agentbalance ADD  Subsiquency_invoice varchar(50) 

--------------------------CustomerDetail----------------------------
--IF COL_LENGTH('customerDetail','user_login_id') IS NULL 		 	ALTER TABLE customerDetail ADD user_login_id VARCHAR(100) 			
--IF COL_LENGTH('customerDetail','sendersalary') IS NULL 			 	ALTER TABLE customerDetail ADD sendersalary VARCHAR(100) 			
--IF COL_LENGTH('customerDetail','allow_web_online') IS NULL 		 	ALTER TABLE customerdetail ADD allow_web_online CHAR(1) 			
--IF COL_LENGTH('customerDetail','sender_State') IS NULL 			 	ALTER TABLE customerdetail ADD sender_State VARCHAR(50) 			
--IF COL_LENGTH('customerDetail','password') IS NULL 				 	ALTER TABLE customerdetail ADD password VARCHAR(50) 				
--IF COL_LENGTH('customerDetail','SenderZipCode') IS NULL 		 	ALTER TABLE customerdetail ADD SenderZipCode VARCHAR(50) 			
--IF COL_LENGTH('customerDetail','lock_status') IS NULL 			 	ALTER TABLE customerdetail ADD lock_status CHAR(1) 					
--IF COL_LENGTH('customerDetail','lock_date') IS NULL 			 	ALTER TABLE customerdetail ADD lock_date DATETIME 					
--IF COL_LENGTH('customerDetail','last_login') IS NULL 			 	ALTER TABLE customerdetail ADD last_login DATETIME 					
--IF COL_LENGTH('customerDetail','active_session') IS NULL 		 	ALTER TABLE customerdetail ADD  active_session VARCHAR(100) 		
--IF COL_LENGTH('customerDetail','nos_min') IS NULL 				 	ALTER TABLE customerdetail ADD  nos_min VARCHAR(100) 				
--IF COL_LENGTH('customerDetail','ip_allowed_country') IS NULL 	 	ALTER TABLE customerdetail ADD  ip_allowed_country VARCHAR(100) 	
--IF COL_LENGTH('customerDetail','c2c_secure_pwd') IS NULL 		 	ALTER TABLE customerdetail ADD  c2c_secure_pwd VARCHAR(10) 			
--IF COL_LENGTH('customerDetail','otp_verifydate') IS NULL 		 	ALTER TABLE customerdetail ADD  otp_verifydate DATETIME 			
--IF COL_LENGTH('customerDetail','approve_by') IS NULL 			 	ALTER TABLE customerdetail ADD  approve_by VARCHAR(50) 				
--IF COL_LENGTH('customerDetail','approve_ts') IS NULL 			 	ALTER TABLE customerdetail ADD  approve_ts DATETIME 				
--IF COL_LENGTH('customerDetail','streetave') IS NULL 			 	ALTER TABLE customerdetail ADD  streetave VARCHAR(50)				
--IF COL_LENGTH('customerDetail','APTsuitno') IS NULL 			 	ALTER TABLE customerdetail ADD  APTsuitno VARCHAR(50) 				
--IF COL_LENGTH('customerDetail','id2_place_of_issue') IS NULL 	 	ALTER TABLE customerDetail ADD  id2_place_of_issue VARCHAR(50) 		
--IF COL_LENGTH('customerDetail','id2_issuedate') IS NULL 		 	ALTER TABLE customerDetail ADD  id2_issuedate DATETIME				
--IF COL_LENGTH('customerDetail','id2_validdate') IS NULL 		 	ALTER TABLE customerdetail ADD  id2_validdate DATETIME 				
--IF COL_LENGTH('customerDetail','id2_type_value') IS NULL 		 	ALTER TABLE customerdetail ADD  id2_type_value VARCHAR(50) 			
--IF COL_LENGTH('customerDetail','agentCode') IS NULL 			 	ALTER TABLE customerDetail ADD  agentCode VARCHAR(50) 				
--IF COL_LENGTH('customerDetail','branchCode') IS NULL 			 	ALTER TABLE customerDetail ADD  branchCode  VARCHAR(50) 			
--IF COL_LENGTH('customerDetail','create_by') IS NULL 			 	ALTER TABLE customerdetail ADD  create_by VARCHAR(50)  				
--IF COL_LENGTH('customerDetail','update_by') IS NULL 			 	ALTER TABLE customerdetail ADD  update_by VARCHAR(50) 				
--IF COL_LENGTH('customerDetail','senderState') IS NULL 			 	ALTER TABLE customerDetail ADD  senderState VARCHAR(50) 			
--IF COL_LENGTH('customerDetail','employmentType') IS NULL 		 	ALTER TABLE customerDetail ADD  employmentType  VARCHAR(50) 		
--IF COL_LENGTH('customerDetail','gender') IS NULL 				 	ALTER TABLE customerdetail ADD  gender VARCHAR(6)  					
--IF COL_LENGTH('customerDetail','id_place_of_issue') IS NULL 	 	ALTER TABLE customerdetail ADD  id_place_of_issue VARCHAR(50) 		
--IF COL_LENGTH('customerDetail','customerType') IS NULL 			 	ALTER TABLE customerdetail ADD  customerType VARCHAR(50) 
--IF COL_LENGTH('customerDetail','last_receiver_id') IS NULL 			ALTER TABLE customerdetail ADD  last_receiver_id INT
--IF COL_LENGTH('customerDetail','relation_other') IS NULL 			ALTER TABLE customerDetail ADD  relation_other VARCHAR(100) 
--IF COL_LENGTH('customerDetail','source_of_income_other') IS NULL 	ALTER TABLE customerDetail ADD  source_of_income_other VARCHAR(100)
--IF COL_LENGTH('customerDetail','sender_occupation_other') IS NULL 	ALTER TABLE customerDetail ADD  sender_occupation_other VARCHAR(100)		
--IF COL_LENGTH('customerDetail','KYC_completed') IS NULL 			ALTER TABLE customerDetail ADD  KYC_completed CHAR(1) 
--IF COL_LENGTH('customerDetail','KYC_Approve_date') IS NULL 			ALTER TABLE customerDetail ADD  KYC_Approve_date datetime
--IF COL_LENGTH('customerDetail','KYC_approve_by') IS NULL 			ALTER TABLE customerDetail ADD  KYC_approve_by VARCHAR(50)	
--IF COL_LENGTH('customerDetail','reason_for_remittance_other') IS NULL 			ALTER TABLE customerDetail ADD  reason_for_remittance_other VARCHAR(50)	
IF COL_LENGTH('customerDetail','Remark') IS NULL 			ALTER TABLE customerDetail ADD  Remark VARCHAR(1000)

-------------------------------customer_doc---------------------------------------------------------------------
--IF COL_LENGTH('customer_doc','upload_by') IS NULL 				 	ALTER TABLE customer_doc ADD upload_by VARCHAR(50) 			
--IF COL_LENGTH('customer_doc','upload_ts') IS NULL 				 	ALTER TABLE customer_doc ADD upload_ts DATETIME 			

----------------------------customerreceiverdetail--------------
--IF COL_LENGTH('customerreceiverdetail','paymentTYpe') IS NULL 				ALTER TABLE customerreceiverdetail ADD  paymentTYpe VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','commercial_bank_id') IS NULL 			ALTER TABLE customerreceiverdetail ADD  commercial_bank_id VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','commercial_bank_branch_id') IS NULL 	ALTER TABLE customerreceiverdetail ADD  commercial_bank_branch_id VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','payoutpartner') IS NULL 				ALTER TABLE customerreceiverdetail ADD  payoutpartner VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','payoutpartner_branch') IS NULL 			ALTER TABLE customerreceiverdetail ADD  payoutpartner_branch VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','commercial_branch_name') IS NULL 		ALTER TABLE customerreceiverdetail ADD  commercial_branch_name VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','api_partner_bank_name') IS NULL 		ALTER TABLE customerreceiverdetail ADD  api_partner_bank_name VARCHAR(50)
--IF COL_LENGTH('customerreceiverdetail','api_partner_branch_name') IS NULL 		ALTER TABLE customerreceiverdetail ADD  api_partner_branch_name VARCHAR(50)
IF COL_LENGTH('customerReceiverDetail','img_path') IS NULL 	 		ALTER TABLE customerReceiverDetail ADD  img_path VARCHAR(50)
----------------------------deposit_detail-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('deposit_detail','bank_serial_no') IS NULL 						ALTER TABLE deposit_detail ADD  bank_serial_no VARCHAR(50) 

----------------------------deposit_detail_audit-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('deposit_detail_audit','bank_serial_no') IS NULL 					ALTER TABLE deposit_detail_audit ADD  bank_serial_no VARCHAR(50)

----------------------------deposit_detail_arch1-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('deposit_detail_arch1','bank_serial_no') IS NULL 					ALTER TABLE deposit_detail_arch1 ADD  bank_serial_no VARCHAR(50)

----------------------------deposit_detail_hold-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('deposit_detail_hold','bank_serial_no') IS NULL 					ALTER TABLE deposit_detail_hold ADD  bank_serial_no VARCHAR(50)


----------------------------MONEYSEND-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('MONEYSEND','SENDERZIPCODE') IS NULL 				  		ALTER TABLE MONEYSEND ADD  SENDERZIPCODE VARCHAR(50) 				
--IF COL_LENGTH('MONEYSEND','API_ProcessID') IS NULL 				  		ALTER TABLE MONEYSEND ADD  API_ProcessID VARCHAR(150) 				
--IF COL_LENGTH('MONEYSEND','id_place_of_issue') IS NULL 			  		ALTER TABLE MONEYSEND ADD  id_place_of_issue VARCHAR(50) 			
--IF COL_LENGTH('MONEYSEND','senderState') IS NULL 				  		ALTER TABLE MONEYSEND ADD  senderState VARCHAR(50) 					
--IF COL_LENGTH('MONEYSEND','customer_type') IS NULL 				  		ALTER TABLE MONEYSEND ADD  customer_type VARCHAR(50) 				
--IF COL_LENGTH('MONEYSEND','employmentType') IS NULL 			  		ALTER TABLE MONEYSEND ADD  employmentType VARCHAR(50) 				
--IF COL_LENGTH('MONEYSEND','gender') IS NULL 					  		ALTER TABLE MONEYSEND ADD  gender VARCHAR(6) 						
--IF COL_LENGTH('MONEYSEND','customerType') IS NULL 				  		ALTER TABLE MONEYSEND ADD  customerType VARCHAR(50) 
--IF COL_LENGTH('MONEYSEND','acknowledge_by') IS NULL 					ALTER TABLE MONEYSEND ADD  acknowledge_by VARCHAR(50) 	
--IF COL_LENGTH('MONEYSEND','paid_beneficiary_dob') IS NULL 			  	ALTER TABLE MONEYSEND ADD  paid_beneficiary_dob DATETIME 				
--IF COL_LENGTH('MONEYSEND','paid_beneficiary_id_expire_date') IS NULL 	ALTER TABLE MONEYSEND ADD  paid_beneficiary_id_expire_date DATETIME					
--IF COL_LENGTH('MONEYSEND','Beneficiary_Occupation') IS NULL 			ALTER TABLE MONEYSEND ADD  Beneficiary_Occupation VARCHAR(50) 
--IF COL_LENGTH('MONEYSEND','transaction_type') IS NULL 					ALTER TABLE MONEYSEND ADD  transaction_type VARCHAR(50)
--IF COL_LENGTH('MONEYSEND','relation_other') IS NULL 					ALTER TABLE MONEYSEND ADD  relation_other VARCHAR(100) 
--IF COL_LENGTH('MONEYSEND','source_of_income_other') IS NULL 			ALTER TABLE MONEYSEND ADD  source_of_income_other VARCHAR(100)
--IF COL_LENGTH('MONEYSEND','sender_occupation_other') IS NULL 			ALTER TABLE MONEYSEND ADD  sender_occupation_other VARCHAR(100)
--IF COL_LENGTH('MONEYSEND','reason_for_remittance_other') IS NULL 		ALTER TABLE MONEYSEND ADD  reason_for_remittance_other VARCHAR(50)
--IF COL_LENGTH('moneySend','transStatusPrevious') IS NULL 		 ALTER TABLE moneySend ADD  transStatusPrevious VARCHAR(50) 
----------------------------moneysend_audit-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('moneysend_audit','process_id') IS NULL 				  		ALTER TABLE moneysend_audit ADD  process_id VARCHAR(100) 
--IF COL_LENGTH('moneysend_audit','HO_confirmDate') IS NULL 				  	ALTER TABLE moneysend_audit ADD  HO_confirmDate datetime
--IF COL_LENGTH('moneysend_audit','SSN_Card_ID') IS NULL 				  		ALTER TABLE moneysend_audit ADD  SSN_Card_ID VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','ID_type2') IS NULL 				  		ALTER TABLE moneysend_audit ADD  ID_type2 VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','customer_category_id') IS NULL 			ALTER TABLE moneysend_audit ADD  customer_category_id int 
--IF COL_LENGTH('moneysend_audit','payout_send_agent_id') IS NULL 			ALTER TABLE moneysend_audit ADD  payout_send_agent_id VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','chk_cancel_charge') IS NULL 				ALTER TABLE moneysend_audit ADD  chk_cancel_charge CHAR(1) 
--IF COL_LENGTH('moneysend_audit','cancel_reason') IS NULL 				  	ALTER TABLE moneysend_audit ADD  cancel_reason VARCHAR(150) 
--IF COL_LENGTH('moneysend_audit','txn_token_id') IS NULL 				  	ALTER TABLE moneysend_audit ADD  txn_token_id int 
--IF COL_LENGTH('moneysend_audit','chk_change_charge') IS NULL 				ALTER TABLE moneysend_audit ADD  chk_change_charge CHAR(1) 
--IF COL_LENGTH('moneysend_audit','refund_amount') IS NULL 				  	ALTER TABLE moneysend_audit ADD  refund_amount money 
--IF COL_LENGTH('moneysend_audit','Supicious_mark') IS NULL 				  	ALTER TABLE moneysend_audit ADD  Supicious_mark CHAR(1) 
--IF COL_LENGTH('moneysend_audit','Supicious_mark_by') IS NULL 				ALTER TABLE moneysend_audit ADD  Supicious_mark_by VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','Supicious_mark_date') IS NULL 				ALTER TABLE moneysend_audit ADD  Supicious_mark_date datetime
--IF COL_LENGTH('moneysend_audit','Supicious_mark_Remark') IS NULL 	  		ALTER TABLE moneysend_audit ADD  Supicious_mark_Remark VARCHAR(200) 
--IF COL_LENGTH('moneysend_audit','SSS_refno') IS NULL 						ALTER TABLE moneysend_audit ADD  SSS_refno VARCHAR(50)  
--IF COL_LENGTH('moneysend_audit','trace_number') IS NULL 					ALTER TABLE moneysend_audit ADD  trace_number VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','acknowledge_by') IS NULL 					ALTER TABLE moneysend_audit ADD  acknowledge_by VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','API_TokenID') IS NULL 				  		ALTER TABLE moneysend_audit ADD  API_TokenID VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','CustRate') IS NULL 				  		ALTER TABLE moneysend_audit ADD  CustRate float 
--IF COL_LENGTH('moneysend_audit','PayoutAmount') IS NULL 					ALTER TABLE moneysend_audit ADD  PayoutAmount money 
--IF COL_LENGTH('moneysend_audit','PayoutCCY') IS NULL 				  		ALTER TABLE moneysend_audit ADD  PayoutCCY  VARCHAR(3)  
--IF COL_LENGTH('moneysend_audit','senderState') IS NULL 				  		ALTER TABLE moneysend_audit ADD  senderState VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','customer_type') IS NULL 				  	ALTER TABLE moneysend_audit ADD  customer_type VARCHAR(50)  
--IF COL_LENGTH('moneysend_audit','customer_type_detail') IS NULL 			ALTER TABLE moneysend_audit ADD  customer_type_detail VARCHAR(100) 
--IF COL_LENGTH('moneysend_audit','employmentType') IS NULL 				  	ALTER TABLE moneysend_audit ADD  employmentType VARCHAR(50)  
--IF COL_LENGTH('moneysend_audit','gender') IS NULL 				  			ALTER TABLE moneysend_audit ADD  gender  VARCHAR(6)
--IF COL_LENGTH('moneysend_audit','customerType') IS NULL 					ALTER TABLE moneysend_audit ADD  customerType VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','id_place_of_issue') IS NULL 				ALTER TABLE moneysend_audit ADD  id_place_of_issue VARCHAR(50)
--IF COL_LENGTH('moneysend_audit','approve_notes') IS NULL 	  				ALTER TABLE moneysend_audit ADD  approve_notes VARCHAR(2000) 
--IF COL_LENGTH('moneysend_audit','relation_other') IS NULL 					ALTER TABLE moneysend_audit ADD  relation_other VARCHAR(100)  
--IF COL_LENGTH('moneysend_audit','source_of_income_other') IS NULL 			ALTER TABLE moneysend_audit ADD  source_of_income_other VARCHAR(100) 
--IF COL_LENGTH('moneysend_audit','sender_occupation_other') IS NULL 			ALTER TABLE moneysend_audit ADD  sender_occupation_other VARCHAR(100) 
--IF COL_LENGTH('moneysend_audit','paid_beneficiary_dob') IS NULL 	  		ALTER TABLE moneysend_audit ADD  paid_beneficiary_dob datetime
--IF COL_LENGTH('moneysend_audit','paid_beneficiary_id_expire_date') IS NULL 	ALTER TABLE moneysend_audit ADD  paid_beneficiary_id_expire_date datetime
--IF COL_LENGTH('moneysend_audit','Beneficiary_Occupation') IS NULL 			ALTER TABLE moneysend_audit ADD  Beneficiary_Occupation VARCHAR(100) 
--IF COL_LENGTH('moneysend_audit','ben_bank_branch_extid') IS NULL 			ALTER TABLE moneysend_audit ADD  ben_bank_branch_extid VARCHAR(50)
--IF COL_LENGTH('moneysend_audit','DeliveryOptionName') IS NULL 	  			ALTER TABLE moneysend_audit ADD  DeliveryOptionName VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','ReceiverState') IS NULL 					ALTER TABLE moneysend_audit ADD  ReceiverState VARCHAR(50)  
--IF COL_LENGTH('moneysend_audit','SenderDocIssueState') IS NULL 				ALTER TABLE moneysend_audit ADD  SenderDocIssueState VARCHAR(50) 
--IF COL_LENGTH('moneysend_audit','SenderDocIssueBy') IS NULL 				ALTER TABLE moneysend_audit ADD  SenderDocIssueBy VARCHAR(100) 
--IF COL_LENGTH('moneysend_audit','transStatusPrevious') IS NULL 		  ALTER TABLE moneysend_audit ADD  transStatusPrevious VARCHAR(50) 
-----------------Change Data Type------------------------------				
--IF COL_LENGTH('MONEYSEND','ExchangeRate') IS NOT NULL 		 				ALTER TABLE moneySend ALTER COLUMN ExchangeRate FLOAT
--IF COL_LENGTH('MONEYSEND','Today_Dollar_rate') IS NOT NULL 		 			ALTER TABLE moneySend ALTER COLUMN Today_Dollar_rate FLOAT
--IF COL_LENGTH('MONEYSEND','agent_dollar_rate') IS NOT NULL 		 			ALTER TABLE moneySend ALTER COLUMN agent_dollar_rate FLOAT
--IF COL_LENGTH('MONEYSEND','ho_dollar_rate') IS NOT NULL 		 			ALTER TABLE moneySend ALTER COLUMN ho_dollar_rate FLOAT
--IF COL_LENGTH('MONEYSEND','agent_settlement_rate') IS NOT NULL 				ALTER TABLE moneySend ALTER COLUMN agent_settlement_rate FLOAT

----------------------------moneySend_arch1-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('moneySend_arch1','relation_other') IS NULL 					ALTER TABLE moneySend_arch1 ADD  relation_other VARCHAR(100) 
--IF COL_LENGTH('moneySend_arch1','source_of_income_other') IS NULL 			ALTER TABLE moneySend_arch1 ADD  source_of_income_other VARCHAR(100)
--IF COL_LENGTH('moneySend_arch1','sender_occupation_other') IS NULL 			ALTER TABLE moneySend_arch1 ADD  sender_occupation_other VARCHAR(100)

--IF COL_LENGTH('moneySend_arch1','ExchangeRate') IS NOT NULL 		 		ALTER TABLE moneySend ALTER COLUMN ExchangeRate FLOAT
--IF COL_LENGTH('moneySend_arch1','Today_Dollar_rate') IS NOT NULL 		 	ALTER TABLE moneySend ALTER COLUMN Today_Dollar_rate FLOAT
--IF COL_LENGTH('moneySend_arch1','agent_dollar_rate') IS NOT NULL 		 	ALTER TABLE moneySend ALTER COLUMN agent_dollar_rate FLOAT
--IF COL_LENGTH('moneySend_arch1','ho_dollar_rate') IS NOT NULL 		 		ALTER TABLE moneySend ALTER COLUMN ho_dollar_rate FLOAT
--IF COL_LENGTH('moneySend_arch1','agent_settlement_rate') IS NOT NULL 		ALTER TABLE moneySend ALTER COLUMN agent_settlement_rate FLOAT
--IF COL_LENGTH('moneySend_arch1','transStatusPrevious') IS NULL 		  ALTER TABLE moneySend_arch1 ADD  transStatusPrevious VARCHAR(50) 
----------------------------cancelMoneySend-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('cancelMoneySend','relation_other') IS NULL 					ALTER TABLE cancelMoneySend ADD  relation_other VARCHAR(100) 
--IF COL_LENGTH('cancelMoneySend','source_of_income_other') IS NULL 			ALTER TABLE cancelMoneySend ADD  source_of_income_other VARCHAR(100)
--IF COL_LENGTH('cancelMoneySend','sender_occupation_other') IS NULL 			ALTER TABLE cancelMoneySend ADD  sender_occupation_other VARCHAR(100)

----------------------------MoneySend_HOld-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('MoneySend_HOld','relation_other') IS NULL 					ALTER TABLE MoneySend_HOld ADD  relation_other VARCHAR(100) 
--IF COL_LENGTH('MoneySend_HOld','source_of_income_other') IS NULL 			ALTER TABLE MoneySend_HOld ADD  source_of_income_other VARCHAR(100)
--IF COL_LENGTH('MoneySend_HOld','sender_occupation_other') IS NULL 			ALTER TABLE MoneySend_HOld ADD  sender_occupation_other VARCHAR(100)
				
----------------------------tbl_apiforex---------------------------------------------------------------------------------------------------------
--IF COL_LENGTH('tbl_apiforex','api_payoutamt') IS NULL 			 	ALTER TABLE tbl_apiforex ADD  api_payoutamt MONEY 					
--IF COL_LENGTH('tbl_apiforex','api_payin_amt') IS NULL 			 	ALTER TABLE tbl_apiforex ADD  api_payin_amt MONEY 					
--IF COL_LENGTH('tbl_apiforex','api_collect_amt') IS NULL 		 	ALTER TABLE tbl_apiforex ADD  api_collect_amt MONEY 				
--IF COL_LENGTH('tbl_apiforex','ExRate_Session_ID') IS NULL 		 	ALTER TABLE tbl_apiforex ADD  ExRate_Session_ID VARCHAR(50) 		
--IF COL_LENGTH('tbl_apiforex','calc_by') IS NULL 				 	ALTER TABLE tbl_apiforex ADD  calc_by VARCHAR(20) 					
--IF COL_LENGTH('tbl_apiforex','API_PartnerPaymentType') IS NULL 	 	ALTER TABLE tbl_apiforex ADD  API_PartnerPaymentType VARCHAR(50) 	
--IF COL_LENGTH('tbl_apiforex','TRANNO') IS NULL 					 	ALTER TABLE tbl_apiforex ADD  TRANNO INT 							

----------------------------tbl_integrated_agents-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('tbl_integrated_agents','send_url') IS NULL 		  	ALTER TABLE tbl_integrated_agents ADD  send_url VARCHAR(200) 		
--IF COL_LENGTH('tbl_integrated_agents','pay_url') IS NULL 		  	ALTER TABLE tbl_integrated_agents ADD  pay_url VARCHAR(200) 		
--IF COL_LENGTH('tbl_integrated_agents','cancel_url') IS NULL 	  	ALTER TABLE tbl_integrated_agents ADD  cancel_url VARCHAR(200) 	

----------------------------static_values-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('static_values','helpdesk_detail') IS NULL 		  			ALTER TABLE static_values ADD  helpdesk_detail VARCHAR(8000) 		


----------------------------Partner_Branch-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('Partner_Branch','Ext_Country') IS NULL 							ALTER TABLE Partner_Branch ADD  Ext_Country VARCHAR(50)
--IF COL_LENGTH('Partner_Branch','Ext_Currency') IS NULL 							ALTER TABLE Partner_Branch ADD  Ext_Currency VARCHAR(50)
--IF COL_LENGTH('Partner_Branch','Is_AnyWhere') IS NULL 							ALTER TABLE Partner_Branch ADD  Is_AnyWhere CHAR(1)

----------------------------soap_log-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('soap_log','resxml') IS NULL 										ALTER TABLE soap_log ADD  resxml TEXT

----------------------------soap_log_arch1-------------------------------------------------------------------------------------------------
--IF COL_LENGTH('soap_log_arch1','resxml') IS NULL 								ALTER TABLE soap_log_arch1 ADD  resxml TEXT


----------------------[moneysend_arch1_audit]-------------------------
--IF COL_LENGTH('[moneysend_arch1_audit]','transStatusPrevious') IS NULL 		  ALTER TABLE [moneysend_arch1_audit] ADD  transStatusPrevious VARCHAR(50) 

------------delMoneysend-------------
--IF COL_LENGTH('delMoneysend','transStatusPrevious') IS NULL 		  ALTER TABLE delMoneysend ADD  transStatusPrevious VARCHAR(50) 





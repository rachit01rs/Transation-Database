


/*  
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Created new module Online Transaction and submenus- Customer Online, UnConfirmed Online Transaction and UnRealeased Online Transaction
** Author      : Puja Ghaju 
** Date        : 20 September 2013  
*/ 


INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
  SELECT MAX(sno)+1  , -- sno - int
          'Customer Online' , -- function_name - varchar(50)
          'Customer Online' , -- Description - varchar(50)
          'customer_online/customer_list.asp' , -- link_file - varchar(250)
          'Online Transaction'  -- main_menu - varchar(100)
        FROM dbo.application_function
        
        
        UPDATE dbo.application_function SET link_file='customer_online/customer_list.asp' WHERE function_name='Customer Online'
 
 INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
  SELECT MAX(sno)+1  , -- sno - int
          'UnConfirmed Online Transaction' , -- function_name - varchar(50)
          'UnConfirmed Online Transaction' , -- Description - varchar(50)
          'customer_online/online_txn/unconfirm_txn.asp' , -- link_file - varchar(250)
          'Online Transaction'  -- main_menu - varchar(100)
        FROM dbo.application_function
        
 
 
 INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
  SELECT MAX(sno)+1  , -- sno - int
          'UnRealeased Online Transaction' , -- function_name - varchar(50)
          'UnRealeased Online Transaction' , -- Description - varchar(50)
          'customer_online/online_txn/unrelease_txn.asp' , -- link_file - varchar(250)
          'Online Transaction'  -- main_menu - varchar(100)
        FROM dbo.application_function
      
 
 /*         
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Created New Module Yearly OFAC/Compliance Report
** Author      : Sudaman Shrestha
** Date        : 27 August 2014  
 */
 INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
        SELECT MAX(sno)+1, 'Yearly OFAC/compliance Report', 'Yearly OFAC/compliance Report', 'OFAC_Suspected\ofac_yearly_report\OFAC_Report.asp', 'Reports' from application_function
  
  /*         
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Alter table application_function for BOC Hold TXN
** Author      : Suntia Shrestha
** Date        : 21st sep 2014  
 */  
 
INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
        SELECT MAX(sno)+1, 'BOC Hold TXN','BOC Hold TXN', 'API_BOC/holdtxn/holdtransAll.asp', 'Utilities' 
        from application_function

 
 
 
 
 /*         
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Created New Module  OFAC/Approve Agent Limit Exceed
** Author      : Paribesh Jung Karki
** Date        : 10 /10/ 2014  
 */
 
 INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select	MAX(sno)+1,
	'Agent Limit Exceed',
	'Approve Agent Limit Exceed',
	'OFAC_Suspected/approve_AgentLimit_Exceed.asp' ,
	'OFAC Detail' FROM application_function af
  
  
  
  
   /*         
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Created New Module  
** Author      : Paribesh Jung Karki
** Date        : 10 /10/ 2014  
 */
 
 INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select	MAX(sno)+1,
	'Search By Agent TXNID',
	'Search Transaction By Agent TXNID',
	'headoffice/findAPITransaction.asp' ,
	'Utilities' FROM application_function af
	
	
	   /*         
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Created New Module  
** Author      : Paribesh Jung Karki
** Date        : 27 /1/ 2015  
 */
 
 INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select	MAX(sno)+1,
	'Check Remittance Card No.',
	'Check Remittance Card Number',
	'pfcl_accountCheck/verify_remittancecard.asp' ,
	'Utilities' FROM application_function af
	
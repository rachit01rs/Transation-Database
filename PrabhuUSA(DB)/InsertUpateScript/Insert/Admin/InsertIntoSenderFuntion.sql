
INSERT INTO sender_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1,
	'Exchange Rate History(PBBL)',
	'Exchange Rate History(PBBL)',
	'exchange/reports/exchange_rate_history.asp',
	'Utilities'
FROM sender_function

--SELECT * FROM sender_function WHERE sno=373




   /*         
** Database    : PrabhuUSA
** Object      : TABLE sender_function
** Purpose     : Created New Module  
** Author      : Paribesh Jung Karki
** Date        : 10 /10/ 2014  
 */
 
 INSERT INTO sender_function
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
	'transaction/findAPITransaction.asp' ,
	'Utilities' FROM sender_function
	
	
	
	
   /*         
** Database    : PrabhuUSA
** Object      : TABLE sender_function
** Purpose     : Created New Module  
** Author      : Paribesh Jung Karki
** Date        : 10 /10/ 2014  
 */
 
 INSERT INTO sender_function
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
	'pfcl/verify_remittancecard.asp' ,
	'Utilities' FROM sender_function
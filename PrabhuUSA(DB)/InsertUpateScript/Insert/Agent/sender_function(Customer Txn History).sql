 /*         
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : insert Customer Txn History
** Author      : Sunita Shrestha
** Date        : 2nd Sept 2014  
 */

INSERT INTO sender_function
(
	sno,
	function_name,
	[Description],
	main_menu
	
)
SELECT MAX(sno)+1,
	'Customer Txn History',
	'Customer Txn History',
	'Function'
FROM sender_function sf

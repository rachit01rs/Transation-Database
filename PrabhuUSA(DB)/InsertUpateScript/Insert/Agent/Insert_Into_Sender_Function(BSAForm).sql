/*  
** Database    : PrabhuUSA  
** Object      : Table sender_function  
** Purpose     : Insert data (new menu) BSA Form to utilities panel of agent
** Author      : Bikash Giri
** Date        : 16th September 2013  
 
*/

INSERT INTO sender_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
	
)
SELECT MAX(sno)+1,
	'BSA Form',
	'BSA Form',
	'BSA_Form\searchBSAForm.asp',
	'Utilities'
FROM sender_function sf
/*  
** Database    : PrabhuUSA  
** Object      : Table sender_function  
** Purpose     : Insert data (new menu) LMVT Form to utilities panel of agent
** Author      : Bikash Giri
** Date        : 17th September 2013  
 
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
	'LMVT Form',
	'LMVT Form',
	'LMVT_Form\searchLMVTForm.asp',
	'Utilities'
FROM sender_function sf
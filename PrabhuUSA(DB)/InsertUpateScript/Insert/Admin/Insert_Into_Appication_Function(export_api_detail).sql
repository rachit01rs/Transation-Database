/*  
** Database    : PrabhuUSA  
** Object      : Table application_function 
** Purpose     : Insert data(new menu) to utilities panel
** Author      : Bikash Giri
** Date        : 10th september 2013  

*/

DELETE FROM application_function WHERE function_name='Export API detail' 

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1,
	'Export API detail',
	'Export API detail',
	'export_xls_agent\export_api_detail.asp',
	'Utilities'
FROM application_function af


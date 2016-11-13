/*  
** Database    : PrabhuUSA  
** Object      : Insert_Into_Sender_Function
** Purpose     : Insert sub menu Export Transaction(XLS).v2 into application_function table
** Author      : Bikash Giri
** Date        : 5 september 2013  

*/

	
	INSERT INTO sender_function
	(
		sno,
		function_name,
		[Description],
		link_file,
		main_menu
		
	)
	SELECT 
	MAX(sno)+1,
		'Export Transaction(XLS) V2',
		'Export Transaction(XLS) V2',
		'export_xls\export2excel_v2.asp',
		'Utilities'
	FROM sender_function sf
	
	
	
	
	
		

		
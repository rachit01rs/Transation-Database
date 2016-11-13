INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT 
	MAX(sno)+1,
	'Export TXN Soneri Bank',
	'Export TXN Soneri Bank',
	'export_xls_agent/export2excelSoneriBank.asp','Utilities' FROM application_function af
	
	--delete FROM application_function WHERE sno=400
	

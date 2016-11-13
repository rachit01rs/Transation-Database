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
	'Export TXN Bank Of Cylon',
	'Export TXN Bank Of Cylon',
	'export_xls_agent/export2excelCommercialBankOfCylon.asp','Utilities' FROM application_function af
	
	--delete FROM application_function WHERE sno=400
	

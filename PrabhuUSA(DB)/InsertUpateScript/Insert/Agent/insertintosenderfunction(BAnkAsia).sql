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
	'Export TXN Bank Asia',
	'Export TXN Bank Asia',
	'export_xls\export2excelBankAsia.asp','Utilities' FROM sender_function af
	
	--delete FROM sender_function WHERE sno=353
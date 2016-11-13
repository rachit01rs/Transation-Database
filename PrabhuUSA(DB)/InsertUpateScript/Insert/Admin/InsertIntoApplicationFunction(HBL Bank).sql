INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select
MAX(sno)+1,
	'Export HBL',
	'Export HBL',
	'export_xls_agent\export2excelHBL.asp',
	'Utilities'
FROM application_function af 

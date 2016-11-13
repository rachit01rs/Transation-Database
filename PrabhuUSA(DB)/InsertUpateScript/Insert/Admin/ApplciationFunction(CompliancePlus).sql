
INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select	MAX(sno)+1,
	'Export Compliance Plus',
	'Export Compliance Plus',
	'export_xls_agent\export2excelCompliancePlus.asp' ,
	'Utilities' FROM application_function af

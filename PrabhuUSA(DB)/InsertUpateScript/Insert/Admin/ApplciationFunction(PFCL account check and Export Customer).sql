INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select	MAX(sno)+1,
	'PFCL Account Check',
	'PFCL Account Check',
	'pfcl_accountCheck/verify_account.asp' ,
	'Utilities' FROM application_function af
	
INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
select	MAX(sno)+1,
	'Export Customer Detail',
	'Export Customer Detail',
	'export_xls_agent\export2excelCustomerDetail.asp' ,
	'Utilities' FROM application_function af

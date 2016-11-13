INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1,'Download Reconcile(PMT/PFCL)','Download Reconcile(PMT/PFCL)','export_xls/export2excel_Reconcile.asp','Utilities' FROM application_function af

SELECT * FROM application_function af
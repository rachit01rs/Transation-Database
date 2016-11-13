--SELECT * FROM sender_function


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
	'Ofac/Compliance Hold Report',
	'Ofac/Compliance Hold Report',
	'report/OfacComplianceHoldReport.asp',
'Reporting'
FROM sender_function sf


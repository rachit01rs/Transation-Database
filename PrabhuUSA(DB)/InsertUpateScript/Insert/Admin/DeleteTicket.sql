INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT 
MAX(sno+1),
'Allow to Delete Ticket',
'Allow to Delete Ticket',
NULL,
'function'
FROM application_function af

SELECT * FROM application_function af WHERE af.main_menu LIKE '%fun%' ORDER BY 1 DESC
 
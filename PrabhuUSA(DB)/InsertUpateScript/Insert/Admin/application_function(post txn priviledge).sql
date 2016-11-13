/*
** Database : PrabhuUsa
** Object :insert script
**
** Purpose : ----created insert script for dbo.application_function  --------- 
**
** Author: Paribesh Jung Karki	
** Date:    5th June,2014
** 
*/



INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	main_menu
)
SELECT 
	MAX(sno)+1,
	'Edit Post Txn ',
	'POST TRANSACTIONS can be edited with privilege',
	'function' FROM application_function
	
--	SELECT * FROM dbo.application_function ORDER BY 1 DESC
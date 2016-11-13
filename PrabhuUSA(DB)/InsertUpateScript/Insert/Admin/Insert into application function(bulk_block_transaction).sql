/*
** Database : PrabhuUsa
** Object :insert script 
**
** Purpose : ----created insert script for adding bulk block transanction by sendingagent and payout countrywise --------- 
**
** Author: Paribesh Jung Karki	
** Date:    15th June,2014
** 
*/



INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file ,
	main_menu
)
SELECT 
	MAX(sno)+1,
	'Bulk Block Transaction',
	'block transaction sendingagent/payout countrywise',
	'block_trns/bulk_blocked_list.asp',
	'Utilities' FROM application_function
	

SELECT * FROM sender_function sf WHERE sf.function_name LIKE '%v2%'

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
	'Send Transaction V2',
	'Send Transaction V2',
	'send_trans_v2/search_customer.asp',
	'Transaction'
 FROM sender_function sf
 
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
	'Hold Transaction V2',
	'Hold Transaction V2',
	'transaction/holdv2/holdtransAll.asp',
	'Transaction'
 FROM sender_function sf
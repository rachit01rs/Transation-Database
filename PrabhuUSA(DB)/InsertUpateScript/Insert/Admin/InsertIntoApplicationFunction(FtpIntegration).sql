INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu

)

SELECT 
	MAX(sno)+1,
	'Hold Transaction',
	'Hold Transaction',
	'FtpIntegration\hold_txn\hold_txn.asp',
	'FtpIntegration'
FROM application_function af 
	
	

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu

)

SELECT 
	MAX(sno)+1,
	'Transaction Log',
	'Transaction Log',
	'FtpIntegration\txn_log\txn_log.asp',
	'FtpIntegration'
FROM application_function af 	

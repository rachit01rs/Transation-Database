/*  
** Database    : PrabhuUSA  
** Object      : Table application_function 
** Purpose     : Insert data(new menu) to AirTimeSettings panel
** Author      : Bikash Giri
** Date        : 24th October 2013  

*/
INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1,
	'Exchange Rate',
	'Exchange Rate',
	'MobileTransfer\AirTimeSettings\ExchangeRateSetup\exchangerate_setup.asp',
	'AirtimeSetting'
FROM application_function af

/*  
** Database    : PrabhuUSA  
** Object      : Table application_function 
** Purpose     : update application_function (for dynamic super agent)
** Author      : Puja Ghaju 
** Date        : 07 September 2013  
** Modified
** Purpose     : Made script more detailed by adding function_name
** Date		   : 08 October 2013
*/

----SELECT * FROM application_function WHERE main_menu IN ('SReports','control panel')
UPDATE dbo.application_function SET Description='SPanel' WHERE main_menu ='SReports' AND function_name IN ('Summary Send Wise','Summary Paid Wise','Settlement Report','Statement of Account','Sender Agent Wise Report')
UPDATE dbo.application_function SET Description='SPanel' WHERE main_menu ='control panel' AND function_name IN ('ExRate History','ExRate Setup','ExRate All','Setup Service Charge','Service Charge History','Service Charge All','Cost Exchange','Update Premium Rate','ExRate Quick Search','ExRate All New')


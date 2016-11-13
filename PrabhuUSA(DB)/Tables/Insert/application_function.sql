INSERT INTO dbo.application_function (sno, function_name, Description, link_file, main_menu)
VALUES (299, 'Statistical Report', 'Statistical Report', 'Statistical_Report/statisticalReportPanel.asp', 'Reports')
GO
--SELECT * FROM dbo.application_function ORDER BY sno DESC
INSERT INTO application_function
(
sno	,
function_name	,
Description	,
link_file	,
main_menu	,
menu_type	
)
SELECT '287','Receiving Transaction Rules','Length Rules Setup','ComlianceSetup/EnhancementSetup/LengthRule/LengthRules_Detail.asp','OFAC Detail',NULL
UNION
SELECT '288','ID Compliance Logic Setup','Payment Rules Setup','ComlianceSetup/EnhancementSetup/PaymentRule/PaymentRules_Detail.asp','OFAC Detail',NULL
UNION
SELECT '289','Compliance Setup','Compliance Setup','ComlianceSetup/compliance_setup.asp','OFAC Detail',null	

--SELECT * FROM dbo.application_function ORDER BY sno DESC

INSERT INTO application_function
(
sno	,
function_name	,
Description	,
link_file	,
main_menu	,
menu_type	
)
SELECT '292','ExRate All New','ExRate All New','ExRateAll_New/show_all_exrate.asp','Control Panel',NULL

-- for report writer---

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1, 'Report List', 'Report List', 'report_writer/rptList.asp','Reports' FROM application_function

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1, 'Report Writer', 'Report Writer', 'report_writer/rptWriter.asp','Reports' FROM application_function

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1, 'Customer Category Report', 'Customer Category Report', 'report/Customer_Category/customerCategory.asp','Reports' FROM application_function


-- --Author :Amit Timalsina
--Purpose : adding submenu in utilities for Export NIB transaction
--date : 10th august, 2014	   
 -----------------------------------**********-------------------------------  

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1, 'Export NIB TXN', 'Export NIB TXN', 'export_xls_agent/export2excelNIB.asp','Utilities' FROM application_function

---------------------------------------------------------------------------------------------------------
--DATE: 02/24/2015
--PURPOSE: VIEW UNPAID REMMITANCE CARD TRANSACTION LIST 

INSERT INTO application_function
(
	sno,
	function_name,
	[Description],
	link_file,
	main_menu
)
SELECT MAX(sno)+1, 'Remittance Card Transactions', 'Remittance Card Transactions', 'rupiya_pay/search_txn.asp','Reports' 
FROM application_function
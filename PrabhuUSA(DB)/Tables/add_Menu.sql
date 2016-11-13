INSERT INTO application_function (sno,function_name,Description,Link_file,main_menu)
SELECT max(sno)+1,'Export Agent List','Export Agent List','export_xls_agent/export2excelAgentList.asp','Utilities'
FROM application_function

----For IMport/Export Log Report

INSERT INTO application_function (sno,function_name,Description,Link_file,main_menu)
SELECT max(sno)+1,'Import/Export File Log','Import/Export File Log','report/ImportExportFileLog/importExportLogRpt.asp','Reports'
FROM application_function
----end------------


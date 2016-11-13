INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Export Paid report','Export Paid report','export_xls_agent/export2excelPaidReport.asp',
'Utilities' FROM dbo.application_function

--SELECT * FROM dbo.application_function  WHERE function_name='Export Paid Cash report'


--UPDATE dbo.application_function SET function_name='Export Paid report',link_file='export_xls_agent/export2excelPaidReport.asp' WHERE sno=392
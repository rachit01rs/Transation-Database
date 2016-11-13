--SELECT * FROM dbo.sender_function WHERE function_name LIKE 'EXport%'

INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu )
SELECT MAX(sno)+1,'Export TXN Rupali Bank','Export TXN Rupali Bank','export_xls\export2excelRupaliBank.asp','Utilities' FROM dbo.sender_function
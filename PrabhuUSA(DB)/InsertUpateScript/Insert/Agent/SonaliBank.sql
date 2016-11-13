INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Export TXN Sonali Bank','Export TXN Sonali Bank','export_xls\export2excelSonaliBank.asp','Utilities' FROM dbo.sender_function



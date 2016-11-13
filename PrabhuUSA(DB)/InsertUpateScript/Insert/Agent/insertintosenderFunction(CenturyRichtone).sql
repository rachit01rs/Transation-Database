INSERT INTO dbo.sender_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT  MAX(sno)+1 , -- sno - int
          'Export TXN Century Richtone Ltd' , -- function_name - varchar(50)
          'Export TXN Century Richtone Ltd' , -- Description - varchar(50)
          'export_xls\export2excel_Century_Richtone_Ltd.asp' , -- link_file - varchar(250)
          'Utilities' 
        FROM dbo.application_function
        
        --SELECT * FROM dbo.sender_function WHERE link_file LIKE '%Century%'

/*  
** Database    : PrabhuUSA
** Object      : TABLE application_function
** Purpose     : Insert into application_function for PNB EXPORT 
** Author      : Sunita Shrestha
** Date        : 24th Novenber 2014
*/ 


INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
  SELECT MAX(sno)+1  , 
          'PNB Export' , 
          'PNB Export' , 
          'export_xls_agent/export2excelPNB.asp' , 
          'Utilities' 
        FROM dbo.application_function
        
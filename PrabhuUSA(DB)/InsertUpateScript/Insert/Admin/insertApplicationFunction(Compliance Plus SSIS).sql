INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1 , -- sno - int
          'Export Complaince Plus SSIS' , -- function_name - varchar(50)
          'Export Complaince Plus SSIS' , -- Description - varchar(50)
          'export_xls_agent/export2excelCompliancePlusSSIS.asp' , -- link_file - varchar(250)
          'Utilities' FROM dbo.application_function
          
          

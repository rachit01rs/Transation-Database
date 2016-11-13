INSERT INTO dbo.application_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'IP Trace Report','IP Trace Report','ip_trace_report/ip_trace_report.asp','Reports' FROM dbo.application_function


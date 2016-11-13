INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Hold Transaction V2','Hold Transaction V2','FtpIntegration/hold_txn_v2/hold_txn.asp','FtpIntegration' 
FROM dbo.application_function --WHERE main_menu LIKE 'FTP%'
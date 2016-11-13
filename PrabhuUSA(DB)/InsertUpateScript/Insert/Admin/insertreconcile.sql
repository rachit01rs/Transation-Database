INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Reconcile Transaction New','Reconcile Transaction New','reconsile_transaction_new/search_transaction.asp','Utilities' FROM dbo.application_function


SELECT *  FROM dbo.application_function WHERE sno=372
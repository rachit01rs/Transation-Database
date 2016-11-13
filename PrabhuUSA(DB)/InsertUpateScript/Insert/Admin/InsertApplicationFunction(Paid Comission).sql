INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )

SELECT MAX(sno)+1,'Update Paid Commission','Update Paid Commission','update_Paid_commission/Update_paid_commission.asp','Utilities'
 FROM dbo.application_function
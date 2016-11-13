--INSERT INTO dbo.application_function 
--        ( sno ,
--          function_name ,
--          Description ,
--          link_file ,
--          main_menu 
--        )
--SELECT MAX(sno)+1 , -- sno - int
--          'Provider Setup' , -- function_name - varchar(50)
--          'Provider Setup' , -- Description - varchar(50)
--          'MobileTransfer/AirTimeSettings/ProviderSetup/providersetup.asp' , -- link_file - varchar(250)
--          'AirtimeSetting' FROM dbo.application_function
          
--          INSERT INTO dbo.application_function 
--        ( sno ,
--          function_name ,
--          Description ,
--          link_file ,
--          main_menu 
--        )
--SELECT MAX(sno)+1 , -- sno - int
--          'Country Setup' , -- function_name - varchar(50)
--          'Country Setup' , -- Description - varchar(50)
--          'MobileTransfer/AirTimeSettings/CountrySetup/countrylist.asp' , -- link_file - varchar(250)
--          'AirtimeSetting' FROM dbo.application_function
          
--                    INSERT INTO dbo.application_function 
--        ( sno ,
--          function_name ,
--          Description ,
--          link_file ,
--          main_menu 
--        )
--SELECT MAX(sno)+1 , -- sno - int
--          'Operator Setup' , -- function_name - varchar(50)
--          'Operator Setup' , -- Description - varchar(50)
--          'MobileTransfer/AirTimeSettings/OperatorSetup/operatorlist.asp' , -- link_file - varchar(250)
--          'AirtimeSetting' FROM dbo.application_function
          
             INSERT INTO dbo.application_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1 , -- sno - int
          'Denomination Setup' , -- function_name - varchar(50)
          'Denomination Setup' , -- Description - varchar(50)
          'MobileTransfer/AirTimeSettings/DenominationSetup/denominationlist.asp' , -- link_file - varchar(250)
          'AirtimeSetting' FROM dbo.application_function
          
--                       INSERT INTO dbo.application_function 
--        ( sno ,
--          function_name ,
--          Description ,
--          link_file ,
--          main_menu 
--        )
--SELECT MAX(sno)+1 , -- sno - int
--          'Agent Country Setup' , -- function_name - varchar(50)
--          'Agent Country Setup' , -- Description - varchar(50)
--          'MobileTransfer/AirTimeSettings/AgentCountrySetUp/agent_country.asp' , -- link_file - varchar(250)
--          'AirtimeSetting' FROM dbo.application_function
          
          
          
--   INSERT INTO dbo.application_function 
--        ( sno ,
--          function_name ,
--          Description ,
--          link_file ,
--          main_menu 
--        )
--SELECT MAX(sno)+1 , -- sno - int
--          'Pending List' , -- function_name - varchar(50)
--          'Pending List' , -- Description - varchar(50)
--          'MobileTransfer/AirTimeSettings/PendingList/pending.asp' , -- link_file - varchar(250)
--          'AirtimeSetting' FROM dbo.application_function



        INSERT INTO dbo.application_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1 , -- sno - int
          'Airtime Report' , -- function_name - varchar(50)
          'Airtime Report' , -- Description - varchar(50)
          'MobileTransfer/AirTimeSettings/Report/BalanceTransfer_Search.asp' , -- link_file - varchar(250)
          'AirtimeSetting' FROM dbo.application_function
          
         --DELETE FROM dbo.application_function WHERE sno=379
         
         
                      INSERT INTO dbo.application_function 
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1 , -- sno - int
          'Denomination ALL' , -- function_name - varchar(50)
          'Denomination ALL' , -- Description - varchar(50)
          'MobileTransfer/AirTimeSettings/DenominationSetup/denominationlist_all.asp' , -- link_file - varchar(250)
          'AirtimeSetting' FROM dbo.application_function
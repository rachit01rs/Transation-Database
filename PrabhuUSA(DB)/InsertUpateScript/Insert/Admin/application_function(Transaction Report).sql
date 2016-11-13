

/*  
** Database    : PrabhuUSA  
** Object      : Table application_function 
** Purpose     : Insert into application_function
** Author      : Sunita	Shrestha
** Date        : 8th fev 2015  
modified       :
purpose        :
*/
INSERT INTO dbo.application_function
        ( sno ,
          function_name ,
          Description ,
          link_file ,
          main_menu 
        )
SELECT MAX(sno)+1,'Transaction Report','Transaction Report','Transaction/AgentWise.asp','Reports' FROM dbo.application_function


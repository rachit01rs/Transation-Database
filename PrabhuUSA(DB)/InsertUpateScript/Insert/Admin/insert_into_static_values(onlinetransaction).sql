
/*  
** Database    : PrabhuUSA
** Object      : TABLE static_values
** Purpose     : Added Online Transaction in table static_values
** Author      : Puja Ghaju 
** Date        : 20 September 2013  
*/ 

 
 
 INSERT INTO dbo.static_values
         ( sno ,
           static_value ,
           static_data ,
           Description ,
           additional_value 
         )
 VALUES  ( 101 , -- sno - int
           'Online Transaction' , -- static_value - varchar(100)
           'Online Transaction' , -- static_data - varchar(200)
           'Admin' , -- Description - varchar(100)
           'agent.gif'  -- additional_value - varchar(50)
         )       
        

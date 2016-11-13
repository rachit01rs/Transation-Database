
/*  
** Database    : PrabhuUSA  
** Object      : Table Static_values 
** Purpose     : Insert into static_values where sno=7
** Author      : Paribesh  Jung Karki 
** Date        : 16th Jan 2015
*/


--select * from static_values where sno=7

INSERT INTO [PrabhuUSA].[dbo].[static_values]
           ([sno]
           ,[static_value]
           ,[static_data]
           ,[Description]
           ,[additional_value])
     VALUES
           (7
           ,'Remittance Card'
           ,'Remittance Card'
           ,'n'
           ,'R'
			)
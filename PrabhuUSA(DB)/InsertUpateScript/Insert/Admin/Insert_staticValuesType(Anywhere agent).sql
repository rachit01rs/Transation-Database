--SELECT * FROM dbo.static_values_type

INSERT INTO dbo.static_values_type
        ( type_id ,
          type_name ,
          type_description ,
          static_type
        )
VALUES  ( 54 , -- type_id - int
          'Anywhere Agent' , -- type_name - varchar(200)
          'For Mapping of default  anywhere agent' , -- type_description - varchar(200)
          'e'  -- static_type - char(1)
        )
        
      --  SELECT * FROM dbo.static_values WHERE static_data
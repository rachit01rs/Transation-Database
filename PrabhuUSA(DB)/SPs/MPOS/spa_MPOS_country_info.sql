    
    
    
    
CREATE proc [dbo].[spa_MPOS_country_info]    
(    
@flag char(5),    
@country_name varchar(100)=NULL,    
@country_code varchar(10)=NULL,    
@iso2 char(2)=NULL,    
@iso3 char(3)=NULL,    
@currency_code char(3)=NULL,    
@provider_id varchar(50)=NULL    
)    
AS           
BEGIN          
DECLARE @sql VARCHAR(MAX)     
IF @flag = 's'  ---select data from tblcountry    
        BEGIN               
            SET @sql = 'select c.*,p.provider_name vendor from tblcountry c    
INNER JOIN MPOS_provider_list p ON c.provider_id = p.provider_id    
 where c.provider_id is not null'     
       IF @country_code IS NOT NULL        
    SET @sql = @sql + ' and sno =' + @country_code    
    SET @sql = @sql + ' order by c.country_name asc'    
            
   EXEC (@sql)         
 END    
    
 IF @flag = 'u'------Update              
        BEGIN               
            UPDATE  tblCountry          
            SET              
                    provider_id = @provider_id            
            WHERE  sno= @country_code              
            SELECT  'Success' Status ,          
                    ' Country Information  Updated Successfully..!!' Message                   
        END           
     
    
    
   IF @flag = 'i'-------Inserting the values              
        BEGIN              
             UPDATE  tblCountry          
            SET              
                    provider_id = @provider_id            
            WHERE  sno= @country_code              
            SELECT  'Success' Status ,          
                    ' Country Information  Updated Successfully..!!' Message      
        END      
    
      IF @flag = 'd'------Deleting the product name              
        BEGIN                       
            UPDATE  tblCountry          
            SET              
                    provider_id = NULL            
            WHERE  sno= @country_code              
            SELECT  'Success' Status ,          
                    ' Country Delete Successfully..!!' Message                      
        END     
    
-----------------------     
IF @flag = 'sa'           
    BEGIN               
      SET @sql = 'SELECT * FROM MPOS_tblOperator'            
        IF @country_code IS NOT NULL        
    SET @sql = @sql + ' and sno=' + @country_code         
      PRINT @sql      
   EXEC (@sql)         
        END     
END         
    
    
    
    
  
  
  
  DROP PROCEDURE spa_MPOS_operator_info
  GO
  
CREATE PROC [dbo].[spa_MPOS_operator_info]  
    (  
      @flag CHAR(5) ,  
      @country VARCHAR(100) = NULL ,  
      @operator_name VARCHAR(100) = NULL ,  
      @isEnable VARCHAR(5) = NULL ,  
      @operator_no VARCHAR(10) = NULL,  
   @actionKey VARCHAR(10)=NULL    
    )  
AS   
    IF @flag = 's'   
        BEGIN    
            SELECT  o.operator_name operator,o.IsEnable IsEnable,o.sno sno,  
                    c.country_name Countryname,  
                    c.provider_id,p.provider_name vendor  
            FROM    tblCountry c  
                    INNER JOIN MPOS_tbloperator o ON c.country_name=o.country_name 
     INNER JOIN MPOS_provider_list p ON c.provider_id=p.provider_id  
            WHERE   ISNULL(c.provider_id, '') <> ''   
            ORDER BY o.operator_name  asc  
        END    
    
    IF @flag = 'u'------Update              
        BEGIN               
            UPDATE  MPOS_tbloperator  
            SET     Operator_name = @operator_name ,  
					actionkey= @actionKey,  
                    IsEnable = @isEnable  
            WHERE   sno = @operator_no              
            SELECT  'Success' Status ,  
                    ' Operator Information  Updated Successfully..!!' Message                   
        END           
     
    
    
    --IF @flag = 'i'-------Inserting the values              
    --    BEGIN              
              
    --        INSERT  INTO MPOS_tbloperator  
    --                ( country_sno ,  
    --                  Operator_name ,  
    --                  IsEnable,  
    --    actionKey   
    --                )  
    --        VALUES  ( @country_sno ,  
    --                  @operator_name ,  
    --                  @isEnable,  
    --   @actionKey      
    --                )              
    --    END      
  
    IF @flag = 'sa'   
        BEGIN    
            SELECT  o.operator_name operator,o.IsEnable IsEnable,o.sno sno,  
                    c.country_name Countryname,  
                    c.provider_id,p.provider_name vendor  
            FROM    tblCountry c  
                    INNER JOIN MPOS_tbloperator o ON c.country_name=o.country_name  
     INNER JOIN MPOS_provider_list p ON c.provider_id=p.provider_id  
            WHERE   ISNULL(c.provider_id, '') <> ''   
   AND o.country_name=@country  
            ORDER BY o.operator_name  asc  
        END    
  
  
  
  
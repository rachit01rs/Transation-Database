DROP FUNCTION dbo.FNANumericOnly
GO
CREATE FUNCTION dbo.FNANumericOnly
    (
      @inpStr VARCHAR(max)=NULL ,
      @repChar VARCHAR(1)
    )
RETURNS VARCHAR(max)
    BEGIN 
		IF @inpStr IS NULL OR @inpStr=''
			RETURN @inpStr
        DECLARE @retStr VARCHAR(max)  
        SET @retStr = ''  
        IF ( LEN(@inpStr) > 0 ) 
            BEGIN  
                DECLARE @l INT  
                SET @l = LEN(@inpStr)  
                DECLARE @p INT  
                SET @p = 1  
                WHILE @p <= @l 
                    BEGIN  
                        DECLARE @c INT  
                        SET @c = ASCII(SUBSTRING(@inpStr, @p, 1))  
                        IF @c BETWEEN 48 AND 57
                            SET @retStr = @retStr + CHAR(@c)  
                        ELSE 
                            SET @retStr = @retStr + @repChar  
                        SET @p = @p + 1  
                    END  
            END  
        RETURN @retStr  
    END 

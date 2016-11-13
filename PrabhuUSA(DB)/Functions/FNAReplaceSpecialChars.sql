DROP FUNCTION dbo.FNAReplaceSpecialChars
GO
CREATE FUNCTION dbo.FNAReplaceSpecialChars
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
                            OR @c BETWEEN 65 AND 90
                            OR @c BETWEEN 97 AND 122 
                            SET @retStr = @retStr + CHAR(@c)  
                        ELSE 
                            SET @retStr = @retStr + @repChar  
                        SET @p = @p + 1  
                    END  
            END  
        RETURN @retStr  
    END 

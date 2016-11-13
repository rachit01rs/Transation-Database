CREATE FUNCTION [dbo].[FNAAddFrontSpecialCharFormatAlfaNumeric]
    (
      @inpStr VARCHAR(MAX)=NULL ,
      @length INT=NULL,
      @prefixchar CHAR(1)=NULL
    )
RETURNS VARCHAR(MAX)
    BEGIN 
        SET @length = ISNULL(@length,1)        
        SET @inpStr = LTRIM(RTRIM(isNull(@inpStr,'')))
        SET @prefixchar=ISNULL(@prefixchar,'0')
        IF LEN(@inpStr) > @length
			SET @inpStr=LEFT(@inpStr,@length) 
            --RETURN 'Out Of Range Length'
        DECLARE @retStr VARCHAR(MAX) ,
            @char CHAR(1)  
        SET @retStr = ''
        SET @char = @prefixchar  
        DECLARE @p INT  
        SET @p = 1 
        SET @length = @length - LEN(@inpStr) 
        WHILE @p <= @length 
            BEGIN  
                SET @retStr = @retStr + @char  
                SET @p = @p + 1  
            END 
        IF @inpStr IS NULL
            OR @inpStr = '' 
            RETURN @retStr
        SET @retStr = @retStr + @inpStr
              
        RETURN @retStr  
    END 

GO




CREATE FUNCTION [dbo].[split_FullName] 
( 
@StringInput VARCHAR(100) 
)
RETURNS @OutputTable TABLE ( [FirstName] VARCHAR(50),[MiddleName] VARCHAR(50),[LastName] VARCHAR(50) )
AS
BEGIN
    DECLARE @String    VARCHAR(50)
	DECLARE @FIRST    VARCHAR(50)
	DECLARE @MIDDLE    VARCHAR(50)
	DECLARE @LAST    VARCHAR(50)
	declare @COUNT int
		set @COUNT=1
	set @StringInput=reverse(@StringInput)
    WHILE LEN(@StringInput) > 0
    BEGIN
		set @StringInput=ltrim(rtrim(@StringInput))
        SET @String      = LEFT(@StringInput, 
                                ISNULL(NULLIF(CHARINDEX(' ', @StringInput) - 1, -1),
                                LEN(@StringInput)))
        SET @StringInput = SUBSTRING(@StringInput,
                                     ISNULL(NULLIF(CHARINDEX(' ', @StringInput), 0),
                                     LEN(@StringInput)) + 1, LEN(@StringInput))
		if @COUNT=1
			set @LAST=@String
		else if @COUNT=2
			set @MIDDLE=@String
		else
			set @FIRST=isNULL(@FIRST,'')+' '+@String
        set @COUNT=@COUNT+1
    END
		if @first is NULL
		  begin
			set @FIRST=@MIDDLE
			set @MIDDLE=NULL
				if @FIRST is NULL
					begin		
					 set @FIRST=@LAST
					 set @LAST=NULL
					end
		  end

    INSERT INTO @OutputTable ( [FirstName],[MiddleName],[LastName] )
        VALUES ( ltrim(rtrim(reverse(@FIRST))),ltrim(rtrim(reverse(@MIDDLE))),ltrim(rtrim(reverse(@LAST))) )
    RETURN
END
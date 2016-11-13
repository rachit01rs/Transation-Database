IF OBJECT_ID('FNARemoveExponential', 'FN') IS NOT NULL 
    DROP FUNCTION [dbo].[FNARemoveExponential]
GO
CREATE FUNCTION [dbo].[FNARemoveExponential] ( @refno VARCHAR(50) )
RETURNS VARCHAR(50)
AS 
    BEGIN
        SET @refno = CASE WHEN ISNUMERIC(@refno) = 1
                          THEN CONVERT(VARCHAR, CONVERT(BIGINT, CONVERT(FLOAT(53), @refno)))
                          ELSE @refno
                     END
        RETURN @refno
    END
DROP FUNCTION FNAExportSequenceNumber
GO
-- =============================================
CREATE FUNCTION FNAExportSequenceNumber 
(
	@expected_payoutagentid VARCHAR(20)
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE @count INT,@currentDate VARCHAR(10)
	SELECT @currentDate=CONVERT(VARCHAR(10),dbo.getDateHO(GETUTCDATE()),121)
		SELECT @count=COUNT(*) FROM (SELECT downloaded_ts  FROM dbo.moneySend WITH(NOLOCK)
		WHERE expected_payoutagentid=@expected_payoutagentid AND downloaded_ts IS NOT NULL 
		AND downloaded_ts BETWEEN @currentDate AND @currentDate+' 23:59:59.998'
		GROUP BY downloaded_ts)t

		IF RTRIM(LTRIM(ISNULL(@count,0))) <>0
			SET @count =@count
		ELSE
			SET @count=1

	-- Return the result of the function
	RETURN @count

END
GO


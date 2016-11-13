IF OBJECT_ID('spa_importExportFileLog', 'P') IS NOT NULL 
    DROP PROC spa_importExportFileLog
	
GO
CREATE PROC spa_importExportFileLog
    @flag CHAR(1) ,
    @fileName VARCHAR(100) = NULL ,
    @status VARCHAR(50) = NULL ,
    @systemName VARCHAR(100) = NULL ,
    @fileType CHAR(1) = NULL ,
    @fromDate VARCHAR(50) = NULL ,
    @toDate VARCHAR(50) = NULL
AS 
    BEGIN
        IF @toDate IS NOT NULL 
            SET @toDate = @toDate + ' 23:59:59.998'
            
        IF @flag = 'i' 
            BEGIN
                INSERT  INTO dbo.ImportExportFileLog
                        ( FileName ,
                          Status ,
                          systemName ,
                          Create_ts ,
                          FileType
		            )
                VALUES  ( @fileName , -- FileName - varchar(100)
                          @status , -- Status - varchar(50)
                          @systemName , -- systemName - varchar(100)
                          dbo.getDateHO(GETUTCDATE()) , -- Create_ts - datetime
                          @fileType  -- FileType - char(1)
		            )
            END
	
        IF @flag = 's' 
            BEGIN
                SELECT  *
                FROM    dbo.ImportExportFileLog with(nolock)
                WHERE   CASE WHEN @fileType IS NOT NULL THEN FileType
                             ELSE 1
                        END = ISNULL(@fileType, 1)
                        AND CASE WHEN @systemName IS NOT NULL THEN systemName
                                 ELSE 1
                            END = ISNULL(@systemName, 1)
                        AND CASE WHEN @status IS NOT NULL THEN status
                                 ELSE 1
                            END = ISNULL(@status, 1)
                        AND Create_ts BETWEEN @fromDate AND @toDate 
            END
            
        IF @flag = 'v'------------------view overall report----
		BEGIN
			DECLARE @sql_smt VARCHAR(5000)
			
			SELECT @sql_smt = 'SELECT iml.sno,iml.[FileName],iml.[Status],iml.systemName,iml.Create_ts,
			CASE WHEN iml.FileType = ''I'' THEN ''Import'' ELSE ''Export'' END fileType 
			  FROM ImportExportFileLog iml with(nolock) where 1=1'
			  
			IF @status IS NOT NULL
			BEGIN
				SELECT @sql_smt = @sql_smt + ' AND iml.Status='''+ @status+''''
			END
			
			IF @systemName IS NOT NULL
			BEGIN
				SELECT @sql_smt = @sql_smt + ' AND iml.systemName='''+ @systemName+''''
			END
			
			IF @fileType IS NOT NULL
			BEGIN
				SELECT @sql_smt = @sql_smt + ' AND iml.fileType='''+ @fileType +''''
			END
			
			IF @fromDate IS NOT NULL 
			BEGIN
				SELECT @sql_smt = @sql_smt + ' AND iml.Create_ts  between ''' + @fromDate + ' 00:00:00:000'' And ''' + @toDate +''''
			END
			
			SELECT @sql_smt = @sql_smt + ' ORDER BY iml.Create_ts DESC'
			
			EXEC(@sql_smt)
			--PRINT @sql_smt
		END
	
	END
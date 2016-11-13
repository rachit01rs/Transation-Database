
/*  
** Database    : PrabhuUSA
** Object      : spa_run_report
** Purpose     : Create spa_run_report
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_run_report]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_run_report]
  
GO 
  

--spa_run_report 1,'@from_date=2009-01-01;@to_date=2009-07-01;@receive_country=Nepal;'  

CREATE PROC [dbo].[spa_run_report]  

@report_id INT,  

@where_condition VARCHAR(1000) = NULL  

AS  

--DECLARE @report_id int,@where_condition varchar(1000)  

--SET @report_id=1  

--SET @where_condition='@from_date=2009-01-01;@to_date=2009-07-01;@receive_country=Nepal;'  

  

DECLARE @sql         AS VARCHAR(MAX),

        @where_clm   VARCHAR(1000),

        @str         VARCHAR(200),

        @clm_name    VARCHAR(100),

        @clm_value   VARCHAR(100),

        @spot        INT,

        @spot_clm    INT

  

DECLARE @calc_total  CHAR(1)  

SELECT @sql = vw_sql,

       @calc_total = calc_total

FROM   report_writer_header

WHERE  report_id = @report_id

  

IF @calc_total = 'y'

    SET @sql = @sql + ' WITH ROLLUP'  

  

PRINT @sql  

  

WHILE @where_condition <> ''

BEGIN

    SET @spot = CHARINDEX(';', @where_condition)     

    IF @spot > 0

    BEGIN

        PRINT @spot  

        SET @str = LEFT(@where_condition, @spot -1)   

        SET @spot_clm = CHARINDEX('=', @str)    

        SET @clm_name = LEFT(@str, @spot_clm -1)   

        SET @clm_value = RIGHT(@str, LEN(@str) -@spot_clm)    

        

        SET @where_condition = RIGHT(@where_condition, LEN(@where_condition) -@spot)

    END

    ELSE

    BEGIN

        SET @str = @where_condition   

        SET @spot_clm = CHARINDEX('=', @str)    

        SET @clm_name = LEFT(@str, @spot_clm -1)   

        SET @clm_value = RIGHT(@str, LEN(@str) -@spot_clm)    

        SET @where_condition = ''

    END  

    DECLARE @null_allow  CHAR(1),

            @clm_type    VARCHAR(10)

    

    SELECT @clm_type = clm_type,

           @null_allow = null_allow

    FROM   report_writer_clm

    WHERE  report_id = @report_id

           AND clm_name_id = @clm_name  

    

    IF @clm_type = 'Numeric'

        SET @sql = REPLACE(@sql, @clm_name, @clm_value)

    ELSE

    BEGIN

    	IF @clm_value='NULL'

    	SET @sql = REPLACE(@sql, @clm_name, '' + @clm_value + '')

    	else

    	SET @sql = REPLACE(@sql, @clm_name, '''' + @clm_value + '''')

    END

        

END  

PRINT @sql  

EXEC (@sql)  

  

  

  

  

  

  

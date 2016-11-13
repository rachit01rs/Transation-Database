IF OBJECT_ID('dbo.FNADateUTC','fn') IS NOT NULL
	DROP function dbo.FNADateUTC  
go
--select dbo.FNADateUTC(345,GETUTCDATE()),dbo.FNADateUTC(-300,GETUTCDATE())  
CREATE function dbo.FNADateUTC(@gmt_value int,@utc_date datetime)  
RETURNS datetime AS    
BEGIN   
  
declare @ret_date datetime  
  
if @gmt_value>=180  
begin  
 set @ret_date=dateadd(mi,isNUll(@gmt_value,-300),@utc_date)  
 return @ret_date  
end  
  
declare @currentYear int  
set @currentYear=datepart(year,getdate())  
  
declare @secondSundayOfMar datetime  
 set @secondSundayOfMar= CAST('3/8/' + CAST(@currentYear as varchar) as datetime)  
declare @firstSundayOfNov datetime   
set @firstSundayOfNov = CAST( '11/1/' + CAST(@currentYear as varchar) as datetime)  
   
--find first sunday  
while( DATENAME(WEEKDAY,@secondSundayOfMar) != 'Sunday' )  
begin  
 set @secondSundayOfMar = DATEADD(day,1,@secondSundayOfMar)  
end  
   
--find last sunday of nov  
while( DATENAME(WEEKDAY,@firstSundayOfNov) != 'Sunday' )  
begin  
set @firstSundayOfNov = DATEADD(day,-1,@firstSundayOfNov)  
end  
   
   
  
declare @currentDate datetime   
set @currentDate= getDate()  
   
--for EST  
if ( @currentDate >= @secondSundayOfMar AND @currentDate < @firstSundayOfNov )  
 set @gmt_value = @gmt_value+60  
  
  set @ret_date=dateadd(mi,isNUll(@gmt_value,-300),@utc_date)  
return @ret_date  
--print @gmt  
end  
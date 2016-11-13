CREATE PROC [dbo].[spa_API_Agent_Setup]      
@flag char(1),      
@update_by varchar(50)=null,      
@countryCode varchar(200) =NULL,      
@city varchar(200) =NULL,      
@DestinationCurrency varchar(20)=NULL,      
@ProductId varchar(5)=NULL,      
@sessionid varchar(200)=NULL      
      
      
AS     
SET NOCOUNT ON   
--select all records      
DECLARE @idoc int      
DECLARE @doc varchar(1000)      
declare @sql varchar(8000)      
      
if @flag='s'      
BEGIN      
 set @sql='select * from API_Agents where 1=1'      
 if @countryCode is not null      
  set @sql=@sql+' and DestinationCountry='''+@countryCode+''''      
 if @city is not null      
  set @sql=@sql+' and isNULL(City,''-Blank-'')='''+@city+''''      
      
 set @sql=@sql+' order by DestinationCountry,AgentName'    
print @sql    
exec(@sql)      
END      
      
--if @flag='g'      
--BEGIN      
--if exists (select agentid from CMT_Agents_temp where SessionID=@sessionid and DestinationCountry=@countryCode      
-- and DestinationCurrency=@DestinationCurrency and ProductId=@ProductId)      
-- begin      
-- delete CMT_Agents where DestinationCountry=@countryCode      
-- and DestinationCurrency=@DestinationCurrency and ProductId=@ProductId and is_anywhere is NULL      
--      
-- INSERT INTO [CMT_Agents]      
--           ([DestinationCountry]      
--           ,[AgentId]      
--           ,[AgentName]      
--           ,[Address1]      
--           ,[Address2]      
--           ,[PhoneNumber]      
--           ,[FaxNumber]      
--           ,[Email]      
--           ,[BusinessHours]      
--           ,[Directions]      
--           ,[Location]      
--           ,[State]      
--           ,[City]      
--           ,[ProductId]      
--           ,[serviceid]      
--           ,[DestinationCurrency])      
-- select [DestinationCountry]      
--           ,[AgentId]      
--           ,[AgentName]      
--           ,[Address1]      
--           ,[Address2]      
--           ,[PhoneNumber]      
--           ,[FaxNumber]      
--           ,[Email]      
--           ,[BusinessHours]      
--           ,[Directions]      
--           ,[Location]      
--           ,[State]      
--           ,[City]      
--           ,[ProductId]      
--           ,[serviceid]      
--           ,[DestinationCurrency]      
-- from CMT_Agents_temp where SessionID=@sessionid and DestinationCountry=@countryCode      
-- and DestinationCurrency=@DestinationCurrency and ProductId=@ProductId       
-- order by DestinationCountry,AgentName,AgentID,Productid,DestinationCurrency      
-- end      
-- delete CMT_Agents_temp where SessionID=@sessionid      
--END      
--      
--if @flag='a'      
--BEGIN      
--if exists (select agentid from CMT_Agents_temp where SessionID=@sessionid and DestinationCountry=@countryCode      
-- and DestinationCurrency=@DestinationCurrency and ProductId=@ProductId)      
-- begin      
-- delete CMT_Agents where DestinationCountry=@countryCode      
-- and DestinationCurrency=@DestinationCurrency and ProductId=@ProductId and is_anywhere is NOT NULL      
--      
-- INSERT INTO [CMT_Agents]      
--           ([DestinationCountry]      
--           ,[AgentId]      
--           ,[AgentName]      
--           ,[Address1]      
--           ,[Address2]      
--           ,[PhoneNumber]      
--           ,[FaxNumber]      
--           ,[Email]      
--           ,[BusinessHours]      
--           ,[Directions]      
--           ,[Location]      
--           ,[State]      
--           ,[City]      
--           ,[ProductId]      
--           ,[serviceid]      
--           ,[DestinationCurrency]      
--     ,[is_anywhere])      
-- select [DestinationCountry]      
--           ,[AgentId]      
--           ,[AgentName]      
--           ,[Address1]      
--           ,[Address2]      
--           ,[PhoneNumber]      
--           ,[FaxNumber]      
--           ,[Email]      
--           ,[BusinessHours]      
--           ,[Directions]      
--           ,[Location]      
--           ,[State]      
--           ,[City]      
--           ,[ProductId]      
--           ,[serviceid]      
--           ,[DestinationCurrency]      
--     ,'y'      
-- from CMT_Agents_temp where SessionID=@sessionid and DestinationCountry=@countryCode      
-- and DestinationCurrency=@DestinationCurrency and ProductId=@ProductId       
-- order by DestinationCountry,AgentName,AgentID,Productid,DestinationCurrency      
-- end      
-- delete CMT_Agents_temp where SessionID=@sessionid      
--END 
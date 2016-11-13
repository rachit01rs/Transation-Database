

/*  
** Database    : PrabhuUSA
** Object      : spa_add_menu
** Purpose     : Create spa_add_menu
** Author      : Puja Ghaju 
** Date        : 12 September 2013

**Modified
**Date		   : 07 October 2013
**Purpose      : Added new flag q for superagent 
**Author       : Puja Ghaju 
*/ 


IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_add_menu]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_add_menu]
  
GO 
--spa_add_menu 'a','agent',NULL,NULL,NULL,NULL,'cancel'    
--spa_add_menu 'c','agent',10    
--spa_add_menu 'i','agent',NULL,'Cancel Transaction','test','transaction/findTrns2cancel.asp','Utilities'    
CREATE proc [dbo].[spa_add_menu]    
 @flag char(1),    
 @application varchar(50)=null,    
 @snum int=NULL,    
 @function_name varchar(500)=NULL,    
 @description varchar(100)=NULL,    
 @link_file varchar(200)=NULL,    
 @main_menu varchar(150)=NULL,    
 @menu_type varchar(50)=NULL,    
 @newFn_name varchar(50)=NULL    
as    
SET NOCOUNT ON

declare @sno int    
   select additional_value MenuName into #disable from tbl_integrated_agents i join static_values s
    on i.agentcode=s.static_data and s.sno=500
    where isEnable='n'
    
    
if @flag='s'    
begin    
 if @application='admin'    
  select sno,function_name,description,link_file,main_menu,menu_type from application_function    
  where main_menu not in ('canceled','cancel') order by main_menu,function_name     
 if @application='agent'    
  select sno,function_name,description,link_file,main_menu from sender_function    
  where main_menu not in ('canceled','cancel') order by main_menu,function_name     
end    
    
if @flag='a'    
begin    
    
 
    
DECLARE @sql_select varchar(900)    
if @application='admin'    
BEGIN     
 SET @sql_select='select m.sno,m.function_name,m.description,m.link_file,isNull(s.static_value,main_menu) main_menu,menu_type 
	from application_function m left outer join
 static_values s on s.static_data=m.main_menu and s.sno=101   
 left outer join #disable d on m.main_menu=d.MenuName 
  where  d.MenuName is null '    
 IF @function_name IS NOT NULL    
 SET @sql_select=@sql_select +' and m.function_name like '''+@function_name+'%'''    
 IF @main_menu IS NOT NULL    
 BEGIN    
 IF @main_menu ='cancel'    
 SET @sql_select=@sql_select +' and m.main_menu in (''canceled'',''cancel'')'    
 ELSE    
 SET @sql_select=@sql_select +' and m.main_menu='''+@main_menu+''''    
 END    
 SET @sql_select=@sql_select +' and m.main_menu not in (''canceled'',''cancel'')'  
 SET @sql_select=@sql_select +' order by m.main_menu,m.function_name '    
END    
if @application='agent'    
BEGIN    
 SET @sql_select='select m.sno,m.function_name,m.description,m.link_file,isNull(s.static_value,main_menu) main_menu from sender_function m left outer join
 static_values s on s.static_data=m.main_menu and s.sno=102 where 1=1 '    
 IF @function_name IS NOT NULL    
 SET @sql_select=@sql_select +' and m.function_name like '''+@function_name+'%'''    
 IF @main_menu IS NOT NULL    
 BEGIN    
 IF @main_menu ='cancel'    
 SET @sql_select=@sql_select +' and m.main_menu in (''canceled'',''cancel'')'    
 ELSE    
 SET @sql_select=@sql_select +' and m.main_menu='''+@main_menu+''''    
 END    
 SET @sql_select=@sql_select +' and m.main_menu not in (''canceled'',''cancel'')'  
 SET @sql_select=@sql_select +' order by m.main_menu,m.function_name '    
END    
   
EXEC (@sql_select)    
END     
    
    
    
if @flag='i'    
begin    
 if @application='admin'    
 begin    
  select @sno=max(sno)+1 from application_function    
  if not exists(select sno from application_function where function_name=@function_name and main_menu=@main_menu)    
  begin    
  insert into application_function (sno,function_name,description,link_file,main_menu,menu_type)    
  values(@sno,@function_name,@description,@link_file,@main_menu,@menu_type)    
  select 'Success' status,'Application Menu is Successfully Added' msg    
  end    
  else    
  select 'Error' status,'This application already exists' msg    
 end    
 if @application='agent'    
 begin    
  select @sno=max(sno)+1 from sender_function    
  if not exists(select sno from sender_function where function_name=@function_name and main_menu=@main_menu)    
  begin    
  insert into sender_function (sno,function_name,description,link_file,main_menu)    
  values(@sno,@function_name,@description,@link_file,@main_menu)    
  select 'Success' status,'Application Menu is Successfully Added' msg    
  end    
  else    
   select 'Error' status,'This application already exists' msg    
 end    
end    
if @flag='c' -- Cancel the Function Name    
begin    
 if @application='admin'    
 begin     
  Update application_function set    
  main_menu='canceled'    
  where sno=@snum    
 end    
 if @application='agent'    
 begin    
  Update sender_function set    
  main_menu='canceled'    
  where sno=@snum    
 end    
end    
if @flag='m'    
 begin    
 if @application='admin'    
	select distinct main_menu id,isNull(s.static_value,main_menu) val from application_function a left outer join
	static_values s on s.static_data=a.main_menu and s.sno=101  
	left outer join #disable d on a.main_menu=d.MenuName 
	where  d.MenuName is null and a.main_menu not in ('canceled','cancel') AND ISNULL(a.Description,'') NOT IN ('SPanel')   
 if @application='agent'    
	select distinct main_menu id,isNull(s.static_value,main_menu) val from sender_function a left outer join
	static_values s on s.static_data=a.main_menu and s.sno=102  
	left outer join #disable d on a.main_menu=d.MenuName 
	where  d.MenuName is null and a.main_menu not in ('canceled','cancel') AND ISNULL(a.Description,'') NOT IN ('SPanel') 
 if @application is null
	 SELECT static_id id,CASE WHEN sv.sno=101 then 'Admin-'+sv.static_value ELSE 'Partner-'+sv.static_value 
	 END val FROM static_values sv left outer join #disable d on sv.static_data=d.MenuName 
	  WHERE sv.sno in (101,102) and d.MenuName is null order by val

end    



if @flag='q'    
 begin    
 if @application='admin'    
	select distinct main_menu id,isNull(s.static_value,main_menu) val from application_function a left outer join
	static_values s on s.static_data=a.main_menu and s.sno=101  
	left outer join #disable d on a.main_menu=d.MenuName 
	where  d.MenuName is null and a.main_menu not in ('canceled','cancel') AND ISNULL(a.Description,'')='SPanel'  
 if @application='agent'    
	select distinct main_menu id,isNull(s.static_value,main_menu) val from sender_function a left outer join
	static_values s on s.static_data=a.main_menu and s.sno=102  
	left outer join #disable d on a.main_menu=d.MenuName 
	where  d.MenuName is null and a.main_menu not in ('canceled','cancel') AND ISNULL(a.Description,'')='SPanel'
 if @application is null
	 SELECT static_id id,CASE WHEN sv.sno=101 then 'Admin-'+sv.static_value ELSE 'Partner-'+sv.static_value 
	 END val FROM static_values sv left outer join #disable d on sv.static_data=d.MenuName 
	  WHERE sv.sno in (101,102) and d.MenuName is null order by val

end    





    
    
if @flag='u' -- Changes the Function Name    
begin    
declare @sql varchar(8000),@comma char(1)    
 if @application='admin'    
 begin    
     
  set @sql='Update application_function set '    
  if @function_name is not null    
  set @sql=@sql+' function_name='''+@function_name+''''    
  if @description is not null    
  begin    
  if @function_name is not null    
  set @comma=','    
  else    
  set @comma=''    
  set @sql=@sql+@comma+' description='''+@description+''''    
  end    
  if @link_file is not null    
  begin    
  if @function_name is not null or @description is not null    
  set @comma=','    
  else    
  set @comma=''    
  set @sql=@sql+@comma+' link_file='''+@link_file+''''    
  end     
  if @main_menu is not null    
  begin    
  if @function_name is not null or @description is not null or @link_file is not NULL    
  set @comma=','    
  else    
  set @comma=''    
  set @sql=@sql+@comma+' main_menu='''+@main_menu+''''    
  end    
  set @sql=@sql+' where sno='+ cast(@snum as varchar(20))    
  --print (@sql)    
  exec (@sql)    
  select 'Success' status,'Application Menu is Successfully Changed' msg    
 end    
    
--spa_add_menu 'u','admin',109,NULL,'33','d','23'    
    
 if @application='agent'    
 begin    
--  Update sender_function set    
--  function_name=@function_name,    
--  description=@description,    
--  main_menu=@main_menu    
--  where sno=@snum    
    
  set @sql='Update sender_function set'    
  if @function_name is not null    
  set @sql=@sql+' function_name='''+@function_name+''''    
  if @description is not null    
  begin    
  if @function_name is not null    
  set @comma=','    
  else    
  set @comma=''    
  set @sql=@sql+@comma+' description='''+@description+''''    
  end    
  if @link_file is not null    
  begin    
  if @function_name is not null or @description is not null    
  set @comma=','    
  else    
  set @comma=''    
  set @sql=@sql+@comma+' link_file='''+@link_file+''''    
  end     
  if @main_menu is not null    
  begin    
  if @function_name is not null or @description is not null or @link_file is not NULL    
  set @comma=','    
  else    
  set @comma=''    
  set @sql=@sql+@comma+' main_menu='''+@main_menu+''''    
  end    
  set @sql=@sql+' where sno='+ cast(@snum as varchar(20))    
  --print (@sql)    
  exec (@sql)    
  --select 'Success' status,'Application Menu is Successfully Changed' msg    
 end    
end    
    
    
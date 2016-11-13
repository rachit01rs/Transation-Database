
/*  
** Database    : PrabhuUSA
** Object      : spa_manage_fav
** Purpose     : Create spa_manage_fav
** Author      : Puja Ghaju 
** Date        : 12 September 2013  
*/ 


IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_manage_fav]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_manage_fav]
  
GO 
  
--spa_manage_fav 'r',NULL,'42'  
--spa_manage_fav 'a','acharyabishnu'  
CREATE PROC [dbo].[spa_manage_fav]  
  @flag char(1),  
  @user_login_id varchar(50)=NULL,  
  @role_id int=null  
AS  
return  
if @flag='a'  
begin  
SELECT distinct sender_function.sno,sender_function.main_menu +' &raquo; '+sender_function.function_name as menu  
 FROM sender_function INNER JOIN sender_function_user   
ON sender_function.sno = sender_function_user.function_id   
where sender_function.link_file is not null   
AND sender_function.main_menu not in ('canceled','cancel')  
and (role_id in( select role_id   
from application_role_agent_user where user_id=@user_login_id)   
or sender_function_user.user_id=@user_login_id)  
and sender_function.sno not in(select func_id from tool_bar_agent where user_id=@user_login_id)  
order by menu  
end  
if @flag='u'  
begin  
 SELECT distinct sender_function.sno INTO #temp  
 FROM sender_function INNER JOIN sender_function_user   
 ON sender_function.sno = sender_function_user.function_id   
 where sender_function.link_file is not null   
 AND sender_function.main_menu not in ('canceled','cancel')  
 and (role_id in( select role_id   
 from application_role_agent_user where user_id=@user_login_id)   
 or sender_function_user.user_id=@user_login_id)   
  
 DELETE tool_bar_agent WHERE func_id IN (SELECT b.func_id FROM #temp t RIGHT OUTER JOIN tool_bar_agent b  
 ON t.sno=b.func_id  
 WHERE t.sno IS null)  
 AND user_id=@user_login_id  
  
   
end  
  
if @flag='r'  
begin  
  SELECT distinct sender_function.sno INTO #tempTable  
  FROM sender_function INNER JOIN sender_function_user   
  ON sender_function.sno = sender_function_user.function_id   
  where sender_function.link_file is not null   
  AND sender_function.main_menu not in ('canceled','cancel')  
  and role_id =@role_id or sender_function_user.user_id in (select user_id  
  from application_role_agent_user where role_id=@role_id)  
  
DELETE tool_bar_agent WHERE func_id IN (SELECT b.func_id FROM #tempTable t RIGHT OUTER JOIN tool_bar_agent b  
ON t.sno=b.func_id  
WHERE t.sno IS null)  
AND user_id in (select user_id  
from application_role_agent_user where role_id=@role_id)  
end  
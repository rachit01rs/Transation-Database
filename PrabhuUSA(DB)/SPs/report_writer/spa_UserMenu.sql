

/*  
** Database    : PrabhuUSA
** Object      : spa_UserMenu
** Purpose     : Create spa_UserMenu
** Author      : Puja Ghaju 
** Date        : 12 September 2013  

Modified
Modified by    : Puja Ghaju	
Date		   : 23rd October 2013
Purpose		   : Added order by l.mainmenu in flag 'a' to display according to mainmenu
*/ 


IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[spa_UserMenu]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
DROP PROCEDURE [DBO].[spa_UserMenu]
  
GO 
   
--spa_UserMenu 'anoop','a'  
CREATE PROC [dbo].[spa_UserMenu] 
@user_id VARCHAR(50),  
@control_type CHAR(1)  
AS  
DECLARE @isAdmin VARCHAR(2)  
IF @control_type = 'h' --- Admin Site  
BEGIN  
    SELECT @isAdmin = at.rights  
    FROM   adminTable at  
    WHERE  at.cUser = @user_id  
    
    select additional_value MenuName into #disable from tbl_integrated_agents i join static_values s
    on i.agentcode=s.static_data and s.sno=500
    where isEnable='n'
    
    
    IF @isAdmin = '1'  
    BEGIN  
        SELECT DISTINCT *   
        FROM   (  
                   SELECT function_name,  
                          CASE   
                               WHEN CHARINDEX('?', link_file) = 0 THEN link_file   
                                    + '?report_name=' + function_name  
                               ELSE link_file + '&report_name=' + function_name  
                          END link_file,  
                          main_menu,  
                          a.sno,  
                          s.static_value header,  
                          additional_value icon,  
                          a.description,  
                          a.menu_order  
                   FROM   application_function a  
                          JOIN static_values s  
                               ON  static_data = main_menu  and s.sno=101
                   WHERE  s.sno = 101  and a.main_menu<>'Function'
                   UNION  
                   SELECT  h.report_name,  
                          'report_writer/rptView.asp?report_id=' + CAST(h.report_id AS VARCHAR)  
                          + '&report_name=' + h.report_name,  
                          isNUll(h.main_menu,'Report'),  
                          h.report_id,  
                          s.static_value header,  
                          additional_value icon,  
                          h.report_name,  
                          h.report_id menu_order  
                   FROM   report_writer_header h  
                          JOIN static_values s  
                               ON  static_data = isNUll(h.main_menu,'Report')  
                               AND s.sno = 101  
                   WHERE h.main_menu IS NOT NULL and h.main_menu_agent is null 
               ) l left outer join #disable d on l.main_menu=d.MenuName
               where d.MenuName is null
        ORDER BY  
               l.header,  
               menu_order,  
               function_name  
    END  
    ELSE  
        --- NOT ADMINISTRATOR  
    BEGIN  
        SELECT DISTINCT *   
        FROM   (  
                   SELECT function_name,  
                          CASE   
                               WHEN CHARINDEX('?', link_file) = 0 THEN link_file   
                                    + '?report_name=' + function_name  
                               ELSE link_file + '&report_name=' + function_name  
                          END link_file,  
                          main_menu,  
                          function_id sno,  
                          s.static_value header,  
                          additional_value icon,  
                          a.description  
                   FROM   application_function_user u  
                          JOIN application_function a  
                               ON  a.sno = u.function_id  
                          JOIN static_values s  
                               ON  static_data = main_menu   and s.sno=101
                   WHERE  s.sno = 101   and a.main_menu<>'Function' 
                          AND (role_id IN (SELECT role_id  
                                          FROM   application_role_user  
                                          WHERE  USER_ID = @user_id)  
                          OR  USER_ID = @user_id  )
                   UNION  
                   SELECT  h.report_name,  
                          'report_writer/rptView.asp?report_id=' + CAST(h.report_id AS VARCHAR)  
                          + '&report_name=' + h.report_name,  
                          isNUll(h.main_menu,'Report'),  
                          h.report_id,  
                          s.static_value header,  
                          additional_value icon,  
                          h.report_name  
                   FROM   report_writer_header h  
                          JOIN report_func_user f  
                               ON  f.function_id = h.report_id  
                          JOIN static_values s  
         ON  static_data =  isNUll(h.main_menu,'Report')  
                               AND s.sno = 101  
                   WHERE  f.user_id = @user_id   
                   and h.main_menu IS NOT NULL and h.main_menu_agent is null 
                   UNION  
                   SELECT  h.report_name,  
                          'report_writer/rptView.asp?report_id=' + CAST(h.report_id AS VARCHAR)  
                          + '&report_name=' + h.report_name,  
                          isNUll(h.main_menu,'Report'),  
                          h.report_id,  
                          s.static_value header,  
                          additional_value icon,  
                          h.report_name  
                   FROM   report_writer_header h  
                          JOIN report_func_user f  
                               ON  f.function_id = h.report_id  
                          JOIN static_values s  
                               ON  static_data =  isNUll(h.main_menu,'Report')  
                               AND s.sno = 101  
                   WHERE  f.role_id IN (SELECT role_id  
                                        FROM   application_role_user  
                                        WHERE  USER_ID = @user_id)  
                                        and h.main_menu IS NOT NULL
               ) l left outer join #disable d on l.main_menu=d.MenuName
        ORDER BY  
               l.header,  
               function_name  
    END  
END  
IF @control_type = 'a' --- Agent Site  
BEGIN  
  
        SELECT DISTINCT *   
        FROM   (  
                   SELECT function_name,  
                          CASE   
                               WHEN CHARINDEX('?', link_file) = 0 THEN link_file   
                                    + '?report_name=' + function_name  
                               ELSE link_file + '&report_name=' + function_name  
                          END link_file,  
                          main_menu,  
                          function_id sno,  
                          s.static_value header,  
                          additional_value icon,  
                          a.description  
                   FROM sender_function_user u  
                          JOIN sender_function a  
                               ON  a.sno = u.function_id  
                          JOIN static_values s  
                               ON  static_data = main_menu   and s.sno=102
                   WHERE  s.sno = 102   and a.main_menu<>'Function' 
                          AND ( role_id IN (SELECT role_id  
                                          FROM application_role_agent_user  
                                          WHERE  USER_ID = @user_id)  
                          OR  USER_ID = @user_id )
                   UNION  
                   SELECT  h.report_name,  
                          'report_writer/rptView.asp?report_id=' + CAST(h.report_id AS VARCHAR)  
                          + '&report_name=' + h.report_name,  
                          isNUll(h.main_menu_agent,'Report'),  
                          h.report_id,  
                          s.static_value header,  
                          additional_value icon,  
                          h.report_name  
                   FROM   report_writer_header h  
                          JOIN report_func_user f  
                               ON  f.function_id = h.report_id  
                          JOIN static_values s  
         ON  static_data =  isNUll(h.main_menu_agent,'Report')  
                               AND s.sno = 102  
                   WHERE  f.user_id = @user_id   
                   and h.main_menu IS NULL and h.main_menu_agent is not null 
                   UNION  
                   SELECT  h.report_name,  
                          'report_writer/rptView.asp?report_id=' + CAST(h.report_id AS VARCHAR)  
                          + '&report_name=' + h.report_name,  
                          isNUll(h.main_menu_agent,'Report'),  
                          h.report_id,  
                          s.static_value header,  
                          additional_value icon,  
                          h.report_name  
                   FROM   report_writer_header h  
                          JOIN report_func_user f  
                               ON  f.function_id = h.report_id  
                          JOIN static_values s  
                               ON  static_data =  isNUll(h.main_menu_agent,'Report')  
                               AND s.sno = 102  
                   WHERE  f.role_id IN (SELECT role_id  
                                          FROM application_role_agent_user  
                                          WHERE  USER_ID = @user_id) 
                                        and h.main_menu IS NULL and h.main_menu_agent is not null 
                    
               ) l  
        ORDER BY  
               l.header, l.main_menu, 
               function_name  
END  
  
  
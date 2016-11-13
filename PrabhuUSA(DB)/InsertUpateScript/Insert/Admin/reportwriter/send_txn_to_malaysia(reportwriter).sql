
/*
** Database : Prabhu_Usa
** Object : Send TXN to Malaysia
**
** Purpose :---- creating report writer for Sending TXN to Malaysia -----------------
**
** Author: Paribesh Jung Karki	
** Date:    12/18/2014
**
** Modifications:
** 
**			
** Execute Examples :
** 
*/

DECLARE @drill1 VARCHAR(50),@main_report_id VARCHAR(50)
INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
VALUES ('Send TXN to Malaysia', 'spRemote_Processing ''r'',null,@refno', NULL, 'Reports', 'y', NULL)
SET @drill1=@@IDENTITY


INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source,null_allow)
VALUES (@drill1, '@refno', 'refno', 'Text', '','n')










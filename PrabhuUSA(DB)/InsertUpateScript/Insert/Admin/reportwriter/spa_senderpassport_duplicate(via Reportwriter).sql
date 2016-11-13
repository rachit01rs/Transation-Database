/*
** Database : Prabhu_Usa
** Object : Senderpassport duplicate Report
**
** Purpose :---- creating report writer for spa_senderpassport_duplicate -----------------
**
** Author: Paribesh Jung Karki	
** Date:    07/30/2014
**
** Modifications:
** 
**			
** Execute Examples :
** 
*/
DECLARE @drill1 VARCHAR(50),@main_report_id VARCHAR(50)

	INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
	VALUES ('Senderpassport duplicate Report', 'spa_senderpassport_duplicate ''d'', @senderfax, @senderPassport,null', NULL, '', 'y', NULL)
	SET @drill1=@@IDENTITY



INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@senderfax', 'Id type', 'Combo', 'select static_data, static_value from static_values where sno=8 order by static_value', NULL, 'y')

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@senderPassport', 'Id  number', 'Text', NULL, NULL, 'y')


INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
VALUES ('Senderpassport Duplicate summary Report', ' spa_senderpassport_duplicate ''s'',null,null,'''+@drill1+'''' , NULL, 'Utilities', 'y', NULL)



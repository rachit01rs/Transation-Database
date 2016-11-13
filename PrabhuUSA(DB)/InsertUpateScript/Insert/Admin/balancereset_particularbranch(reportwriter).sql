


-------example of reportwriter--------------------------------------------------------------------------------

DECLARE @drill1 VARCHAR(50),@main_report_id VARCHAR(50)
INSERT INTO dbo.report_writer_header (report_name, vw_sql, calc_total, main_menu, enable_paging, main_menu_agent)
VALUES ('Reset Cash in Hand', 'spa_UnitellerCashReport_resetV2  ''u'',@agentid,@username,@branchCode,@fromDate', NULL, 'Utilities', NULL, NULL)




SET @drill1=@@IDENTITY

INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@agentid', 'Agent Name', 'Combo', 'select agentcode,companyname from agentdetail with (nolock) where isUniteller_Agent=''y''', NULL, 'n')


INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@branchcode', 'Branch Name', 'Text', '', NULL, NULL)


INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@username', 'User', 'Text', '', NULL, NULL)


INSERT INTO dbo.report_writer_clm (report_id, clm_name_id, clm_label, clm_type, clm_source, clm_sequence, null_allow)
VALUES (@drill1, '@fromdate', 'Date', 'Date', '', NULL, NULL)





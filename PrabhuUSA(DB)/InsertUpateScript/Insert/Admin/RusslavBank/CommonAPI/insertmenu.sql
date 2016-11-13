INSERT INTO static_values(sno,static_value,static_data,[Description],additional_value)
SELECT '101','RusslavBank','RusslavBank','Admin','RusslavBank_logo1.jpg'
GO
insert into  static_values(sno,static_value,static_data,description,additional_value)
select '500','39319339','20100162','Russlav Bank','RusslavBank'
GO
---####### Country Setup menu [ADMIN] ##########3
DECLARE @sno INT
SELECT TOP 1 @sno=sno FROM application_function ORDER BY sno DESC
INSERT INTO application_function(sno,function_name,Description,link_file,main_menu)
SELECT @sno+1,'Counrty Setup','Counrty Setup','API_RusslavBank/setup/countrySetup.asp','RusslavBank'
GO
---####### SETTLEMENT REPORT [ADMIN] ##########3
DECLARE @sno INT
SELECT TOP 1 @sno=sno FROM application_function af ORDER BY sno DESC
INSERT INTO application_function(sno,function_name,[Description],link_file,main_menu)
SELECT @sno+1,'Settlement report','Russlav SettlementReport','API_RusslavBank/Reports/Partner_report.asp','RusslavBank'
--############# insert Send Menu in Agent SIte ##################
DECLARE @sno INT
SELECT TOP 1 @sno=sno FROM sender_function sf ORDER BY sno DESC
INSERT INTO sender_function(sno,function_name,link_file,main_menu)
SELECT @sno+1,'Send Transaction','API_RusslavBank/selectRoute.asp','RusslavBank'
GO
--########### insert API agents ##############
INSERT INTO tbl_integrated_agents(agentcode,agentName,paymentType,send_url,amend_url,approved_url)
SELECT  '20100103',
		'RusslavBank','Default',
		'API_RusslavBank/SendTxn/SendMoney_Russlav.asp',
		'API_RusslavBank/Amendment/AmendTransaction.asp',
		'API_RusslavBank/HoldTxn/ReCalc_approveRate.asp'
GO
--########insert Partner in static_values where sno=500 ###########
 GO
 INSERT INTO static_values(sno,static_value,static_data,[Description],additional_value)
 SELECT '500','20100103','30107814','Russlav Bank','RusslavBank'
 GO
 
-- INSERT INTO APIPartner_Agent_Margin_Setup(API_Partner,Send_AgentID,Payout_Country,ServiceFee_Margin,update_by,update_ts)
--SELECT '20100103','20100000','RUSSIA','2.33','jiwan',GETDATE()
--GO
--/*########## AGent MENU SETUP ############*/
insert into static_values(sno,static_value,static_data,description)
select 102,'RusslavBank','RusslavBank','Agent'
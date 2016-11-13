alter table agentcurrencyrate_audit
alter column ExchangeRate float
go
alter table agentcurrencyrate_audit
alter column margin_sending_agent  float
go
alter table agentcurrencyrate_audit
alter column SENDING_CUST_EXCHANGERATE  float
go
alter table agentcurrencyrate_audit
alter column DollarRate   float
go
alter table agentcurrencyrate_audit
alter column receiver_rate_diff_value float
go
alter table agentcurrencyrate_audit
alter column payout_agent_rate float
go
alter table agentcurrencyrate_audit
alter column NPRRate  float
go
alter table agentcurrencyrate_audit
alter column customer_diff_value  float
go
alter table agentcurrencyrate_audit
alter column customer_rate  float
go
alter table agentcurrencyrate_audit
alter column agent_premium_payout float
go
alter table agentcurrencyrate_audit
alter column agent_premium_send float
go
alter table agentcurrencyrate_audit
alter column max_premium_receiver float
go
alter table agentcurrencyrate_audit
alter column min_premium_receiver float
go
alter table agentcurrencyrate_audit
alter column max_premium_sender float
go
alter table agentcurrencyrate_audit
alter column min_premium_sender float
go

sp_columns agentcurrencyrate_audit

--alter table agentcurrencyrate_audit 
--add margin_sending_agent float,SENDING_CUST_EXCHANGERATE float,agent_premium_send float,
--max_premium_receiver float,min_premium_receiver float,max_premium_sender float
alter table agentcurrencyrate
alter column ExchangeRate float
go
alter table agentcurrencyrate
alter column margin_sending_agent  float
go
alter table agentcurrencyrate
alter column SENDING_CUST_EXCHANGERATE  float
go
alter table agentcurrencyrate
alter column DollarRate   float
go
alter table agentcurrencyrate
alter column receiver_rate_diff_value float
go
alter table agentcurrencyrate
alter column payout_agent_rate float
go
alter table agentcurrencyrate
alter column NPRRate  float
go
alter table agentcurrencyrate
alter column customer_diff_value  float
go
alter table agentcurrencyrate
alter column customer_rate  float
go
alter table agentcurrencyrate
alter column agent_premium_payout float
go
alter table agentcurrencyrate
alter column agent_premium_send float
go
alter table agentcurrencyrate
alter column max_premium_receiver float
go
alter table agentcurrencyrate
alter column min_premium_receiver float
go
alter table agentcurrencyrate
alter column max_premium_sender float
go
alter table agentcurrencyrate
alter column min_premium_sender float

go
sp_columns agentcurrencyrate
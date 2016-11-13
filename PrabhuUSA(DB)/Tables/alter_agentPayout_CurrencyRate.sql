alter table agentPayout_currencyrate
alter column ExchangeRate float
go
alter table agentPayout_currencyrate
alter column margin_sending_agent  float
go
alter table agentPayout_currencyrate
alter column SENDING_CUST_EXCHANGERATE  float
go
alter table agentPayout_currencyrate
alter column DollarRate   float
go
alter table agentPayout_currencyrate
alter column receiver_rate_diff_value float
go
alter table agentPayout_currencyrate
alter column payout_agent_rate float
go
alter table agentPayout_currencyrate
alter column NPRRate  float
go
alter table agentPayout_currencyrate
alter column customer_diff_value  float
go
alter table agentPayout_currencyrate
alter column customer_rate  float
go
alter table agentPayout_currencyrate
alter column agent_premium_payout float
go
alter table agentPayout_currencyrate
alter column agent_premium_send float
go
alter table agentPayout_currencyrate
alter column max_premium_receiver float
go
alter table agentPayout_currencyrate
alter column min_premium_receiver float
go
alter table agentPayout_currencyrate
alter column max_premium_sender float
go
alter table agentPayout_currencyrate
alter column min_premium_sender float

go
sp_columns agentPayout_currencyrate
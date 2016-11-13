drop table MoeX_temp
go
create table MoeX_temp(
	IdGiro char(13), -- Invoice number
	FechaGiro char(8), --  Date of Invoice
	HoraGiro char(4), --  Time of Invoice
	NombreRte char(25), --  First Name of the Sender
	Apellido1Rte char(20), --  Family Name (1) of the Sender
	Apellido2Rte char(20), --  Family Name (2) of the Sender
	NombreBnf char(25), --  First Name of the Beneficiary
	Apellido1Bnf char(20), --  Family Name (1) of the Beneficiary
	Apellido2Bnf char(20), --  Family Name (2) of the Beneficiary
	DirecciónBnf char(80), --  Address of the Beneficiary
	CiudadBnf char(50), --  Town of the Beneficiary
	PaisBnf char(3), --  Country of the Beneficiary
	TlfBnf1 char(20), --  Telephone number of the Beneficiary
	TlfBnf2 char(20), -- 	Another telephone number of the Beneficiary
	Notas char(200), --Notes
	IdOfiCorresponsal char(9), --  Number of the correspondents office
	OfiCorresponsal char(50), --  Name of the correspondents office
	IdCorresponsal char(4), -- 	Code assigned for the specific correspondent
	NombreCorresponsal char(50), --  Name of the correspondent
	PaisCorresponsal char(3), --  Country of the correspondent
	Total char(12),	-- Total amount
	Moneda char(3), --  Currency
	PagoBanco char(1), --  Credit in a Bank account
	NombreBanco char(30), -- 	Name of the bank where the beneficiary has the account
	DireccionBanco char(50), --  Address of the bank
	NumeroCuenta char(40), --  Number of the account
	ClaveValidacion char(12), -- Validation key to check Ordering Institution
	ClavePago char(25), --  Payment key known by beneficiary
	TipoDocBnf char(3), --  Type of ID document
	NumDocBnf char(20), --  Beneficiary ID document number
	CodigoOficina char(20), --  Code of payment point
)

alter table MoeX_temp
add tranno int
create table ISO_3166_1_alfa_3(
ISOCode varchar(3),NCIConceptCode varchar(50),NCIPreferredTerm varchar(100)
)
alter table ISO_3166_1_alfa_3 add country varchar(100)

--update ISO_3166_1_alfa_3 set country=NCIPreferredTerm

--spMoeX_import_transaction 'i'
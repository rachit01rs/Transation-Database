--SELECT * FROM static_values where sno=300 order by static_value

INSERT INTO static_values
(
	-- static_id -- this column value is auto-generated,
	sno,
	static_value,
	static_data,
	[Description]
)
VALUES
(
	'300',
	'Relationship',
	'txt_relation',
	'Relationship'
)
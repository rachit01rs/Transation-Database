insert into static_values_type(type_id,type_name,type_description,static_type)
values(99,'States','states','e')

alter table agentbranchdetail
add state_branch varchar(50)

update application_function set main_menu='Utilities' where sno=220

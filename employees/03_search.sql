#search by id
select * from employees where id = 1000;

#search by name
select * from employees where name = 'employee-56';

#search like name
select * from employees where name like 'employee-56%';

#search by department
select * from employees where department_id =100;

#search by department name
select * from employees where department_id in ( select id from departments where name like 'depto-53');

#search by boss id
select * from employees where department_id in 
( 
select id from departments where boss_id =  100
)

#search by birthday

explain analyze select * from employees where birthday > '1980-01-01'::date AND birthday < '1980-12-31'::date

#search by boss name
select * from employees where department_id in 
( 
select id from departments where boss_id in 
(
select id from employees where name like 'employee-56%' 
)
);

#

CREATE INDEX tbl_col_text_pattern_ops_idx ON employees(name text_pattern_ops);

#
create INDEX tbl_col_text_pattern_ops_idx on employees using gin(to_tsvector('english',name));

#
select * from employees where department_id in 
( 
select id from departments where boss_id in 
(
select id from employees where to_tsvector('english',name) @@  to_tsquery('employee-56*') 
)
);




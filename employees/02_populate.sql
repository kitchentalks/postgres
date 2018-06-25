insert into departments(name,boss_id) select 'depto-'||s.a , null from generate_series(1,10000) as s(a);
insert into employees(name) select 'employee-'||s.a  from generate_series(1,1000000) as s(a);

update employees e set birthday=(
select s.a from generate_series('1970-01-01 00:00'::timestamp,
                              '1999-12-04 12:00', '1 week') as s(a)  order by random() limit 1);
select distinct birthday from employees ;

update employees e set birthday=(
select s.a from generate_series('1970-01-01 00:00'::timestamp,
                              '1999-12-04 12:00', '1 week') as s(a) where e.id=e.id order by random() limit 1);

select distinct birthday from employees ;

#
update employees set start_date=(
select s.a from generate_series('2017-01-01 00:00'::timestamp,
                              '2017-12-31 12:00', '1 week') as s(a) order by random() limit 1);

#
update employees e set start_date=(
select s.a from generate_series('2017-01-01 00:00'::timestamp,
                              '2017-12-31 12:00', '1 week') as s(a) where e.id=e.id order by random() limit 1);

#
select distinct start_date from employees ;
#
update employees e set end_date=(
select s.a from generate_series('2018-01-01 00:00'::timestamp,
                              '2018-12-24 12:00', '1 week') as s(a) where e.id=e.id order by random() limit 1)
where random()<0.3;
#
select distinct end_date from employees ;
#


select count(*) from employees where end_date is not null
#
update employees set department_id=(select id from departments order by random() limit 1) ;
#
#
select distinct department_id from employees ;
#
update employees e set department_id=(select id from departments where e.id=e.id order by random() limit 1) ;

#
update departments d set boss_id = 
(select id from employees e where d.id=e.department_id order by e.birthday desc limit 1 );

SELECT pg_size_pretty(pg_relation_size('employees'));
SELECT pg_column_size(t) FROM employees t LIMIT 10;
show temp_buffers;
set temp_buffers='256MB';


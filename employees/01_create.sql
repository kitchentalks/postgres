create table employees
(
id serial primary key,
name varchar(128),
birthday date,
start_date date,
end_date date,
department_id numeric(10,0)
);

create table departments(
id serial primary key,
name varchar(128),
boss_id numeric(10,0)
)


create table employees
(
id serial primary key,
name varchar(128),
birthday date,
start_date date,
end_date date,
department_id integer
);

create table departments(
id serial primary key,
name varchar(128),
boss_id integer
);






-- # activity
select pid,datname,usename,application_name,client_addr,(now() - xact_start) as runtime, (now() - state_change) as state_change,wait_event,wait_event_type,state,query::varchar(80) from pg_stat_activity where pid != pg_backend_pid();

select pid,datname,usename,application_name,client_addr,(now() - xact_start) as runtime, (now() - state_change) as state_change,waiting,state,query::varchar(80) from pg_stat_activity where pid != pg_backend_pid();

-- who is connected to db?
SELECT datname,usename,application_name,client_addr,client_port FROM pg_stat_activity ;

--Identify slowest running queries.   !!!!
SELECT
    pid,
    current_timestamp - xact_start as xact_runtime,
    query
FROM pg_stat_activity
ORDER BY xact_start;

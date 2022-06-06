SELECT pg_terminate_backend(pid),state_change,pid from pg_stat_activity where datname = 'your_db' and state ='active' and now() - state_change >= '00:05:00';

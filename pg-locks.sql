-- ============================== LOCKS Section ======================================
SELECT blocked_locks.pid     AS blocked_pid,
         blocked_activity.usename  AS blocked_user,
         blocking_locks.pid     AS blocking_pid,
         blocking_activity.usename AS blocking_user,
         blocked_activity.query    AS blocked_statement,
         blocking_activity.query   AS current_statement_in_blocking_process
   FROM  pg_catalog.pg_locks         blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks         blocking_locks
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid

    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
   WHERE NOT blocked_locks.GRANTED;

-- LOCKs  view of that same data that includes an idea how old the state is
 SELECT bl.pid                 AS blocked_pid,
         a.usename              AS blocked_user,
         ka.query               AS current_or_recent_statement_in_blocking_process,
         ka.state               AS state_of_blocking_process,
         now() - ka.query_start AS blocking_duration,
         kl.pid                 AS blocking_pid,
         ka.usename             AS blocking_user,
         a.query                AS blocked_statement,
         now() - a.query_start  AS blocked_duration
  FROM  pg_catalog.pg_locks         bl
   JOIN pg_catalog.pg_stat_activity a  ON a.pid = bl.pid
   JOIN pg_catalog.pg_locks         kl ON kl.transactionid = bl.transactionid AND kl.pid != bl.pid
   JOIN pg_catalog.pg_stat_activity ka ON ka.pid = kl.pid
  WHERE NOT bl.GRANTED;

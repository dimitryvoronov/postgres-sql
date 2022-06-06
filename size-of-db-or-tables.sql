--#size of all databases:
select datname, pg_size_pretty(pg_database_size(datname)) as size from pg_database;

--Finding the total size of your biggest tables
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;

  -- sizes, pretty output
	  SELECT
		table_name,
		pg_size_pretty(table_size) AS table_size,
		pg_size_pretty(indexes_size) AS indexes_size,
		pg_size_pretty(total_size) AS total_size
	FROM (
		SELECT
			table_name,
			pg_table_size(table_name) AS table_size,
			pg_indexes_size(table_name) AS indexes_size,
			pg_total_relation_size(table_name) AS total_size
		FROM (
			SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
			FROM information_schema.tables
		) AS all_tables
		ORDER BY total_size DESC
	) AS pretty_sizes;

-- tables/index sizes, but works not everywhere:
SELECT
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN 'Y'
       ELSE 'N'
    END AS UNIQUE,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_tables t
LEFT OUTER JOIN pg_class c ON t.tablename=c.relname
LEFT OUTER JOIN
    ( SELECT c.relname AS ctablename, ipg.relname AS indexname, x.indnatts AS number_of_columns, idx_scan, idx_tup_read, idx_tup_fetch, indexrelname, indisunique FROM pg_index x
           JOIN pg_class c ON c.oid = x.indrelid
           JOIN pg_class ipg ON ipg.oid = x.indexrelid
           JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid )
    AS foo
    ON t.tablename = foo.ctablename
WHERE t.schemaname='public'
ORDER BY 1,2;

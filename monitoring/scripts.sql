select * from pg_stat_activity where state = 'active';

select xmin,xmax,*
from employees limit 1;

SELECT pg_terminate_backend(pg_stat_activity.pid);

show all;


SELECT
 sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM
 pg_statio_user_tables;

  select * from pg_statio_user_tables;

SELECT
 schemaname || '.' || relname AS table,
  indexrelname AS index,
  pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
  idx_scan as index_scans
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
ORDER BY pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
pg_relation_size(i.indexrelid) DESC;

---

WITH constants AS (
    -- define some constants for sizes of things
 -- for reference down the query and easy maintenance
 SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 8 AS ma
),
no_stats AS (
    -- screen out table who have attributes
 -- which dont have stats, such as JSON
 SELECT table_schema, table_name,
        n_live_tup::numeric as est_rows,
        pg_table_size(relid)::numeric as table_size
    FROM information_schema.columns
        JOIN pg_stat_user_tables as psut
           ON table_schema = psut.schemaname
           AND table_name = psut.relname
        LEFT OUTER JOIN pg_stats
        ON table_schema = pg_stats.schemaname
            AND table_name = pg_stats.tablename
            AND column_name = attname
    WHERE attname IS NULL
 AND table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY table_schema, table_name, relid, n_live_tup
),
null_headers AS (
    -- calculate null header sizes
 -- omitting tables which dont have complete stats
 -- and attributes which aren't visible
 SELECT
 hdr+1+(sum(case when null_frac <> 0 THEN 1 else 0 END)/8) as nullhdr,
        SUM((1-null_frac)*avg_width) as datawidth,
        MAX(null_frac) as maxfracsum,
        schemaname,
        tablename,
        hdr, ma, bs
    FROM pg_stats CROSS JOIN constants
        LEFT OUTER JOIN no_stats
            ON schemaname = no_stats.table_schema
            AND tablename = no_stats.table_name
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
        AND no_stats.table_name IS NULL
 AND EXISTS ( SELECT 1
 FROM information_schema.columns
                WHERE schemaname = columns.table_schema
                    AND tablename = columns.table_name )
    GROUP BY schemaname, tablename, hdr, ma, bs
),
data_headers AS (
    -- estimate header and row size
 SELECT
 ma, bs, hdr, schemaname, tablename,
        (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
        (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM null_headers
),
table_estimates AS (
    -- make estimates of how large the table should be
 -- based on row and page size
 SELECT schemaname, tablename, bs,
        reltuples::numeric as est_rows, relpages * bs as table_bytes,
    CEIL((reltuples*
            (datahdr + nullhdr2 + 4 + ma -
                (CASE WHEN datahdr%ma=0
 THEN ma ELSE datahdr%ma END)
                )/(bs-20))) * bs AS expected_bytes,
        reltoastrelid
    FROM data_headers
        JOIN pg_class ON tablename = relname
        JOIN pg_namespace ON relnamespace = pg_namespace.oid
 AND schemaname = nspname
    WHERE pg_class.relkind = 'r'
),
estimates_with_toast AS (
    -- add in estimated TOAST table sizes
 -- estimate based on 4 toast tuples per page because we dont have
 -- anything better. also append the no_data tables
 SELECT schemaname, tablename,
        TRUE as can_estimate,
        est_rows,
        table_bytes + ( coalesce(toast.relpages, 0) * bs ) as table_bytes,
        expected_bytes + ( ceil( coalesce(toast.reltuples, 0) / 4 ) * bs ) as expected_bytes
    FROM table_estimates LEFT OUTER JOIN pg_class as toast
 ON table_estimates.reltoastrelid = toast.oid
 AND toast.relkind = 't'
),
table_estimates_plus AS (
-- add some extra metadata to the table data
-- and calculations to be reused
-- including whether we cant estimate it
-- or whether we think it might be compressed
 SELECT current_database() as databasename,
            schemaname, tablename, can_estimate,
            est_rows,
            CASE WHEN table_bytes > 0
 THEN table_bytes::NUMERIC
 ELSE NULL::NUMERIC END
 AS table_bytes,
            CASE WHEN expected_bytes > 0
 THEN expected_bytes::NUMERIC
 ELSE NULL::NUMERIC END
 AS expected_bytes,
            CASE WHEN expected_bytes > 0 AND table_bytes > 0
 AND expected_bytes <= table_bytes
                THEN (table_bytes - expected_bytes)::NUMERIC
 ELSE 0::NUMERIC END AS bloat_bytes
    FROM estimates_with_toast
    UNION ALL
 SELECT current_database() as databasename,
        table_schema, table_name, FALSE,
        est_rows, table_size,
        NULL::NUMERIC, NULL::NUMERIC
 FROM no_stats
),
bloat_data AS (
    -- do final math calculations and formatting
 select current_database() as databasename,
        schemaname, tablename, can_estimate,
        table_bytes, round(table_bytes/(1024^2)::NUMERIC,3) as table_mb,
        expected_bytes, round(expected_bytes/(1024^2)::NUMERIC,3) as expected_mb,
        round(bloat_bytes*100/table_bytes) as pct_bloat,
        round(bloat_bytes/(1024::NUMERIC^2),2) as mb_bloat,
        table_bytes, expected_bytes, est_rows
    FROM table_estimates_plus
)
-- filter output for bloated tables
SELECT databasename, schemaname, tablename,
    can_estimate,
    est_rows,
    pct_bloat, mb_bloat,
    table_mb
FROM bloat_data
-- this where clause defines which tables actually appear
-- in the bloat chart
-- example below filters for tables which are either 50%
-- bloated and more than 20mb in size, or more than 25%
-- bloated and more than 1GB in size
WHERE ( pct_bloat >= 50 AND mb_bloat >= 20 )
    OR ( pct_bloat >= 25 AND mb_bloat >= 1000 )
ORDER BY pct_bloat DESC;

show MAINTENANCE_WORK_MEM ;

show all;


--- 32 GB * 0.05 ( candidate for maintenance_work_mem )
select 32*0.05

show autovacuum_max_workers;



show wal_buffers;

 show wal_sync_method;
show SHARED_BUFFERS ;

show effective_cache_size;

SELECT schemaname,relname,last_autovacuum,last_autoanalyze FROM pg_stat_all_tables;


SELECT max(age(datfrozenxid)) FROM pg_database;
SELECT datname,age(datfrozenxid) from pg_database ORDER BY
age(datfrozenxid) DESC;
SELECT relname, age(relfrozenxid) FROM pg_class WHERE relkind = 'r' ORDER
BY age(relfrozenxid) DESC;

SELECT *,
 n_dead_tup > av_threshold AS "av_needed",
 CASE WHEN reltuples > 0
 THEN round(100.0 * n_dead_tup / (reltuples))
 ELSE 0
 END
 AS pct_dead
 FROM
(SELECT
N.nspname,
 C.relname,
 pg_stat_get_tuples_inserted(C.oid) AS n_tup_ins,
 pg_stat_get_tuples_updated(C.oid) AS n_tup_upd,
 pg_stat_get_tuples_deleted(C.oid) AS n_tup_del,
 pg_stat_get_live_tuples(C.oid) AS n_live_tup,
 pg_stat_get_dead_tuples(C.oid) AS n_dead_tup,
 C.reltuples AS reltuples,
 round(current_setting('autovacuum_vacuum_threshold')::integer
 + current_setting('autovacuum_vacuum_scale_factor')::numeric *
C.reltuples)
 AS av_threshold, date_trunc('minute',greatest(pg_stat_get_last_vacuum_time(C.oid),
pg_stat_get_last_autovacuum_time(C.oid))) AS last_vacuum, date_trunc('minute',greatest(pg_stat_get_last_analyze_time(C.oid),
pg_stat_get_last_analyze_time(C.oid))) AS last_analyze
 FROM pg_class C
 LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
 WHERE C.relkind IN ('r', 't')
 AND N.nspname NOT IN ('pg_catalog', 'information_schema') AND
 N.nspname !~ '^pg_toast'
) AS av
ORDER BY av_needed DESC,n_dead_tup DESC;

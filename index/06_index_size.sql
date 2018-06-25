SELECT
nspname AS schema_name,
relname AS index_name,
round(100 * pg_relation_size(indexrelid) / pg_relation_size(indrelid)) / 100 AS index_ratio,
pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
pg_size_pretty(pg_relation_size(indrelid)) AS table_size

FROM
pg_index I

LEFT JOIN
pg_class C

ON
(C.oid = I.indexrelid)

LEFT JOIN
pg_namespace N

ON
(N.oid = C.relnamespace)

WHERE
C.relkind = 'i' AND
pg_relation_size(indrelid) > 0 AND
relname='idx_temperature_log_log_timestamp'

ORDER BY
pg_relation_size(indexrelid) DESC, index_ratio DESC;

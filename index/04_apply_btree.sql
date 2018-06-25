CREATE INDEX idx_temperature_log_log_timestamp ON temperature_log USING btree (log_timestamp);
vacuum analyze;


QUERY PLAN
Aggregate  (cost=3136.21..3136.22 rows=1 width=32) (actual time=174.039..174.040 rows=1 loops=1)
  ->  Index Scan using idx_temperature_log_log_timestamp on temperature_log  (cost=0.56..2939.80 rows=78562 width=4) (actual time=60.244..161.055 rows=86400 loops=1)
        Index Cond: ((log_timestamp >= '2016-04-04 00:00:00'::timestamp without time zone) AND (log_timestamp < '2016-04-05 00:00:00'::timestamp without time zone))
Planning time: 18.945 ms
Execution time: 174.177 ms

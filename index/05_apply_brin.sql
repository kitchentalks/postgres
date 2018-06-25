DROP INDEX idx_temperature_log_log_timestamp;

CREATE INDEX idx_temperature_log_log_timestamp ON temperature_log USING BRIN (log_timestamp) WITH (pages_per_range = 128);

vacuum analyse;

EXPLAIN ANALYZE SELECT AVG(temperature) FROM temperature_log WHERE log_timestamp>='2016-04-04' AND log_timestamp<'2016-04-05'; 

Aggregate  (cost=159739.34..159739.35 rows=1 width=32) (actual time=26.676..26.676 rows=1 loops=1)
  ->  Bitmap Heap Scan on temperature_log  (cost=919.37..159523.88 rows=86182 width=4) (actual time=1.000..18.838 rows=86400 loops=1)
        Recheck Cond: ((log_timestamp >= '2016-04-04 00:00:00'::timestamp without time zone) AND (log_timestamp < '2016-04-05 00:00:00'::timestamp without time zone))
        Rows Removed by Index Recheck: 14080
        Heap Blocks: lossy=640
        ->  Bitmap Index Scan on idx_temperature_log_log_timestamp  (cost=0.00..897.82 rows=86182 width=0) (actual time=0.610..0.610 rows=6400 loops=1)
              Index Cond: ((log_timestamp >= '2016-04-04 00:00:00'::timestamp without time zone) AND (log_timestamp < '2016-04-05 00:00:00'::timestamp without time zone))
Planning time: 0.262 ms
Execution time: 26.750 ms





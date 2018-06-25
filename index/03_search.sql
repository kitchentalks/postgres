EXPLAIN ANALYZE SELECT AVG(temperature) FROM temperature_log WHERE log_timestamp>='2016-04-04' AND log_timestamp<'2016-04-05'; 

Aggregate  (cost=674103.68..674103.69 rows=1 width=32) (actual time=12466.447..12466.447 rows=1 loops=1)
  ->  Seq Scan on temperature_log  (cost=0.00..673907.27 rows=78562 width=4) (actual time=3357.070..12458.090 rows=86400 loops=1)
        Filter: ((log_timestamp >= '2016-04-04 00:00:00'::timestamp without time zone) AND (log_timestamp < '2016-04-05 00:00:00'::timestamp without time zone))
        Rows Removed by Filter: 31449601
Planning time: 0.117 ms
Execution time: 12466.520 ms

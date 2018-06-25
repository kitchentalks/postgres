#31536001 fila(s) afectadas.
#Tiempo total de ejecución: 181,241.214 ms

INSERT INTO temperature_log(sensor_id,log_timestamp,temperature) 
VALUES (1,generate_series('2016-01-01'::timestamp,'2016-12-31'::timestamp,'1 second'),round(random()*100)::int);

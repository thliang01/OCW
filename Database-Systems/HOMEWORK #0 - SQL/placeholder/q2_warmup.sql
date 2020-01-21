SELECT city ,COUNT(distinct(station_name)) AS stations_count FROM station group by city order by stations_count ASC , city ASC;

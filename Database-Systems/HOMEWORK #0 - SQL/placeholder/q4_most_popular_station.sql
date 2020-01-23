WITH start_count AS (
	SELECT city AS scity, start_station_name as start_name, count(start_station_id) as count1 from station left join trip
	where station.station_id = trip.start_station_id and trip.start_station_id != trip.end_station_id
	group by start_station_id
),
     end_count AS (
-- count of end station's visits with different end and start station
	SELECT city as ecity, end_station_name as end_name, count(end_station_id) as count2 from station left join trip
	where station.station_id = trip.end_station_id and trip.start_station_id != trip.end_station_id
	group by start_station_id
),
     unique_count AS (
-- count of visits whose end and start station are the same
	select city as ucity, station_name, end_station_name, count(station_name) as count3 from trip left join station
	where station.station_id = trip.start_station_id and station.station_id = trip.end_station_id
	group by station_id
),
    tmp_table1 AS (
	select scity, start_name, (count1 + count2) as partial_count from start_count left join end_count where scity = ecity
	AND start_name = end_name
),
    tmp_table2 AS (
 	SELECT scity, start_name, (partial_count + count3) as total from tmp_table1 left join unique_count where ucity = scity
 	AND start_name = station_name
),
    final_table AS (
     select scity, start_name, sum(total) as res from tmp_table2 group by scity, start_name
)
SELECT scity, start_name ,res from final_table order by res DESC;
WITH diff_end AS (
	select end_city, count(end_city) as diff_end_count from
	(select * from (select id, city as start_city from trip left join station where station.station_id = trip.start_station_id) as A
	left join
	(select id, city as end_city from trip left join station where station.station_id = trip.end_station_id) as B where A.id = B.id)
	where start_city != end_city
	group by end_city
),
diff_start AS (
	select start_city, count(start_city) as diff_start_count from
	(select * from (select id, city as start_city from trip left join station where station.station_id = trip.start_station_id) as A
	left join
	(select id, city as end_city from trip left join station where station.station_id = trip.end_station_id) as B where A.id = B.id)
	where start_city != end_city
	group by start_city
),
unique_dest AS (
	select start_city, count(start_city) as unique_count from
	(select * from (select id, city as start_city from trip left join station where station.station_id = trip.start_station_id) as A
	left join
	(select id, city as end_city from trip left join station where station.station_id = trip.end_station_id) as B where A.id = B.id)
	where start_city == end_city
	group by start_city
),
city_trip_count AS (
	select start_city, (unique_count + diff_start_count + diff_end_count) as city_total_count from
	(SELECT * from unique_dest inner join diff_start where unique_dest.start_city = diff_start.start_city) as tmp
	inner join diff_end
	where tmp.start_city = diff_end.end_city
)
SELECT city_trip_count.start_city,
round((city_trip_count.city_total_count * 1.0 / (select COUNT(*) from trip)), 4) as ratio
from city_trip_count
order by ratio DESC, city_trip_count.start_city ASC;

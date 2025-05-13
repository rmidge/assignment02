/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

  "130"	"Bucks County Community College"
  "128"	"Oxford Valley Mall"
*/

with

shape_geoms as (
    select
        shape_id,
        st_makeline(
            st_makepoint(shape_pt_lon, shape_pt_lat)
            order by shape_pt_sequence
        )::geography as shape_geog
    from septa.bus_shapes
    group by shape_id
),

trip_lengths as (
    select
        t.trip_id,
        t.route_id,
        t.trip_headsign,
        s.shape_geog,
        st_length(s.shape_geog) as shape_length
    from septa.bus_trips as t
    inner join shape_geoms as s using (shape_id)
),

ranked_trips as (
    select
        r.route_short_name,
        t.trip_headsign,
        t.shape_geog,
        t.shape_length,
        row_number() over (partition by r.route_id order by t.shape_length desc) as rn
    from trip_lengths as t
    inner join septa.bus_routes as r using (route_id)
)

select
    route_short_name,
    trip_headsign,
    shape_geog,
    round(shape_length::numeric) as shape_length
from ranked_trips
where rn = 1
order by shape_length desc
limit 2 
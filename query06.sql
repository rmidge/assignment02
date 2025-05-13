/*
  What are the top five neighborhoods according to your accessibility metric?
  Answer:
    "OVERBROOK"
    "OLNEY"
    "SOMERTON"
    "BUSTLETON"
    "LOGAN"
*/

with

neighborhood_bus_stops as (
    select
        n.name as neighborhood_name,
        count(*) as total_stops,
        sum(case when s.wheelchair_boarding = 1 then 1 else 0 end) as accessible_stops
    from phl.neighborhoods as n
    left join septa.bus_stops as s
        on st_contains(n.geog::geometry, s.geog::geometry)
    group by n.name
)

select
    neighborhood_name,
    total_stops,
    accessible_stops as num_bus_stops_accessible,
    (total_stops - accessible_stops) as num_bus_stops_inaccessible,
    case
        when total_stops = 0 then 0
        else (accessible_stops::float / total_stops) * 100
    end as accessibility_percent
from neighborhood_bus_stops
order by total_stops desc, accessibility_percent desc
limit 5

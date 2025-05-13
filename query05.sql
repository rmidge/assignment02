/*
  Rate neighborhoods by both the total number of bus stops and the percentage of those stops that are wheelchair accessible.
  The accessibility metric is calculated as:
  - total_stops: the total number of bus stops in the neighborhood (transit coverage)
  - accessibility_percent: the percentage of those stops that are wheelchair accessible (wheelchair_boarding = 1)
  This approach highlights neighborhoods with both high transit coverage and high accessibility quality.
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
    case
        when total_stops = 0 then 0
        else (accessible_stops::float / total_stops) * 100
    end as accessibility_percent,
    accessible_stops as num_bus_stops_accessible,
    (total_stops - accessible_stops) as num_bus_stops_inaccessible
from neighborhood_bus_stops
order by total_stops desc, accessibility_percent desc

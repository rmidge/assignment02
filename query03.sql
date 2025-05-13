/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop.
  The final result should give the parcel address, bus stop name, and distance apart in meters.

  First 5 rows;
	"170 SPRING LN"	"Ridge Av & Ivins Rd"	1658.82
	"150 SPRING LN"	"Ridge Av & Ivins Rd"	1620.32
	"130 SPRING LN"	"Ridge Av & Ivins Rd"	1611.02
	"190 SPRING LN"	"Ridge Av & Ivins Rd"	1490.10
	"630 SAINT ANDREW RD"	"Germantown Av & Springfield Av "	1418.42
*/

with

parcel_bus_stop_distances as (
    select
        p.address as parcel_address,
        s.stop_name,
        st_distance(p.geog, s.geog) as distance
    from phl.pwd_parcels as p
    cross join lateral (
        select
            stop_name,
            geog
        from septa.bus_stops
        order by p.geog <-> geog
        limit 1
    ) as s
)

select
    parcel_address,
    stop_name,
    round(distance::numeric, 2) as distance
from parcel_bus_stop_distances
order by distance desc 
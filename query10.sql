/*
  Build a description for each rail stop using nearby landmarks and distances.
*/

with

nearest_landmarks as (
    select
        r.stop_id,
        r.stop_name,
        r.stop_lon,
        r.stop_lat,
        p.address as landmark_address,
        st_distance(r.geog, p.geog) as distance,
        st_azimuth(r.geog, st_centroid(p.geog::geometry)::geography) as azimuth,
        row_number() over (
            partition by r.stop_id
            order by
                st_distance(r.geog, p.geog)
        ) as rn
    from (
        select *
        from septa.rail_stops
        limit 10
    ) as r
    cross join lateral (
        select
            p.address,
            p.geog
        from phl.pwd_parcels as p
        where p.address is not null
        order by
            r.geog <-> p.geog
        limit 1
    ) as p
)

select
    nl.stop_id::integer,
    nl.stop_name,
    nl.stop_lon,
    nl.stop_lat,
    case
        when nl.distance < 1000
        then
            round(nl.distance::numeric) || ' meters ' ||
            case
                when nl.azimuth between 0 and pi() / 8
                then 'N'
                when nl.azimuth between pi() / 8 and 3 * pi() / 8
                then 'NE'
                when nl.azimuth between 3 * pi() / 8 and 5 * pi() / 8
                then 'E'
                when nl.azimuth between 5 * pi() / 8 and 7 * pi() / 8
                then 'SE'
                when nl.azimuth between 7 * pi() / 8 and 9 * pi() / 8
                then 'S'
                when nl.azimuth between 9 * pi() / 8 and 11 * pi() / 8
                then 'SW'
                when nl.azimuth between 11 * pi() / 8 and 13 * pi() / 8
                then 'W'
                when nl.azimuth between 13 * pi() / 8 and 15 * pi() / 8
                then 'NW'
                else 'N'
            end || ' of ' || nl.landmark_address
        else
            'Nearest landmark: ' || nl.landmark_address || ' (' || round(nl.distance::numeric) || ' meters away)'
    end as stop_desc
from nearest_landmarks as nl
where nl.rn = 1

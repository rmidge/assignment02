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
        st_azimuth(r.geog, ST_Centroid(p.geog::geometry)::geography) as azimuth,
        row_number() over (partition by r.stop_id order by st_distance(r.geog, p.geog)) as rn
    from (select * from septa.rail_stops limit 10) as r
    cross join lateral (
        select
            address,
            geog
        from phl.pwd_parcels
        where address is not null
        order by r.geog <-> geog
        limit 1
    ) as p
)

select
    stop_id::integer,
    stop_name,
    case
        when distance < 1000 then
            round(distance::numeric) || ' meters ' ||
            case
                when azimuth between 0 and pi()/8 then 'N'
                when azimuth between pi()/8 and 3*pi()/8 then 'NE'
                when azimuth between 3*pi()/8 and 5*pi()/8 then 'E'
                when azimuth between 5*pi()/8 and 7*pi()/8 then 'SE'
                when azimuth between 7*pi()/8 and 9*pi()/8 then 'S'
                when azimuth between 9*pi()/8 and 11*pi()/8 then 'SW'
                when azimuth between 11*pi()/8 and 13*pi()/8 then 'W'
                when azimuth between 13*pi()/8 and 15*pi()/8 then 'NW'
                else 'N'
            end || ' of ' || landmark_address
        else
            'Nearest landmark: ' || landmark_address || ' (' || round(distance::numeric) || ' meters away)'
    end as stop_desc,
    stop_lon,
    stop_lat
from nearest_landmarks
where rn = 1 
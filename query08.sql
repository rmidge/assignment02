/*
  With a query, find out how many census block groups Penn's main campus fully contains.
  Used the upenn_extent table (loaded from GeoJSON) to define Penn's campus.
  Answer: 17
*/

with penn_campus as (
    select 
        st_union(geog::geometry)::geography as geog 
    from upenn_extent
)

select
    count(*) as count_block_groups
from census.blockgroups_2020 as bg
inner join penn_campus as p
    on st_contains(p.geog::geometry, bg.geog::geometry) 
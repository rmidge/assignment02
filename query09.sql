/*
  With a query involving PWD parcels and census block groups, find the geo_id of the block group
  that contains Meyerson Hall.
  210 South 34th Street; Philadelphia, Pennsylvania United States
  Using the address of the building next door since 210 S 34th is not in the dataset.

  Answer: 421010369022
*/

select
    bg.geoid as 
        geo_id
from census.blockgroups_2020 as bg
inner join phl.pwd_parcels as p
    on st_contains(bg.geog::geometry, p.geog::geometry)
where p.address ilike '%220-30 S 34TH ST%'
limit 1

-- retention rate = retained customer/total customer

with query_sql as (
    select *
    from dwh_metabase.query
    where question_type = 'SQL query' and context = 'ad-hoc' and user_id not in (1,5))
, first_week_table as (
    select user_id, date_trunc('week', MIN (started_at)) as first_week
    from query_sql
    group by user_id
    order by 1)
, new_user_by_week as (
    select first_week, count (user_id) as new_mem
    from first_week_table
    group by first_week
    order by 1)
 , week_user_table as (
    select user_id, date_trunc ('week', started_at) as week_user
    from query_sql
    group by user_id, date_trunc ('week', started_at)
    order by 1,2)
, retained_user_table as (
    select first_week, week_user, count (week_user_table. user_id) as retained_user
    from week_user_table
    left join first_week_table on first_week_table.user_id = week_user_table.user_id
    group by first_week, week_user
    order by 1,2)
select retained_user_table.*, 
    new_user_by_week.new_mem,
    retained_user::numeric/new_mem as ti_le_giu_chan,
    concat ('week', ' ', (week_user::date - retained_user_table.first_week::date)/7)
from retained_user_table
left join new_user_by_week on new_user_by_week.first_week = retained_user_table.first_week




with days as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2025-01-01' as date)",
        end_date="cast('2027-01-01' as date)"
    ) }}
)

select
    cast(date_day as date)               as date_day,
    extract(year from date_day)          as year,
    extract(month from date_day)         as month,
    cast(date_trunc('month', date_day) as date) as month_start,
    extract(isodow from date_day)        as iso_weekday
from days
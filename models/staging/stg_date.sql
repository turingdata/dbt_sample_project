{{ 
    config(
        enabled=true
    ) 
}}

{{ dbt_date.get_date_dimension("2020-10-01", "2022-08-30") }}

{{ 
    config(
        enabled=true
    ) 
}}

{{ dbt_date.get_date_dimension("2022-04-01", "2022-04-30") }}

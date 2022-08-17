{{ config(materialized = 'ephemeral') }} 

with {{   create_multiple_ctes_with_ref_function_macro([
          ('cte__date', 'dim_date')
        , ('cte__subscriptions', 'fct_recharge_subscriptions')
])
}}

,daily_subscriptions as (
    with daily_status as (
        select 
            cte__date.date_id
            , cte__subscriptions.*
            , case 
                when cte__subscriptions.subscription_cancelled_date=cte__date.date_id then 'CANCELLED' 
            else 'ACTIVE' end 
            as subscription_daily_status
        from cte__date
        left join cte__subscriptions 
            on cte__date.date_id between cte__subscriptions.first_day_active and cte__subscriptions.last_day_active
    )
    select
        daily_status.*
        , case 
            when daily_status.date_id=daily_status.subscription_created_date then 1 else 0
          end as is_subscription_new
        , case 
            when daily_status.date_id=daily_status.subscription_cancelled_date then 1 else 0
          end as is_subscription_cancelled
        , case 
            when daily_status.subscription_daily_status='ACTIVE' then 1 else 0
          end as is_subscription_active
    from daily_status
)


, final as (
  select 
    *
  from daily_subscriptions
  
)
select * from final
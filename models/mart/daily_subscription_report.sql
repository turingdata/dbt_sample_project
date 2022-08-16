{{ config(materialized = 'ephemeral') }} 

with {{   create_multiple_ctes_with_ref_function_macro([
          ('cte__date', 'dim_date')
        , ('cte__subscriptions', 'fct_recharge_subscriptions')
])
}}

,new_customers as(
    select 
        cte__date.date_id
        , count(cte__subscriptions.subscription_id) as subscriptions_new
from cte__date
left join cte__subscriptions on cte__date.date_id=cte__subscriptions.subscription_created_date
group by 1
)

,previous_customers as (
  select distinct 
    customer_id
  from cte__subscriptions
  where 1=1
    and subscription_status = 'CANCELLED'
)

,returning_subscriptions as(
    select 
        cte__date.date_id
        , count(cte__subscriptions.subscription_id) as subscriptions_returning
    from cte__date
    left join cte__subscriptions on cte__date.date_id=cte__subscriptions.subscription_created_date
    where  1=1
    and cte__subscriptions.customer_id in (select customer_id from previous_customers)
    group by 1
)


, active_subscriptions as (
    select 
        cte__date.date_id
        , count(cte__subscriptions.subscription_id) as subscriptions_active
    from cte__date
    left join cte__subscriptions on (cte__subscriptions.first_day_active <= cte__date.date_id) and (cte__date.date_id <= cte__subscriptions.last_day_active)
    group by 1
)

, churned_subscriptions as (
    select 
        cte__date.date_id
        , count(cte__subscriptions.subscription_id) as subscription_cancelled

    from cte__date
    left join cte__subscriptions on cte__date.date_id = cte__subscriptions.subscription_cancelled_date
    group by 1
)

, final as (
  select 
    cte__date.date_id
    ,new_customers.subscriptions_new
    ,returning_subscriptions.subscriptions_returning
    ,active_subscriptions.subscriptions_active
    , sum(churned_subscriptions.subscription_cancelled) over (order by cte__date.date_id ASC ) subscription_churned

  from cte__date
  left join new_customers on cte__date.date_id = new_customers.date_id
  left join returning_subscriptions on cte__date.date_id = returning_subscriptions.date_id
  left join active_subscriptions on cte__date.date_id = active_subscriptions.date_id
  left join churned_subscriptions on cte__date.date_id = churned_subscriptions.date_id

)
select * from final
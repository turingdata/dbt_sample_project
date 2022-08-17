{{ config(materialized = 'ephemeral') }} 

with {{   create_multiple_ctes_with_ref_function_macro([
          ('cte__date', 'dim_date')
        , ('cte__subscriptions', 'fct_recharge_subscriptions')
])
}}

,daily_subscriptions as (
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


,customer_first_created_dates as(
  with customers_ranked as (
    select 
      *
      , row_number() over (partition by customer_id order by subscription_created_date ASC) ranked
    from cte__subscriptions
    )
    select distinct
        daily_subscriptions.*
        ,customers_ranked.subscription_created_date as customer_first_created_date
        , case 
            when customers_ranked.subscription_created_date = daily_subscriptions.date_id then 1 else 0 
          end as is_new_customer
    from daily_subscriptions
    left join customers_ranked on daily_subscriptions.customer_id = customers_ranked.customer_id
    where customers_ranked.ranked=1
)

,returning_customers as(
    select 
      customer_first_created_dates.*
      , case 
          when is_new_customer=0 and subscription_created_date=date_id then 1 else 0
        end as is_returning_customer
    from customer_first_created_dates
)


, customers_statuses as (
    with customers_daily_status as (
      select 
        date_id
        ,customer_id
        , ARRAY_AGG(subscription_daily_status) as daily_status
      from daily_subscriptions
      group by 1,2
    )
    ,customer_status as (
    select 
      date_id
      ,customer_id
      ,'ACTIVE' in unnest(daily_status) as is_customer_active
    from customers_daily_status
    group by 1,2,3
    )
    select 
      date_id
      ,customer_id
      ,case when is_customer_active then 1 else 0 end is_customer_active
      ,case when is_customer_active then 0 else 1 end is_customer_cancelled
    from customer_status
)

, final as (
  select 
    returning_customers.*
    ,customers_statuses.is_customer_active
    ,customers_statuses.is_customer_cancelled
  from returning_customers
  left join customers_statuses 
    on returning_customers.date_id=customers_statuses.date_id 
      and returning_customers.customer_id=customers_statuses.customer_id 
  order by 1 asc
)
select * from final
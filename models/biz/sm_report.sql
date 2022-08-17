
with {{   create_multiple_ctes_with_ref_function_macro([
          ('cte__subscriber', 'daily_subscriber_report')
          ,('cte__subscription', 'daily_subscription_report')
])
}}

,subscription_summary as (
    SELECT
        cte__subscription.date_id
        ,sum(cte__subscription.is_subscription_new) as subscription_new
        ,sum(cte__subscription.is_subscription_cancelled) as subscription_cancelled
        ,sum(cte__subscription.is_subscription_active) as subscription_active
    from cte__subscription
    group by 1
    order by 1 ASC
)

,subscription_summary_churned_subscription as (
    select 
     subscription_summary.*
     , sum (subscription_cancelled) over (order by date_id ASC) as subscription_churned
    from subscription_summary
)

,subscribers_summary as (
    SELECT
        cte__subscriber.date_id
        ,sum(cte__subscriber.is_returning_customer) as subscription_returning
        ,sum(cte__subscriber.is_new_customer) as subscribers_new
        ,sum(cte__subscriber.is_customer_cancelled) as subscribers_cancelled
        ,sum(cte__subscriber.is_customer_active) as subscribers_active
    from cte__subscriber
    group by 1
    order by 1 ASC
)

,subscriber_summary_churned_customers as (
    select 
     subscribers_summary.*
     , sum (subscribers_cancelled) over (order by date_id ASC) as subscribers_churned
    from subscribers_summary
)

,final as (
    select
        date_id
        ,subscription_new
        ,subscription_returning
        ,subscription_cancelled
        ,subscription_active
        ,subscription_churned
        ,subscribers_new
        ,subscribers_cancelled
        ,subscribers_active
        ,subscribers_churned
    from subscription_summary_churned_subscription
    inner join subscriber_summary_churned_customers using(date_id)
)



select * from final
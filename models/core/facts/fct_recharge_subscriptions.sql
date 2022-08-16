{{ config(materialized = 'ephemeral') }} 

with {{   create_multiple_ctes_with_ref_function_macro([
          ('cte__subscriptions', 'stg_recharge_subscriptions')
]) }}

, convert_to_date as (
    select 
        subscription_id
        ,subscription_status
        , cast(subscription_created_at as date)          as subscription_created_date
        , cast(subscription_updated_at as date)          as subscription_updated_date
        , cast(subscription_cancelled_at as date)         as subscription_cancelled_date
        , cast(next_charge_scheduled_at as date)         as next_charge_scheduled_date
    from cte__subscriptions
)

,subscription_active_dates as (
  select 
    subscription_id
    ,subscription_created_date as first_day_active
    , case when subscription_status = 'CANCELLED' THEN subscription_cancelled_date else current_date end as last_day_active
  from convert_to_date
)

, final as (
    select 
        subscription_id
        , customer_id
        , product_sku
        , email_id
        , product_title_id
        , product_price
        , cte__subscriptions.subscription_status
        , quantity_subscribed
        , is_prepaid
        , subscription_properties
        , is_subscription_skippable
        , is_subscription_swappable
        , is_sku_override
        , commit_update
        , variant_title
        , analytics_data
        , order_day_of_week
        , has_queued_charges
        , order_day_of_month
        , shopify_product_id
        , shopify_variant_id
        , cancellation_reason
        , max_retries_reached
        , order_interval_unit
        , recharge_product_id
        , order_interval_frequency
        , charge_interval_frequency
        , cancellation_reason_comments
        , expire_after_specific_number_of_charges
        , utm_params
        , subscription_created_date
        , subscription_updated_date
        , subscription_cancelled_date
        , next_charge_scheduled_date
        , subscription_active_dates.first_day_active
        , subscription_active_dates.last_day_active
    from cte__subscriptions
    left join convert_to_date using (subscription_id)
    left join subscription_active_dates using (subscription_id)
)

select * from final
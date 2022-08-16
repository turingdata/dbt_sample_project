{{ config(materialized = 'ephemeral') }} 

with source as (
    select *
    from {{ source( 'raw_data_sandbox', 'recharge_subscriptions' ) 
    }}
)
, cast_renamed as (
    select 
        id                               as subscription_id,
        customer_id                      as customer_id,
        sku                              as product_sku,
        email                            as email_id,
        product_title                    as product_title_id,
        price                            as product_price,
        status                           as subscription_status,
        quantity                         as quantity_subscribed,
        cast(created_at as timestamp)    as subscription_created_at,
        is_prepaid                       as is_prepaid,
        properties                       as subscription_properties,
        cast(updated_at as timestamp)    as subscription_updated_at,
        cast(cancelled_at as timestamp)  as subscription_cancelled_at,
        cast(is_skippable as BOOL)       as is_subscription_skippable,
        cast(is_swappable as BOOL)       as is_subscription_swappable,
        cast(sku_override as BOOL)       as is_sku_override,
        commit_update                    as commit_update,
        variant_title                    as variant_title,
        analytics_data                   as analytics_data,
        order_day_of_week                as order_day_of_week,
        has_queued_charges               as has_queued_charges,
        order_day_of_month               as order_day_of_month,
        shopify_product_id               as shopify_product_id,
        shopify_variant_id               as shopify_variant_id,
        cancellation_reason              as cancellation_reason,
        max_retries_reached              as max_retries_reached,
        order_interval_unit              as order_interval_unit,
        recharge_product_id              as recharge_product_id,
        cast(next_charge_scheduled_at as timestamp) as next_charge_scheduled_at,
        order_interval_frequency         as order_interval_frequency,
        charge_interval_frequency        as charge_interval_frequency,
        cancellation_reason_comments     as cancellation_reason_comments,
        expire_after_specific_number_of_charges  as expire_after_specific_number_of_charges,
        json_extract_array( analytics_data, '$.utm_params' ) as utm_params
    from source
)
select *
from cast_renamed
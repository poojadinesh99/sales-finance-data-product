select distinct
    service_code,
    case service_code
        when 'BUSINESS'    then 'Business Parcel'
        when 'EXPRESS'     then 'Express Parcel'
        when 'EURO'        then 'Euro Business Parcel'
        when 'SHOP_RETURN' then 'Shop Return'
    end as service_name
from {{ ref('stg_contracts') }}
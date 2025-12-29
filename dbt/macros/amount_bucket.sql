{% macro amount_bucket(amount_col) -%}
    case
        when {{ amount_col }} < 50 then 'S'
        when {{ amount_col }} < 200 then 'M'
        when {{ amount_col }} < 1000 then 'L'
        else 'XL'
    end
{%- endmacro %}

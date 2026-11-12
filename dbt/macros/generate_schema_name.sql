{# Use the schema names from dbt_project.yml as-is (staging, marts, reference)
   instead of dbt's default "main_staging" style prefixes. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}{{ target.schema }}{%- else -%}{{ custom_schema_name | trim }}{%- endif -%}
{%- endmacro %}

--http://tech.valgog.com/2011/02/pgadmin-iii-macros-get-table-fields.html
select quote_ident(nspname) || '.' || quote_ident(relname) as table_name, 
       quote_ident(attname) as field_name, 
       format_type(atttypid,atttypmod) as field_type, 
       case when attnotnull then ' NOT NULL' else '' end as null_constraint,
       case when atthasdef then 'DEFAULT ' || 
                                ( select pg_get_expr(adbin, attrelid) 
                                    from pg_attrdef 
                                   where adrelid = attrelid and adnum = attnum )::text else ''
       end as dafault_value,
       case when nullif(confrelid, 0) is not null
            then confrelid::regclass::text || '( ' || 
                 array_to_string( ARRAY( select quote_ident( fa.attname ) 
                                           from pg_attribute as fa 
                                          where fa.attnum = ANY ( confkey ) 
                                            and fa.attrelid = confrelid
                                          order by fa.attnum 
                                        ), ','
                                 ) || ' )'
            else '' end as references_to
  from pg_attribute 
       left outer join pg_constraint on conrelid = attrelid 
                                    and attnum = conkey[1] 
                                    and array_upper( conkey, 1 ) = 1,
       pg_class, 
       pg_namespace
 where pg_class.oid = attrelid
   and pg_namespace.oid = relnamespace
   and pg_class.oid = btrim( '$SELECTION$' )::regclass::oid
   and attnum > 0
   and not attisdropped
 order by attrelid, attnum;
 
 
 -- Alternative 
 -- http://analytikdat.cz/index.php/entry/macros-in-pgadmin
 with 

s as (
  select 
    case when position('.' in '$SELECTION$') = 0 then table_schema || '.' else '' end || selection as selection
  from
    information_schema.tables
    cross join (select lower(regexp_replace('$SELECTION$', E'[\n\r ]+', '', 'g'))::text as selection) s
  where
   case
      when position('.' in selection) = 0 then table_name = selection
      else lower(table_schema) || '.' || table_name = selection  end  
  limit 1
)
    
, raw_data as (

  select 
    column_name as property,
    data_type as value,
    'column_02'::text as obj_type
  from 
    information_schema.columns 
    cross join s
  where 
    case
      when position('.' in selection) = 0 then table_name = s.selection
      else lower(table_schema || '.' || table_name) = selection end

  union all
  
  select 
    conname,
    pg_catalog.pg_get_constraintdef(r.oid, true) as condef,
    'constraint_02'::text as obj_type
  from 
    pg_catalog.pg_constraint r
    cross join s
  where 
    r.conrelid = s.selection::regclass 
    and r.contype in ('p', 'f') 

  union all

  values
    ('--Constraints--','---','constraint_01'),
    ('--Columns--','---','column_01')

)

select 
  property, 
  value 
from 
  raw_data 
order by 
  obj_type, 
  property,
  value 
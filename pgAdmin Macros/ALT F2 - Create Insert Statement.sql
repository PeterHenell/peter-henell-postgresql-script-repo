
with datatype_to_placeholder(data_type, replacement) as (
	select 'timestamp without time zone', 'now()' UNION ALL 	select 'timestamp with time zone', 'now()' UNION ALL 
	select 'integer', '0' UNION ALL 	select 'char', '''''' UNION ALL 
	select 'boolean', '0' UNION ALL 	select 'date', 'now()' UNION ALL 
	select 'text', '''''' UNION ALL 	select 'bytea', '0x0' UNION ALL 
	select 'bit', '0::bit' UNION ALL	select 'interval', '''1 year 2 months 3 days 4 hours 5 minutes 6 seconds''' UNION ALL 
	select 'anyarray', 'ARRAY[]' UNION ALL 	select 'character varying', '''''' UNION ALL 
	select 'inet', '0' UNION ALL 		select 'numeric', '0' UNION ALL 
	select 'abstime', 'now()' UNION ALL 	select 'pg_node_tree', '0' UNION ALL 
	select 'regproc', '''''' UNION ALL 	select 'name', '''''' UNION ALL 
	select 'bigint', '0' UNION ALL 		select 'ARRAY', 'ARRAY[]' UNION ALL 
	select 'oid', '0' UNION ALL 		select 'real', '0' UNION ALL 
	select 'xid', '0' UNION ALL 		select 'double precision', '0' UNION ALL 
	select 'smallint', '0' UNION ALL 	select 'uuid', ''''''
)
select CONCAT('INSERT INTO ', lower(TABLE_SCHEMA || '.' || TABLE_NAME), '(' , columnNames, ') VALUES(
' ,columnTypes, ')') as insertString
from 
	information_schema.tables tabl
cross join lateral
(
	select 
		string_agg(column_name::text, ', ') ,
		string_agg(overlay(
				replacementValue || '                ' 
				placing columnInformation 
				from 15 for char_length(columnInformation)) 
			, ', 
') 		
	from information_schema.columns cols 
	left outer join
		datatype_to_placeholder ph
		on lower(ph.data_type) = lower(cols.data_type)
	cross join lateral (
		values(CASE when cols.is_nullable = 'YES' then 'NULL'  ELSE COALESCE(ph.replacement, '''') END)
	) as rep(replacementValue)
	cross join lateral ( 
		values('/* ' || column_name || '(' || cols.data_type || ') */ ')
	) as inf(columnInformation)

	where 	cols.table_name = tabl.table_name 
		and cols.table_schema = tabl.table_Schema
	
)  as col(columnNames, columnTypes)

where 
	lower(tabl.table_schema) = 
		CASE WHEN POSITION('.' IN '$SELECTION$') > 0 THEN lower(substring('$SELECTION$' from 1 for position('.' in '$SELECTION$') - 1))
		ELSE 'public' END
	and lower(tabl.table_name) = 
		lower(substring('$SELECTION$' from position('.' in '$SELECTION$') + 1))
		
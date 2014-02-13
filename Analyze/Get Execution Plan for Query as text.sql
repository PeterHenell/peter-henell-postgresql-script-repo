create function expl(q text) returns setof text as $$
 declare r record;
 begin
   for r in execute 'explain ' || q loop
     return next r."QUERY PLAN";
   end loop;
 end $$ language plpgsql;
 

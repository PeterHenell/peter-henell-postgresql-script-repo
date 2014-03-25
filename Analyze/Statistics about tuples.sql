SELECT relname,relpages,reltuples FROM pg_class WHERE relname='t';
--A manual ANALYZE step will make sure all the statistics are current,



-- display how large an index is
SELECT relname,reltuples,relpages FROM pg_class WHERE relname='i';

SELECT relname,round(reltuples / relpages) AS rows_per_page FROM pg_class 
WHERE relname='i';


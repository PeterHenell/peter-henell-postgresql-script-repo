CREATE OR REPLACE VIEW table_stats 
AS
	SELECT
		stat.relname AS relname, 
		seq_scan, seq_tup_read, idx_scan, idx_tup_fetch,
		heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit 
	FROM
		pg_stat_user_tables stat
	RIGHT JOIN 
		pg_statio_user_tables statio 
		ON stat.relid=statio.relid;

--For the examples coming up, the following snippet of code is used after each 
--statement (with t being the only table they use) to show the buffer usage count 
--statistics that follow the query:

SELECT pg_sleep(1);
\pset x on -- one field per row output
SELECT * FROM table_stats WHERE relname='t';
SELECT pg_stat_reset();
\pset x off



-- This is a full table scan
-- -> Seq Scan on t (cost=0.00..1693.00 rows=9903 width=0) (actual

-- This is a search that is using an index
-- -> Index Scan using t_pkey on t (cost=0.00..8.28 rows=1 width=0)


-- this query will show the buffers hit and read
-- 
EXPLAIN (ANALYZE ON, BUFFERS ON) SELECT count(*) FROM t WHERE v=5;
/* QUERY PLAN 
----------------------------------
Aggregate (cost=1717.71..1717.72 rows=1 width=0) (actual 
time=75.539..75.541 rows=1 loops=1)
 Buffers: shared hit=443
 -> Seq Scan on t (cost=0.00..1693.00 rows=9883 width=0) (actual 
time=20.987..58.050 rows=9993 loops=1)
 Filter: (v = 5)
 Buffers: shared hit=443 */
 
 -- Buffers: is the amount of pages
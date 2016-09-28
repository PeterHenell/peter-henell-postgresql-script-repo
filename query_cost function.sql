-- Thanks to http://stackoverflow.com/questions/39732612/postgres-get-the-query-cost-assign-to-a-variable
CREATE OR REPLACE FUNCTION query_cost(
      queries text[],
      query OUT text, cost OUT float8, duration OUT float8
   ) RETURNS SETOF record LANGUAGE plpgsql STRICT AS
$$DECLARE
   i integer;
   p json;
BEGIN
   /* loop through input queries */
   FOR i IN array_lower(queries, 1)..array_upper(queries, 1) LOOP
      query := queries[i];
      /* get execution plan in JSON */
      EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || query INTO p;
      /* extract total cost and execution time */
      SELECT p->0->'Plan'->>'Total Cost',
             p->0->'Plan'->>'Actual Total Time'
         INTO cost, duration;
      /* return query, cost and duration */
      RETURN NEXT;
   END LOOP;
END;$$;
You can use it like this:

SELECT *
FROM query_cost(
        ARRAY[
           'SELECT 42',
           'SELECT count(*) FROM large'
        ]
     )
ORDER BY duration DESC;

┌────────────────────────────┬─────────┬──────────┐
│           query            │  cost   │ duration │
├────────────────────────────┼─────────┼──────────┤
│ SELECT count(*) FROM large │ 1693.01 │  150.171 │
│ SELECT 42                  │    0.01 │    0.002 │
└────────────────────────────┴─────────┴──────────┘
(2 rows)

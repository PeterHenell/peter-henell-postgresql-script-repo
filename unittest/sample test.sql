 -- define the API

-- setup class that will include tests.
-- Should setup a schema and some talbes inside it perhaps
-- This should first drop the schema including all objects inside it.
DO language plpgsql $$
 BEGIN
   PERFORM pgSQLt.NewTestClass ('GetCustomerByName');
 END
 $$;

 -- each class should be able to have a SetUp function that would be called before each test function
create function GetCustomerByName.SetUp()
returns void
as $$

	INSERT INTO public.orders(orderid, orderdate, customerid, netamount, tax, totalamount) VALUES(
		0             /* orderid(integer) */ , 
		now()         /* orderdate(date) */ , 
		NULL          /* customerid(integer) */ , 
		0             /* netamount(numeric) */ , 
		0             /* tax(numeric) */ , 
		0             /* totalamount(numeric) */ );
	

$$ language sql;

-- Run each function in a test class
-- select tSQLt.Run('[dbo.GetEndOfDaySummaryTest]');

-- ... or run all testclasses
-- select tSQLt.RunAll();
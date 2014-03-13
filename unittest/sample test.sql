﻿/*
        Copyright 2014 Peter Henell

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

                http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS $$ IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

*/

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
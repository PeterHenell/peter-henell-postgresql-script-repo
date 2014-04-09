﻿-- Copyright 2014 Peter Henell
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.


--                       WHAT IS THIS DOCUMENT?
-- This document is the unit test for the test framework itself.
-- Running this should indicate that the framework is in good shape.

DO language plpgsql $$
 BEGIN
   PERFORM pgSQLt.new_test_class ('InternalUnitTest');
   delete from public.orders;
 END
 $$;

 -- each class should be able to have a SetUp function that would be called before each test function
create function InternalUnitTest.setup()
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

DO language plpgsql $$
 BEGIN
   perform pgSQLt.private_split_object_name('InternalUnitTest.ShouldGetCustomerByName');
   if not found then
	raise exception 'could not split string into schema and object'; 
   end if;
 END
 $$;


create function InternalUnitTest.ShouldMakeSureSetupIsCalledBefore()
returns void
as
$BODY$
declare
	tableShouldHaveOneRow int;
BEGIN
	select 1 into tableShouldHaveOneRow from public.orders;
	if not found then
		raise exception 'setup was not run';
	end if;
END
$BODY$ language plpgsql;


create function InternalUnitTest.ShouldReturnErrorWhenErrorInTestMethod()
returns void
as
$BODY$

BEGIN
	select 1 / 0;
END
$BODY$ language plpgsql;



create function InternalUnitTest.ShouldAssertThatTwoEqualStringsAreEqual()
returns void
as
$BODY$

BEGIN
	perform pgSQLt.assert_equal_strings('pgsqlt', 'pgsqlt');
END
$BODY$ language plpgsql;


create function InternalUnitTest.ShouldAssertThatTwoDifferentStringsAreNotEqual()
returns void
as
$BODY$

BEGIN
	perform pgSQLt.assert_equal_strings('pgsqlt', 'postgres');
END
$BODY$ language plpgsql;


create function InternalUnitTest.should_split_object_name()
returns void
as
$BODY$

BEGIN
	perform pgSQLt.assert_equal_strings('class', schema_name) from pgSQLt.private_split_object_name('class.method');
	perform pgSQLt.assert_equal_strings('method',object_name) from pgSQLt.private_split_object_name('class.method');

	perform pgSQLt.assert_equal_strings('public', schema_name) from pgSQLt.private_split_object_name('method');
	perform pgSQLt.assert_equal_strings('method', object_name) from pgSQLt.private_split_object_name('method');
	
END
$BODY$ language plpgsql;

create function InternalUnitTest.should_error_if_test_not_started()
returns void
as
$BODY$

BEGIN
	perform pgSQLt.assert_equal_strings('class', 'class');	
END
$BODY$ language plpgsql;


-- Execution of test methods
-- This part of the document is running and validating framework tests.
DO language plpgsql $$
declare
	res pgSQLt.test_report;
	
 BEGIN
	select * into res from pgSQLt.Run('InternalUnitTest.ShouldMakeSureSetupIsCalledBefore');
	if res.message != 'Test succeded' and res.result = 'OK' THEN
		raise exception 'test should have finished ok but didnt [%]', res.message;
	end if;   

	select * into res from pgSQLt.Run('InternalUnitTest.ShouldReturnErrorWhenErrorInTestMethod');
	if res.result != 'ERROR' THEN
		raise exception 'test should have return ERROR but didnt, instead we got: [%]', res.message;
	end if;
		
	select * into res from pgSQLt.Run('DoesNotExist.ShouldThrowExceptionThatTestClassIsMissing');
 	if res.result != 'ERROR' THEN
		raise exception 'test should have return ERROR but didnt, instead we got: [%]', res.message;
	end if;	


	-- Assertion tests
	select * into res from pgSQLt.Run('InternalUnitTest.ShouldAssertThatTwoEqualStringsAreEqual');
	if res.result != 'OK' THEN
		raise exception 'two strings should be asserted to be equal if they are equal instead we got: [%]', res.message;
	end if;
	select * into res from pgSQLt.Run('InternalUnitTest.ShouldAssertThatTwoDifferentStringsAreNotEqual');
	if res.result != 'FAIL' THEN
		raise exception 'Should not be equal. Instead we got: [%]', res.message;
	end if;

	select * into res from pgSQLt.Run('InternalUnitTest.ShouldAssertThatTwoDifferentStringsAreNotEqual');
	if res.result != 'FAIL' THEN
		raise exception 'Should not be equal. Instead we got: [%]', res.message;
	end if;

	if (select count(*) from pgSQLt.run_class('InternalUnitTest') where result != 'OK') != 2 THEN
		raise exception 'Only two of the tests are expected to fail';		
	end if;	
EXCEPTION 
	when others then
		raise notice 'Omg';
 END
 $$;

DO language plpgsql $$
declare
	res pgSQLt.test_report;	
BEGIN
	perform InternalUnitTest.should_error_if_test_not_started();
	raise exception 'Should have failed because test session have not been started';
EXCEPTION 
	when sqlstate 'ERROR' then	
		raise notice 'Test Completed OK!';
	when sqlstate 'ALLOK' then
		raise exception 'Test should have failed in ERROR';
	when others then
		raise exception 'Test should have failed in ERROR';
 END
 $$;



select * from pgSQLt.run_class('InternalUnitTest') where result in( 'FAIL', 'ERROR');
-- select routine_name from information_schema.routines 
-- where routine_schema = lower('InternalUnitTest') and lower(routine_name) != 'setup'

select * from pgSQLt.test_session

 


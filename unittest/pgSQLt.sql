-- Copyright 2014 Peter Henell
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



drop schema IF EXISTS pgSQLt cascade;

create schema pgSQLt;

create table pgsqlt.test_class(
	class_id serial primary key,
	name text
);


create function pgSQLt.NewTestClass(className text)
returns void
as
$$ 
DECLARE
	sql text;
begin

	sql := 'DROP SCHEMA IF EXISTS ' || className || ' CASCADE';
	EXECUTE (sql);
	sql := 'CREATE SCHEMA ' || className;
	EXECUTE (sql);
	insert into pgsqlt.test_class (name) values(className);
	
end
$$ language plpgsql;


-- CREATE TABLE pgSQLt.CaptureOutputLog (
--   Id SERIAL PRIMARY KEY ,
--   OutputText text
-- );

-- 
-- CREATE VIEW pgSQLt.TestClasses
-- AS
--   -- SELECT s.name AS Name, s.schema_id AS SchemaId
-- --     FROM sys.extended_properties ep
-- --     JOIN sys.schemas s
-- --       ON ep.major_id = s.schema_id
-- --    WHERE ep.name = N'pgSQLt.TestClass';
-- select 1
-- ;
-- 
-- CREATE VIEW pgSQLt.Tests
-- AS
-- --   SELECT classes.SchemaId, classes.Name AS TestClassName, 
-- --          procs.object_id AS ObjectId, procs.name AS Name
-- --     FROM pgSQLt.TestClasses classes
-- --     JOIN sys.procedures procs ON classes.SchemaId = procs.schema_id
-- --    WHERE LOWER(procs.name) LIKE 'test%';
-- select 1
-- ;


-- CREATE TABLE pgSQLt.TestResult(
--     Id SERIAL PRIMARY KEY ,
--     Class text NOT NULL,
--     TestCase text NOT NULL,
--     TranName text NOT NULL,
--     Result text NULL,
--     Msg text NULL
-- );

-- CREATE TABLE pgSQLt.TestMessage(
--     Msg text
-- );
-- ;
-- CREATE TABLE pgSQLt.Run_LastExecution(
--     TestName text,
--     SessionId INT,
--     LoginTime timestamp
-- );

create type pgSQLt.test_execution_result as ENUM ('OK', 'FAIL', 'ERROR');
create type pgSQLt.test_report as (test_name text, message text, result pgSQLt.test_execution_result);



create function pgSQLt.private_split_object_name(objectName text, out schema_name text , out object_name text )
returns record AS
$$
begin	
	select 
		case when strpos(objectName, '.') = 0 then 'public'
		     else split_part(objectName, '.', 1)
		end, 
		case when strpos(objectName, '.') = 0 then objectName
		     else split_part(objectName, '.', 2) 
		end
		
	into 
		schema_name, object_name; 
end
$$ language plpgsql;


CREATE FUNCTION pgSQLt.Run(testName text) 
RETURNS pgSQLt.test_report AS 
$$
DECLARE 
	tc text;
	exceptionText text;
BEGIN 	
	select schema_name into tc from pgSQLt.private_split_object_name(testName);
	if not exists (select 1 FROM information_schema.schemata WHERE schema_name = lower(tc)) THEN
		raise exception 'Test class [%] does not exist, to add it run PERFORM pgSQLt.NewTestClass (''%'');', tc, tc;
	end if;
	raise notice 'Setting up test class [%]', tc;
	execute 'select ' || tc || '.setup();';
	
 	raise notice 'Running test [%]' ,testname;
	execute 'SELECT ' || testName || '();';

	raise exception using
            errcode='ALLOK',
            message='Test case successfull.',
            hint='This exception is only ment to rollback any changes made by the test.';

EXCEPTION 
	when sqlstate 'ALLOK' then
		GET STACKED DIAGNOSTICS 
			exceptionText = MESSAGE_TEXT;
	
		raise notice 'Test Completed OK!';
		return (testName, 'Test succeded', 'OK')::pgSQLt.test_report;
	when sqlstate 'ASSRT' then
		GET STACKED DIAGNOSTICS 
			exceptionText = MESSAGE_TEXT;
	
		raise notice 'Test FAILED due to assertion [%]', exceptionText;
		return (testName, 'Test FAILED to due assertion error [' || exceptionText || ']', 'FAIL')::pgSQLt.test_report;
	when others then
		GET STACKED DIAGNOSTICS 
			exceptionText = MESSAGE_TEXT;
		raise notice 'Test in ERROR due to [%]', exceptionText;
		return (testName, 'Test failed in ERROR due to [' || exceptionText ||']' , 'ERROR')::pgSQLt.test_report;	
END 
$$ LANGUAGE plpgsql;


CREATE FUNCTION pgSQLt.run_class(class_name text, out report pgSQLt.test_report) 
RETURNS setof pgSQLt.test_report AS 
$$
DECLARE 
	test_method RECORD;
	--report pgSQLt.test_report;
BEGIN

	FOR test_method IN select routine_name as test, class_name as test_class from information_schema.routines 
		where routine_schema = lower(class_name) 
		and lower(routine_name) != 'setup' 
	LOOP
		select * into report from pgSQLt.run(format('%s.%s', test_method.test_class, test_method.test));
		return next;
	END LOOP;

	
END
$$ LANGUAGE plpgsql;




create function pgsqlt.private_raise_assert_exception(message text) 
returns void
as
$$
BEGIN 
	raise exception using
            errcode='ASSRT',
            message=message,
            hint='This test failed due to assertion exception';
END 
$$ LANGUAGE plpgsql;

-- 
-- 
-- create function pgSQLt.AssertEquals() returns void AS 
-- $$
-- BEGIN 
-- 	RAISE EXCEPTION 'NOT IMPLEMENTED';  
-- END 
-- $$ LANGUAGE plpgsql;



create function pgSQLt.assert_equal_strings(expected text, actual text) 
returns void AS 
$$
 BEGIN 
     if expected != actual then
	perform pgSQLt.private_raise_assert_exception(format('assert_equal_strings: Expected [%s] but got [%s]', expected, actual));
     end if;
END 
$$ LANGUAGE plpgsql;

-- 
-- create function pgSQLt.AssertObjectExists() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.AssertResultSetsHaveSameMetaData() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.ResultSetFilter() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.AssertEqualsTable() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.AssertLike() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.AssertNotEquals() returns void AS 
-- $$	
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.AssertEmptyTable() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.Fail() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.ExpectNoException() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.ExpectException() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.FakeFunction() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.FakeTable() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.RenameClass() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.RemoveObject() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.ApplyTrigger() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.SpyProcedure() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.Info() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.TableToText() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.RunAll() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.RunTest() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.RunTestClass() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.RunWithNullResults() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.RunWithXmlResults() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.TestCaseSummary() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.XmlResultFormatter() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.DefaultResultFormatter() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.GetTestResultFormatter() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.SetTestResultFormatter() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.LogCapturedOutput() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.SuppressOutput() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.CaptureOutput() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.NewConnection() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.Uninstall() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.DropClass() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.SetFakeViewOff() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- create function pgSQLt.SetFakeViewOn() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.F_Num() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 
-- create function pgSQLt.GetNewTranName() returns void AS 
-- $$
--  BEGIN 
--      RAISE EXCEPTION 'NOT IMPLEMENTED'; 
-- END 
-- $$ LANGUAGE plpgsql;
-- 
-- 

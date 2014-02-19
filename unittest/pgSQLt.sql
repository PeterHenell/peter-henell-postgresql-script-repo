drop schema IF EXISTS pgSQLt cascade;

create schema pgSQLt;

create function pgSQLt.NewTestClass(className text)
returns void
as $$ 
DECLARE
	sql text;
begin

	sql := 'DROP SCHEMA IF EXISTS ' || className || ' CASCADE';
	EXECUTE (sql);
	sql := 'CREATE SCHEMA ' || className;
	EXECUTE (sql);
	
end $$ language plpgsql;


CREATE TABLE pgSQLt.CaptureOutputLog (
  Id SERIAL PRIMARY KEY ,
  OutputText text
);


CREATE VIEW pgSQLt.TestClasses
AS
  -- SELECT s.name AS Name, s.schema_id AS SchemaId
--     FROM sys.extended_properties ep
--     JOIN sys.schemas s
--       ON ep.major_id = s.schema_id
--    WHERE ep.name = N'pgSQLt.TestClass';
select 1
;

CREATE VIEW pgSQLt.Tests
AS
--   SELECT classes.SchemaId, classes.Name AS TestClassName, 
--          procs.object_id AS ObjectId, procs.name AS Name
--     FROM pgSQLt.TestClasses classes
--     JOIN sys.procedures procs ON classes.SchemaId = procs.schema_id
--    WHERE LOWER(procs.name) LIKE 'test%';
select 1
;


CREATE TABLE pgSQLt.TestResult(
    Id SERIAL PRIMARY KEY ,
    Class text NOT NULL,
    TestCase text NOT NULL,
    --Name AS (QUOTENAME(Class) + '.' + QUOTENAME(TestCase)),
    TranName text NOT NULL,
    Result text NULL,
    Msg text NULL
);
;
CREATE TABLE pgSQLt.TestMessage(
    Msg text
);
;
CREATE TABLE pgSQLt.Run_LastExecution(
    TestName text,
    SessionId INT,
    LoginTime timestamp
);




create function pgSQLt.AssertEquals() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertEqualsString() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertObjectExists() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertResultSetsHaveSameMetaData() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.ResultSetFilter() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertEqualsTable() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertLike() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertNotEquals() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.AssertEmptyTable() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.Fail() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.ExpectNoException() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.ExpectException() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.FakeFunction() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.FakeTable() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.RenameClass() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.RemoveObject() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.ApplyTrigger() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.SpyProcedure() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.Info() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.TableToText() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.RunAll() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.Run() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.RunTest() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.RunTestClass() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.RunWithNullResults() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.RunWithXmlResults() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.TestCaseSummary() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.XmlResultFormatter() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.DefaultResultFormatter() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.GetTestResultFormatter() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.SetTestResultFormatter() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.LogCapturedOutput() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.SuppressOutput() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.CaptureOutput() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.NewConnection() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.Uninstall() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.DropClass() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.SetFakeViewOff() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;
create function pgSQLt.SetFakeViewOn() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.F_Num() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;

create function pgSQLt.GetNewTranName() returns void AS 
 $$
 BEGIN RAISE EXCEPTION 'NOT IMPLEMENTED';  END 
$$ LANGUAGE plpgsql;



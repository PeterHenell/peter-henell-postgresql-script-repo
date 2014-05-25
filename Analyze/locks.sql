SELECT
locktype, virtualtransaction,transactionid,nspname,relname,mode,granted,
cast(date_trunc('second',query_start) AS timestamp) AS query_start,
substr(query,1,25) AS query
FROM pg_locks
LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
LEFT OUTER JOIN pg_namespace ON (pg_namespace.oid = pg_class.
relnamespace), pg_stat_activity
WHERE
NOT pg_locks.pid=pg_backend_pid() AND pg_locks.pid=pg_stat_activity.pid;

--select * from pg_stat_activity

SELECT
locked.pid AS locked_pid, locker.pid AS locker_pid, locked_act.usename AS locked_user, locker_act.usename AS locker_user,
locked.virtualtransaction, locked.transactionid, locked.locktype
FROM
pg_locks locked, pg_locks locker, pg_stat_activity locked_act, pg_stat_activity locker_act
WHERE
locker.granted=true AND  locked.granted=false AND locked.pid=locked_act.pid AND
locker.pid=locker_act.pid AND (locked.virtualtransaction=locker.virtualtransaction OR locked.transactionid=locker.transactionid);

SELECT
locked.pid AS locked_pid, locker.pid AS locker_pid, locked_act.usename AS locked_user, locker_act.usename AS locker_user,
locked.virtualtransaction, locked.transactionid, relname
FROM
pg_locks locked
LEFT OUTER JOIN pg_class ON (locked.relation = pg_class.oid), pg_locks locker,pg_stat_activity locked_act, pg_stat_activity locker_act
WHERE
locker.granted=true AND locked.granted=false AND locked.pid=locked_act.pid AND locker.pid=locker_act.pid AND locked.relation=locker.relation;
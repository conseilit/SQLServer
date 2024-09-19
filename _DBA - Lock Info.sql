


select * from sys.dm_exec_sessions 

select IF @@OPTIONS & 2 = 0

SELECT es.session_id,es.host_name,es.program_name,es.login_name,
	   es.status,er.blocking_session_id,er.wait_type, er.wait_resource,
	   est.text
FROM sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er on es.session_id = er.session_id
INNER JOIN sys.dm_exec_connections ec on es.session_id = ec.session_id
OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) est
WHERE es.session_id = 83
for xml auto


CREATE DATABASE _DBA
GO
USE _DBA
GO
CREATE TABLE LocInfo
(
	ID int identity(1,1) primary key,
	EventTime datetime default getdate(),
	LoginTime datetime,
	SessionId int,
	LoginName varchar(100),
	HostName varchar(100),
	ProgramName varchar(100),
	Status varchar(100),
	BlockingSessionId int,
	OpenTransactionCount int,
	LockCount int,
	LockInformation xml,
	SQLStatement nvarchar(4000)
)

INSERT INTO _DBA.dbo.LocInfo 
(	LoginTime ,
    SessionId,
	LoginName ,
	HostName ,
	ProgramName ,
	Status ,
	BlockingSessionId,
	OpenTransactionCount ,
	LockCount ,
	LockInformation ,
	SQLStatement )
select login_time,es.session_id,login_name,host_name,program_name,
	ISNULL(er.status,es.status) as status,er.blocking_session_id, es.open_transaction_count,
	(select count(*) from sys.dm_tran_locks where request_session_id = es.session_id) as LockCount,
	(SELECT resource_type,db_name(resource_database_id) as DatabaseName,
				CASE resource_type
				 WHEN 'KEY' THEN  
					( SELECT CONCAT('Table ',object_name(object_id),' / KeyHashValue ',SUBSTRING(resource_description,2,LEN(resource_description)-2))
						FROM sys.dm_db_partition_stats
						WHERE partition_id= resource_associated_entity_id
					)
				 WHEN 'PAGE' THEN  
					( SELECT CONCAT('Table ',object_name(object_id),' / Page ', SUBSTRING(resource_description,CHARINDEX(':',resource_description)+1,LEN(resource_description)))
						FROM sys.dm_db_partition_stats
						WHERE partition_id= resource_associated_entity_id
					)
				 WHEN 'DATABASE' THEN  
					( SELECT CONCAT('Database ',db_name(resource_database_id))
					)
				 ELSE CONCAT('Table ',object_name(resource_associated_entity_id))
			END	 as [Resource],
			resource_description,
			request_mode,request_type,request_status,request_session_id 
	FROM sys.dm_tran_locks
	WHERE request_session_id = es.session_id
	FOR xml auto) as LockInformation
			,ib.event_info
from sys.dm_exec_sessions es
LEFT JOIN sys.dm_exec_requests er on er.session_id = es.session_id
OUTER APPLY sys.dm_exec_input_buffer(es.session_id, NULL) AS ib
where is_user_process=1

SELECT * FROM _DBA.dbo.LocInfo
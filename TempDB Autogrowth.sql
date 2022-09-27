

CREATE EVENT SESSION [TempDBAutogrowth] ON SERVER 
        ADD EVENT sqlserver.database_file_size_change(
            ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
            WHERE ([database_id]=(2) AND [session_id]>(50))),
        ADD EVENT sqlserver.databases_log_file_used_changed(
            ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
            WHERE ([database_id]=(2) AND [session_id]>(50)))
        ADD TARGET package0.event_file(SET filename=N'TempDBAutogrowth',max_file_size=(50),max_rollover_files=(10))
        WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
        
        

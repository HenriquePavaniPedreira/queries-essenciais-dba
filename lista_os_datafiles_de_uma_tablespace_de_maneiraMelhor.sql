set verify off
COL file_name FORM a70
set Linesize 190
SELECT v.file#, d.tablespace_name,d.file_name, d.autoextensible, d.maxbytes/1024/1024 max_mb, d.bytes/1024/1024 mb
FROM dba_data_files d, v$datafile v
WHERE d.tablespace_name like upper('&1')
and v.file# = d.file_id
order by CREATION_TIME;

set linesize 1000
 set pagesize 1000
 set trimspool on
 col free format 999999990.00
 col used format 999999990.00
 col megas format 999999990.00
 col PCT_USED format 999.00
 COL NAME FORMAT A27
 col banco format a30
select i.host_name || '-'|| i.instance_name banco,nvl(b.tablespace_name,nvl(a.tablespace_name,'UNKOWN')) name,
       mbytes_alloc megas,
       round(mbytes_alloc-nvl(mbytes_free,0),2) used,
       round(nvl(mbytes_free,0),2) free, 
       --round(nvl(largest,0),2) largest,
       trunc(((mbytes_alloc-nvl(mbytes_free,0))/mbytes_alloc)*100,2) pct_used
  from ( select  sum(bytes)/1024/1024 mbytes_free, max(bytes)/1024/1024 largest, tablespace_name from sys.dba_free_space group by tablespace_name ) a,
       ( select sum(bytes)/1024/1024 mbytes_alloc, tablespace_name from sys.dba_data_files group by tablespace_name ) b,
( select sum(next_extent)/1024/1024 mbytes_nexts, tablespace_name from sys.dba_segments group by tablespace_name ) c, v$instance i
  where a.tablespace_name (+) = b.tablespace_name and
        c.tablespace_name (+) = b.tablespace_name
--and   trunc(((mbytes_alloc-nvl(mbytes_free,0))/mbytes_alloc)*100,2) >80
--AND  b.tablespace_name='SYSTEM'
   order by 6 asc;

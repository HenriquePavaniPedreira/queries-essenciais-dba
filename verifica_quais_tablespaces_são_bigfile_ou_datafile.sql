set linesize 150 pagesize 50000
column  tablespace_name   format  a30
column  Ocupado    format 999,999,990.00 heading "Ocupado"
column  Alocado    format 999,999,990.00 heading "Alocado"
column  Maximo     format 999,999,990.00 heading "Maximo"
column  Perc_Livre format         990.00 heading "%Livre"
column  AutoExt    format A3             heading "Aut"
column  Bigfile    format A3             heading "Big"
column  filter     format A3             heading "M_F"
break   on report
compute sum of ocupado on report
compute sum of alocado on report
compute sum of maximo  on report
compute sum label "Totais" of ocupado alocado maximo on report
select a.tablespace_name,
       nvl(alocado-livre,0)                                       as ocupado,
       alocado,
       maximo,
       round(((maximo-(alocado-livre))/maximo)*100,2)             as Perc_Livre,
       (case when (auto_yes = 0 AND auto_no > 0 ) then '   '
             when (auto_yes > 0 AND auto_no > 0 ) then '(*)'
             when (auto_yes > 0 AND auto_no = 0 ) then ' Y ' end) as AutoExt,
       (case when a.bigfile = 'NO'                then '   '
                                                  else '(*)' end) as Bigfile
from
   dba_tablespaces a,
  (select tablespace_name, round(sum(bytes)/1024/1024,2) alocado, round(sum(case maxbytes when 0 then bytes else maxbytes end)/1024/1024,2) maximo, sum(decode(autoextensible,'YES',1,0)) auto_yes, sum(decode(autoextensible,'NO',1,0)) auto_no from dba_data_files group by tablespace_name
   union
   select tablespace_name, round(sum(bytes)/1024/1024,2) alocado, round(sum(case maxbytes when 0 then bytes else maxbytes end)/1024/1024,2) maximo, sum(decode(autoextensible,'YES',1,0)) auto_yes, sum(decode(autoextensible,'NO',1,0)) auto_no from dba_temp_files group by tablespace_name) b,
  (select tablespace_name, round(sum(bytes)/1024/1024,2) livre                                                                                                                                                                                   from dba_free_space group by tablespace_name) c
where
   a.tablespace_name = b.tablespace_name (+) and
   a.tablespace_name = c.tablespace_name (+)
order by 5
/
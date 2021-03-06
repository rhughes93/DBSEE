/*********************************************************************/
/* Author      : VLDB                                                */
/* Date        : 16/03/2017                                          */
/* Version     : 1                                                   */
/* Description : Generate report on primary index (PI) datatypes     */
/*********************************************************************/
select  t1.columnname as column_name
       ,t1.columntype as column_type
       ,case when t1.columntype = 'I'  then 'integer'
             when t1.columntype = 'F'  then 'float'
             when t1.columntype = 'D'  then 'decimal'
             when t1.columntype = 'CF' then 'char'
             when t1.columntype = 'CV' then 'varchar'
             when t1.columntype = 'BF' then 'binary'
             when t1.columntype = 'BV' then 'varbinary'
             when t1.columntype = 'TS' then 'timestamp'
             when t1.columntype = 'I8' then 'bigint'
             when t1.columntype = 'I2' then 'smallint'
             when t1.columntype = 'I1' then 'byteint'
             when t1.columntype = 'DA' then 'date'
             else 'recheck'
        end as data_type
       ,count(t2.columnname) as index_column_freq
       ,sum(t3.table_size) as total_perm
from    dbc.columnsv t1
inner join
        dbc.indicesv t2
on      t1.databasename = t2.databasename
and     t1.tablename    = t2.tablename
and     t1.columnname   = t2.columnname
left join
       (select  databasename 
               ,tablename
               ,sum(currentperm) as table_size
        from    dbc.tablesizev
        group by 1,2) t3 -- table size
on      t2.databasename = t3.databasename
and     t2.tablename    = t3.tablename
inner join 
       (select  dr1.columnname
               ,count(distinct(dr1.columntype)) as number_different
        from    dbc.columnsv dr1
        inner join
                dbc.indicesv dr2
        on      dr1.databasename = dr2.databasename
        and     dr1.tablename    = dr2.tablename
        and     dr1.columnname   = dr2.columnname
        where   dr2.indexnumber  = 1 -- denotes primary index
        group by 1
        having  number_different > 1 ) t4 -- filter to remove PI columns that only have 1 datatype
on      t1.columnname  = t4.columnname 
where   t2.indexnumber = 1
group by 1,2,3
;


/*********************************************************************/
/* Author      : VLDB                                                */
/* Date        : 16/03/2017                                          */
/* Version     : 1                                                   */
/* Description : Generate CSV to report on tables with missing or    */
/*               out of date index stats within the Teradata System  */
/*********************************************************************/
/* 1 - Export contents of the target table to CSV                    */
/*********************************************************************/

-- export location is now defined by the controlling shell

.set recordmode off
.set separator '|'
.set width 2000
.set titledashes off
.set null as ' '

select t1.databasename as database_name
      ,t1.tablename    as table_name
      ,t1.columnname   as column_name
      ,case when t1.indextype in ('P','Q') and t1.uniqueflag = 'Y' then 'unique primary index'
            when t1.indextype in ('P','Q') and t1.uniqueflag = 'N' then 'non-unique primary index'
            when t1.indextype = 'S' then 'secondary index'
            when t1.indextype = 'K' then 'primary key'
            when t1.indextype = 'J' then 'join index'
       end as index_type
      ,max(t2.lastcollecttimestamp) as last_collect_timestamp
      ,t3.total_perm     as total_perm
      ,current_date - cast(last_collect_timestamp as date) as days_since_collection
from   dbc.indicesv   t1
left outer join
       dbc.indexstatsv t2
on     t1.databasename = t2.databasename
and    t1.tablename    = t2.tablename
inner join 
      (select databasename
             ,tablename
             ,sum(currentperm) as total_perm
       from   dbc.tablesizev
       group by 1,2) t3
on     t1.databasename = t3.databasename
and    t1.tablename    = t3.tablename
group by 1,2,3,4,6
;
.if errorcode <> 0 then .quit errorcode

.logoff
.exit

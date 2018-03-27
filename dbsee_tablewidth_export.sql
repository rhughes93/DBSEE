/*********************************************************************/
/* Author      : VLDB                                                */
/* Date        : 23/02/2017                                          */
/* Version     : 1                                                   */
/* Description : Generate csv for reporting on number of columns per */
/*               table on the Teradata System                        */
/*********************************************************************/
/* 1 - Export contents of the target table to CSV                    */
/*********************************************************************/

-- export location defined by a controlling shell

.set recordmode off
.set separator '|'
.set width 2000
.set titledashes off
.set null as ' '

select  t1.databasename      as database_name
       ,t1.tablename         as table_name
       ,t2.total             as total_perm
       ,count(t1.columnname) as number_columns
from    dbc.columnsv t1
left join
       (select  databasename
               ,tablename
               ,sum(currentperm) as total
        from    dbc.tablesizev
        group by 1,2)t2
on      t1.databasename = t2.databasename
and     t1.tablename    = t2.tablename
inner join 
        dbc.tablesV t3
on      t1.databasename = t3.databasename
and     t1.tablename    = t3.tablename
where   t3.tablekind in ('O','T')
group by 1,2,3
;
.if errorcode <> 0 then .quit errorcode

.logoff
.exit


/*********************************************************************/
/* Author      : VLDB                                                */
/* Date        : 07/02/2017                                          */
/* Version     : 1                                                   */
/* Description : Generate a CSV reporting on available space within  */
/*               each database on the Teradata System                */
/*********************************************************************/
/* 1 - Export contents of the target table to CSV                    */
/*********************************************************************/

-- export location defined by controlling shell

.set recordmode off
.set separator '|'
.set width 2000
.set titledashes off
.set null as ' '

select  t1.databasename  as database_name
       ,sum(maxperm)     as perm_size
       ,sum(currentperm) as perm_used
       ,cast(sum(maxperm-currentperm) as bigint) as perm_free
       ,cast(case when perm_size = 0 then 0
                  else (cast(perm_free as decimal(25,4))/cast(perm_size as decimal(25,4)))*100
             end as decimal(23,2)) as perm_free_perc
from    dbc.diskspaceV t1
group by 1
;
.if errorcode <> 0 then .quit errorcode

.logoff
.exit



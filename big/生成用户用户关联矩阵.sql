--先创建用户用户关联矩阵表，用三元组存这个矩阵
use ml_big;
create table User_User_Matrix(
	userid1 int ,
	userid2 int,
	relation float
)

insert into User_User_Matrix
select userid1,userid2,relation
from 
(select T1.rowid userid1, T2.rowid userid2 ,count(*) relation
from User_Movie_Matrix T1, User_Movie_Matrix T2
where T1.rowid < T2.rowid and T1.colid = T2.colid and abs(T1.rating - T2.rating) <0.3 
group by T1.rowid, T2.rowid) as T

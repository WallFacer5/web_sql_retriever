create table Challenger
(
    O_Ring_failure DECIMAL(1, 0) NOT NULL,
    Launch_temperature INT NOT NULL,
    Leak_check_pressure VARCHAR(10) NOT NULL
);

load data local infile 'Challenger.csv' into table Challenger fields terminated by ',' lines terminated by '\r\n' ignore 1 lines;

delimiter //

create procedure KNN(tb varchar(30), target varchar(30), predictor varchar(30), v decimal(7, 2), k decimal(1))
begin
    set @stmt=concat('select ', target, ' from\n', '(select ', target, ' from ', tb, ' order by abs(', predictor, '-', v,
                     ') limit ', k, ') t1\n', 'group by ', target, ' order by count(', target, ') desc limit 1;'
                    );
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

delimiter ;


--sample query

call KNN('Challenger', 'O_Ring_failure', 'Launch_temperature', 30, 1);

select O_Ring_failure, abs(Launch_temperature-30) as distance from Challenger order by distance limit 5;

select O_Ring_failure from
(select O_Ring_failure from Challenger order by abs(Launch_temperature-30) limit 5) t1
group by O_Ring_failure order by count(O_Ring_failure) desc limit 1;

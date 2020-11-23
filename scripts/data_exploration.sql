delimiter //

create procedure median(tb varchar(30), col varchar(30))
begin
    set @stmt=concat('set @Median =(select avg(', col, ') from (select (@row_num := @row_num + 1) as line, ', col, '\n',
                     'from (select ', col, ' from ', tb, ' order by ', col, ') mid_t1, (select @row_num := 0) r) mid_t2\n',
                     'where line between floor((@row_num + 1) / 2) and floor((@row_num + 2) / 2));'
                    );
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

create procedure percent_get(tb varchar(30), col varchar(30), pct float, save_name varchar(30))
begin
    set @stmt=concat('set @', save_name, '=(select ', col, ' from ', tb, ' order by abs(PERCENT_RANK() OVER (ORDER BY ',
                     col, ' ASC)-', pct, ') limit 1);');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

create procedure Q1(tb varchar(30), col varchar(30))
begin
    call percent_get(tb, col, 0.25, 'Q1');
end //

create procedure Q3(tb varchar(30), col varchar(30))
begin
    call percent_get(tb, col, 0.75, 'Q3');
end //

create procedure M3AQ2(tb varchar(30), col varchar(30))
begin
    call median(tb, col);
    call Q1(tb, col);
    call Q3(tb, col);
    set @Median=cast(@median as decimal(5, 2));
    set @Q1=cast(@Q1 as decimal(5, 2));
    set @Q3=cast(@Q3 as decimal(5, 2));
    set @stmt=concat('select min(', col, ') as Min, max(', col, ') as Max, cast(@Median as decimal(5, 2)) as Median, avg(',
                     col, ') as Average, cast(@Q1 as decimal(5, 2)) as Q1, cast(@Q3 as decimal(5, 2)) as Q3 from ', tb, ';'
                    );
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

create procedure correlation(tb varchar(30), col1 varchar(30), col2 varchar(30))
begin
    set @stmt=concat('set @x_avg=(select avg(', col1, ') from ', tb, ');');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    set @stmt=concat('set @y_avg=(select avg(', col2, ') from ', tb, ');');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    set @stmt=concat('set @n=(select count(*) from ', tb, ');');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    set @stmt=concat('set @x_var=(select sum((', col1, '-@x_avg)*(', col1, '-@x_avg)) / @n from ', tb, ');');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    set @stmt=concat('set @y_var=(select sum((', col2, '-@y_avg)*(', col2, '-@y_avg)) / @n from ', tb, ');');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    set @stmt=concat('set @cov=(select sum((', col1, '-@x_avg)*(', col2, '-@y_avg)) / @n from ', tb, ');');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    set @stmt=concat('select @cov / sqrt(@x_var*@y_var) as Correlation;');
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

delimiter ;

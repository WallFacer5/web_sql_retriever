delimiter //

create procedure getv(tb varchar(20), k varchar(20))
begin
    set @stmt=concat('select v from ', tb, " where k='", k, "';");
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

create procedure put(tb varchar(20), k varchar(20), v json)
begin
    set @stmt=concat('select count(*) from ', tb, " where k='", k, "' into @count;");
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
    if @count>0 then
        set @stmt=concat("select json_merge_patch(v, '", v, "') from ", tb, " where k='", k, "' into @merged_v;");
        prepare stmt from @stmt;
        execute stmt;
        deallocate prepare stmt;
        set @stmt=concat('update ', tb, " set v='", @merged_v, "' where k='", k, "';");
        prepare stmt from @stmt;
        execute stmt;
        deallocate prepare stmt;
    else
        set @stmt=concat('insert into ', tb, " values ('", k, "', '", v, "');");
        prepare stmt from @stmt;
        execute stmt;
        deallocate prepare stmt;
    end if;
end //

create procedure del(tb varchar(20), k varchar(20))
begin
    set @stmt=concat('delete from ', tb, " where k='", k, "';");
    prepare stmt from @stmt;
    execute stmt;
    deallocate prepare stmt;
end //

create procedure exec(tb varchar(20), k varchar(20), operation varchar(10), param varchar(30))
begin
    if operation='len' then
        set @stmt=concat('select json_length(v) as attr_num from ', tb, " where k='", k, "';");
        prepare stmt from @stmt;
        execute stmt;
        deallocate prepare stmt;
    elseif operation='get_attr' then
        set @stmt=concat("select json_unquote(json_extract(v, '$.", param, "')) as ", param, " from ", tb, " where k='", k, "';");
        prepare stmt from @stmt;
        execute stmt;
        deallocate prepare stmt;
    end if;
end //

delimiter ;
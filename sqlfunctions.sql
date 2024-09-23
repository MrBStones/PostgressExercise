DROP FUNCTION IF EXISTS NewPerson;
create FUNCTION NewPerson (
    IN pname VARCHAR(50),
    IN pgender CHAR(1),
    IN pheight FLOAT
) RETURNS INTEGER as $$ begin
insert into Person (name, gender, height)
values (pname, pgender, pheight);
return lastval();
end;
$$ language plpgsql;
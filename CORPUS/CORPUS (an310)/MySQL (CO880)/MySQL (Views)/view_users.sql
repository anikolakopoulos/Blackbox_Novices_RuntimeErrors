CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `whitebox`@`localhost` 
    SQL SECURITY DEFINER
VIEW `view_users` AS
    select 
        `blackbox_production`.`users`.`id` AS `id`,
        `blackbox_production`.`users`.`uuid` AS `uuid`
    from
        `blackbox_production`.`users`
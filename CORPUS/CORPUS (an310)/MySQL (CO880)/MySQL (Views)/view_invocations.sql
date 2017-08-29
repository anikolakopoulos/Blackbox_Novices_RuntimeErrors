CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `whitebox`@`localhost` 
    SQL SECURITY DEFINER
VIEW `view_invocations` AS
    select 
        `blackbox_production`.`invocations`.`id` AS `id`,
        `blackbox_production`.`invocations`.`exception_class` AS `exception_class`,
        `blackbox_production`.`invocations`.`exception_message` AS `exception_message`
    from
        `blackbox_production`.`invocations`
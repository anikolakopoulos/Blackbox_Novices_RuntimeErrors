CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `whitebox`@`localhost` 
    SQL SECURITY DEFINER
VIEW `view_master_events` AS
    select 
        `blackbox_production`.`master_events`.`id` AS `id`,
        `blackbox_production`.`master_events`.`event_id` AS `event_id`,
        `blackbox_production`.`master_events`.`created_at` AS `created_at`,
        `blackbox_production`.`master_events`.`name` AS `name`
    from
        `blackbox_production`.`master_events`
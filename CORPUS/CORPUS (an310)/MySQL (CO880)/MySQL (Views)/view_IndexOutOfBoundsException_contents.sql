CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `whitebox`@`localhost` 
    SQL SECURITY DEFINER
VIEW `view_IndexOutOfBoundsException_contents` AS
    select 
        `u`.`uuid` AS `uuid`,
        `u`.`id` AS `id`,
        (to_days(`m`.`created_at`) - to_days(`u`.`created_at`)) AS `User LifeTime`,
        `m`.`created_at` AS `created_at`
    from
        (((`blackbox_production`.`master_events` `m`
        join `blackbox_production`.`invocations` `i` ON (((`m`.`name` = 'invoke_method')
            and (`m`.`event_id` = `i`.`id`))))
        join `blackbox_production`.`users` `u` ON ((`m`.`user_id` = `u`.`id`)))
        left join `blackbox_production`.`source_histories` `h` ON (((`h`.`master_event_id` = `m`.`id`)
            and (`i`.`exception_class` like 'java.lang.IndexOutOfBoundsException')
            and ((`i`.`exception_message` like 'Index: %')
            or (`i`.`exception_message` like '% is out of bounds (min%')
            or (`i`.`exception_message` like '')
            or (`i`.`exception_message` like ('(' and ')'))))))
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `whitebox`@`localhost` 
    SQL SECURITY DEFINER
VIEW `view_ArrayIndexOutOfBoundsException_contents` AS
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
            and (`i`.`exception_class` like 'java.lang.ArrayIndexOutOfBoundsException')
            and ((concat('', (`i`.`exception_message` * 1)) = `i`.`exception_message`)
            or (`i`.`exception_message` = 'Coordinate out of bounds!')))))
			
# The `User LifeTime` number designates the time-difference between the time that each individual subject user had
# opted-in to participate in Blackbox, until the time that this participant subject user’s exception error occurred
# (was thrown). For example in initializing: `User LifeTime` = 0 | means that MySQL will return those Users whose
# error happened in the SAME day that they registered to Blackbox and the exception occured; `User LifeTime` = 1  
# means that MySQL will return those Users whose error happened ONE day after they registered to Blackbox and the
# exception occured; `User LifeTime` = 2 means that MySQL will return those Users whose error happened TWO days after
# they registered to Blackbox and the exception occured, and so on.
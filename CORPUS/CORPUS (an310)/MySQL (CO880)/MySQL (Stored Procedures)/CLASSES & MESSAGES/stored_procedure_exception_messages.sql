-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`whitebox`@`localhost` PROCEDURE `stored_procedure_exception_messages`(IN a DATETIME, IN b DATETIME)
BEGIN
	SELECT date(m.created_at) AS `Date`, i.exception_class AS `Class`, i.exception_message AS `Message`, COUNT(*) AS `Instances`
	FROM `test`.`view_master_events` AS m JOIN `test`.`view_invocations` AS i ON 
	m.name = "invoke_method" AND m.event_id = i.id
	WHERE m.created_at BETWEEN a AND b
	AND i.exception_class LIKE "%.ArrayIndexOutOfBoundsException%"
	GROUP BY `date`, i.exception_class, i.exception_message;
END
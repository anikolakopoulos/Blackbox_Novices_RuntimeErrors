-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`whitebox`@`localhost` PROCEDURE `stored_procedure_ArrayIndexOutOfBoundsException_total_number`(IN a DATETIME, IN b DATETIME)
BEGIN
SELECT a, b, a1.`Message Type`, a1.`User LifeTime`, SUM(a1.`Instances`) AS `Instances` FROM
(
	SELECT u.uuid, if(i.exception_message > 0, 'ArrayIndexOutOfBoundsException(+)', if(i.exception_message < 0, 'ArrayIndexOutOfBoundsException(-)', if(i.exception_message = "Coordinate out of bounds!", 'ArrayIndexOutOfBoundsException(Coordinate out of bounds!)','ArrayIndexOutOfBoundsException(0)'))) AS `Message Type`, 
	DATEDIFF(m.created_at, u.created_at) AS `User LifeTime`, count(*) AS `Instances`
	FROM `blackbox_production`.`master_events` AS m
    JOIN `blackbox_production`.`invocations` AS i ON m.name = 'invoke_method' AND m.event_id = i.id
    JOIN `blackbox_production`.`users` as u ON m.user_id = u.id
    LEFT JOIN `blackbox_production`.`source_histories` as h ON h.master_event_id = m.id
	WHERE m.created_at BETWEEN a AND b
	AND i.exception_class LIKE "java.lang.ArrayIndexOutOfBoundsException"
	AND ((concat('', i.exception_message * 1) = i.exception_message) OR i.exception_message = "Coordinate out of bounds!")
	GROUP BY u.uuid,`Message Type`, `User LifeTime`
) AS a1	
JOIN 
(
	SELECT a.uuid, `a`.`User LifeTime`, b.sessions FROM
	(SELECT DISTINCT
		c.uuid, c.id as id, c.`User LifeTime`
	FROM `view_ArrayIndexOutOfBoundsException_contents` as c
		WHERE c.created_at BETWEEN a AND b 
	) AS a
	JOIN 
	(SELECT x.id, count(*) as sessions FROM (
	SELECT DISTINCT c.id
	FROM `view_ArrayIndexOutOfBoundsException_contents` AS c
		WHERE c.created_at BETWEEN a AND b 
	) as x
		JOIN blackbox_production.sessions AS s0 ON s0.user_id = x.id
	GROUP BY x.id
	HAVING `sessions` > 1
	) AS b
	ON a.id = b.id
) AS a2
ON a1.uuid = a2.uuid AND a1.`User LifeTime` = a2.`User LifeTime`
GROUP BY a1.`Message Type`, a1.`User LifeTime`;

END
-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`whitebox`@`localhost` PROCEDURE `stored_procedure_IndexOutOfBoundsException_total_number`(IN a DATETIME, IN b DATETIME)
BEGIN
SELECT a, b, a1.`Message Type`, a1.`User LifeTime`, SUM(a1.`Instances`) AS `Instances` FROM
(
	SELECT u.uuid, if(i.exception_message LIKE "Index: %", 'IndexOutOfBoundsException(Index: ,Size: )', if(i.exception_message LIKE "% is out of bounds (min%", 'IndexOutOfBoundsException(row|col is out of bounds)', if(i.exception_message LIKE "", 'IndexOutOfBoundsException('' '')', if(i.exception_message LIKE ("(" AND ")"), 'IndexOutOfBoundsException(  ,  )', 'IndexOutOfBoundsException(other message type)')))) AS `Message Type`, 
	DATEDIFF(m.created_at, u.created_at) AS `User LifeTime`, count(*) AS `Instances`
	FROM `blackbox_production`.`master_events` AS m 
	JOIN blackbox_production.invocations AS i ON  m.name = "invoke_method" AND m.event_id = i.id
	JOIN blackbox_production.users as u ON m.user_id = u.id
	#LEFT JOIN blackbox_production.source_histories as h ON h.master_event_id = m.id
	WHERE m.created_at BETWEEN a AND b
	AND i.exception_class LIKE "java.lang.IndexOutOfBoundsException"
	GROUP BY u.uuid,`Message Type`, `User LifeTime`
) AS a1	
JOIN 
(
	SELECT a.uuid, `a`.`User LifeTime`, b.sessions FROM
	(SELECT DISTINCT
	u.uuid, u.id as id,
	DATEDIFF(m.created_at, u.created_at) AS `User LifeTime`
	FROM `blackbox_production`.`master_events` AS m 
	JOIN blackbox_production.invocations AS i ON  m.name = "invoke_method" AND m.event_id = i.id
	JOIN blackbox_production.users as u ON m.user_id = u.id
	#LEFT JOIN blackbox_production.source_histories as h ON h.master_event_id = m.id
	WHERE m.created_at BETWEEN a AND b 
	AND i.exception_class LIKE "java.lang.IndexOutOfBoundsException"
	AND (i.exception_message LIKE "Index: %" OR
	i.exception_message LIKE "% is out of bounds (min%" OR
	i.exception_message LIKE "" OR
	i.exception_message LIKE ("(" AND ")")) 
) AS a
	JOIN 
	(SELECT x.id, count(*) as sessions FROM (
	SELECT DISTINCT u0.id
	FROM `blackbox_production`.`master_events` AS m0
	JOIN blackbox_production.invocations AS i0 ON  m0.name = "invoke_method" AND m0.event_id = i0.id
	JOIN blackbox_production.users as u0 ON m0.user_id = u0.id
	#LEFT JOIN blackbox_production.source_histories as h0 ON h0.master_event_id = m0.id
	WHERE m0.created_at BETWEEN a AND b 
	AND i0.exception_class LIKE "java.lang.IndexOutOfBoundsException"
	AND (i0.exception_message LIKE "Index: %" OR
	i0.exception_message LIKE "% is out of bounds (min%" OR
	i0.exception_message LIKE "" OR
	i0.exception_message LIKE ("(" AND ")"))
) AS x
		JOIN blackbox_production.sessions AS s0 ON s0.user_id = x.id
	GROUP BY x.id
	HAVING `sessions` > 1
	) AS b
	ON a.id = b.id
) AS a2
ON a1.uuid = a2.uuid AND a1.`User LifeTime` = a2.`User LifeTime`
GROUP BY a1.`Message Type`, a1.`User LifeTime`;

END
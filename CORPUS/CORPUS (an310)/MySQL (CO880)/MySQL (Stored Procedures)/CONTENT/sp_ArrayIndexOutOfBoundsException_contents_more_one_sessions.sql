-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`whitebox`@`localhost` PROCEDURE `sp_ArrayIndexOutOfBoundsException_contents_more_one_sessions`(IN a DATETIME, IN b DATETIME)
BEGIN
SELECT a, b, a1.created_at, a1.uuid, a2.sessions, a1.exception_class,
	a1.exception_message, a1. `Message Type`, a1.content as content, a1.source_history_type,
	a1.code, a1.`source_files.id`, a1.`m.id` FROM
(
	SELECT m.created_at, u.uuid, i.exception_class,
	i.exception_message,
	if(i.exception_message > 0, 'ArrayIndexOutOfBoundsException(+)',
	if(i.exception_message < 0, 'ArrayIndexOutOfBoundsException(-)',
	if(i.exception_message = "Coordinate out of bounds!",
	'ArrayIndexOutOfBoundsException(Coordinate out of bounds!)',
	'ArrayIndexOutOfBoundsException(0)'))) AS `Message Type`,
	h.content as `content`, h.source_history_type AS `source_history_type`,
	i.code AS `code`, source_files.id AS `source_files.id`, m.id AS `m.id`
FROM `blackbox_production`.`master_events` AS m 
	JOIN `blackbox_production`.`invocations` AS i ON  m.name = "invoke_method" AND m.event_id = i.id
	JOIN `blackbox_production`.`users` AS u ON m.user_id = u.id
	JOIN `blackbox_production`.`source_histories` AS h ON h.master_event_id = m.event_id
	LEFT JOIN `blackbox_production`.`source_files` on m.project_id = source_files.project_id
	AND substring_index(source_files.name,'.',1) = substring_index(i.code,'.',1)
	WHERE m.created_at BETWEEN a AND b
	AND i.exception_class = "java.lang.ArrayIndexOutOfBoundsException"
	AND ((concat('', i.exception_message * 1) = i.exception_message) OR i.exception_message = "Coordinate out of bounds!") 
	AND h.source_history_type = 'complete'
	AND DATEDIFF(m.created_at, u.created_at) = 0 
	AND m.id IS NOT NULL 
	AND source_files.id IS NOT NULL
	#AND i.code like "%.main({%";
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
		JOIN `blackbox_production`.`sessions` AS s ON s.user_id = x.id
	GROUP BY x.id
	HAVING `sessions` > 1
	) AS b
	ON a.id = b.id
) AS a2
ON a1.uuid = a2.uuid AND a2.`User LifeTime` = 0; 
END
-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`whitebox`@`localhost` PROCEDURE `stored_procedure_exception_classes`(IN a DATETIME, IN b DATETIME)
BEGIN
	SELECT date(m.created_at) AS `Date`, i.exception_class AS `Class`, COUNT(*) AS `Instances`
	FROM `test`.`view_master_events` AS m JOIN `test`.`view_invocations` AS i ON 
	m.name = "invoke_method" AND m.event_id = i.id
	WHERE m.created_at BETWEEN a AND b
	GROUP BY `date`, i.exception_class
	HAVING i.exception_class LIKE "%.ArithmeticException%" OR
	i.exception_class LIKE "%.ArrayIndexOutOfBoundsException%" OR
	i.exception_class LIKE "%.ArrayStoreException%" OR
	i.exception_class LIKE "%.ClassCastException%" OR
	i.exception_class LIKE "%.IllegalArgumentException%" OR
	i.exception_class LIKE "%.IllegalStateException%" OR
	i.exception_class LIKE "%.IndexOutOfBoundsException%" OR
	i.exception_class LIKE "%.NegativeArraySizeException%" OR
	i.exception_class LIKE "%.NoSuchElementException%" OR
	i.exception_class LIKE "%.NullPointerException%" OR
	i.exception_class LIKE "%.RuntimeException%" OR
	i.exception_class LIKE "%.SecurityException%" OR
	i.exception_class LIKE "%.StringIndexOutOfBoundsException%" OR
	i.exception_class LIKE "%.UnsupportedOperationException%";
END
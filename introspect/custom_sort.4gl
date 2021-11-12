PACKAGE introspect
IMPORT reflect
IMPORT util
PUBLIC TYPE sort_func_type FUNCTION(p1 reflect.Value, p2 reflect.Value, sort_param STRING) RETURNS SMALLINT
--------------------------------------------------------------------------------
FUNCTION custom_sort(a reflect.Value, sort_func sort_func_type, sort_param STRING)
	DEFINE l_len INTEGER
	LET l_len = a.getLength()
	CALL merge_sort(a, 1, l_len, sort_func, sort_param)
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION merge_sort(a reflect.Value, l_min INTEGER, l_max INTEGER, sort_func sort_func_type, sort_param STRING)
		RETURNS()

	CASE
		WHEN l_min = l_max -- only 1 element, return
			RETURN
		WHEN l_max - l_min = 1 -- 2 elements, swap if required
			IF sort_func(a.getArrayElement(l_min), a.getArrayElement(l_max), sort_param) = 1 THEN
				CALL swap(a, l_min, l_max)
			END IF
			RETURN

		OTHERWISE -- split in two
			VAR middle, left, right INTEGER

			LET middle = (l_min + l_max) / 2
			CALL merge_sort(a, l_min, middle, sort_func, sort_param)
			CALL merge_sort(a, middle + 1, l_max, sort_func, sort_param)

			-- merge the left and right side back together
			LET left  = l_min
			LET right = middle + 1

			WHILE TRUE
				IF left > l_max THEN
					EXIT WHILE
				END IF
				IF right > l_max THEN
					EXIT WHILE
				END IF
				IF sort_func(a.getArrayElement(left), a.getArrayElement(right), sort_param) = 1 THEN
					-- bring right across before left
					CALL a.insertArrayElement(left)
					CALL a.getArrayElement(left).set(a.getArrayElement(right + 1))
					CALL a.deleteArrayElement(right + 1)
					LET left  = left + 1
					LET right = right + 1
				ELSE
					-- left is in correct place, move on
					LET left = left + 1
					CONTINUE WHILE
				END IF
			END WHILE
	END CASE

END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION swap(a reflect.Value, i INT, j INT) RETURNS()
	-- assumes i,j valid
	CALL a.insertArrayElement(i)
	CALL a.getArrayElement(i).set(a.getArrayElement(j + 1))
	CALL a.getArrayElement(j + 1).set(a.getArrayElement(i + 1))
	CALL a.deleteArrayElement(i + 1)
END FUNCTION
--------------------------------------------------------------------------------
-- A sort that ignores The if the sort column begins The ...
FUNCTION itunes_sort(p1 reflect.Value, p2 reflect.Value, sort_param STRING) RETURNS SMALLINT
	DEFINE s1, s2 STRING

	LET s1 = p1.getFieldByName(sort_param).toString()
	LET s2 = p2.getFieldByName(sort_param).toString()

	IF s1.subString(1, 4) = "The " THEN
		LET s1 = s1.subString(5, s1.getLength())
	END IF
	IF s2.subString(1, 4) = "The " THEN
		LET s2 = s2.subString(5, s2.getLength())
	END IF

	CASE
		WHEN s1 < s2
			RETURN -1
		WHEN s1 > s2
			RETURN 1
	END CASE
	RETURN 0
END FUNCTION
--------------------------------------------------------------------------------
-- Sort based on length of sort column
FUNCTION length_sort(p1 reflect.Value, p2 reflect.Value, sort_param STRING) RETURNS SMALLINT
	DEFINE l1, l2 INTEGER

	LET l1 = p1.getFieldByName(sort_param).toString().getLength()
	LET l2 = p2.getFieldByName(sort_param).toString().getLength()

	CASE
		WHEN l1 < l2
			RETURN -1
		WHEN l1 > l2
			RETURN 1
	END CASE
	RETURN 0
END FUNCTION
--------------------------------------------------------------------------------
-- A sort that calculates a distance vector from two columns
FUNCTION distance_sort(p1 reflect.Value, p2 reflect.Value, sort_param STRING) RETURNS SMALLINT
	DEFINE column1, column2       STRING
	DEFINE x1, x2, y1, y2, d1, d2 FLOAT

	VAR comma_position = sort_param.getIndexOf(",", 1)
	LET column1 = sort_param.subString(1, comma_position - 1)
	LET column2 = sort_param.subString(comma_position + 1, sort_param.getLength())

	-- TODO Figure out way to avoid calculating each time
	LET x1 = p1.getFieldByName(column1).toString()
	LET y1 = p1.getFieldByName(column2).toString()

	LET x2 = p2.getFieldByName(column1).toString()
	LET y2 = p2.getFieldByName(column2).toString()

	LET d1 = util.Math.sqrt(x1 * x1 + y1 * y1)
	LET d2 = util.Math.sqrt(x2 * x2 + y2 * y2)

	CASE
		WHEN d1 < d2
			RETURN -1
		WHEN d1 > d2
			RETURN 1
	END CASE
	RETURN 0
END FUNCTION

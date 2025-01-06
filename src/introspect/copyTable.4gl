IMPORT reflect
FUNCTION copyTable(l_rv reflect.Value)
	DEFINE l_rec_count INTEGER
	DEFINE x, z        SMALLINT
	DEFINE l_head      STRING
	DEFINE l_line      STRING
	DEFINE l_copy      STRING
	VAR l_rt           reflect.Type = l_rv.getType()

	IF l_rt.getKind() != "ARRAY" THEN
		RETURN
	END IF

	LET l_rec_count = l_rv.getLength()
	VAR l_rv2 reflect.Value
	FOR z = 1 TO l_rec_count -- loop thru array items
		LET l_rv2 = l_rv.getArrayElement(z)
		VAR l_rt2 reflect.Type = l_rv2.getType()
		LET l_line = NULL
		FOR x = 1 TO l_rt2.getFieldCount() -- loop thru fields
			IF z = 1 THEN
				LET l_head = l_head.append(SFMT("%1%2", l_rt2.getFieldName(x), ASCII (9)))
			END IF
			LET l_line = l_line.append(SFMT("%1%2", l_rv2.getField(x).toString() CLIPPED, ASCII (9)))
		END FOR
		IF z = 1 THEN LET l_copy = l_head END IF
		LET l_copy = l_copy.append(SFMT("\n%1", l_line))
	END FOR
	DISPLAY l_copy
	CALL ui.Interface.frontCall("standard","cbset",l_copy,l_head)

END FUNCTION

PACKAGE introspect
IMPORT reflect
FUNCTION sql2array(l_sql STRING, l_r_arr reflect.Value) RETURNS()
	DEFINE l_handle        base.SqlHandle
	DEFINE l_col, l_row    INTEGER
	DEFINE l_r_rec, r_cell reflect.Value

	-- Delete existing array
	CALL l_r_arr.clear()

	LET l_handle = base.SqlHandle.create()
	CALL l_handle.prepare(l_sql)
	--TODO: added error handling
	CALL l_handle.open()
	--TODO: added error handling
	WHILE TRUE
		CALL l_handle.fetch()
		IF sqlca.sqlcode = NOTFOUND THEN
			EXIT WHILE
		END IF
		CALL l_r_arr.appendArrayElement()
		LET l_row   = l_r_arr.getLength()
		LET l_r_rec = l_r_arr.getArrayElement(l_row)

		FOR l_col = 1 TO l_handle.getResultCount()
			-- Assumes table and array structure match, you could modify so it
			-- was more forgiving by using r_rec.getFieldByName, h.getResultByName etc
			LET r_cell = l_r_rec.getField(l_col)
			CALL r_cell.set(reflect.Value.copyOf(l_handle.getResultValue(l_col)))
		END FOR
	END WHILE
	CALL l_handle.close()
END FUNCTION

PACKAGE introspect

IMPORT reflect

FUNCTION show(l_rv reflect.Value)
	DEFINE l_f    ui.Form
	DEFINE l_n    om.DomNode
	DEFINE l_tabl om.DomNode
	DEFINE l_rv2  reflect.Value
	DEFINE x, z   SMALLINT
	DEFINE l_typ  STRING
	DEFINE l_d    ui.Dialog
	DEFINE l_fields DYNAMIC ARRAY OF RECORD
		nam STRING,
		typ STRING
	END RECORD
	DEFINE l_event STRING
	DEFINE l_tabn  STRING

	DISPLAY "Type:", l_rv.getType().toString(), " Kind:", l_rv.getType().getKind()
	DISPLAY "Name:", l_rv.getType().getAttribute("json_name")

-- open a window and create a form with a grid
	OPEN WINDOW intro_show AT 1, 1 WITH 1 ROWS, 1 COLUMNS
	LET l_f = ui.Window.getCurrent().createForm("intro_show")
	LET l_n = l_f.getNode().createChild('Grid')
	CALL l_n.setAttribute("width", 100)
	CALL l_n.setAttribute("gridWidth", 100)

-- find out if we have RECORD or an ARRAY passed.
	LET l_typ = l_rv.getType().toString()
	IF l_typ != "RECORD" THEN
		LET l_typ = l_rv.getType().getKind()
	END IF

-- If it's record then add the record items to the form and do a simple menu.
	IF l_typ = "RECORD" THEN
		FOR x = 1 TO l_rv.getType().getFieldCount()
			CALL formAddGridItem(x, l_n, l_rv.getType(), l_rv.getField(x).toString())
		END FOR
		MENU
			ON ACTION back ATTRIBUTES(TEXT = "Back")
				EXIT MENU
			ON ACTION close
				EXIT MENU
		END MENU
	END IF

-- If it's an array then create a table build a display array
	IF l_typ = "ARRAY" THEN
		LET l_tabl = l_n.createChild("Table")
		LET l_tabn = "tablistv"
		DISPLAY "Tabn:", l_tabn, " Len: ", l_rv.getLength()
		CALL l_tabl.setAttribute("tabName", l_tabn)
		CALL l_tabl.setAttribute("width", 100)
		CALL l_tabl.setAttribute("gridWidth", 100)
		CALL l_tabl.setAttribute("height", "20")
		CALL l_tabl.setAttribute("pageSize", "20")
		CALL l_tabl.setAttribute("posY", "1")

		-- add the columns to the table build our 'fields' list.
		LET l_rv2 = l_rv.getArrayElement(1)
		FOR x = 1 TO l_rv2.getType().getFieldCount()
			LET l_fields[x].nam = l_rv2.getType().getFieldName(x)
			LET l_fields[x].typ = l_rv2.getType().getFieldType(x).toString()
			CALL formAddTableColumn(x, l_tabl, l_rv2.getType())
		END FOR

		-- create a dialog object and populate it.
		LET l_d = ui.Dialog.createDisplayArrayTo(l_fields, l_tabn)
		FOR z = 1 TO l_rv.getLength() -- loop through array items
			LET l_rv2 = l_rv.getArrayElement(z)
			CALL l_d.setCurrentRow(l_tabn, z)
			FOR x = 1 TO l_rv2.getType().getFieldCount() -- loop though fields in the record
				CALL l_d.setFieldValue(l_fields[x].nam, l_rv2.getField(x).toString())
			END FOR
			CALL l_d.setCurrentRow(l_tabn, 1) -- force the first row to be the current row.
		END FOR

		-- add our default actions to the dialog
		CALL l_d.addTrigger("ON ACTION close")
		CALL l_d.addTrigger("ON ACTION accept")
		CALL l_d.addTrigger("ON ACTION cancel")

		-- loop getting events from the dialog object
		WHILE TRUE
			LET l_event = l_d.nextEvent()
			CASE l_event
				WHEN "ON ACTION close"
					LET int_flag = TRUE
					EXIT WHILE
				WHEN "ON ACTION cancel"
					LET int_flag = TRUE
					EXIT WHILE
			END CASE
		END WHILE
		CALL l_d.close()
	END IF

	CLOSE WINDOW intro_show

END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- add a label and field to the passed grid.
PRIVATE FUNCTION formAddGridItem(x SMALLINT, l_n om.domNode, l_et reflect.Type, l_val STRING) RETURNS()
	DEFINE l_lab      om.DomNode
	DEFINE l_ff       om.DomNode
	DEFINE l_len      SMALLINT
	DEFINE l_numalign BOOLEAN = FALSE

	LET l_lab = l_n.createChild("Label")
	CALL l_lab.setAttribute("text", l_et.getFieldName(x) || ":")
	CALL l_lab.setAttribute("posY", x)
	CALL l_lab.setAttribute("posX", 1)
	CALL l_lab.setAttribute("gridWidth", 18)
	CALL l_lab.setAttribute("justify", "right")

	CALL getTypeLen(l_et.getFieldType(x).toString()) RETURNING l_len, l_numalign

	LET l_ff = l_n.createChild("FormField")
	CALL l_ff.setAttribute("colName", l_et.getFieldName(x))
	CALL l_ff.setAttribute("name", "formonly." || l_et.getFieldName(x))
	CALL l_ff.setAttribute("value", l_val)
	CALL l_ff.setAttribute("numAlign", l_numalign)
	CALL l_ff.setAttribute("varType", l_et.getFieldType(x).toString())
	LET l_ff = l_ff.createChild("Edit")
	CALL l_ff.setAttribute("name", l_et.getFieldName(x))
	CALL l_ff.setAttribute("posY", x)
	CALL l_ff.setAttribute("posX", 20)
	CALL l_ff.setAttribute("width", l_len)
	CALL l_ff.setAttribute("gridWidth", l_len)
	CALL l_ff.setAttribute("comment", l_et.getFieldType(x).toString())
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- add a tableColmumn to the passed table object.
PRIVATE FUNCTION formAddTableColumn(x SMALLINT, l_n om.domNode, l_et reflect.Type) RETURNS()
	DEFINE l_tc       om.DomNode
	DEFINE l_len      SMALLINT
	DEFINE l_numalign BOOLEAN = FALSE

	CALL getTypeLen(l_et.getFieldType(x).toString()) RETURNING l_len, l_numalign
	LET l_tc = l_n.createChild("TableColumn")
	CALL l_tc.setAttribute("text", l_et.getFieldName(x))
	CALL l_tc.setAttribute("colName", l_et.getFieldName(x))
	CALL l_tc.setAttribute("name", "formonly." || l_et.getFieldName(x))
	CALL l_tc.setAttribute("varType", l_et.getFieldType(x).toString())
	CALL l_tc.setAttribute("numAlign", l_numalign)
	LET l_tc = l_tc.createChild("Edit")
	CALL l_tc.setAttribute("width", l_len)

END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- find the length of the field and if it's numeric or not
-- @returns length ( smallint ), isnumeric ( boolean )
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION getTypeLen(l_typ STRING) RETURNS(SMALLINT, BOOLEAN)
	DEFINE z, y, l_len SMALLINT
	DEFINE l_numalign  BOOLEAN = FALSE
	DISPLAY "Type:", l_typ
	CASE l_typ
		WHEN "SMALLINT"
			LET l_len      = 5
			LET l_numalign = TRUE
		WHEN "INTEGER"
			LET l_len      = 10
			LET l_numalign = TRUE
		WHEN "FLOAT"
			LET l_len      = 10
			LET l_numalign = TRUE
		WHEN "STRING"
			LET l_len = 50
		WHEN "DATE"
			LET l_len      = 10
			LET l_numalign = TRUE
		WHEN "DATETIME YEAR TO FRACTION(5)"
			LET l_len      = 26
			LET l_numalign = TRUE
		WHEN "DATETIME YEAR TO SECOND"
			LET l_len      = 20
			LET l_numalign = TRUE
		WHEN "DATETIME YEAR TO MINUTE"
			LET l_len      = 17
			LET l_numalign = TRUE
		WHEN "DATETIME YEAR TO HOUR"
			LET l_len      = 14
			LET l_numalign = TRUE
	END CASE
	LET z = l_typ.getIndexOf("(", 1)
	IF l_typ MATCHES "DECIMAL*" OR l_typ MATCHES "MONEY*" THEN
		LET l_numalign = TRUE
	END IF

	IF z > 0 THEN
		LET y = l_typ.getIndexOf(",", z)
		IF y = 0 THEN
			LET y = l_typ.getIndexOf(")", z)
		END IF
		LET l_len = l_typ.subString(z + 1, y - 1)
	END IF

	RETURN l_len, l_numalign
END FUNCTION

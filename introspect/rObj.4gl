PACKAGE introspect

IMPORT reflect

PUBLIC TYPE rObj RECORD
	kind STRING,
	type STRING,
	flds DYNAMIC ARRAY OF RECORD
		name   STRING,
		type   STRING,
		len    INTEGER,
		num    BOOLEAN,
		func   BOOLEAN,
		values DYNAMIC ARRAY OF STRING
	END RECORD,
	methods DYNAMIC ARRAY OF RECORD
		name    STRING,
		params  DYNAMIC ARRAY OF STRING,
		returns DYNAMIC ARRAY OF STRING
	END RECORD,
	rec_count SMALLINT
END RECORD

FUNCTION (this rObj) init(l_rv reflect.Value)
	DEFINE x, z SMALLINT
	LET this.kind = l_rv.getType().getKind()
	LET this.type = l_rv.getType().toString()
	DISPLAY SFMT("\ninit - Type: %1 Kind: %2 json_name: %3",
			this.type, this.kind, l_rv.getType().getAttribute("json_name"))

	IF this.kind = "RECORD" THEN
		FOR x = 1 TO l_rv.getType().getFieldCount()
			VAR l_et reflect.Type = l_rv.getType()
			LET this.flds[x].name = l_et.getFieldName(x)
			LET this.flds[x].type = l_et.getFieldType(x).toString()
			CALL getTypeLen(this.flds[x].type) RETURNING this.flds[x].len, this.flds[x].num, this.flds[x].func
			LET this.flds[x].values[1] = l_rv.getField(x).toString()
			LET this.rec_count         = 1
		END FOR
		FOR x = 1 TO l_rv.getType().getMethodCount()
			VAR l_em reflect.Method = l_rv.getType().getMethod(x)
			LET this.methods[x].name = l_em.getName()
			FOR z = 1 TO l_em.getParameterCount()
				LET this.methods[x].params[z] = l_em.getParameterType(z).toString()
			END FOR
			FOR z = 1 TO l_em.getReturnCount()
				LET this.methods[x].returns[z] = l_em.getReturnType(z).toString()
			END FOR
		END FOR
	END IF
	IF this.kind = "ARRAY" THEN
		LET this.rec_count = l_rv.getLength()
		FOR z = 1 TO this.rec_count -- loop through array items
			VAR l_rv2 reflect.Value
			LET l_rv2 = l_rv.getArrayElement(z)
			FOR x = 1 TO l_rv2.getType().getFieldCount()
				IF z = 1 THEN
					VAR l_et reflect.Type = l_rv2.getType()
					LET this.flds[x].name = l_et.getFieldName(x)
					LET this.flds[x].type = l_et.getFieldType(x).toString()
					CALL getTypeLen(this.flds[x].type) RETURNING this.flds[x].len, this.flds[x].num, this.flds[x].func
				END IF
				LET this.flds[x].values[z] = l_rv2.getField(x).toString()
			END FOR
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this rObj) dump()
	DEFINE x, z SMALLINT
	DISPLAY this.kind
	IF this.kind = "RECORD" THEN
		DISPLAY "Fields:"
		FOR x = 1 TO this.flds.getLength()
			DISPLAY SFMT("%1) %2 %3 Length: %4", x, this.flds[x].name, this.flds[x].type, this.flds[x].len)
		END FOR
		DISPLAY "Methods:"
		FOR x = 1 TO this.methods.getLength()
			IF this.methods[x].params.getLength() > 0 THEN
				DISPLAY SFMT("%1) %2(", x, this.methods[x].name)
				FOR z = 1 TO this.methods[x].params.getLength()
					DISPLAY SFMT("  p%1 %2", z, this.methods[x].params[z])
				END FOR
				DISPLAY "    )"
			ELSE
				DISPLAY SFMT("%1) %2()", x, this.methods[x].name)
			END IF
			IF this.methods[x].returns.getLength() > 0 THEN
				DISPLAY " RETURNS ("
				FOR z = 1 TO this.methods[x].returns.getLength()
					DISPLAY SFMT(" %1", this.methods[x].returns[z])
				END FOR
				DISPLAY "    )"
			ELSE
				DISPLAY " ) RETURNS ()"
			END IF
		END FOR
	END IF
	IF this.kind = "ARRAY" THEN
		FOR z = 1 TO this.rec_count
			FOR x = 1 TO this.flds.getLength()
				DISPLAY SFMT("Row %1: %2 = %3 ( %4 )", z, this.flds[x].name, this.flds[x].values[z], this.flds[x].type)
			END FOR
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this rObj) show()
	DEFINE l_n om.DomNode
	IF this.flds.getLength() = 0 THEN
		RETURN
	END IF
-- open a window and create a form with a grid
	OPEN WINDOW intro_show AT 1, 1 WITH 1 ROWS, 1 COLUMNS
	LET l_n = ui.Window.getCurrent().createForm("intro_show").getNode().createChild('Grid')
	CALL l_n.setAttribute("width", 100)
	CALL l_n.setAttribute("gridWidth", 100)
	IF this.kind = "RECORD" THEN
		CALL this.showRecord(l_n)
	END IF
	IF this.kind = "ARRAY" THEN
		CALL this.showArray(l_n)
	END IF
	CLOSE WINDOW intro_show
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Add the record items to the form and do a simple menu.
FUNCTION (this rObj) showRecord(l_n om.DomNode)
	DEFINE x, y, z  SMALLINT
	DEFINE l_lab    om.DomNode
	DEFINE l_ff     om.DomNode
	DEFINE l_method STRING
	LET y = 1
	FOR x = 1 TO this.flds.getLength()
		LET l_lab = l_n.createChild("Label")
		CALL l_lab.setAttribute("text", this.flds[x].name || ":")
		CALL l_lab.setAttribute("posY", y)
		CALL l_lab.setAttribute("posX", 1)
		CALL l_lab.setAttribute("gridWidth", 18)
		CALL l_lab.setAttribute("justify", "right")

		LET l_ff = l_n.createChild("FormField")
		CALL l_ff.setAttribute("colName", this.flds[x].name)
		CALL l_ff.setAttribute("name", "formonly." || this.flds[x].name)
		CALL l_ff.setAttribute("value", this.flds[x].values[1])
		IF this.flds[x].func THEN
			CALL l_ff.setAttribute("value", this.flds[x].type)
		END IF
		CALL l_ff.setAttribute("numAlign", this.flds[x].num)
		CALL l_ff.setAttribute("varType", this.flds[x].type)
		LET l_ff = l_ff.createChild("Edit")
		CALL l_ff.setAttribute("name", this.flds[x].name)
		CALL l_ff.setAttribute("posY", y)
		CALL l_ff.setAttribute("posX", 20)
		CALL l_ff.setAttribute("width", this.flds[x].len)
		CALL l_ff.setAttribute("gridWidth", this.flds[x].len)
		CALL l_ff.setAttribute("comment", this.flds[x].type)
		LET y += 1
	END FOR
	IF this.methods.getLength() > 0 THEN
		LET l_lab = l_n.createChild("Label")
		CALL l_lab.setAttribute("text", "Methods:")
		CALL l_lab.setAttribute("posY", y)
		CALL l_lab.setAttribute("posX", 1)
		CALL l_lab.setAttribute("gridWidth", 20)
		CALL l_lab.setAttribute("justify", "left")
		LET y += 1
		FOR x = 1 TO this.methods.getLength()
			LET l_method = this.methods[x].name || "("
			FOR z = 1 TO this.methods[x].params.getLength()
				LET l_method = l_method.append(SFMT("p%1 %2", z, this.methods[x].params[z]))
				IF z < this.methods[x].params.getLength() THEN
					LET l_method = l_method.append(", ")
				END IF
			END FOR
			LET l_method = l_method.append(") RETURNS (")
			FOR z = 1 TO this.methods[x].returns.getLength()
				LET l_method = l_method.append(SFMT("%1", this.methods[x].returns[z]))
				IF z < this.methods[x].returns.getLength() THEN
					LET l_method = l_method.append(", ")
				END IF
			END FOR
			LET l_method = l_method.append(")")
			LET l_lab    = l_n.createChild("Label")
			CALL l_lab.setAttribute("text", l_method)
			CALL l_lab.setAttribute("posY", y)
			CALL l_lab.setAttribute("posX", 1)
			CALL l_lab.setAttribute("gridWidth", l_method.getLength())
			CALL l_lab.setAttribute("fontPitch", "fixed")
			LET y += 1
		END FOR
	END IF
	MENU
		ON ACTION back ATTRIBUTES(TEXT = "Back")
			EXIT MENU
		ON ACTION close
			EXIT MENU
	END MENU
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- create a table build a display array
FUNCTION (this rObj) showArray(l_n om.DomNode)
	DEFINE l_d ui.Dialog
	DEFINE l_fields DYNAMIC ARRAY OF RECORD
		nam STRING,
		typ STRING
	END RECORD
	DEFINE l_tabl, l_tc om.DomNode
	DEFINE l_event      STRING
	DEFINE l_tabn       STRING
	DEFINE x, z         SMALLINT

	LET l_tabl = l_n.createChild("Table")
	LET l_tabn = "tablistv"
	CALL l_tabl.setAttribute("tabName", l_tabn)
	CALL l_tabl.setAttribute("width", 100)
	CALL l_tabl.setAttribute("gridWidth", 100)
	CALL l_tabl.setAttribute("height", "20")
	CALL l_tabl.setAttribute("pageSize", "20")
	CALL l_tabl.setAttribute("posY", "1")

	-- add the columns to the table build our 'fields' list.
	FOR x = 1 TO this.flds.getLength()
		LET l_fields[x].nam = this.flds[x].name
		LET l_fields[x].typ = this.flds[x].type
		LET l_tc            = l_tabl.createChild("TableColumn")
		CALL l_tc.setAttribute("text", this.flds[x].name)
		CALL l_tc.setAttribute("colName", this.flds[x].name)
		CALL l_tc.setAttribute("name", "formonly." || this.flds[x].name)
		CALL l_tc.setAttribute("varType", this.flds[x].type)
		CALL l_tc.setAttribute("numAlign", this.flds[x].num)
		LET l_tc = l_tc.createChild("Edit")
		CALL l_tc.setAttribute("width", this.flds[x].len)
	END FOR

	-- create a dialog object and populate it.
	LET l_d = ui.Dialog.createDisplayArrayTo(l_fields, l_tabn)
	FOR z = 1 TO this.flds[1].values.getLength() -- loop through array items
		CALL l_d.setCurrentRow(l_tabn, z)
		FOR x = 1 TO this.flds.getLength() -- loop though fields in the record
			CALL l_d.setFieldValue(l_fields[x].nam, this.flds[x].values[z])
		END FOR
		CALL l_d.setCurrentRow(l_tabn, 1) -- force the first row to be the current row.
	END FOR

	-- add our default actions to the dialog
	CALL l_d.addTrigger("ON ACTION close")
	CALL l_d.addTrigger("ON ACTION back")
	CALL l_d.setActionAttribute("back", "text", "Back")

	-- loop getting events from the dialog object
	WHILE TRUE
		LET l_event = l_d.nextEvent()
		CASE l_event
			WHEN "ON ACTION close"
				EXIT WHILE
			WHEN "ON ACTION back"
				EXIT WHILE
		END CASE
	END WHILE
	CALL l_d.close()
END FUNCTION

--------------------------------------------------------------------------------------------------------------
-- find the length of the field and if it's numeric or not
-- @returns length ( smallint ), isnumeric ( boolean )
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION getTypeLen(l_typ STRING) RETURNS(SMALLINT, BOOLEAN, BOOLEAN)
	DEFINE z, y, l_len SMALLINT
	DEFINE l_numalign  BOOLEAN = TRUE
	DEFINE l_func      BOOLEAN = FALSE

	CASE l_typ
		WHEN "SMALLINT"
			LET l_len = 5
		WHEN "INTEGER"
			LET l_len = 10
		WHEN "FLOAT"
			LET l_len = 10
		WHEN "STRING"
			LET l_len = 50
		WHEN "DATE"
			LET l_len = 10
		WHEN "DATETIME YEAR TO FRACTION(5)"
			LET l_len = 26
		WHEN "DATETIME YEAR TO SECOND"
			LET l_len = 20
		WHEN "DATETIME YEAR TO MINUTE"
			LET l_len = 17
		WHEN "DATETIME YEAR TO HOUR"
			LET l_len = 14
	END CASE

	IF l_typ.subString(1, 8) = "FUNCTION" THEN
		LET l_len      = l_typ.getLength()
		LET l_func     = TRUE
		LET l_numalign = FALSE
	ELSE
		IF l_typ.subString(1, 4) = "CHAR" OR l_typ.subString(1, 7) = "VARCHAR" OR l_typ.subString(1, 6) = "STRING" THEN
			LET l_numalign = FALSE
		END IF

		LET z = l_typ.getIndexOf("(", 1)
		IF z > 0 THEN
			LET y = l_typ.getIndexOf(",", z)
			IF y = 0 THEN
				LET y = l_typ.getIndexOf(")", z)
			END IF
			LET l_len = l_typ.subString(z + 1, y - 1)
		END IF
	END IF
	DISPLAY SFMT("Type: %1 Len: %2 Num: %3 Func: %4", l_typ, l_len, l_numalign, l_func)

	RETURN l_len, l_numalign, l_func
END FUNCTION

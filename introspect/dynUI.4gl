-- A simple Dynamic UI module.

PACKAGE introspect
IMPORT reflect
IMPORT FGL introspect.rObj
IMPORT FGL introspect.prettyName

PUBLIC TYPE dUI RECORD
	rObj       rObj,
	windowOpen BOOLEAN
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this dUI) init(l_rObj rObj)
	LET this.rObj       = l_rObj
	LET this.windowOpen = FALSE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this dUI) show(l_titl STRING, l_rObj rObj, l_wait BOOLEAN)
	DEFINE l_n om.DomNode
	DEFINE x   INT
	LET this.rObj = l_rObj
	IF this.rObj.flds.getLength() = 0 THEN
		RETURN
	END IF
--	BREAKPOINT
	IF NOT this.windowOpen THEN
-- open a window and create a form with a grid
		OPEN WINDOW dUI AT 1, 1 WITH 1 ROWS, 1 COLUMNS
		LET this.windowOpen = TRUE
		IF l_titl IS NULL THEN
			LET l_titl = SFMT("Show Introspection of '%1'", this.rObj.name)
		END IF
		CALL ui.Window.getCurrent().setText(l_titl)
		LET l_n = ui.Window.getCurrent().createForm("dUI").getNode().createChild('Grid')
		CALL l_n.setAttribute("width", 100)
		CALL l_n.setAttribute("gridWidth", 100)

		IF this.rObj.kind = "RECORD" THEN
			CALL this.showRecord(l_n)
		END IF
		IF this.rObj.kind = "ARRAY" THEN
			CALL this.showArray("tablistv", l_n)
			LET x = this.displayArray("tablistv", FALSE) -- display the array but exit.
		END IF
	END IF
	IF l_wait THEN
		MENU
			ON ACTION back ATTRIBUTES(TEXT = "Back")
				EXIT MENU
			ON ACTION close
				EXIT MENU
		END MENU
		CALL this.closeWindow()
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this dUI) closeWindow() RETURNS()
	IF this.windowOpen THEN
		CLOSE WINDOW dUI
		LET this.windowOpen = FALSE
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Add the record items to the form and do a simple menu.
FUNCTION (this dUI) showRecord(l_n om.DomNode)
	DEFINE x, y     SMALLINT
	DEFINE l_lab    om.DomNode
	DEFINE l_ff     om.DomNode
	DEFINE l_method STRING
	LET y = 1
	FOR x = 1 TO this.rObj.flds.getLength()
		LET l_lab = l_n.createChild("Label")
		CALL l_lab.setAttribute("text", prettyName(this.rObj.flds[x].name) || ":")
		CALL l_lab.setAttribute("posY", y)
		CALL l_lab.setAttribute("posX", 1)
		CALL l_lab.setAttribute("gridWidth", 18)
		CALL l_lab.setAttribute("justify", "right")
		CALL l_lab.setAttribute("style", "bold")

		LET l_ff = l_n.createChild("FormField")
		CALL l_ff.setAttribute("colName", this.rObj.flds[x].name)
		CALL l_ff.setAttribute("name", "formonly." || this.rObj.flds[x].name)
		CALL l_ff.setAttribute("numAlign", this.rObj.flds[x].num)
		CALL l_ff.setAttribute("varType", this.rObj.flds[x].type)
		IF this.rObj.flds[x].canEdit THEN
			CALL l_ff.setAttribute("value", this.rObj.flds[x].values[1])
			LET l_ff = l_ff.createChild("Edit")
		ELSE
			CALL l_ff.setAttribute("value", this.rObj.flds[x].type)
			LET l_ff = l_ff.createChild("Label")
		END IF
		CALL l_ff.setAttribute("name", this.rObj.flds[x].name)
		CALL l_ff.setAttribute("posY", y)
		CALL l_ff.setAttribute("posX", 20)
		CALL l_ff.setAttribute("width", this.rObj.flds[x].len)
		CALL l_ff.setAttribute("gridWidth", this.rObj.flds[x].len)
		CALL l_ff.setAttribute("comment", this.rObj.flds[x].type)
		LET y += 1
	END FOR
	IF this.rObj.methods.getLength() > 0 THEN
		LET l_lab = l_n.createChild("Label")
		CALL l_lab.setAttribute("text", "Methods:")
		CALL l_lab.setAttribute("posY", y)
		CALL l_lab.setAttribute("posX", 1)
		CALL l_lab.setAttribute("gridWidth", 20)
		CALL l_lab.setAttribute("justify", "left")
		LET y += 1
		FOR x = 1 TO this.rObj.methods.getLength()
			LET l_method = SFMT("%1%2", this.rObj.methods[x].name, this.rObj.methods[x].signature)
{ -- alternative way to show the parameters and returns of the function methods.
			LET l_method = this.rObj.methods[x].name || "("
			FOR z = 1 TO this.rObj.methods[x].params.getLength()
				LET l_method = l_method.append(SFMT("p%1 %2", z, this.rObj.methods[x].params[z]))
				IF z < this.rObj.methods[x].params.getLength() THEN
					LET l_method = l_method.append(", ")
				END IF
			END FOR
			LET l_method = l_method.append(") RETURNS (")
			FOR z = 1 TO this.rObj.methods[x].returns.getLength()
				LET l_method = l_method.append(SFMT("%1", this.rObj.methods[x].returns[z]))
				IF z < this.rObj.methods[x].returns.getLength() THEN
					LET l_method = l_method.append(", ")
				END IF
			END FOR
			LET l_method = l_method.append(")")
}
			LET l_lab = l_n.createChild("Label")
			CALL l_lab.setAttribute("text", l_method)
			CALL l_lab.setAttribute("posY", y)
			CALL l_lab.setAttribute("posX", 1)
			CALL l_lab.setAttribute("gridWidth", l_method.getLength())
			CALL l_lab.setAttribute("fontPitch", "fixed")
			LET y += 1
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- create a table
FUNCTION (this dUI) showArray(l_tabn STRING, l_n om.DomNode)
	DEFINE l_fields DYNAMIC ARRAY OF RECORD
		nam STRING,
		typ STRING
	END RECORD
	DEFINE l_tabl, l_tc om.DomNode
	DEFINE x            SMALLINT

	LET l_tabl = l_n.createChild("Table")
	CALL l_tabl.setAttribute("tabName", l_tabn)
	CALL l_tabl.setAttribute("width", 100)
	CALL l_tabl.setAttribute("gridWidth", 100)
	CALL l_tabl.setAttribute("height", "20")
	CALL l_tabl.setAttribute("pageSize", "20")
	CALL l_tabl.setAttribute("posY", "1")

	-- add the columns to the table build our 'fields' list.
	FOR x = 1 TO this.rObj.flds.getLength()
		LET l_fields[x].nam = this.rObj.flds[x].name
		LET l_fields[x].typ = this.rObj.flds[x].type
		LET l_tc            = l_tabl.createChild("TableColumn")
		CALL l_tc.setAttribute("text", prettyName(this.rObj.flds[x].name))
		CALL l_tc.setAttribute("colName", this.rObj.flds[x].name)
		CALL l_tc.setAttribute("name", "formonly." || this.rObj.flds[x].name)
		CALL l_tc.setAttribute("varType", this.rObj.flds[x].type)
		CALL l_tc.setAttribute("numAlign", this.rObj.flds[x].num)
		LET l_tc = l_tc.createChild("Edit")
		CALL l_tc.setAttribute("width", this.rObj.flds[x].len)
	END FOR
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- create a table
FUNCTION (this dUI) displayArray(l_tabn STRING, l_interactive BOOLEAN) RETURNS INT
	DEFINE l_d ui.Dialog
	DEFINE l_fields DYNAMIC ARRAY OF RECORD
		nam STRING,
		typ STRING
	END RECORD
	DEFINE l_event STRING
	DEFINE x, z    SMALLINT
	FOR x = 1 TO this.rObj.flds.getLength()
		LET l_fields[x].nam = this.rObj.flds[x].name
		LET l_fields[x].typ = this.rObj.flds[x].type
	END FOR
	-- create a dialog object and populate it.
	LET l_d = ui.Dialog.createDisplayArrayTo(l_fields, l_tabn)
	FOR z = 1 TO this.rObj.flds[1].values.getLength() -- loop through array items
		CALL l_d.setCurrentRow(l_tabn, z)
		FOR x = 1 TO this.rObj.flds.getLength() -- loop though fields in the record
			CALL l_d.setFieldValue(l_fields[x].nam, this.rObj.flds[x].values[z])
		END FOR
	END FOR
	CALL l_d.setCurrentRow(l_tabn, 1) -- force the first row to be the current row.

	-- add our default actions to the dialog
	CALL l_d.addTrigger("ON ACTION close")
	CALL l_d.addTrigger("ON ACTION accept")
	CALL l_d.addTrigger("ON ACTION cancel")
	LET x = 0
	-- loop getting events from the dialog object
	WHILE TRUE
		LET l_event = l_d.nextEvent()
		CASE l_event
			WHEN "BEFORE DISPLAY"
				IF NOT l_interactive THEN
					EXIT WHILE
				END IF
			WHEN "ON ACTION close"
				EXIT WHILE
			WHEN "ON ACTION accept"
				LET x = l_d.getCurrentRow(l_tabn)
				EXIT WHILE
			WHEN "ON ACTION cancel"
				EXIT WHILE
		END CASE
	END WHILE
	CALL l_d.close()
	RETURN x
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- do Input, return true if 'accepted'
FUNCTION (this dUI) doInput() RETURNS BOOLEAN
	DEFINE l_fields DYNAMIC ARRAY OF RECORD
		nam STRING,
		typ STRING
	END RECORD
	DEFINE x       SMALLINT
	DEFINE l_event STRING
	DEFINE l_fld   reflect.Value
	DEFINE l_d     ui.Dialog

	FOR x = 1 TO this.rObj.flds.getLength()
		LET l_fields[x].nam = this.rObj.flds[x].name
		LET l_fields[x].typ = this.rObj.flds[x].type
	END FOR
	LET l_d = ui.Dialog.createInputByName(l_fields)
	FOR x = 1 TO this.rObj.flds.getLength() -- loop though fields in the record
		CALL l_d.setFieldValue(l_fields[x].nam, this.rObj.flds[x].values[1])
	END FOR

	-- add our default actions to the dialog
	CALL l_d.addTrigger("ON ACTION accept")
	CALL l_d.addTrigger("ON ACTION cancel")
	CALL l_d.addTrigger("ON ACTION close")

	-- loop getting events from the dialog object
	LET int_flag = FALSE
	WHILE TRUE
		LET l_event = l_d.nextEvent()
		CASE l_event
			WHEN "ON ACTION accept"
				EXIT WHILE
			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
		END CASE
	END WHILE
	IF NOT int_flag THEN
		FOR x = 1 TO this.rObj.flds.getLength()
			LET l_fld = this.rObj.reflectV.getField(x)
			CALL l_fld.set(reflect.Value.copyOf(l_d.getFieldBuffer(l_fields[x].nam)))
		END FOR
	END IF
	CALL l_d.close()
	RETURN NOT int_flag
END FUNCTION

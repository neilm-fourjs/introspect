IMPORT reflect
IMPORT FGL fgldialog
IMPORT FGL introspect.*

&include "debug_dump.inc"

TYPE t_rec RECORD
	my_key   INTEGER ATTRIBUTE(json_name = "key"),
	a_string STRING,
	created  DATETIME YEAR TO SECOND,
	cost     DECIMAL(10, 2)
END RECORD

MAIN
	DEFINE l_rec t_rec ATTRIBUTE(json_name = "l_rec")
	DEFINE l_arr DYNAMIC ARRAY OF t_rec ATTRIBUTE(json_name = "l_arr")
	DEFINE x     SMALLINT
	DEFINE l_r   introspect.rObj.rObj
	DEFINE l_dUI introspect.dynUI.dUI

	FOR x = 1 TO 5
		LET l_arr[x].my_key   = x
		LET l_arr[x].a_string = "This is test " || x
		LET l_arr[x].created  = CURRENT
		LET l_arr[x].cost     = x * .5
	END FOR
	LET l_rec = l_arr[1]

	CALL fgl_settitle("Reflection Interactive Demo")
	MENU
		ON ACTION dumprRec ATTRIBUTES(TEXT = "Dump Rec")
			DEBUG_DUMP("l_rec", l_rec)

		ON ACTION uirRec ATTRIBUTES(TEXT = "UI Rec")
			DISPLAY SFMT("A String Before: %1", l_rec.a_string)
			CALL l_r.init("l_rec", reflect.Value.valueOf(l_rec))
			CALL l_dUI.show(l_titl: NULL, l_rObj: l_r, l_wait: FALSE)
			IF l_dUI.doInput() THEN
				DISPLAY SFMT("A String After: %1", l_rec.a_string)
			ELSE
				DISPLAY "Cancelled"
			END IF
			CALL l_dUI.closeWindow()

		ON ACTION uirArr ATTRIBUTES(TEXT = "UI Arr")
			CALL l_r.init("l_arr", reflect.Value.valueOf(l_arr))
			CALL l_dUI.show(l_titl: NULL, l_rObj: l_r, l_wait: FALSE)
			LET x = l_dUI.displayArray(l_tabn: "tablistv",l_interactive: TRUE)
			IF x > 0 THEN
				DISPLAY SFMT("Row %1 Selected", x)
			ELSE
				DISPLAY "Cancelled"
			END IF
			CALL l_dUI.closeWindow()

		ON ACTION quit ATTRIBUTES(TEXT = "Quit")
			EXIT MENU
	END MENU
	DISPLAY "Program Finished."
END MAIN

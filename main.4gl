IMPORT reflect
IMPORT FGL fgldialog
IMPORT FGL introspect.*

&include "debug_dump.inc"

TYPE t_rec RECORD
	my_key   INTEGER ATTRIBUTE(json_name = "Key"),
	a_string STRING ATTRIBUTE(json_name = "String"),
	created  DATETIME YEAR TO SECOND ATTRIBUTE(json_name = "Created"),
	cost     DECIMAL(10, 2) ATTRIBUTE(json_name = "Cost")
END RECORD

MAIN
	DEFINE l_rec t_rec ATTRIBUTE(json_name = "l_rec")
	DEFINE l_arr DYNAMIC ARRAY ATTRIBUTE(json_name = "l_arr") OF t_rec
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

	CALL fgl_settitle("Reflection Demo")
	MENU
		ON ACTION dumprRec ATTRIBUTES(TEXT = "Dump Rec")
			DEBUG_DUMP("l_rec", l_rec)

		ON ACTION dumprArr ATTRIBUTES(TEXT = "Dump Arr")
			DEBUG_DUMP("l_arr", l_arr)

		ON ACTION uirRec ATTRIBUTES(TEXT = "UI Rec")
			CALL l_r.init("l_rec", reflect.Value.valueOf(l_rec))
			CALL l_dUI.show(l_titl: NULL, l_rObj: l_r, l_wait: TRUE)

		ON ACTION uirArr ATTRIBUTES(TEXT = "UI Arr")
			CALL l_r.init("l_arr", reflect.Value.valueOf(l_arr))
			CALL l_dUI.show(l_titl: NULL, l_rObj: l_r, l_wait: TRUE)

		ON ACTION quit ATTRIBUTES(TEXT = "Quit")
			EXIT MENU
	END MENU
END MAIN

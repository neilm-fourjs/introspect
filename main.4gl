IMPORT reflect
IMPORT FGL fgldialog
IMPORT FGL introspect.*

TYPE t_rec RECORD
	my_key   INTEGER ATTRIBUTE(json_name = "key"),
	a_string STRING,
	created  DATETIME YEAR TO SECOND,
	cost     DECIMAL(10, 2)
END RECORD

MAIN
	DEFINE l_rec   t_rec ATTRIBUTE(json_name = "l_rec")
	DEFINE l_arr   DYNAMIC ARRAY OF t_rec ATTRIBUTE(json_name = "l_arr")
	DEFINE x       SMALLINT
	DEFINE l_r_rec introspect.rObj.rObj
	DEFINE l_r_arr introspect.rObj.rObj

	FOR x = 1 TO 5
		LET l_arr[x].my_key   = x
		LET l_arr[x].a_string = "This is test " || x
		LET l_arr[x].created  = CURRENT
		LET l_arr[x].cost     = x * .5
	END FOR
	LET l_rec = l_arr[1]
	CALL fgl_settitle("Reflection Demo")
	MENU
		ON ACTION rRec ATTRIBUTES(TEXT = "Reflect Rec")
			CALL l_r_rec.init("l_rec", reflect.Value.valueOf(l_rec))
			CALL l_r_rec.dump()
			CALL l_r_rec.show(NULL)

		ON ACTION rArr ATTRIBUTES(TEXT = "Reflect Arr")
			CALL l_r_arr.init("l_arr", reflect.Value.valueOf(l_arr))
			CALL l_r_arr.dump()
			CALL l_r_arr.show(NULL)

		ON ACTION quit ATTRIBUTES(TEXT = "Quit")
			EXIT MENU
	END MENU
END MAIN

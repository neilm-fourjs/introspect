IMPORT reflect
IMPORT FGL introspect.*

TYPE t_rec RECORD
	key     INTEGER,
	desc    STRING,
	created DATETIME YEAR TO SECOND,
	cost    DECIMAL(10, 2)
END RECORD

MAIN
	DEFINE l_rec t_rec
	DEFINE l_arr DYNAMIC ARRAY OF t_rec ATTRIBUTE(json_name = "l_arr")
	DEFINE x     SMALLINT

	FOR x = 1 TO 5
		LET l_arr[x].key     = x
		LET l_arr[x].desc    = "This is test " || x
		LET l_arr[x].created = CURRENT
		LET l_arr[x].cost    = x * .5
	END FOR
	LET l_rec = l_arr[1]

	MENU
		ON ACTION showRec ATTRIBUTES(TEXT = "Show Rec")
			CALL introspect.show(reflect.Value.valueOf(l_rec))
		ON ACTION showArray ATTRIBUTES(TEXT = "Show Array")
			CALL introspect.show(reflect.Value.valueOf(l_arr))
		ON ACTION quit ATTRIBUTES(TEXT = "Quit")
			EXIT MENU
	END MENU
END MAIN

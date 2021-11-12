IMPORT reflect
IMPORT FGL introspect.*

TYPE t_rec RECORD
	key     INTEGER ATTRIBUTE(json_name = "key"),
	desc    STRING,
	created DATETIME YEAR TO SECOND,
	cost    DECIMAL(10, 2)
END RECORD

MAIN
	DEFINE l_rec         t_rec ATTRIBUTE(json_name = "l_rec")
	DEFINE l_arr         DYNAMIC ARRAY OF t_rec ATTRIBUTE(json_name = "l_arr")
	DEFINE x             SMALLINT
	DEFINE l_reflect_rec introspect.introspect.simpleObj
	DEFINE l_reflect_arr introspect.introspect.simpleObj

	FOR x = 1 TO 5
		LET l_arr[x].key     = x
		LET l_arr[x].desc    = "This is test " || x
		LET l_arr[x].created = CURRENT
		LET l_arr[x].cost    = x * .5
	END FOR
	LET l_rec = l_arr[1]

	MENU
		ON ACTION rRec ATTRIBUTES(TEXT = "Reflect Rec")
			CALL l_reflect_rec.init(reflect.Value.valueOf(l_rec))
			CALL l_reflect_rec.dump()
			CALL l_reflect_rec.show()

		ON ACTION rArr ATTRIBUTES(TEXT = "Reflect Arr")
			CALL l_reflect_arr.init(reflect.Value.valueOf(l_arr))
			CALL l_reflect_arr.dump()
			CALL l_reflect_arr.show()

		ON ACTION quit ATTRIBUTES(TEXT = "Quit")
			EXIT MENU
	END MENU
END MAIN

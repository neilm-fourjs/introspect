IMPORT reflect
IMPORT util
IMPORT FGL introspect.*

MAIN
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		idx  INTEGER,
		name STRING,
		x, y INTEGER
	END RECORD
	DEFINE i             INTEGER = 0
	DEFINE l_reflect_arr introspect.rObj.rObj

	-- Populate
	LET l_arr[i := i + 1].name = "The Cure"
	LET l_arr[i := i + 1].name = "The Jam"
	LET l_arr[i := i + 1].name = "Abba"
	LET l_arr[i := i + 1].name = "The Rolling Stones"
	LET l_arr[i := i + 1].name = "Porcupine Tree"
	LET l_arr[i := i + 1].name = "Muse"
	LET l_arr[i := i + 1].name = "Placebo"
	LET l_arr[i := i + 1].name = "The The"
	LET l_arr[i := i + 1].name = "Iron Maiden"
	LET l_arr[i := i + 1].name = "Pink Floyd"
	LET l_arr[i := i + 1].name = "The Police"
	LET l_arr[i := i + 1].name = "Led Zeppelin"
	LET l_arr[i := i + 1].name = "REM"
	LET l_arr[i := i + 1].name = "Them"
	FOR i = 1 TO l_arr.getLength()
		LET l_arr[i].idx = i
		LET l_arr[i].x   = util.Math.rand(10)
		LET l_arr[i].y   = util.Math.rand(10)
	END FOR

	MENU
		COMMAND "iTunes Sort ignoring 'The '"
			DISPLAY "*** iTunes Sort ignoring 'The '"
			CALL custom_sort(reflect.Value.valueOf(l_arr), FUNCTION itunes_sort, "name")
			FOR i = 1 TO l_arr.getLength()
				DISPLAY l_arr[i].idx, ":", l_arr[i].name
			END FOR
			CALL l_reflect_arr.init(reflect.Value.valueOf(l_arr))
			CALL l_reflect_arr.show()

		COMMAND "Length Sort"
			DISPLAY "\n*** Length Sort"
			CALL custom_sort(reflect.Value.valueOf(l_arr), FUNCTION length_sort, "name")
			FOR i = 1 TO l_arr.getLength()
				DISPLAY l_arr[i].idx, ":", l_arr[i].name
			END FOR
			CALL l_reflect_arr.init(reflect.Value.valueOf(l_arr))
			CALL l_reflect_arr.show()

		COMMAND "Distance Sort"
			DISPLAY "\n*** Distance Sort"
			CALL custom_sort(reflect.Value.valueOf(l_arr), FUNCTION distance_sort, "x,y")
			FOR i = 1 TO l_arr.getLength()
				DISPLAY l_arr[i].idx, ":", l_arr[i].name, " ", l_arr[i].x USING "&", ",", l_arr[i].y USING "&"
			END FOR
			CALL l_reflect_arr.init(reflect.Value.valueOf(l_arr))
			CALL l_reflect_arr.show()

		COMMAND "Quit"
			EXIT MENU
	END MENU

END MAIN

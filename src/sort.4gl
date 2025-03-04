IMPORT reflect
IMPORT util
IMPORT FGL introspect.*

MAIN
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		idx  INTEGER,
		name STRING,
		x, y INTEGER
	END RECORD
	DEFINE i       INTEGER = 0
	DEFINE l_r_arr introspect.rObj.rObj
	DEFINE l_dUI   introspect.dynUI.dUI

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
		DISPLAY SFMT("%1) idx: %2 name: %3", (i USING "#&"), (l_arr[i].idx USING "#&"), l_arr[i].name)
	END FOR
	CALL fgl_settitle("Sort Demo")
	MENU
		COMMAND "iTunes Sort ignoring 'The '"
			CALL custom_sort(reflect.Value.valueOf(l_arr), FUNCTION itunes_sort, "name")
			DISPLAY "*** iTunes Sort ignoring 'The '"
			FOR i = 1 TO l_arr.getLength()
				DISPLAY SFMT("%1) idx: %2 name: %3", (i USING "#&"), (l_arr[i].idx USING "#&"), l_arr[i].name)
			END FOR
			CALL l_r_arr.init("l_arr", reflect.Value.valueOf(l_arr))
			CALL l_dUI.show("iTunes Sort", l_r_arr, l_wait: TRUE)

		COMMAND "Length Sort"
			CALL custom_sort(reflect.Value.valueOf(l_arr), FUNCTION length_sort, "name")
			DISPLAY "\n*** Length Sort"
			FOR i = 1 TO l_arr.getLength()
				DISPLAY SFMT("%1) idx: %2 name: %3", (i USING "#&"), (l_arr[i].idx USING "#&"), l_arr[i].name)
			END FOR
			CALL l_r_arr.init("l_arr", reflect.Value.valueOf(l_arr))
			CALL l_dUI.show("Length Sort", l_r_arr, l_wait: TRUE)

		COMMAND "Distance Sort"
			CALL custom_sort(reflect.Value.valueOf(l_arr), FUNCTION distance_sort, "x,y")
			DISPLAY "\n*** Distance Sort"
			FOR i = 1 TO l_arr.getLength()
				DISPLAY SFMT("%1) idx: %2 x: %3 y: %4", (i USING "#&"), (l_arr[i].idx USING "#&"), l_arr[i].x, l_arr[i].y)
			END FOR
			CALL l_r_arr.init("l_arr", reflect.Value.valueOf(l_arr))
			CALL l_dUI.show("Distance Sort", l_r_arr, l_wait: TRUE)

		COMMAND "Quit"
			EXIT MENU
	END MENU

END MAIN
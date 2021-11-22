IMPORT reflect
IMPORT FGL introspect.*
&define TEST_TABLE_STRUCTURE idx INTEGER, dat CHAR(3)

MAIN
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		TEST_TABLE_STRUCTURE
	END RECORD
	DEFINE x SMALLINT

-- setup our test table and test data
	CONNECT TO ":memory:+driver='dbmsqt'"
	CREATE TABLE foo(TEST_TABLE_STRUCTURE)
	INSERT INTO foo VALUES(1, "AAA")
	INSERT INTO foo VALUES(2, "BBB")
	INSERT INTO foo VALUES(3, "CCC")

-- select our test data directly into our array
	CALL sql2array("SELECT * FROM foo", reflect.Value.valueOf(l_arr))

-- display the results
	FOR x = 1 TO l_arr.getLength()
		DISPLAY SFMT("%1 %2", l_arr[x].idx, l_arr[x].dat)
	END FOR

END MAIN

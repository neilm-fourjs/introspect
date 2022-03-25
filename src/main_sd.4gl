IMPORT reflect
IMPORT FGL introspect.*
IMPORT FGL sdLib
MAIN
	DEFINE l_stock sdLib.t_stock
	DEFINE l_simple_test RECORD ATTRIBUTES(json_name="simpleTest")
		fld1 STRING,
		fld2 INT,
		fld3 DATE
	END RECORD
	DEFINE l_arr DYNAMIC ARRAY OF sdLib.t_stock

	CALL introspect.simpleDump.simpleDump("l_simple_test", reflect.Value.valueOf(l_simple_test))

	CALL introspect.simpleDump.simpleDump("l_stock", reflect.Value.valueOf(l_stock))

	CALL introspect.simpleDump.simpleDump("l_arr", reflect.Value.valueOf(l_arr))
END MAIN
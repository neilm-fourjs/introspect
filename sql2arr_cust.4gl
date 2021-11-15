IMPORT reflect
IMPORT FGL introspect.*
&define DBNAME njm_demo310
SCHEMA DBNAME

MAIN
	DEFINE l_cst         DYNAMIC ARRAY OF RECORD LIKE customer.*
	DEFINE l_reflect_arr introspect.rObj.rObj
	DATABASE DBNAME
	CALL sql2array("SELECT * FROM customer", reflect.Value.valueOf(l_cst))
	CALL l_reflect_arr.init("l_cst", reflect.Value.valueOf(l_cst))
	CALL l_reflect_arr.show("Customers")
END MAIN

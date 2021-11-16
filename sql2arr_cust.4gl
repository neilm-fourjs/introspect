IMPORT reflect
IMPORT FGL introspect.*
&define DBNAME njm_demo310
SCHEMA DBNAME

MAIN
	DEFINE l_cst   DYNAMIC ARRAY OF RECORD LIKE customer.*
	DEFINE l_r_arr introspect.rObj.rObj
	DEFINE l_dUI   introspect.dynUI.dUI
	DATABASE DBNAME
	CALL sql2array("SELECT * FROM customer", reflect.Value.valueOf(l_cst))
	CALL l_r_arr.init("l_cst", reflect.Value.valueOf(l_cst))
	CALL l_dUI.show("Customers", l_r_arr)
END MAIN

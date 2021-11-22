IMPORT reflect
IMPORT FGL introspect.*
&define DBNAME njm_demo310
SCHEMA DBNAME
MAIN
	DEFINE l_cst   RECORD LIKE customer.*
	DEFINE l_arr   DYNAMIC ARRAY OF RECORD LIKE customer.*
	DEFINE x       SMALLINT = 1
	DEFINE l_r     introspect.rObj.rObj
	DEFINE l_r_arr introspect.rObj.rObj
	DEFINE l_dUI   introspect.dynUI.dUI
	DATABASE DBNAME
	CALL sql2array("SELECT * FROM customer", reflect.Value.valueOf(l_arr))
	CALL fgl_settitle("Reflection Interactive Customer Demo")
	WHILE x > 0
		CALL l_r_arr.init("l_cst", reflect.Value.valueOf(l_arr))            -- prepare array object
		CALL l_dUI.show("Customers", l_r_arr, l_wait: FALSE)                -- build ui
		LET x = l_dUI.displayArray(l_tabn: "tablistv", l_interactive: TRUE, l_row: x) -- do dispaly array ( keeping current row )
		IF x > 0 THEN                                                       -- a row was selected.
			CALL l_dUI.closeWindow()                                          -- close the array window
			LET l_cst = l_arr[x]                                              -- get the selected row
			CALL l_r.init("l_cst", reflect.Value.valueOf(l_cst))              -- prepare record object
			CALL l_dUI.show(l_titl: SFMT("Customer: %1", l_cst.customer_code), l_rObj: l_r, l_wait: FALSE) -- build ui
			VAR l_updated = l_dUI.doInput()                                                                -- do the Input
			IF l_updated THEN      -- here would also update the database.
				LET l_arr[x] = l_cst -- update the array
			END IF
			CALL l_dUI.closeWindow() -- close the record view window
			IF NOT l_updated THEN
				ERROR "Update Cancelled."
			END IF
		END IF
	END WHILE
	CALL l_dUI.closeWindow()
END MAIN

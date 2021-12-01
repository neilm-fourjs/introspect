IMPORT reflect
IMPORT FGL introspect.*
SCHEMA njm_demo310
MAIN
	DEFINE l_rec   RECORD LIKE customer.*
	DEFINE l_arr   DYNAMIC ARRAY OF RECORD LIKE customer.*
	DEFINE l_row   SMALLINT = 1
	DEFINE l_r     introspect.rObj.rObj                                    -- The record object
	DEFINE l_r_arr introspect.rObj.rObj                                    -- The array object
	DEFINE l_dUI   introspect.dynUI.dUI                                    -- The Dynamic UI object
	DATABASE "njm_demo310.db+driver='dbmsqt'"                                              -- Connect to the database
	CALL sql2array("SELECT * FROM customer", reflect.Value.valueOf(l_arr)) -- Fill array from SQL
	WHILE l_row > 0                                                        -- Loop until the display array is cancelled.
		CALL l_r_arr.init("l_arr", reflect.Value.valueOf(l_arr))             -- Initialize array object
		CALL l_dUI.show("Customers", l_r_arr, l_wait: FALSE)                 -- Build ui
		LET l_row = l_dUI.displayArray("tablistv", TRUE, l_row)              -- Do dispaly array ( keeping current row )
		IF l_row > 0 THEN                                                    -- A row was selected
			CALL l_dUI.closeWindow()                                           -- Close the array window
			LET l_rec = l_arr[l_row]                                           -- Get the selected row
			CALL l_r.init("l_rec", reflect.Value.valueOf(l_rec))               -- Initialize record object
			CALL l_dUI.show(SFMT("Customer: %1", l_rec.customer_code), l_r, l_wait: FALSE) -- Build ui
			VAR l_updated = l_dUI.doInput()                                                -- Do the Input
			IF l_updated THEN          -- Here would also update the database
				LET l_arr[l_row] = l_rec -- Update the array with changed record
			END IF
			CALL l_dUI.closeWindow() -- Close the record view window
			IF NOT l_updated THEN
				ERROR "Update Cancelled."
			END IF
		END IF
	END WHILE
	CALL l_dUI.closeWindow() -- Close list window
END MAIN

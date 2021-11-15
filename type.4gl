IMPORT reflect
IMPORT FGL introspect.*
IMPORT FGL lib_type.*
MAIN
	DEFINE l_reflect_rec introspect.rObj.rObj
	DEFINE l_myObj       lib_type.lib_type.obj
	DEFINE l_myXMLObj    lib_type.lib_type.obj

	IF NOT l_myObj.isCreated() THEN
		IF NOT l_myObj.init(NULL, NULL, NULL, FUNCTION chkString) THEN
			DISPLAY l_myObj.last_error
			IF NOT l_myObj.init("test", "string", " ", FUNCTION chkString) THEN
				DISPLAY l_myObj.last_error
				EXIT PROGRAM
			END IF
		END IF
	END IF
	DISPLAY "Obj Created."
	DISPLAY IIF(l_myObj.isEmpty(), "Obj is empty", "Obj is NOT empty")

	IF NOT l_myObj.setValue("Testing") THEN
		DISPLAY "Failed to setValue: ", l_myObj.last_error
	END IF

	IF NOT l_myObj.setValue("A Test Value") THEN
		DISPLAY "Failed to setValue: ", l_myObj.last_error
	ELSE
		DISPLAY "Value set okay."
	END IF

	IF NOT l_myXMLObj.init("myXML", "xml", NULL, NULL) THEN
		DISPLAY l_myXMLObj.last_error
	END IF

	IF NOT l_myXMLObj.setValue("<xml><MyNode>Test</MyNode></xml>") THEN
		DISPLAY l_myXMLObj.last_error
	END IF

	CALL l_reflect_rec.init(reflect.Value.valueOf(l_myObj))
	CALL l_reflect_rec.dump()
	CALL l_reflect_rec.show()

	DISPLAY "Program Finished."

END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION chkString(l_val STRING) RETURNS STRING
	DEFINE l_err STRING
	IF l_val.getLength() < 10 THEN
		LET l_err = "The Value you tried to set was too short"
	END IF
	RETURN l_err
END FUNCTION

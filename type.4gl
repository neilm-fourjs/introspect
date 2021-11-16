IMPORT reflect
IMPORT FGL introspect.*
IMPORT FGL lib_type.*

DEFINE m_myObj lib_type.lib_type.obj
MAIN
	DEFINE l_r_rec introspect.rObj.rObj
	DEFINE l_dUI   introspect.dynUI.dUI

	IF NOT m_myObj.isCreated() THEN
		IF NOT m_myObj.init(NULL, NULL, NULL, FUNCTION chkString) THEN
			DISPLAY m_myObj.last_error
			IF NOT m_myObj.init("test", "string", " ", FUNCTION chkString) THEN
				DISPLAY m_myObj.last_error
				EXIT PROGRAM
			END IF
		END IF
	END IF
	DISPLAY "Obj Created."
	CALL testIt()

	CALL l_r_rec.init("m_myObj", reflect.Value.valueOf(m_myObj))
	CALL l_r_rec.dump()
	CALL l_dUI.show("Custom Object with Methods", l_r_rec, l_wait: TRUE )

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
--------------------------------------------------------------------------------------------------------------
FUNCTION testIt()
	DISPLAY IIF(m_myObj.isEmpty(), "Obj is empty", "Obj is NOT empty")

	IF NOT m_myObj.setValue("Testing") THEN
		DISPLAY "Failed to setValue: ", m_myObj.last_error
	END IF

	IF NOT m_myObj.setValue("A Test Value") THEN
		DISPLAY "Failed to setValue: ", m_myObj.last_error
	ELSE
		DISPLAY "Value set okay."
	END IF

END FUNCTION

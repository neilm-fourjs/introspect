PACKAGE lib_type

PRIVATE TYPE t_val_func FUNCTION(l_val STRING) RETURNS STRING
PRIVATE TYPE t_str STRING
PUBLIC TYPE obj RECORD
	name       STRING,
	type       STRING,
	value      t_str,
	list       DYNAMIC ARRAY OF RECORD
		key      INT,
		value    STRING
	END RECORD,
	validate   t_val_func,
	state      SMALLINT,
	last_error STRING
END RECORD
--------------------------------------------------------------------------------------------------------------
FUNCTION (this obj) init(l_nam STRING, l_typ STRING, l_val STRING, l_val_func t_val_func) RETURNS BOOLEAN
	LET this.last_error = NULL
	IF l_nam IS NULL THEN
		CALL this.setError("init", "'name' can't be NULL")
	END IF
	IF l_typ IS NULL THEN
		CALL this.setError("init", "'type' can't be NULL")
	END IF
	IF this.last_error IS NOT NULL THEN
		RETURN FALSE
	END IF
	LET this.name = l_nam
	LET this.type = l_typ.toLowerCase()
	IF NOT this.setValue(l_val) THEN
		RETURN FALSE
	END IF
	LET this.validate = l_val_func
	LET this.state    = 1
	CALL this.list.clear()
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this obj) isCreated() RETURNS BOOLEAN
	RETURN this.state
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this obj) isEmpty() RETURNS BOOLEAN
	DEFINE l_val STRING
	IF NOT this.isCreated() THEN
		CALL this.setError("isEmpty", "Not Created!")
		RETURN TRUE
	END IF
	LET l_val = this.value.trim()
	RETURN l_val.getLength() = 0
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- dummy function
FUNCTION (this obj) testNum(l_int INT) RETURNS BOOLEAN
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this obj) setValue(l_val STRING) RETURNS BOOLEAN
	DEFINE l_doc  om.DomDocument
	DEFINE l_node om.DomNode
	DEFINE l_int  INTEGER

	IF l_val IS NULL THEN
		LET this.value = l_val
		RETURN TRUE
	END IF

	IF this.type = "xml" THEN
		TRY
			LET l_doc = om.DomDocument.createFromString(l_val)
		CATCH
		END TRY
		IF l_doc IS NULL THEN
			CALL this.setError("setValue", SFMT("Invalid XML: %1 %2", status, err_get(status)))
			RETURN FALSE
		END IF
		LET l_node = l_doc.getDocumentElement()
		IF l_node IS NULL THEN
			CALL this.setError("setValue", SFMT("Invalid XML: %1 %2", status, err_get(status)))
			RETURN FALSE
		END IF
	END IF

	IF this.type = "int" THEN
		TRY
			LET l_int = l_val
		CATCH
		END TRY
		IF l_int IS NULL THEN
			CALL this.setError("setValue", "Invalid Integer")
			RETURN FALSE
		END IF
	END IF

	IF this.validate IS NOT NULL THEN
		LET this.last_error = this.validate(l_val)
		IF this.last_error IS NOT NULL THEN
			RETURN FALSE
		END IF
	END IF

	LET this.value = l_val
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION (this obj) setError(l_func STRING, l_err STRING) RETURNS()
	IF this.last_error IS NULL THEN
		LET this.last_error = SFMT("%1) %2", l_func, l_err)
		RETURN
	END IF
	LET this.last_error = this.last_error.append(SFMT("\n%1", l_err))
END FUNCTION

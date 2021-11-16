PACKAGE introspect

IMPORT reflect

PUBLIC TYPE rObj RECORD
	reflectV  reflect.Value,
	name      STRING,
	kind      STRING,
	type      STRING,
	json_name STRING,
	flds DYNAMIC ARRAY OF RECORD
		name   STRING,
		type   STRING,
		len    INTEGER,
		num    BOOLEAN,
		func   BOOLEAN,
		values DYNAMIC ARRAY OF STRING
	END RECORD,
	methods DYNAMIC ARRAY OF RECORD
		name      STRING,
		params    DYNAMIC ARRAY OF STRING,
		returns   DYNAMIC ARRAY OF STRING,
		signature STRING
	END RECORD,
	rec_count SMALLINT,
	line      INT,
	module    STRING
END RECORD

FUNCTION (this rObj) init(l_nam STRING, l_rv reflect.Value)
	DEFINE x, z SMALLINT
	INITIALIZE this TO NULL
	LET this.reflectV  = l_rv
	LET this.name      = l_nam
	LET this.kind      = l_rv.getType().getKind()
	LET this.type      = l_rv.getType().toString()
	LET this.json_name = l_rv.getType().getAttribute("json_name")

	IF this.kind = "RECORD" THEN
		FOR x = 1 TO l_rv.getType().getFieldCount() -- Loop thru fields
			VAR l_et reflect.Type = l_rv.getType()
			LET this.flds[x].name = l_et.getFieldName(x)
			LET this.flds[x].type = l_et.getFieldType(x).toString()
			CALL getTypeLen(this.flds[x].type) RETURNING this.flds[x].len, this.flds[x].num, this.flds[x].func
			LET this.flds[x].values[1] = l_rv.getField(x).toString()
			LET this.rec_count         = 1
		END FOR
		FOR x = 1 TO l_rv.getType().getMethodCount() -- Loop thru methods
			VAR l_em reflect.Method = l_rv.getType().getMethod(x)
			LET this.methods[x].name      = l_em.getName()
			LET this.methods[x].signature = l_em.getSignature()
			FOR z = 1 TO l_em.getParameterCount() -- Loop thru Input Parameters
				LET this.methods[x].params[z] = l_em.getParameterType(z).toString()
			END FOR
			FOR z = 1 TO l_em.getReturnCount() -- Loop thru Output Parameters
				LET this.methods[x].returns[z] = l_em.getReturnType(z).toString()
			END FOR
		END FOR
	END IF
	IF this.kind = "ARRAY" THEN
		LET this.rec_count = l_rv.getLength()
		FOR z = 1 TO this.rec_count -- loop thru array items
			VAR l_rv2 reflect.Value
			LET l_rv2 = l_rv.getArrayElement(z)
			FOR x = 1 TO l_rv2.getType().getFieldCount() -- loop thru fields
				IF z = 1 THEN
					VAR l_et reflect.Type = l_rv2.getType()
					LET this.flds[x].name = l_et.getFieldName(x)
					LET this.flds[x].type = l_et.getFieldType(x).toString()
					CALL getTypeLen(this.flds[x].type) RETURNING this.flds[x].len, this.flds[x].num, this.flds[x].func
				END IF
				LET this.flds[x].values[z] = l_rv2.getField(x).toString()
			END FOR
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION (this rObj) dump()
	DEFINE x, z SMALLINT
	IF this.module IS NULL THEN
		DISPLAY SFMT("\nDump - Name: %1 Type: %2 Kind: %3 json_name: %4", this.name, this.type, this.kind, this.json_name)
	ELSE
		DISPLAY SFMT("\nDebug:%1:%2 Name: %3 Type: %4 Kind: %5 json_name: %6",
				this.module, this.line, this.name, this.type, this.kind, this.json_name)
	END IF
	IF this.kind = "RECORD" THEN
		DISPLAY "Fields:"
		FOR x = 1 TO this.flds.getLength()
			DISPLAY SFMT("%1) %2 %3 Length: %4 Value: %5",
					x, this.flds[x].name, this.flds[x].type, this.flds[x].len, this.flds[x].values[1])
		END FOR
		DISPLAY IIF(this.methods.getLength() > 0, "Methods:", "No Methods.")
		FOR x = 1 TO this.methods.getLength()
			IF this.methods[x].params.getLength() > 0 THEN
				DISPLAY SFMT("%1) %2(", x, this.methods[x].name)
				FOR z = 1 TO this.methods[x].params.getLength()
					DISPLAY SFMT("  p%1 %2", z, this.methods[x].params[z])
				END FOR
				DISPLAY "    )"
			ELSE
				DISPLAY SFMT("%1) %2()", x, this.methods[x].name)
			END IF
			IF this.methods[x].returns.getLength() > 0 THEN
				DISPLAY " RETURNS ("
				FOR z = 1 TO this.methods[x].returns.getLength()
					DISPLAY SFMT(" %1", this.methods[x].returns[z])
				END FOR
				DISPLAY "    )"
			ELSE
				DISPLAY " ) RETURNS ()"
			END IF
		END FOR
	END IF
	IF this.kind = "ARRAY" THEN
		FOR z = 1 TO this.rec_count
			FOR x = 1 TO this.flds.getLength()
				DISPLAY SFMT("Row %1: %2 = %3 ( %4 )", z, this.flds[x].name, this.flds[x].values[z], this.flds[x].type)
			END FOR
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Debug dump of data
-- used via the preprocessor - see debug_dump.inc
-- &define DEBUG_DUMP( nam, rv ) \
--	CALL debug_dump(__FILE__, __LINE__, nam, reflect.Value.valueOf(rv))
FUNCTION debug_dump(l_mod STRING, l_line INT, l_nam STRING, l_rv reflect.Value)
	DEFINE l_rObj rObj
	CALL l_rObj.init(l_nam, l_rv)
	LET l_rObj.line   = l_line
	LET l_rObj.module = l_mod
	CALL l_rObj.dump()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- find the length of the field and if it's numeric or not
-- @returns length ( smallint ), isnumeric ( boolean )
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION getTypeLen(l_typ STRING) RETURNS(SMALLINT, BOOLEAN, BOOLEAN)
	DEFINE z, y, l_len SMALLINT
	DEFINE l_numalign  BOOLEAN = TRUE
	DEFINE l_func      BOOLEAN = FALSE

	CASE l_typ
		WHEN "SMALLINT"
			LET l_len = 5
		WHEN "INTEGER"
			LET l_len = 10
		WHEN "FLOAT"
			LET l_len = 10
		WHEN "STRING"
			LET l_len = 50
		WHEN "DATE"
			LET l_len = 10
		WHEN "DATETIME YEAR TO FRACTION(5)"
			LET l_len = 26
		WHEN "DATETIME YEAR TO SECOND"
			LET l_len = 20
		WHEN "DATETIME YEAR TO MINUTE"
			LET l_len = 17
		WHEN "DATETIME YEAR TO HOUR"
			LET l_len = 14
	END CASE

	IF l_typ.subString(1, 8) = "FUNCTION" THEN
		LET l_len      = l_typ.getLength()
		LET l_func     = TRUE
		LET l_numalign = FALSE
	ELSE
		IF l_typ.subString(1, 4) = "CHAR" OR l_typ.subString(1, 7) = "VARCHAR" OR l_typ.subString(1, 6) = "STRING" THEN
			LET l_numalign = FALSE
		END IF

		LET z = l_typ.getIndexOf("(", 1)
		IF z > 0 THEN
			LET y = l_typ.getIndexOf(",", z)
			IF y = 0 THEN
				LET y = l_typ.getIndexOf(")", z)
			END IF
			LET l_len = l_typ.subString(z + 1, y - 1)
		END IF
	END IF
	--DISPLAY SFMT("Type: %1 Len: %2 Num: %3 Func: %4", l_typ, l_len, l_numalign, l_func)

	RETURN l_len, l_numalign, l_func
END FUNCTION

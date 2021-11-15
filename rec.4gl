IMPORT reflect
MAIN
	DEFINE l_rec RECORD
		num     INTEGER,
		str     STRING,
		created DATE,
		cost    DECIMAL(10, 2)
	END RECORD = ( num: 1, str: "This is a test.", created: MDY(11,15,2021), cost: 9.99)
	DEFINE x SMALLINT
	VAR l_rv reflect.Value = reflect.Value.valueOf(l_rec)
	VAR l_rt reflect.Type = l_rv.getType()
	FOR x = 1 TO l_rt.getFieldCount()
		DISPLAY SFMT("%1 = %2 ( %3 )", 
			l_rt.getFieldName(x), 
			l_rv.getField(x).toString(), 
			l_rt.getFieldType(x).toString())
	END FOR
END MAIN

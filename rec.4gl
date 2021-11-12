IMPORT reflect
TYPE t_rec RECORD
	key     INTEGER ATTRIBUTE(json_name = "key"),
	desc    STRING,
	created DATETIME YEAR TO SECOND,
	cost    DECIMAL(10, 2)
END RECORD
MAIN
	DEFINE l_rec t_rec ATTRIBUTE(json_name = "l_rec")
	DEFINE x     SMALLINT
	LET l_rec.key     = 1
	LET l_rec.desc    = "This is test."
	LET l_rec.created = CURRENT
	LET l_rec.cost    = 9.99
	VAR l_rv reflect.Value = reflect.Value.valueOf(l_rec)
	FOR x = 1 TO l_rv.getType().getFieldCount()
		VAR l_et reflect.Type = l_rv.getType()
		DISPLAY l_et.getFieldName(x), " ", l_et.getFieldType(x).toString()
	END FOR
END MAIN

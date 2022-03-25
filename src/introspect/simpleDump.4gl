
-- this will dump a record structure to a file. It works recursively and will handle nested records / arrays
-- it will also breakdown and show records / arrays made with TYPEs from another module, ie:
--  DEFINE l_rec stock.stock_master  -- where stock is a module and stock_master is a PUBLIC TYPE
PACKAGE introspect

IMPORT reflect

PRIVATE DEFINE m_file base.Channel

-- @param l_nam the name of the record / array used as the file name to save to ( with .def as extension )
-- @param l_rv the reflect Value 
PUBLIC FUNCTION simpleDump(l_nam STRING, l_rv reflect.Value) RETURNS()
	DEFINE l_typ STRING
	DEFINE l_rec BOOLEAN
	LET m_file = base.Channel.create()
	CALL m_file.openFile( SFMT("%1.def", l_nam), "w")
	DISPLAY "-------------------------------------------------------------------------------------------"
	CALL getType( l_rv.getType() ) RETURNING l_typ, l_rec
	CALL writeIt( SFMT("%1 %2", l_nam, l_typ ))
--	CALL writeIt( SFMT("%1 %2 ( %3 )", l_nam, l_rv.getType().toString(), l_rv.getType().getKind()) )
	IF l_rec THEN
		CALL simpleDumpType( l_rv.getType(), 1)
	END IF
	DISPLAY "-------------------------------------------------------------------------------------------"
	CALL m_file.close()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION simpleDumpType(l_rt reflect.Type, l_lev SMALLINT) RETURNS()
	DEFINE x, y SMALLINT
	DEFINE l_line STRING
	DEFINE l_typ STRING
	DEFINE l_rec BOOLEAN
	IF l_rt.getKind() = "ARRAY" THEN
		LET l_rt = l_rt.getElementType()
	END IF
	FOR x = 1 TO l_rt.getFieldCount()
		CALL getType( l_rt.getFieldType(x) ) RETURNING l_typ, l_rec
		LET l_line = l_lev SPACES, SFMT(" %1 %2", l_rt.getFieldName(x), l_typ )
		CALL writeIt( l_line )
		IF l_rec THEN
			CALL simpleDumpType( l_rt.getFieldType(x), l_lev + 2 )
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION getType( l_rt reflect.Type ) RETURNS (STRING, BOOLEAN)
	DEFINE l_rec BOOLEAN = FALSE
	DEFINE l_str STRING
	DEFINE x SMALLINT
	VAR l_kind = l_rt.getKind()
	VAR l_typ = l_rt.toString()
	IF l_kind = "ARRAY" THEN LET l_kind = l_rt.getElementType().getKind() END IF
	LET x = l_typ.getIndexOf(".",1) -- detect if the type is a module.type
	IF x > 1 THEN
		LET l_typ = l_typ.append( SFMT(" ( %1 )", l_kind) )
	END IF
	LET l_str = l_rt.getAttribute("json_name")
	IF l_str.getLength() > 1 THEN LET l_typ = l_typ.append( SFMT(" ATTRIBUTES(json_name = \"%1\")", l_str )) END IF
	IF l_kind = "RECORD" THEN LET l_rec = TRUE END IF
	RETURN l_typ, l_rec
END FUNCTION
--------------------------------------------------------------------------------------------------------------
PRIVATE FUNCTION writeIt( l_line STRING ) RETURNS()
	CALL m_file.writeLine(l_line)
	DISPLAY l_line
END FUNCTION

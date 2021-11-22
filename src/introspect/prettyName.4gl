PACKAGE introspect
-- try and make a column name look pretty for a form label or table column title.
FUNCTION prettyName(l_nam STRING) RETURNS STRING
	DEFINE l_newNam STRING
	DEFINE x        SMALLINT
	IF l_nam IS NULL THEN
		RETURN NULL
	END IF
	IF l_nam.getLength() = 1 THEN
		RETURN l_nam.toUpperCase()
	END IF
	LET l_newNam = SFMT("%1%2", l_nam.getCharAt(1).toUpperCase(), l_nam.subString(2, l_nam.getLength()))
	FOR x = 1 TO l_newNam.getLength()
		IF l_newNam.getCharAt(x) = "_" THEN
			LET l_newNam =
					SFMT("%1 %2%3",
							l_newNam.subString(1, x - 1), l_nam.getCharAt(x + 1).toUpperCase(),
							l_nam.subString(x + 2, l_nam.getLength()))
		END IF
	END FOR
	RETURN l_newNam
END FUNCTION

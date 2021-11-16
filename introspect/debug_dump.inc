&define DEBUG_DUMP( nam, rv ) \
	CALL debug_dump(__FILE__, __LINE__, nam, reflect.Value.valueOf(rv))
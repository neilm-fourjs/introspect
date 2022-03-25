
PUBLIC TYPE t_stkctrl RECORD ATTRIBUTES(json_name="stockControl")
	warehouse_id INTEGER ATTRIBUTES(json_name="w_id"),
	in_stock INTEGER ATTRIBUTES(json_name="stock"),
	free INTEGER,
	ordered INTEGER,
	back_ordered INTEGER
	END RECORD

PUBLIC TYPE t_stkfin RECORD ATTRIBUTES(json_name="stockFinancial")
	price DECIMAL(10,2),
	cost DECIMAL(12,3),
	disc_code CHAR(2) ATTRIBUTES(json_name="DiscountCode"),
	tax_code CHAR(2) ATTRIBUTES(json_name="taxCode")
	END RECORD

PUBLIC TYPE t_stock RECORD ATTRIBUTES(json_name="stock")
	id INTEGER,
	desc STRING,
	financial t_stkfin,
	stkctrl DYNAMIC ARRAY OF t_stkctrl
	END RECORD
	
FUNCTION (this t_stock) get(l_id INTEGER)

END FUNCTION
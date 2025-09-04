accessing
enabledStateNumbers

	" 0 - 9 : item number
	       -1: id selected
	       -2: in database
	       -4: in trush (GdsFeel)"

	^ self itemNumberRange asArray , { 
		  self inIdStausNumber.
		  self inDatabaseStausNumber.
		  self inTrushStausNumber }
initialization
typeForCode: aByte

	^ TypeCodeMap at: aByte ifAbsent: [ #UNKOWN ]
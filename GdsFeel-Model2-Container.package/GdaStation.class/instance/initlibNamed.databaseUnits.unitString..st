instance creation
initlibNamed: name databaseUnits: dbu unitString: unit

	| lib |
	lib := GdaLibrary
		       initializeName: name
		       databaseUnits: dbu
		       unitString: unit.
	"lib ifNotNil: [ self changed: #openlibEnabled ]."
	^ lib
initialization
initialize

	| time |
	super initialize.
	time := DateAndTime now.
	timeCreated := time copy.
	timeModified := time copy.
	"colElements := OrderedCollection new."
	elements := nil.
	maxKeyNumber := nil
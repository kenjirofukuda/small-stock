initialization
coerceStructureName: aString

	| partial |
	partial := aString copyReplaceAll: ' ' with: '_'.
	"FIXME"
	^ partial
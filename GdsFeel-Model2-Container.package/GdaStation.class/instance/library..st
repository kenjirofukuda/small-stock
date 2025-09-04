accessing
library: aGdsLibrary

	aGdsLibrary ifNotNil: [ aGdsLibrary station: self ].
	library := aGdsLibrary
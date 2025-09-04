instance creation
sampleAtomicInstance
	| reader inform |
	inform := self new.	
	reader := GdsStreamFormatReader 
		fromStreamFormatPath: (GDSreader_0_3_2 ensureCreateTestGdsFile fullPrintString).
	reader ifNil: [ ^ inform ].
	inform reader: reader.
	inform beAtomic.
	^ inform	
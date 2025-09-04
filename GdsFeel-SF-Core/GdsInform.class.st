"
A GdsInform is INFORM command handler.

Instance Variables
	library:		<GdsLibrary>
	reader:		<GdsStreamFormatReader>
	stderr:		<GdsLog>
	stdout:		<GdsLog>

library
	- xxxxx

reader
	- xxxxx

stderr
	- xxxxx

stdout
	- xxxxx

"
Class {
	#name : #GdsInform,
	#superclass : #Object,
	#instVars : [
		'reader',
		'stderr',
		'stdout',
		'library',
		'libraryClass',
		'structureClass',
		'elementClass'
	],
	#category : #'GdsFeel-SF-Core'
}

{ #category : #'instance creation' }
GdsInform class >> sampleAtomicInstance [
	| reader inform |
	inform := self new.	
	reader := GdsStreamFormatReader 
		fromStreamFormatPath: (GDSreader_0_3_2 ensureCreateTestGdsFile fullPrintString).
	reader ifNil: [ ^ inform ].
	inform reader: reader.
	inform beAtomic.
	^ inform	
]

{ #category : #'instance creation' }
GdsInform class >> sampleInstance [
	^ self sampleAtomicInstance 
]

{ #category : #'instance creation' }
GdsInform class >> sampleReleaseInstance [

	^ self sampleInstance
		  beRelease;
		  yourself
]

{ #category : #private }
GdsInform >> abort: aString [

	self stderr: aString.
	self error: aString
]

{ #category : #configuration }
GdsInform >> beAtomic [
	self libraryClass: GdaLibrary.
	self structureClass: GdaStructure.
	self elementClass: GdaElement.
]

{ #category : #configuration }
GdsInform >> beRelease [
	self libraryClass: GdsLibrary.
	self structureClass: GdsStructure.
	self elementClass: GdsElement.
]

{ #category : #private }
GdsInform >> cantHandledTypes [

	^ #( LIBDIRSIZE SRFNAME LIBSECUR REFLIBS FONTS )
]

{ #category : #accessing }
GdsInform >> elementClass: aClass [ 
	elementClass := aClass
]

{ #category : #accessing }
GdsInform >> elementClassForType: aSymbol [
	^ elementClass classForType: aSymbol
]

{ #category : #initialization }
GdsInform >> initialize [

	super initialize.
	stderr := GdsLog new category: 'stderr'.
	stderr beginLog.
	stdout := GdsLog new category: 'stdout'.
	stdout beginLog
]

{ #category : #accessing }
GdsInform >> installedElementType: aSymbol [

	^ elementClass installedElementType: aSymbol
]

{ #category : #accessing }
GdsInform >> library [

	^ library
]

{ #category : #accessing }
GdsInform >> libraryClass [
	^ libraryClass
]

{ #category : #accessing }
GdsInform >> libraryClass: aClass [ 
	libraryClass := aClass
]

{ #category : #private }
GdsInform >> missingField: aSymbol ofElement: aGdsElement [

	| elementTypeString |
	elementTypeString := aGdsElement.
	(elementTypeString isKindOf: elementClass) 
		ifTrue: [ 
			elementTypeString := elementTypeString typeString ].
	^ 'Missing {1} Field in {1} element. Abort!' format: { 
			  aSymbol asString.
			  elementTypeString }
]

{ #category : #'element reader' }
GdsInform >> readAREF: aGdsStructure [

	| loopContext element record clazz |
	clazz := self elementClassForType: #aref.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #aref ]. 
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupAREFkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchAREF: record ].
	^ loopContext result
]

{ #category : #'element reader' }
GdsInform >> readBOUNDARY: aGdsStructure [

	| element loopContext record clazz |
	clazz := self elementClassForType: #boundary.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #boundary ]. 
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupBOUNDARYkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchBOUNDARY: record ].
	^ loopContext result
]

{ #category : #'element reader' }
GdsInform >> readBOX: aGdsStructure [

	"FIXME: "

	^ { false. nil }
]

{ #category : #'as yet unclassified' }
GdsInform >> readHeader [

	| header |
	header := reader nextRecord.
	header ifNil: [ self abort: 'HEADER is missing. Aborting' ]
]

{ #category : #service }
GdsInform >> readLib [

	| structure |
	reader reset.
	self readHeader.
	self readUpToFirstStruct.
	[ 
	structure := self readStruct.
	structure isNil ] whileFalse: [ library addStructure: structure ]
]

{ #category : #'element reader' }
GdsInform >> readNODE: aGdsStructure [

	"FIXME: "

	^ { false. nil }
]

{ #category : #'element reader' }
GdsInform >> readPATH: aGdsStructure [

	| element record loopContext clazz |
	clazz := self elementClassForType: #path.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #path ]. 	
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupPATHkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchPATH: record ].
	^ loopContext result
]

{ #category : #'as yet unclassified' }
GdsInform >> readPrimitiveBegin: element [

	| record |
	record := reader nextRecord.
	#LAYER = record type ifFalse: [ 
		^ self abort: (self missingField: record type ofElement: element) ].
	element layerNumber: record int2.
	record := reader nextRecord.
	#DATATYPE = record type ifFalse: [ 
		^ self abort: (self missingField: record type ofElement: element) ].
	element datatype: record int2
]

{ #category : #'as yet unclassified' }
GdsInform >> readPrimitiveEnd: element [

	| record points |
	record := reader nextRecord.
	#XY = record type ifFalse: [ 
		^ self abort: (self missingField: record type ofElement: element) ].
	points := record pointsDividedByDatabaseUnit: library databaseUnit.
	element vertices: points.
	record := reader nextRecord.
	#ENDEL = record type ifFalse: [ 
		^ self abort: (self missingField: record type ofElement: element) ]
]

{ #category : #'element reader' }
GdsInform >> readSREF: aGdsStructure [

	| loopContext element record clazz |
	clazz := self elementClassForType: #sref.
	clazz ifNil: [ ^ { false. nil } ].
	element := clazz basicNew initialize.
	clazz == elementClass
		ifTrue: [ element type: #sref ]. 	
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupSREFkeys.
	loopContext result: { false. nil }.
	[ 
	loopContext break ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ 
		loopContext switchSREF: record ].
	^ loopContext result
]

{ #category : #'as yet unclassified' }
GdsInform >> readStruct [

	| break record structure result |
	record := reader nextRecord.
	#BGNSTR = record type ifFalse: [ 
		reader unreadRecord: record.
		record := reader nextRecord.
		#ENDLIB = record type
			ifTrue: [ ^ nil ]
			ifFalse: [ self abort: 'Missing ENDLIB field. Abort!' ] ].
	structure := self structureClass basicNew initialize
		             library: library;
		             yourself.
	break := false.
	[ 
	break ifFalse: [ record := reader nextRecord ].
	break or: [ record isNil ] ] whileFalse: [ 
		result := self readStruct: record structure: structure.
		break := result first.
		break ifTrue: [ ^ result last ] ].
	^ nil
]

{ #category : #accessing }
GdsInform >> readStruct: aRecord structure: aGdsStructure [

	| result result2 |
	result := { false. nil }.
	#STRNAME = aRecord type ifTrue: [ 
		| name |
		name := aRecord asString.
		aGdsStructure name: name.
		self stdout: ('strname = {1}' format: { name }).
		^ result ].
	aRecord isElementHeader ifTrue: [ 
		| sel newElement |
		(self installedElementType: aRecord type) ifTrue: [ 
			sel := ('read{1}:' format: { aRecord type asString }) asSymbol.
			result2 := self perform: sel with: aGdsStructure.
			newElement := result2 last.
			newElement ifNotNil: [ :arg | aGdsStructure addElement: newElement ].
			^ { 
				  false.
				  aGdsStructure } ] ].
	#ENDSTR = aRecord type ifTrue: [ 
		^ { 
			  true.
			  aGdsStructure } ].
	(#BGNSTR = aRecord type or: [ #ENDLIB = aRecord type ]) ifTrue: [ 
		self stderr: 'Incorrect record type in #readStruct'.
		^ { true. nil } ].
	^ result
]

{ #category : #'element reader' }
GdsInform >> readTEXT: aGdsStructure [

	"FIXME: "

	^ { false. nil }
]

{ #category : #'as yet unclassified' }
GdsInform >> readUpToFirstStruct [

	| break record |
	break := false.
	record := nil.
	[ 
	break ifFalse: [ record := reader nextRecord ].
	break or: [ record isNil ] ] whileFalse: [ 
		break := self readUpToFirstStructRecord: record ]
]

{ #category : #'as yet unclassified' }
GdsInform >> readUpToFirstStructRecord: aRecord [

	| items libname |
	#BGNLIB = aRecord type ifTrue: [ 
		library := self libraryClass new.
		items := aRecord dateAndTimes.
		library lastModified: items first.
		library lastAccessed: items second.
		^ false ].
	#LIBNAME = aRecord type ifTrue: [ 
		libname := aRecord asString.
		libname isEmptyOrNil ifTrue: [ 
			self abort: 'Bad LIBNAME record. Aborting' ].
		library libName: libname.
		^ false ].
	#UNITS = aRecord type ifTrue: [ 
		items := aRecord real8Array.
		library userUnit: items first.
		library meterUnit: items second.
		^ false ].
	#BGNSTR = aRecord type ifTrue: [ 
		reader unreadRecord: aRecord.
		^ true ].
	(self cantHandledTypes includes: aRecord type) ifTrue: [ 
		self stderr:
			('Not yet handling {1}' format: { aRecord type asString }) ].
	^ false
]

{ #category : #accessing }
GdsInform >> reader: aGdsStreamFormatReader [

	reader := aGdsStreamFormatReader
]

{ #category : #service }
GdsInform >> run [
	self readLib.
]

{ #category : #private }
GdsInform >> stderr: aString [

	stderr println: aString
]

{ #category : #private }
GdsInform >> stdout: aString [

	stdout println: aString
]

{ #category : #accessing }
GdsInform >> structureClass [
	
	^ structureClass 
]

{ #category : #accessing }
GdsInform >> structureClass: aClass [ 
	structureClass := aClass
]

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
		'library'
	],
	#category : #'GdsFeel-Developer-IO'
}

{ #category : #'as yet unclassified' }
GdsInform class >> downloadSample [
	"self downloadSample"
	| fileName archiver zipFile |
	fileName := self urlForZipedGDSreaderArchive asZnUrl segments last.
	zipFile := GdsFeel projectDirectory / fileName.
	zipFile isFile
		ifFalse:  [
			self downloadUrl: self urlForZipedGDSreaderArchive  toFileNamed: zipFile fullName].

	zipFile isFile
		ifFalse:  [
			^self inform: 'Download Fail'].
		
	(ZipArchive isZipArchive: zipFile fullName)
		ifFalse: [^self inform: ('Not a Zip File {1}' format: {zipFile fullName})].
		
	archiver := ZipArchive new.
	archiver readFrom: zipFile fullName.
	archiver extractAllTo: GdsFeel projectDirectory .
	archiver close.		

]

{ #category : #'as yet unclassified' }
GdsInform class >> downloadUrl: aUrl toFileNamed: aFullPath [
	| data |
	data := nil.
	data := aUrl asUrl retrieveContents.
	data ifNil: [^self].
	StandardFileStream 
		forceNewFileNamed: aFullPath 
		do: [:newStream |
			newStream binary.
			newStream nextPutAll: data].

]

{ #category : #'as yet unclassified' }
GdsInform class >> makeGDSreaderSample [
	"self makeGDSreaderSample"
	| inst reader sampleFile |
	sampleFile := self sampleStreamFormatFile.
	sampleFile isFile
		ifFalse: [ self downloadSample ].
	sampleFile isFile 
		ifFalse: [ ^ self inform: 'Sample file not found' ].
	self makeGDSreaderSampleFromPath: sampleFile fullName.
]

{ #category : #'as yet unclassified' }
GdsInform class >> makeGDSreaderSampleFromPath: aPath [
	| reader inst |
	reader := GdsStreamFormatReader instanceOfPath: aPath.
	reader ifNil: [ ^ self ].
	inst := GdsInform new reader: reader.
	Cursor wait showWhile: [ inst run ]
]

{ #category : #'as yet unclassified' }
GdsInform class >> reMakeGDSreaderSample [
	<script>
	"self reMakeGDSreaderSample"
	| file |
	file := './GdsFeel/BGHIER.DB' asFileReference.
	file ensureDelete.
	self makeGDSreaderSample.
	
]

{ #category : #'as yet unclassified' }
GdsInform class >> sampleStreamFormatFile [
	^ GdsFeel projectDirectory /  'GDSreader.0.3.2' / 'test.gds'

]

{ #category : #'as yet unclassified' }
GdsInform class >> urlForZipedGDSreaderArchive [
	^'http://gdsfeel.com/downloads/GDSreader.0.3.2.zip'.
]

{ #category : #private }
GdsInform >> abort: aString [
	self stderr: aString.
	self error: aString
	
]

{ #category : #private }
GdsInform >> cantHandledTypes [
	^ #(LIBDIRSIZE SRFNAME LIBSECUR REFLIBS FONTS)
]

{ #category : #initialization }
GdsInform >> initialize [
	super initialize.
	stderr := GdsLog new category: 'stderr'.
	stderr beginLog.
	stdout := GdsLog new category: 'stdout'.	
	stdout beginLog.

]

{ #category : #accessing }
GdsInform >> library [
	^ library
]

{ #category : #private }
GdsInform >> missingField: aSymbol ofElement: aGdsElement [
	| elementTypeString |
	elementTypeString := aGdsElement.
	(elementTypeString isKindOf: GdsElement)
		ifTrue: [elementTypeString := elementTypeString typeString].
	^'Missing {1} Field in {1} element. Abort!' format: {aSymbol asString . elementTypeString}

											
]

{ #category : #'element reader' }
GdsInform >> readAREF: aGdsStructure [
	| loopContext element record clazz |
	clazz := GdsElement classForType: #aref.
	clazz ifNil: [ ^ {false . nil} ].
	element := clazz basicNew initialize.
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupAREFkeys.
	loopContext result: {false . nil}.
	[ loopContext break
		ifFalse: [ record := reader nextRecord ].
	loopContext break or: [ record isNil ] ] whileFalse: [ loopContext switchAREF: record ].
	^ loopContext result
]

{ #category : #'element reader' }
GdsInform >> readBOUNDARY:  aGdsStructure [
	| element loopContext record clazz |
	clazz := GdsElement classForType: #boundary.
	clazz ifNil: [^{false . nil }].
	element := clazz basicNew initialize.
	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupBOUNDARYkeys.
	loopContext result: {false . nil }.

	[loopContext break ifFalse: [record := reader nextRecord].
	loopContext break or: [record isNil]]
		whileFalse: [
			loopContext switchBOUNDARY: record].
	^loopContext result.
]

{ #category : #'element reader' }
GdsInform >> readBOX: aGdsStructure [
	"FIXME: "
	^{false . nil}																	
]

{ #category : #'as yet unclassified' }
GdsInform >> readHeader [
	| header |
	header := reader nextRecord.
	header 
		ifNil: [
			self abort: 'HEADER is missing. Aborting'].

]

{ #category : #service }
GdsInform >> readLib [
	| structure |
	reader reset.
	self readHeader.
	self readUpToFirstStruct.
	[structure := self readStruct.
	structure isNil]
		whileFalse: [
			library addStructure: structure.]
	
]

{ #category : #'element reader' }
GdsInform >> readNODE: aGdsStructure [
	"FIXME: "
	^{false . nil}																	
]

{ #category : #'element reader' }
GdsInform >> readPATH:  aGdsStructure [
	| element record loopContext clazz |
	clazz := GdsElement classForType: #path.
	clazz ifNil: [^{false . nil }].
	element := clazz basicNew initialize.

	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupPATHkeys.
	loopContext result: {false . nil }.

	[loopContext break ifFalse: [record := reader nextRecord].
	loopContext break or: [record isNil]]
		whileFalse: [
			loopContext switchPATH: record].
	^loopContext result.
]

{ #category : #'as yet unclassified' }
GdsInform >> readPrimitiveBegin: element [
	|  record |

	record := reader nextRecord.
	#LAYER = record type
		ifFalse: [^self abort: (self missingField:  record type ofElement: element)].
	element layerNumber: record int2.

	record := reader nextRecord.
	#DATATYPE = record type
		ifFalse: [^self abort: (self missingField:  record type ofElement: element)].
	element datatype: record int2.

]

{ #category : #'as yet unclassified' }
GdsInform >> readPrimitiveEnd: element [
	|  record  points |
	record := reader nextRecord.
	#XY = record type
		ifFalse: [^self abort: (self missingField:  record type ofElement: element)].
	points := record pointsDividedByDatabaseUnit: library databaseUnit  .
	element vertices: points.
	
	record := reader nextRecord.
	#ENDEL = record type
		ifFalse: [^self abort: (self missingField:  record type ofElement: element)].

]

{ #category : #'element reader' }
GdsInform >> readSREF: aGdsStructure [
	| loopContext  element record  clazz |
	clazz := GdsElement classForType: #sref.
	clazz ifNil: [^{false . nil }].
	element := clazz basicNew initialize.

	loopContext := GdsStreamLoopContext new.
	loopContext setInform: self.
	loopContext structure: aGdsStructure.
	loopContext element: element.
	loopContext setupSREFkeys.
	loopContext result: {false . nil }.

	[loopContext break ifFalse: [record := reader nextRecord].
	loopContext break or: [record isNil]]
		whileFalse: [
			loopContext switchSREF: record].
	^loopContext result.
]

{ #category : #'as yet unclassified' }
GdsInform >> readStruct [
	| break record structure result |	
	record := reader nextRecord.
	#BGNSTR = record type
		ifFalse: [
			reader unreadRecord: record.
			record := reader nextRecord.
			#ENDLIB = record type
				ifTrue: [^nil]
				ifFalse:[
					self abort: 'Missing ENDLIB field. Abort!']].
	structure := (GdsStructure basicNew initialize) 
		library: library;
		yourself.
	
	break := false.
	[break ifFalse: [record := reader nextRecord].
	break or: [record isNil]]
		whileFalse: [
			result := self readStruct: record structure: structure.
			break := result first.
			break ifTrue: [^result last]].
	^nil.
	
]

{ #category : #'as yet unclassified' }
GdsInform >> readStruct: aRecord structure: aGdsStructure [
	| result result2 |
	result := {false . nil}.
	#STRNAME = aRecord type
		ifTrue: [ | name|
			name := aRecord asString.
			aGdsStructure name: name.
			self stdout: ('strname = {1}' format: {name}).
			^result].

	aRecord  isElementHeader 
		ifTrue: [ | sel newElement |
			(GdsElement installedElementType: aRecord type)
				ifTrue: [
					sel := ('read{1}:' format: {aRecord type asString}) asSymbol.
					result2 := self perform: sel with: aGdsStructure.
					newElement := result2 last.
					newElement ifNotNil: [aGdsStructure addElement: newElement].
					^{false .  aGdsStructure}]].

	#ENDSTR = aRecord type
		ifTrue: [^{true . aGdsStructure}].
	((#BGNSTR = aRecord type) or: [#ENDLIB = aRecord type])
		ifTrue: [
			self stderr: 'Incorrect record type in #readStruct'.
			^{true . nil}].
	^result													
]

{ #category : #'element reader' }
GdsInform >> readTEXT: aGdsStructure [
	"FIXME: "
	^{false . nil}																	
]

{ #category : #'as yet unclassified' }
GdsInform >> readUpToFirstStruct [
	| break record |
	break := false.
	record := nil.
	[break 
		ifFalse: [
		record := reader nextRecord].
	break  or: [record isNil]]
		whileFalse: [
			break := self readUpToFirstStructRecord: record]

]

{ #category : #'as yet unclassified' }
GdsInform >> readUpToFirstStructRecord: aRecord [
	| items libname |
	#BGNLIB = aRecord type
		ifTrue: [ 
			library := GdsLibrary new.
			items := aRecord dateAndTimes.
			library lastModified: items first.
			library lastAccessed: items second.
			^ false ].
	#LIBNAME = aRecord type
		ifTrue: [ 
			libname := aRecord asString.
			libname isEmptyOrNil
				ifTrue: [ self abort: 'Bad LIBNAME record. Aborting' ].
			library libName: libname.
			^ false ].
	#UNITS = aRecord type
		ifTrue: [ 
			items := aRecord real8Array.
			library userUnit: items first.
			library meterUnit: items second.
			^ false ].
	#BGNSTR = aRecord type
		ifTrue: [ reader unreadRecord: aRecord.
			^ true ].
	(self cantHandledTypes includes: aRecord type)
		ifTrue: [ self stderr: ('Not yet handling {1}' format: {aRecord type asString}) ].
	^ false
]

{ #category : #accessing }
GdsInform >> reader: aGdsStreamFormatReader [
	reader := aGdsStreamFormatReader.
	
]

{ #category : #service }
GdsInform >> run [
	self readLib.
	self saveLibrary.
	
]

{ #category : #service }
GdsInform >> saveLibrary [
	library ifNil: [^self].
	(GdsLibrary exists: library libName)
		ifTrue: [^self inform: 'Already exist.'].
	self saveLibraryWithArchive: true.
]

{ #category : #service }
GdsInform >> saveLibraryWithArchive: aBoolean [
	library unitString: 'MICRON'. "TODO: fix"	
	library makeFolder.
	library structures do: [:each | each save: true].
	library autoAllocateLayerColors.
	"library layers explore."
	aBoolean ifTrue: [library close].
]

{ #category : #private }
GdsInform >> stderr: aString [
	stderr println: aString.
	
]

{ #category : #private }
GdsInform >> stdout: aString [
	stdout println: aString.
	
]

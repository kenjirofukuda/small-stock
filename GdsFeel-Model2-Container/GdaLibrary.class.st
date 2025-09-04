Class {
	#name : #GdaLibrary,
	#superclass : #GdaModel,
	#instVars : [
		'station',
		'unitString',
		'libname',
		'databaseUnit',
		'meterUnit',
		'lastModified',
		'lastAccessed',
		'layers',
		'nameToStructureMap',
		'uuid',
		'fileEntry'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #check }
GdaLibrary class >> checkDatabaseUnit: aNumber [

	aNumber < 10 ifTrue: [ ^ self error: 'DBU LEAST 10' ]
]

{ #category : #check }
GdaLibrary class >> checkLibName: aString [

	| libnameSizeRange checkName |
	checkName := "self baseName: " aString.
	self libNameMax > 0 ifTrue: [ 
		libnameSizeRange := 1 to: self libNameMax.
		(libnameSizeRange includes: checkName size) ifFalse: [ 
			^ self error:
				  ('LIBRARYNAME SIZE UNDER {1} ' format: { libnameSizeRange max }) ] ].
	(self isValidLibraryName: checkName) ifFalse: [ "(self exists: checkName)
		ifTrue: [
			^self error: ('LIBNAME ALREADY EXISTS: {1}' format: {checkName})]." 
		self error: 'LIBRARY NAME ERROR' ]
]

{ #category : #check }
GdaLibrary class >> checkUnitString: aString [

	(self unitStrings includes: aString asUppercase) ifFalse: [ 
		^ self error: ('UNITS ONLY {1}' format: { self unitsString }) ]
]

{ #category : #'instance creation' }
GdaLibrary class >> initializeName: aString [

	^ self
		  initializeName: aString
		  databaseUnits: 1000
		  unitString: 'MICRON'
]

{ #category : #'instance creation' }
GdaLibrary class >> initializeName: aString databaseUnits: anInteger unitString: aUnitString [

	self checkLibName: aString.
	self checkDatabaseUnit: anInteger.
	self checkUnitString: aUnitString.
	^ self new
		  name: aString
		  databaseUnit: anInteger
		  unitString: aUnitString
]

{ #category : #examples }
GdaLibrary class >> instanceCheck [

	<script>
	self allInstances inspect
]

{ #category : #compatibility }
GdaLibrary class >> isValidLibraryName: aString [

	^ (self isValidStorageName: aString) and: [ 
		  aString matchesRegex: '[A-Za-z][A-Za-z0-9$_]+' ]
]

{ #category : #compatibility }
GdaLibrary class >> isValidStorageName: aString [

	(aString includes: Character space) ifTrue: [ ^ false ].
	"[ self checker checkName: aString fixErrors: false ]
		on: Error
		do: [ :ex | ^ false ]."
	self multilingalNameAllowed ifFalse: [ 
		^ (aString isKindOf: WideString) not ].
	^ true
]

{ #category : #compatibility }
GdaLibrary class >> libNameMax [

	^ 10
]

{ #category : #compatibility }
GdaLibrary class >> multilingalNameAllowed [

	^ false
]

{ #category : #accessing }
GdaLibrary class >> unitSpec [

	^ { 
		  #( 'M' 1.0 ).
		  #( 'CM' 1.0e-2 ).
		  #( 'MM' 1.0e-3 ).
		  #( 'MICRON' 1.0e-6 ).
		  #( 'INCH' 2.54e-2 ).
		  #( 'MIL' 2.54e-3 ) }
]

{ #category : #accessing }
GdaLibrary class >> unitStrings [

	^ self unitSpec collect: [ :each | each first ]
]

{ #category : #accessing }
GdaLibrary class >> unitsString [

	^ self unitStrings joinUsing: $, asString
]

{ #category : #'structure control' }
GdaLibrary >> addStructure: aGdsStructure [

	nameToStructureMap ifNil: [ nameToStructureMap := Dictionary new ].
	nameToStructureMap at: aGdsStructure name put: aGdsStructure.
	self clearStructuresCache
]

{ #category : #initialization }
GdaLibrary >> allDispose [

	self class allInstVarNames do: [ :each | 
		self instVarNamed: each put: nil ]
]

{ #category : #accessing }
GdaLibrary >> children [

	^ self structures
]

{ #category : #private }
GdaLibrary >> clearStructuresCache [

	self structures do: [ :each | each clearCache ]
]

{ #category : #'accessing - basic' }
GdaLibrary >> databaseUnit [

	^ databaseUnit
]

{ #category : #'accessing - basic' }
GdaLibrary >> databaseUnit: aInteger [

	databaseUnit := aInteger
]

{ #category : #defaults }
GdaLibrary >> defaultDatabaseUnit [

	^ 1000
]

{ #category : #defaults }
GdaLibrary >> defaultUnitString [

	^ 'MICRON'
]

{ #category : #testing }
GdaLibrary >> dirty [

	^ self structures anySatisfy: [ :each | each dirty ]
]

{ #category : #'structure control' }
GdaLibrary >> elementClass [

	^ GdaStructure
]

{ #category : #'structure control' }
GdaLibrary >> ensureCreateStrucureNamed: aStructureName [

	^ (self structureNamed: aStructureName)
		  ifNotNil: [ :foundStructure | foundStructure ]
		  ifNil: [ 
			  | newStructure |
			  newStructure := self elementClass
				                  fromLibrary: self
				                  structureNamed: aStructureName.
			  self addStructure: newStructure.
			  newStructure ]
]

{ #category : #'structure control' }
GdaLibrary >> ensureRemoveStructureNamed: aStructureName [

	(self structureNamed: aStructureName) ifNotNil: [ :foundStructure | 
		self removeStructure: foundStructure ]
]

{ #category : #accessing }
GdaLibrary >> fileEntry [

	^ fileEntry
]

{ #category : #accessing }
GdaLibrary >> fileEntry: aPathOrFileEntry [

	fileEntry ifNotNil: [ ^ self error: 'file set at once.' ].
	fileEntry := aPathOrFileEntry asFileEntry
]

{ #category : #testing }
GdaLibrary >> hasStructureName: aStructureName [

	^ (self structures select: [ :s | s name sameAs: aStructureName ])
		  isNotEmpty
]

{ #category : #initialization }
GdaLibrary >> initialize [

	super initialize.
	self initializeCache.
	uuid := UUID new
]

{ #category : #initialization }
GdaLibrary >> initializeCache [

	unitString := nil.
	layers := nil.
	nameToStructureMap := nil
]

{ #category : #testing }
GdaLibrary >> isLibrary [

	^ true
]

{ #category : #testing }
GdaLibrary >> isTransient [

	^ false
]

{ #category : #'accessing - basic' }
GdaLibrary >> lastAccessed [

	^ lastAccessed
]

{ #category : #'accessing - basic' }
GdaLibrary >> lastAccessed: aDateAndTime [

	lastAccessed := aDateAndTime
]

{ #category : #'accessing - basic' }
GdaLibrary >> lastModified [

	^ lastModified
]

{ #category : #'accessing - basic' }
GdaLibrary >> lastModified: aDateAndTime [

	lastModified := aDateAndTime
]

{ #category : #'accessing - basic' }
GdaLibrary >> libName [

	^ libname
]

{ #category : #'accessing - basic' }
GdaLibrary >> libName: aString [

	libname ifNotNil: [ ^ self error: 'LIBRARY NAME ASSIGNED ONCE' ].
	self class checkLibName: aString.
	libname := "self class baseName:" aString
]

{ #category : #private }
GdaLibrary >> lookupStructureNames [

	^ self structures collect: [ :s | s name ]
]

{ #category : #private }
GdaLibrary >> lookupUsingLayerNumbers [

	| numberSet |
	numberSet := (Array streamContents: [ :s | 
		              self structures do: [ :struc | 
			              s nextPutAll: struc lookupUsingLayerNumbers ] ])
		             asSet.
	"Pharo: asSortedArray "
	^ numberSet asArray sorted
]

{ #category : #'accessing - basic' }
GdaLibrary >> meterUnit [

	^ meterUnit
]

{ #category : #'accessing - basic' }
GdaLibrary >> meterUnit: aFloat [

	meterUnit := aFloat
]

{ #category : #accessing }
GdaLibrary >> name [

	^ libname
]

{ #category : #initialization }
GdaLibrary >> name: aLibName databaseUnit: aInteger unitString: aUnitString [

	self
		privateName: aLibName
		databaseUnit: aInteger
		unitString: aUnitString
]

{ #category : #private }
GdaLibrary >> nameToStructureMap [

	nameToStructureMap ifNil: [ 
		nameToStructureMap := Dictionary new.
		self lookupStructureNames do: [ :structureName | 
			nameToStructureMap
				at: structureName
				ifAbsentPut: [ 
				GdaStructure fromLibrary: self structureNamed: structureName ] ] ].
	^ nameToStructureMap
]

{ #category : #'structure control' }
GdaLibrary >> newStructureNamed: aStructureName [

	| s |
	(self hasStructureName: aStructureName) ifTrue: [ 
		self error:
			'structure name: ' , aStructureName printString , 'already exists' ].
	s := self elementClass
		     fromLibrary: self
		     structureNamed: aStructureName.
	self addStructure: s.
	^ s
]

{ #category : #private }
GdaLibrary >> newStructureNamed: aStructureName withActivate: aBoolean [

	^ self station
		  newStructureNamed: aStructureName
		  withActivate: aBoolean
]

{ #category : #printing }
GdaLibrary >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self libName.
	aStream nextPut: $,.
	aStream nextPutAll: uuid asString.
	aStream nextPut: $)
]

{ #category : #private }
GdaLibrary >> privateLibName: aString [

	libname := self class baseName: aString
]

{ #category : #initialization }
GdaLibrary >> privateName: aLibName databaseUnit: aInteger unitString: aUnitString [

	self libName: aLibName.
	self databaseUnit: aInteger.
	self unitString: aUnitString
]

{ #category : #initialization }
GdaLibrary >> release [

	nameToStructureMap ifNotNil: [ 
		nameToStructureMap valuesDo: [ :each | each release ] ].
	nameToStructureMap := nil.
	station := nil.
	super release
]

{ #category : #'structure control' }
GdaLibrary >> removeStructure: aGdsStructure [

	nameToStructureMap ifNotNil: [ 
		(nameToStructureMap removeKey: aGdsStructure name ifAbsent: [  ]) 
			ifNotNil: [ 
				self clearStructuresCache
				"self announce: (GdsStructureRemoved new
						 structure: aGdsStructure;
						 yourself)" ] ]
]

{ #category : #accessing }
GdaLibrary >> station [

	^ station
]

{ #category : #accessing }
GdaLibrary >> station: aGdsStation [

	station := aGdsStation
]

{ #category : #'structure control' }
GdaLibrary >> structureNamed: aString [

	^ self nameToStructureMap at: aString ifAbsent: [ nil ]
]

{ #category : #'structure control' }
GdaLibrary >> structureNames [

	^ self lookupStructureNames
]

{ #category : #accessing }
GdaLibrary >> structures [

	^ self nameToStructureMap values asArray
]

{ #category : #'accessing - analisys' }
GdaLibrary >> structuresDepthOrder [

	^ self structures sort: [ :a :b | a maxDepth < b maxDepth ]
]

{ #category : #'accessing - analisys' }
GdaLibrary >> structuresMapByDepth [

	| map |
	map := Dictionary new.
	self structures do: [ :s | 
		(map at: s maxDepth ifAbsentPut: [ OrderedCollection new ]) add: s ].
	^ map
]

{ #category : #'accessing - analisys' }
GdaLibrary >> topStructures [

	^ self structures select: [ :s | 
		  s isLeaf not and: [ s indirectReferencedStructureNames isEmpty ] ]
]

{ #category : #accessing }
GdaLibrary >> unitString [

	^ unitString
]

{ #category : #accessing }
GdaLibrary >> unitString: aString [

	self class checkUnitString: aString.
	unitString := aString asUppercase
]

{ #category : #'accessing - basic' }
GdaLibrary >> userUnit [

	^ self databaseUnit reciprocal asFloat
]

{ #category : #'accessing - basic' }
GdaLibrary >> userUnit: aFloat [

	self databaseUnit: aFloat reciprocal asInteger
]

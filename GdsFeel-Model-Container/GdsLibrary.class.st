"
A GdsLibrary is xxxxxxxxx.

Instance Variables
	nameMap:		<Dictionary<String,GdsStructure>>
	station:		<GdsStation>
	structures:		<Array<GdsStructure>>
	lastModified:	<DateAndTime>
	lastAccessed:  <DateAndTime>

nameMap
	- fast lookup structure instance by structure name.

station
	- reference to Application Model instance.

structures
	- holds structures instance 

"
Class {
	#name : #GdsLibrary,
	#superclass : #GdsModel,
	#traits : 'TGdsExchange - {#asJson}',
	#classTraits : 'TGdsExchange classTrait',
	#instVars : [
		'station',
		'unitString',
		'libname',
		'databaseUnit',
		'meterUnit',
		'lastModified',
		'lastAccessed',
		'layers',
		'kinds',
		'file',
		'nameToStructureMap',
		'uuid'
	],
	#classVars : [
		'LibraryLocationInsideVM'
	],
	#category : #'GdsFeel-Model-Container'
}

{ #category : #'objects from disk' }
GdsLibrary class >> archivedNames [
	"self archivedNames"
	^(self findFiles
		collect: [:each | each basename]) asArray
]

{ #category : #accessing }
GdsLibrary class >> baseName: aString [
	^((aString endsWith: self extension)
		ifTrue: [aString  allButLast: self extension size]
		ifFalse: [aString]) asUppercase
]

{ #category : #accessing }
GdsLibrary class >> baseNames [
	^ self names collect: [:each | self baseName: each ].
]

{ #category : #check }
GdsLibrary class >> checkDatabaseUnit: aNumber [
	aNumber < 10 ifTrue: [^self error: 'DBU LEAST 10'].
	
]

{ #category : #check }
GdsLibrary class >> checkLibName: aString [
	| libnameSizeRange checkName |
	checkName := self baseName: aString.
	GdsCompatibility default libNameMax > 0
		ifTrue: [
			libnameSizeRange := 1 to: GdsCompatibility default libNameMax.
			(libnameSizeRange includes: checkName size)
				ifFalse: [
					^self error: ('LIBRARYNAME SIZE UNDER {1} ' 
						format: {libnameSizeRange max})]].
	(GdsCompatibility default isValidLibraryName: checkName)
		ifFalse: [self error: 'LIBRARY NAME ERROR'].
	"(self exists: checkName)
		ifTrue: [
			^self error: ('LIBNAME ALREADY EXISTS: {1}' format: {checkName})]."
]

{ #category : #check }
GdsLibrary class >> checkUnitString: aString [
	(self  unitStrings includes: aString asUppercase)
		ifFalse: [^self error: ('UNITS ONLY {1}' format: {self unitsString })].
	
]

{ #category : #accessing }
GdsLibrary class >> dbName: aString [
	^((aString endsWith: self extension)
		ifTrue: [aString]
		ifFalse: [aString, self extension]) asUppercase
]

{ #category : #'as yet unclassified' }
GdsLibrary class >> direcoryForThumbnailExtract: aLocalName [
	^ self subDirectoryNamed: '.session' forExtract: aLocalName
]

{ #category : #'as yet unclassified' }
GdsLibrary class >> directoryForExtract: aLocalName [
	^self subDirectoryNamed: '.editlibs' forExtract: aLocalName
]

{ #category : #accessing }
GdsLibrary class >> exists: aString [
	| checkName |
	checkName := self baseName: aString.
	^self baseNames anySatisfy: [:each | each sameAs: checkName] 
]

{ #category : #testing }
GdsLibrary class >> existsBaseName: aBaseName [
	^ self baseNames anySatisfy: [:each | each sameAs: aBaseName].
]

{ #category : #constants }
GdsLibrary class >> extension [
	^'.' , self extensionBody 
]

{ #category : #constants }
GdsLibrary class >> extensionBasicMatchExpr [
	^'*', self extension.
]

{ #category : #constants }
GdsLibrary class >> extensionBody [
	^'DB'
]

{ #category : #accessing }
GdsLibrary class >> extractedNames [
	"self extractedNames"
	^((GdsFeel projectDirectory) directoryNames 
		select: [:each | 
			(each endsWith: self extension)]) 
]

{ #category : #'as yet unclassified' }
GdsLibrary class >> findFiles [
	"self findFiles explore."
	^self findFilesOn: GdsFeel projectDirectory

]

{ #category : #'as yet unclassified' }
GdsLibrary class >> findFilesOn: aPathOrDirectoryEntry [
	| dirRef | 
	dirRef := aPathOrDirectoryEntry asFileReference.
	dirRef isDirectory 
		ifFalse: [^#()].
	^dirRef files select: [ :fileEntry | self isLibraryFile: fileEntry ].

]

{ #category : #'instance creation' }
GdsLibrary class >> fromFile: aPathOrFileReference [
	(GdsLibrary allInstances reverse
		detect: [ :lib | 
			([ lib file asAbsolute ]
				on: Error
				do: [ :ex | ex return: nil ]) = aPathOrFileReference asAbsolute ]
		ifNone: [  ]) ifNotNil: [ :lib | ^ lib ].
	^ self basicNew initialize file: aPathOrFileReference
]

{ #category : #testing }
GdsLibrary class >> hasBothFileSystem [
	^(Smalltalk hasClassNamed: #GdsLibraryFD) and: [Smalltalk hasClassNamed: #GdsLibraryFS].
]

{ #category : #testing }
GdsLibrary class >> hasMemberNamed: aZipMemberName archivePath: aPathToDatabase [
	| members |
	members := self privateZipMembersOf: aPathToDatabase.
	members ifEmpty: [^false].
	^members includes: aZipMemberName
]

{ #category : #'instance creation' }
GdsLibrary class >> initializeName: aString [ 
	^self initializeName: aString databaseUnits: 1000 unitString: 'MICRON'. 
]

{ #category : #'instance creation' }
GdsLibrary class >> initializeName: aString databaseUnits: anInteger unitString: aUnitString [ 
	self checkLibName: aString.
	self checkDatabaseUnit: anInteger.
	self checkUnitString: aUnitString.
	^GdsLibrary new
		name: aString databaseUnit: anInteger unitString: aUnitString.

]

{ #category : #'as yet unclassified' }
GdsLibrary class >> instanceCheck [
	<script>
	self  allInstances explore.
]

{ #category : #testing }
GdsLibrary class >> isLibraryFile: aFileReference [
	#ZipStore asClassIfPresent: [ ^ self isLibraryFileModern: aFileReference ].
	^ self isLibraryFileClassic: aFileReference
]

{ #category : #testing }
GdsLibrary class >> isLibraryFileClassic: aFileReference [
	| result |
	(aFileReference extension sameAs: 'DB')
		ifFalse: [ ^ false ].
	aFileReference size < 4
		ifTrue: [ ^ false ].
	result := false.
	aFileReference
		readStreamDo: [ :s | 
			s isZipArchive
				ifTrue: [ | ar names |
					ar := ZipArchive new.
					[ ar readFrom: s ]
						on: Error
						do: [ :ex | 
							ex traceCr.
							^ false ].
					names := ar memberNames.
					"result := {'LIB.ini'} allSatisfy: [ :file | names includes: file ]"
					result := names notEmpty ] ].
	^ result
]

{ #category : #testing }
GdsLibrary class >> isLibraryFileModern: aFileReference [
	| result |
	(aFileReference extension sameAs: 'DB')
		ifFalse: [ ^ false ].
	aFileReference size < 4
		ifTrue: [ ^ false ].
	result := false.
	aFileReference
		binaryReadStreamDo: [ :s | | fixedStream |
			fixedStream := s contents readStream.
			fixedStream isZipArchive
				ifTrue: [ | ar names |
					ar := ZipArchive new.
					[ ar readFrom: fixedStream ]
						on: Error
						do: [ :ex | 
							ex traceCr.
							^ false ].
					names := ar memberNames.
					"result := {'LIB.ini'} allSatisfy: [ :file | names includes: file ]"
					result := names notEmpty ] ].
	^ result
]

{ #category : #constants }
GdsLibrary class >> libInfoFileName [
	^'LIB.ini'
]

{ #category : #private }
GdsLibrary class >> libInfoFromIni: aIniStream [
	| iniFile |
	iniFile := INIFile readFrom: aIniStream.
	^(iniFile section: 'INITLIB')
	
	
	
	
	  
]

{ #category : #private }
GdsLibrary class >> libInfoFromIniOrig: aIniStream [
	| map |
	map := self libInfoMapFromIni: aIniStream.
	({ 'name' . 'dbu' . 'unit'}
		anySatisfy: [:each | (map includesKey: each) not])
		ifTrue: [^self error: 'LIBRARY INFO FORMAT ERROR'].
	({ 'name' . 'dbu' . 'unit'}
		anySatisfy: [:each | (map at: each ifAbsent: [nil]) isNil])
		ifTrue: [^self error: 'LIBRARY INFO FORMAT ERROR'].
	^map.
	
	
	
	
	  
]

{ #category : #private }
GdsLibrary class >> libInfoMapFromIni: aIniStream [
	| map line sepIndex key value |
	map := Dictionary new.
	[aIniStream atEnd]
		whileFalse: [
			line := aIniStream  upToAll: String crlf.
			sepIndex := line indexOf: $=.
			sepIndex > 0
				ifTrue: [
					key := line copyFrom: 1 to: sepIndex - 1.
					value := line copyFrom: sepIndex + 1 to: line size.
					map at: key put: value]].
	^map.	
	
	
	
	  
]

{ #category : #accessing }
GdsLibrary class >> locationOnlyInsideVM [
	^LibraryLocationInsideVM ifNil: [ LibraryLocationInsideVM := true ]
]

{ #category : #accessing }
GdsLibrary class >> locationOnlyInsideVM: aBoolean [
	LibraryLocationInsideVM := aBoolean
]

{ #category : #accessing }
GdsLibrary class >> names [
	^ self archivedNames , self extractedNames
]

{ #category : #testing }
GdsLibrary class >> privateZipMembersOf: aPathToDatabase [
	| zipArchive result |
	result := #().
	zipArchive := ZipArchive new.
	[zipArchive readFrom: aPathToDatabase.
	result := zipArchive memberNames]
		on: Error do: [: ex | ].
	zipArchive close.	
	^result.		
]

{ #category : #'objects from disk' }
GdsLibrary class >> storageFileDbNamed: aLibName [
	| tLibName fullDbName |
	tLibName := self baseName: aLibName.
	fullDbName := (tLibName, self  extension).
	^ GdsFeel projectDirectory / fullDbName.
]

{ #category : #'as yet unclassified' }
GdsLibrary class >> subDirectoryNamed: aSubDirName forExtract: aLocalName [
	^GdsFeel projectDirectory / aSubDirName / aLocalName .

]

{ #category : #accessing }
GdsLibrary class >> unitSpec [
	^{
		#('M' 1.0) . 
		#('CM' 1.0e-2) . 
		#('MM' 1.0e-3). 
		#('MICRON' 1.0e-6) . 
		#('INCH' 2.54e-2). 
		#('MIL' 2.54e-3) 
	}
]

{ #category : #accessing }
GdsLibrary class >> unitStrings [
	^self unitSpec collect: [:each | each first].
]

{ #category : #accessing }
GdsLibrary class >> unitsString [
	^(self unitStrings joinUsing: $, asString)
]

{ #category : #'structure control' }
GdsLibrary >> addStructure: aGdsStructure [
	| ann |
	nameToStructureMap ifNil: [ nameToStructureMap := Dictionary new ].
	nameToStructureMap at: aGdsStructure name put: aGdsStructure.
	self clearStructuresCache.
	ann := GdsStructureAdded new structure: aGdsStructure.
	self announce: ann.
	self clearStructuresCache.
	
]

{ #category : #initialization }
GdsLibrary >> allDispose [
	self class allInstVarNames  do: [ :each |
		self instVarNamed: each put: nil.
		 ]

]

{ #category : #'structure control' }
GdsLibrary >> announce: aAnnouncement [
	self announcer announce: aAnnouncement.
	GdsStation default announcer announce: aAnnouncement.
	
]

{ #category : #'xml/json data exchange' }
GdsLibrary >> attributesOn: aDictionary [ 
	"override hear"
	aDictionary at: 'name' put: self libName.

	aDictionary at: 'lastModified' put: self lastModified.
	aDictionary at: 'lastAccessed' put: self lastAccessed.

	aDictionary at: 'unitString' put: self unitString.
	aDictionary at: 'databaseUnit' put: self databaseUnit.
	aDictionary at: 'meterUnit' put: self meterUnit.
	
]

{ #category : #utility }
GdsLibrary >> autoAllocateLayerColors [
	| numbers layer colorStream |
	numbers := self lookupUsingLayerNumbers.
	colorStream := ReadStream on: (Color wheel: numbers size saturation: 0.7 brightness: 1.0).
	numbers do: [:each | 
		layer := self layers atNumber: each.
		layer color: colorStream next].
	
	
	
]

{ #category : #accessing }
GdsLibrary >> children [
	^ self structures
]

{ #category : #'as yet unclassified' }
GdsLibrary >> clearStructuresCache [
	self structures do: [ :each | each clearCache ]
]

{ #category : #'objects from disk' }
GdsLibrary >> close [
	self closeSaving: true.
]

{ #category : #'objects from disk' }
GdsLibrary >> closeNoSave [
	self closeSaving: false.
]

{ #category : #'objects from disk' }
GdsLibrary >> closeSaving: aBoolean [
	| announcement |
	self isOpen
		ifTrue: [ 
			aBoolean
				ifTrue: [
					self save].
			self deleteWorkFolder ].
	self initializeCache.
	announcement := (GdsLibraryClosed new) library: self; yourself.
	self announcer announce: announcement.
	GdsStation default announcer announce: announcement.
	

]

{ #category : #accessing }
GdsLibrary >> databaseUnit [
	^databaseUnit 
	
]

{ #category : #accessing }
GdsLibrary >> databaseUnit: aInteger [
	databaseUnit := aInteger.
	
]

{ #category : #defaults }
GdsLibrary >> defaultDatabaseUnit [
	^1000
	
]

{ #category : #defaults }
GdsLibrary >> defaultUnitString [
	^'MICRON'
	
]

{ #category : #'objects from disk' }
GdsLibrary >> deleteExtracted [
	self extractDirectory isDirectory
		ifTrue: [ self extractDirectory deleteAll ]
]

{ #category : #'objects from disk' }
GdsLibrary >> deleteWorkFolder [
	self extractDirectory ensureDeleteAll.
]

{ #category : #testing }
GdsLibrary >> dirty [
	^self structures anySatisfy: [:each | each dirty].
]

{ #category : #'structure control' }
GdsLibrary >> elementClass [
	^GdsStructure
	
]

{ #category : #'structure control' }
GdsLibrary >> ensureCreateStrucureNamed: aStructureName [
	^ (self structureNamed: aStructureName)
		ifNotNil: [ :foundStructure | foundStructure ]
		ifNil: [ | newStructure |
			newStructure := self elementClass
				fromLibrary: self
				structureNamed: aStructureName.
			self addStructure: newStructure.
			newStructure ]
]

{ #category : #'objects from disk' }
GdsLibrary >> ensureOpenDuring: aBlock [ 
	| saveOpend |
	saveOpend := self isOpen.
	[saveOpend ifFalse: [ self open ].
	aBlock value.] 
	ensure: [
		saveOpend ifFalse: [ self close ]].
]

{ #category : #'structure control' }
GdsLibrary >> ensureRemoveStructureNamed: aStructureName [
	(self structureNamed: aStructureName)
		ifNotNil: [ :foundStructure  | self removeStructure: foundStructure ]
]

{ #category : #'as yet unclassified' }
GdsLibrary >> extract [
	self extractDirectory isDirectory ifTrue: [ self error: 'Already Extracted' ].
	self zipArchiveDo: [ :zip |
		zip extractAllTo: self extractDirectory ]
]

{ #category : #'accessing - resource' }
GdsLibrary >> extractDirectory [
	^(self file parent / '.editlibs' / file basename) asFileReference. 
]

{ #category : #testing }
GdsLibrary >> extracted [
	^self extractDirectory isDirectory 
]

{ #category : #private }
GdsLibrary >> extractedStructureNames [
	self extracted
		ifFalse: [ ^self error: 'invalid call: library not extracted' ].
	^self extractDirectory directories 
		collect: [:dirRef | dirRef basenameWithoutExtension ]. 
]

{ #category : #accessing }
GdsLibrary >> file [
	^file ifNil: [ file := GdsFeel projectDirectory / self libNameWithExtension]
	
]

{ #category : #accessing }
GdsLibrary >> file: aPathOrFileReference [
	file ifNotNil: [ ^self error: 'file set at once.' ].
	file := aPathOrFileReference asFileReference.
	
]

{ #category : #maintenance }
GdsLibrary >> fixLayerColors [
	"self layers colorAllocated 
		ifFalse: [" 
		[self open.	
		self autoAllocateLayerColors.
		] ensure: [ self close ]"]".
]

{ #category : #testing }
GdsLibrary >> hasStructureName: aStructureName [
	^ (self structures select: [ :s | s name sameAs: aStructureName ])
		isNotEmpty
]

{ #category : #initialization }
GdsLibrary >> initialize [
	super initialize.
	self initializeCache.
	uuid := UUID new.

]

{ #category : #initialization }
GdsLibrary >> initializeCache [
	unitString := nil.
	layers := nil.
	kinds := GdsKinds new.
	nameToStructureMap := nil.
	

]

{ #category : #testing }
GdsLibrary >> isOpen [
	^self extracted
]

{ #category : #testing }
GdsLibrary >> isTransient [
	^ false
]

{ #category : #'xml/json data exchange' }
GdsLibrary >> jsonElementsOn: aDictionary [
	aDictionary at: 'structures' put: self structures. 
	aDictionary at: 'layers' put: self layers. 
]

{ #category : #accessing }
GdsLibrary >> kinds [
	kinds ifNil: [kinds := GdsKinds new].
	^kinds
]

{ #category : #accessing }
GdsLibrary >> lastAccessed [
	^lastAccessed
	
]

{ #category : #accessing }
GdsLibrary >> lastAccessed: aDateAndTime [
	lastAccessed := aDateAndTime.
	
]

{ #category : #accessing }
GdsLibrary >> lastModified [
	^lastModified.
	
]

{ #category : #accessing }
GdsLibrary >> lastModified: aDateAndTime [
	lastModified := aDateAndTime.
	
]

{ #category : #accessing }
GdsLibrary >> layers [
	layers 
		ifNil: [
			layers := GdsLayers new.
			self ensureOpenDuring: [
			self loadLayersTo: layers]].
	^layers
]

{ #category : #'accessing - resource' }
GdsLibrary >> layersFile [
	^ self extractDirectory / 'layers.xml'.
]

{ #category : #private }
GdsLibrary >> libInfoAsIniOn: aIniStream [ 
	| iniFile |
	iniFile := INIFile new.
	iniFile 
		section: 'INITLIB'
		at: 'name'
		put: self libName.
	iniFile 
		section: 'INITLIB'
		at: 'dbu'
		put: self databaseUnit asString.
	iniFile 
		section: 'INITLIB'
		at: 'unit'
		put: self unitString.
	iniFile writeOn: aIniStream.
]

{ #category : #accessing }
GdsLibrary >> libName [
	libname ifNotNil: [ ^ libname ].
	file ifNotNil: [ ^ self class baseName: file base ].
	^ ''
]

{ #category : #accessing }
GdsLibrary >> libName: aString [
	libname ifNotNil: [^self error: 'LIBRARY NAME ASSIGNED ONCE'].
	GdsLibrary checkLibName: aString.
	libname := self class baseName: aString.
]

{ #category : #accessing }
GdsLibrary >> libNameWithExtension [
	^self libName, self class extension.
	
]

{ #category : #'objects from disk' }
GdsLibrary >> loadLayersTo: aGdsLayer [
	self layersFile isFile 
		ifFalse: [
			('file not found: <1p>' expandMacrosWith: self layersFile) traceCr.
			^ self].
	self layersFile 
		readStreamDo: [ :s | | doc |
			doc := [XMLDOMParser parse: s]
				on: Error 
				do: [:ex | 
					ex traceCr. 
					s reset.
					Smalltalk tools workspace openContents: s contents label: self layersFile fullName.
					nil].
			doc 
				ifNotNil: 
					[ aGdsLayer loadFromXmlDocument: doc] ].

]

{ #category : #'objects from disk' }
GdsLibrary >> loadLibInfo [
	(self extractDirectory / 'LIB.ini') 
		readStreamDo: [:stream | 
			(self class libInfoFromIni: stream) 
			ifNotNil: [ :map |
				[self privateLibName: (map at: 'name'). 
				self databaseUnit: (map at: 'dbu') asInteger.
				self unitString: (map at: 'unit')] 
					on: Error
					do:  [:ex | 
						^self error: 'LIBRARY INFO FORMAT ERROR']].]
		ifAbsent: ['LIB.ini not found' traceCr].
	
]

{ #category : #'as yet unclassified' }
GdsLibrary >> loadStructureNamed: aStructureName [
	| structure |
	structure := self newStructureNamed: aStructureName withActivate: false.
	[structure load] on: Error
		do: 
			[:ex | 
				Transcript
					cr;
					show: (String streamContents: 
								[:s | 
									s nextPutAll: '***ERROR***'.
									s nextPutAll: ' '.
									s nextPutAll: 'skip broken structure: '.
									s nextPutAll: aStructureName]).
				self removeStructure: structure]
]

{ #category : #deprecated }
GdsLibrary >> loadStructures [
	self extractDirectory ensureCreateDirectory. 
	Cursor wait showWhile: [self loadStructures: self extractDirectory.].
]

{ #category : #'as yet unclassified' }
GdsLibrary >> loadStructures: aDirectory [
	"TODO: replace by GdsStructure2 Factory method"
	| subDirs |
	subDirs := aDirectory directories do: [ :dir | 
		(dir extension sameAs: 'structure')
			and: [ GdsCompatibility default isValidStructureName: dir base ] ].
	subDirs do: [ :dir | self loadStructureNamed: dir base ].
]

{ #category : #'objects from disk' }
GdsLibrary >> localNameForLayers [
	^'layers.xml'.

]

{ #category : #private }
GdsLibrary >> lookupStructureNames [
	^self extracted
		ifTrue: [ self extractedStructureNames ]
		ifFalse: [ self zipStructureNames ]. 
]

{ #category : #private }
GdsLibrary >> lookupUsingLayerNumbers [
	| numberSet |
	numberSet := (Array streamContents: [:s |
		self structures do: [:struc |
			s nextPutAll: struc lookupUsingLayerNumbers]
		]) asSet.
	"Pharo: asSortedArray "
	^numberSet asArray sorted.
]

{ #category : #'objects from disk' }
GdsLibrary >> makeArchive [
	self makeArchiveOld
]

{ #category : #'objects from disk' }
GdsLibrary >> makeArchiveNew [
	| archive   |
	(file exists)
		ifTrue: [file delete].
	archive := ZipArchive new.
	self extractDirectory directories 
		do: [ :dir | 
			archive addDirectory:  dir as:  dir basename ].
	self extractDirectory files 
		do: [ :f | 
			archive addFile: f as:  f basename ].
	[archive writeToFileNamed: file] 
		on: Error do: [:ex | self inform: ex description].		
	archive close.	
]

{ #category : #'objects from disk' }
GdsLibrary >> makeArchiveOld [
	| archive  trimSize |
	(file exists)
		ifTrue: [file delete].
	archive := ZipArchive new.
	trimSize := self extractDirectory fullName size.
	archive 
		addTree: self extractDirectory removingFirstCharacters: trimSize .		
	[archive writeToFileNamed: file] 
		on: Error do: [:ex | self inform: ex description].		
	archive close.	
]

{ #category : #'objects from disk' }
GdsLibrary >> makeFolder [
	self extractDirectory
		ifNotNil: [ :dir | 
			dir ensureCreateDirectory.
			dir / self class libInfoFileName
				writeStreamDo: [ :s | self libInfoAsIniOn: s ] ]
]

{ #category : #accessing }
GdsLibrary >> meterUnit [
	^meterUnit
	
]

{ #category : #accessing }
GdsLibrary >> meterUnit: aFloat [
	meterUnit := aFloat.
	
]

{ #category : #accessing }
GdsLibrary >> name [
	file ifNil: [ ^'!!!ERROR!!!' ].
	^file basenameWithoutExtension asUppercase .
]

{ #category : #initialization }
GdsLibrary >> name: aLibName databaseUnit: aInteger unitString: aUnitString [
	| announcement |
	self privateName: aLibName databaseUnit:  aInteger unitString: aUnitString.
	self autoAllocateLayerColors.
	self saveLayers.
	self makeArchive.
	self deleteWorkFolder.
	announcement := GdsLibraryCreated new library: self; yourself.
	self announcer announce: announcement.
	GdsStation default announcer announce: announcement.
]

{ #category : #private }
GdsLibrary >> nameToStructureMap [
	nameToStructureMap 
		ifNil: [ 
			nameToStructureMap := Dictionary new .
			self lookupStructureNames do: [ :structureName | 
				nameToStructureMap 
					at: structureName 
					ifAbsentPut: [GdsStructure fromLibrary: self structureNamed: structureName ] ] ].
	^ nameToStructureMap
]

{ #category : #'structure control' }
GdsLibrary >> newStructureNamed: aStructureName [
	| s |
	(self hasStructureName: aStructureName)
		ifTrue: [self error: 'structure name: ', aStructureName printString, 'already exists'].
	s := self elementClass fromLibrary: self structureNamed: aStructureName.
	self addStructure: s.
	^s.
	
]

{ #category : #private }
GdsLibrary >> newStructureNamed: aStructureName withActivate: aBoolean [
	^ self station newStructureNamed: aStructureName withActivate: aBoolean.
]

{ #category : #'objects from disk' }
GdsLibrary >> open [
	| announcement | 
	self isOpen 
		ifFalse: [
			self extract.
			"self privateLoad "].
	announcement := GdsLibraryOpend new library: self.
	self announcer announce: announcement.
	GdsStation default announcer announce: announcement.
]

{ #category : #printing }
GdsLibrary >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self libName.	
	aStream nextPut: $,.
	aStream nextPutAll: uuid asString.	
	aStream nextPut: $).
	
]

{ #category : #private }
GdsLibrary >> privateLibName: aString [
	libname := self class baseName: aString.
]

{ #category : #'objects from disk' }
GdsLibrary >> privateLoad [
	self loadLibInfo.
	self layers.
	self loadStructures.
	
]

{ #category : #initialization }
GdsLibrary >> privateName: aLibName databaseUnit: aInteger unitString: aUnitString [
	self libName: aLibName.
	self databaseUnit: aInteger.
	self unitString: aUnitString.
	self makeFolder.
	
]

{ #category : #initialization }
GdsLibrary >> release [
	nameToStructureMap ifNotNil: [nameToStructureMap values do: [:each | each release]].
	nameToStructureMap  := nil.
	station := nil.
	super release.
]

{ #category : #'structure control' }
GdsLibrary >> removeStructure: aGdsStructure [
	nameToStructureMap
		ifNotNil: [ 
			(nameToStructureMap removeKey: aGdsStructure name ifAbsent: [  ])
				ifNotNil: [ 
					self clearStructuresCache.
					self
						announce:
							(GdsStructureRemoved new
								structure: aGdsStructure;
								yourself) ] ]
]

{ #category : #'objects from disk' }
GdsLibrary >> save [
	self saveLayers.
	self structures do: [:s | s save ].
	self makeArchive
]

{ #category : #'objects from disk' }
GdsLibrary >> saveLayers [
	GdsFeel
		fileOutXmlTopElement: self layers asXmlElement
		toFile: self layersFile.
]

{ #category : #'accessing - resource' }
GdsLibrary >> sessionDirectory [
	^(file parent / '.session' / file basename) asFileReference. 
]

{ #category : #accessing }
GdsLibrary >> station [
	^station
]

{ #category : #accessing }
GdsLibrary >> station: aGdsStation [
	station := aGdsStation.
]

{ #category : #'structure control' }
GdsLibrary >> structureNamed: aString [	
	^ self nameToStructureMap at: aString ifAbsent: [ nil ]
]

{ #category : #'structure control' }
GdsLibrary >> structureNames [
	^ self lookupStructureNames
]

{ #category : #accessing }
GdsLibrary >> structures [
	^ self nameToStructureMap values asArray
]

{ #category : #'accessing - analisys' }
GdsLibrary >> structuresDepthOrder [
	^ self structures sort: [ :a :b | a maxDepth < b maxDepth ].
]

{ #category : #'accessing - analisys' }
GdsLibrary >> structuresMapByDepth [
	| map |
	map := Dictionary new.
	self structures
		do: [ :s | (map at: s maxDepth ifAbsentPut: [ OrderedCollection new ]) add: s ].
	^ map
]

{ #category : #'accessing - analisys' }
GdsLibrary >> topStructures [
	^ self structures select: [ :s | 
		s isLeaf not 
			and: [s indirectReferencedStructureNames  isEmpty ]].
]

{ #category : #accessing }
GdsLibrary >> unitString [
	^unitString
]

{ #category : #accessing }
GdsLibrary >> unitString: aString [
	self class checkUnitString: aString.
	unitString := aString asUppercase.
]

{ #category : #accessing }
GdsLibrary >> userUnit [
	^self databaseUnit reciprocal asFloat.
]

{ #category : #accessing }
GdsLibrary >> userUnit: aFloat [
	self databaseUnit: aFloat reciprocal asInteger.
]

{ #category : #'as yet unclassified' }
GdsLibrary >> zipArchiveDo: aArchiveBlock [
	^ GdsFeel zipArchive: file do: aArchiveBlock
]

{ #category : #private }
GdsLibrary >> zipStructureNames [
	self zipArchiveDo: [ :zip | 
		^(zip members select: [ :m | m isKindOf: ZipDirectoryMember ])
			collect: [ :dm | ((dm fileName allButLast) findTokens: '.') first ] ]
]

"
A GdsStation is xxxxxxxxx.

Instance Variables
	items:		<GdsItems>
	library:		<GdsLibrary>
	structure:		<GdsStructure>

items
	- xxxxx

library
	- xxxxx

structure
	- xxxxx

"
Class {
	#name : #GdsStation,
	#superclass : #GdsModel,
	#instVars : [
		'library',
		'structure',
		'items',
		'fileMap',
		'nameMap',
		'autoCloseLibrary'
	],
	#classVars : [
		'Default'
	],
	#category : #'GdsFeel-Model-Container'
}

{ #category : #'instance creation' }
GdsStation class >> default [
	^Default ifNil: [ Default := GdsStation basicNew initialize ].
	
]

{ #category : #examples }
GdsStation class >> exampleSandBox [
	"GdsStation exampleSandBox."
	<example>
	| randomPointGenerator |
	randomPointGenerator := [ :size | size atRandom @ size atRandom ].
	GdsStation default ensureSandbox.
	GdsStation default currentItem
		ifNotNil: [ :item | 
			300
				timesRepeat: [ item
						putPathFrom: (randomPointGenerator value: 540)
						to: (randomPointGenerator value: 540) ] ].
	GdsStation default quit
]

{ #category : #mantenance }
GdsStation class >> fixMissingLayerColor [
	"self fixMissingLayerColor"
	self default libraries
		do: [ :l | l fixLayerColors ]
]

{ #category : #'class initialization' }
GdsStation class >> initialize [
	"GdsStation initialize."
	Default := nil.
	
]

{ #category : #'notification-constants' }
GdsStation class >> libraryDidChangeNotification [
	^'GdsStationLibraryDidChangeNotification'
]

{ #category : #accessing }
GdsStation class >> libraryFiles [
	^ GdsLibrary findFiles.
]

{ #category : #'instance creation' }
GdsStation class >> new [
	^self error: 'use: GdsStation default.'
]

{ #category : #'instance creation' }
GdsStation class >> openDefault [
	^self new openDefault.
]

{ #category : #'instance creation' }
GdsStation class >> quit [
	^Default ifNotNil: [ Default quit].
	
]

{ #category : #'notification-constants' }
GdsStation class >> structureDidChangeNotification [
	^'GdsStationStructureDidChangeNotification'
]

{ #category : #'command-handler' }
GdsStation >> assertNilDependent [
	self assert: [(self dependents includes: nil) not].
	
]

{ #category : #accessing }
GdsStation >> autoCloseLibrary: aBoolean [
	autoCloseLibrary := aBoolean.
]

{ #category : #'command-handler' }
GdsStation >> bstructEnabled [
	self library ifNil: [^false].
	self structure ifNotNil: [^false].
	^true.

]

{ #category : #'command-handler' }
GdsStation >> bstructName: aBlockOrString [
	self newStructureNamed: aBlockOrString  withActivate: true.
	^self.
	

]

{ #category : #testing }
GdsStation >> closeEnabled [
	self structure ifNil: [^true].
	^self structure closeEnabled
]

{ #category : #action }
GdsStation >> closeLibrary [
	self library
		ifNotNil: [ :lib | 
			lib close.
			self library: nil.
			lib allDispose.
			self library: nil.
			self damageStorageInformation ]
]

{ #category : #action }
GdsStation >> closeStructure [
	"self assertNilDependent."
	self structure ifNil: [^self error: 'structure already closed.'].
	self structure closeWithSave.
	self structure: nil.
	
]

{ #category : #accessing }
GdsStation >> currentItem [
	^ self structure currentItem.
]

{ #category : #private }
GdsStation >> damageStorageInformation [
	nameMap := nil.
	fileMap := nil.

]

{ #category : #action }
GdsStation >> ensureCloseStructure [
	"self assertNilDependent."
	self structure ifNil: [^self].
	self closeStructure
	
]

{ #category : #'instance creation' }
GdsStation >> ensureCreateLibraryNamed: name [ 
	| newName |
	newName := name trimBoth.
	newName := GdsCompatibility default coerceStructureName: newName.
	(self nameMap includesKey: newName)
		ifTrue: [ ^ self nameMap at: newName] .	
	^ self initlibNamed: newName databaseUnits: 1000 unitString: 'M' 

]

{ #category : #'instance creation' }
GdsStation >> ensureOpenLibrary: aGdsLibrary during: aBlock [
	| savedLib |
	savedLib := self library.
	[GdsStation default library: aGdsLibrary.
	aGdsLibrary ensureOpenDuring: aBlock.]
		ensure: [
			self library: savedLib]

]

{ #category : #'as yet unclassified' }
GdsStation >> ensureSandbox [
	| newName |
	newName := self uniqueSandboxLibraryName.
	self ensureCreateLibraryNamed: newName.
	self library: (self ensureCreateLibraryNamed: newName).
	(self library ensureCreateStrucureNamed: newName)
		ifNotNil: [ :s | 
			s == self structure
				ifFalse: [ self structure: s ] ]
]

{ #category : #private }
GdsStation >> fileMap [
	"self default fileMap explore."
	fileMap
		ifNil: [ 
			fileMap := Dictionary new.
			GdsLibrary findFiles
				do: [ :f | 
					(fileMap includesKey: f)
						ifFalse: [ fileMap at: f put: (GdsLibrary fromFile: f) ] ] ].
	fileMap keysAndValuesRemove: [ :f :lib | f isFile not ].
	^ fileMap
]

{ #category : #updating }
GdsStation >> fireLibraryChanged [
	self announcer announce: #libraryChanged.
	GdsFeel dependentEnabled
		ifFalse: [ ^ self ].
	self notifyStructureChanged.
	self notifyLibraryChanged
]

{ #category : #updating }
GdsStation >> fireStructureChanged [
	self announcer announce: #structureChanged.
	GdsFeel dependentEnabled 
		ifTrue: [
			self notifyStructureChanged].
]

{ #category : #maintenance }
GdsStation >> garbageCollect. [
	self structure ifNotNil: [ ^ self inform: 'Cannt garbageCollect: use structure' ].
	self library ifNotNil: [ ^ self inform: 'Cannt garbageCollect: use library' ].
	GdsStructure allInstancesDo: [ :s | s allDispose ].	
	GdsLibrary allInstancesDo: [ :l | l allDispose ].
	3 timesRepeat: [ Smalltalk garbageCollect ].		
]

{ #category : #updating }
GdsStation >> handleLibraryChanged: aGdsPropertyChanged [
	| trace |
	trace := false.
	aGdsPropertyChanged oldValue
		ifNotNil: [ :lib | 
			trace
				ifTrue: [ self
						traceCr: ('libraryDeactivate: <1p>' expandMacrosWith: lib libName) ].
			lib removeDependent: self.
			self isAutoCloseLibrary
				ifTrue: [ lib close ] ].
	aGdsPropertyChanged newValue
		ifNotNil: [ :lib | 
			trace
				ifTrue: [ self
						traceCr: ('libraryActivate: <1p>' expandMacrosWith: lib libName) ].
			lib addDependent: self.
			self structure: nil.
			lib open ].
	self fireLibraryChanged
]

{ #category : #updating }
GdsStation >> handleStructureChanged: aGdsPropertyChanged [
	| trace |
	trace := false.
	aGdsPropertyChanged oldValue
		ifNotNil: [ :s | 
			trace
				ifTrue:
					[ self traceCr: ('structureDeactivate: <1p>' expandMacrosWith: s name) ].
			s save.
			s removeDependent: self ].
	aGdsPropertyChanged newValue
		ifNotNil: [ :s | 
			trace
				ifTrue:
					[ self traceCr: ('structureActivate: <1p>' expandMacrosWith: s name) ].
			s addDependent: self ]
		ifNil: [ trace
				ifTrue: [ self traceCr: 'structureCleard: nil'.
					self
						traceCr: ('items dependents: <1p>' expandMacrosWith: items dependents) ] ].
	self fireStructureChanged
]

{ #category : #accessing }
GdsStation >> idSelection [
	self structure ifNotNil: [ :struc | ^ struc idSelection ].
	^ nil
]

{ #category : #initialization }
GdsStation >> initialize [
	super initialize.
	self damageStorageInformation.
	"items := GdsItems new station: self."
	library := GdsObjectProperty named: 'library' type: GdsLibrary owner: self.
	library nilAllowed: true.
	library whenChangedPropertyDo:  [ :prop :ann | self handleLibraryChanged: ann ].
	
	structure := GdsObjectProperty named: 'structure' type: GdsStructure owner: self.
	structure nilAllowed: true.
	structure whenChangedPropertyDo:  [ :prop :ann | self handleStructureChanged: ann ].
	
	self announcer when: GdsLibraryCreated send: #damageStorageInformation to: self.
	 
]

{ #category : #'instance creation' }
GdsStation >> initlibNamed: name [ 
	^self initlibNamed: name databaseUnits: 1000 unitString: 'M' 

]

{ #category : #'instance creation' }
GdsStation >> initlibNamed: name databaseUnits: dbu unitString: unit [
	| lib |
	lib := GdsLibrary initializeName: name databaseUnits: dbu unitString: unit.
	lib ifNotNil: [self changed: #openlibEnabled].
	^lib
]

{ #category : #'instance creation' }
GdsStation >> initlibNamed: name unitString: unit [
	^self initlibNamed: name databaseUnits: 1000 unitString: unit 

]

{ #category : #accessing }
GdsStation >> isAutoCloseLibrary [
	^ autoCloseLibrary ifNil: [ autoCloseLibrary := true ]
]

{ #category : #accessing }
GdsStation >> items [
	^items

]

{ #category : #accessing }
GdsStation >> labelString [
	^String streamContents: [:s |
		s nextPutAll: 'GdsFeel: '.
		self library 
			ifNotNil: [self library dirty ifTrue: [s nextPutAll: '* ']].
		s nextPutAll: self labelStringAfter].

]

{ #category : #accessing }
GdsStation >> labelStringAfter [
	self library ifNil: [^'NO LIBRARY OPEN'].
	self structure ifNil: [^'[{1}].NO STRUCTURE OPEN' format: {self library libName}].
	^'[{1}].[{2}]' format: {self library libName . self structure name}.
]

{ #category : #accessing }
GdsStation >> libraries [
	"self default libraries explore."
	^self nameMap values.

]

{ #category : #accessing }
GdsStation >> library [
	^library getValue.
]

{ #category : #accessing }
GdsStation >> library: aGdsLibrary [
	aGdsLibrary ifNotNil: [aGdsLibrary station: self].
	library setValue: aGdsLibrary
]

{ #category : #accessing }
GdsStation >> libraryNames [
	"self default libraryNames explore."
	^self nameMap keys sort.

]

{ #category : #accessing }
GdsStation >> libraryProperty [
	^ library
]

{ #category : #private }
GdsStation >> nameMap [
	"self default nameMap explore."

	nameMap ifNil: [ nameMap := Dictionary new ].
	self fileMap
		keysAndValuesDo:
			[ :f :lib | nameMap at: f basenameWithoutExtension ifAbsentPut: [ lib ] ].
	(nameMap values reject: [ :l | l file exists ])
		ifNotEmpty: [ :removedLibs | 
			removedLibs
				do: [ :l | nameMap removeKey: l file basenameWithoutExtension ] ].
	^ nameMap
]

{ #category : #'instance creation' }
GdsStation >> newStructureNamed: aBlockOrString [
	^ self newStructureNamed: aBlockOrString withActivate: false

]

{ #category : #'instance creation' }
GdsStation >> newStructureNamed: aBlockOrString withActivate: aActivateBoolean [
	| name newStructure |
	self assertNilDependent.
	self library ifNil: [^self error: 'no library open.'].
	aActivateBoolean
		ifTrue: [
			self structure ifNotNil: [^self error: 'structure already opend.']].
	name := aBlockOrString value.
	name ifNil: [^self].
	newStructure := self library newStructureNamed: name.
	aActivateBoolean
		ifTrue: [
			self structure: newStructure.
			].
	^newStructure

]

{ #category : #updating }
GdsStation >> notifyLibraryChanged [
	self changed: #library.
	self changed: #openlibEnabled.
	self changed: #closelibEnabled.

]

{ #category : #updating }
GdsStation >> notifyStructureChanged [
	self changed: #relabel.
	self changed: #structure.		
	self changed: #ostructEnabled.
	self changed: #bstructEnabled.
	self changed: #tstructEnabled.		
]

{ #category : #action }
GdsStation >> openDefault [
	"self openBetaLibrary"
]

{ #category : #action }
GdsStation >> openLibrary: aGdsLibrary [
	aGdsLibrary station: self.
	self library: aGdsLibrary.
	aGdsLibrary open.
	self structure: nil.
	
]

{ #category : #action }
GdsStation >> openLibraryNamed: aLibName [
	| lib |
	lib := self fileMap at: (GdsLibrary storageFileDbNamed: aLibName) ifAbsent: [nil].
	self assert: lib notNil.
	self openLibrary: lib.
]

{ #category : #action }
GdsStation >> openLibraryNamed: aLibName during: aLibraryBlock [
	[self openLibraryNamed: aLibName.
	aLibraryBlock cull: self library.] 
	ensure: [ self closeLibrary ]	
]

{ #category : #'command-handler' }
GdsStation >> openStructureNamed: aStructureName [ 
	self openStructureNamed: aStructureName ifAbsentCreate: false
]

{ #category : #'command-handler' }
GdsStation >> openStructureNamed: aStructureName ifAbsentCreate: aDoCreate [
	| struc |
	struc := self library structureNamed: aStructureName. 
	(struc isNil and: [aDoCreate]) 
		ifTrue:  [self bstructName: aStructureName]
		ifFalse: [self ostructNames: [:names | aStructureName]].
	^self structure.
	
]

{ #category : #'command-handler' }
GdsStation >> openlibNames: aNamesArgBlock sortBlock: sortBlock [
	"aNamesArgBlock must be return library name"
	| name names |
	self assertNilDependent.
	self library ifNotNil: [^self error: 'library already opend.'].
	self structure ifNotNil: [^self error: 'structure already opend.'].
	names := (GdsLibrary baseNames asArray sort: sortBlock) collect: [:each | each ].	
	name := aNamesArgBlock value: names.	
	name ifNil: [^self].
	self openLibraryNamed:  name.

]

{ #category : #'command-handler' }
GdsStation >> ostructEnabled [
	self library ifNil: [ ^ false ].
	self structure ifNotNil: [ ^ false ].
	^ self library structures isNotEmpty
]

{ #category : #'command-handler' }
GdsStation >> ostructNames: aNamesArgBlock [
	^self ostructNames: aNamesArgBlock  sortBlock: [:a :b | a  name <= b name]. 

]

{ #category : #'command-handler' }
GdsStation >> ostructNames: aNamesArgBlock sortBlock: sortBlock [
	"aNamesArgBlock must be return structure name"
	| name names |
	"self assertNilDependent."
	self library ifNil: [^self error: 'no library open.'].
	self structure ifNotNil: [^self error: 'structure already opend.'].
	names := (self library structures sort: sortBlock) collect: [:each | each name].	
	name := aNamesArgBlock value: names.	
	name ifNil: [^self].
	self structure: (self library structureNamed: name).

]

{ #category : #action }
GdsStation >> quit [
	self damageStorageInformation.
	(self libraries select: [:lib | lib isOpen ]) do: [ :lib | lib close ] 
]

{ #category : #initialization }
GdsStation >> release [
	self announcer unsubscribe: self.
	items := nil.
	structure := nil.
	library := nil.
	super release.
	
	
]

{ #category : #accessing }
GdsStation >> structure [
	^structure getValue
]

{ #category : #accessing }
GdsStation >> structure: aGdsStructure [
	structure setValue: aGdsStructure.
]

{ #category : #accessing }
GdsStation >> structureProperty [
	^ structure
]

{ #category : #'command-handler' }
GdsStation >> tstruct [
	Cursor wait showWhile: [self ensureCloseStructure].
	
	
]

{ #category : #'command-handler' }
GdsStation >> tstructEnabled [	
	^ self structure notNil and: [ self structure closeEnabled ]

	
	
]

{ #category : #'as yet unclassified' }
GdsStation >> uniqueSandboxLibraryName [
	^ 
	String streamContents: [ :s |
		s << 'SB'.
		s << (Date today yyyymmdd copyReplaceAll: '-' with: '').
		"s << (Time now print24 copyReplaceAll: ':' with: '')"].
]

{ #category : #updating }
GdsStation >> update: aParameter [
	aParameter == #tstructEnabled
		ifTrue: [
			self changed: #tstructEnabled.
			self changed: #closelibEnabled].
	aParameter == #elementType
		ifTrue: [self changed: #elementType].
	super update: aParameter.
]

"
A GdsFeel is Project symbolic name.

- not a real GUI class. (real class GdsStationUI).
- project property holder like as NextStep's defaults (write|read) NSGlobalDomain.

Instance Variables

"
Class {
	#name : #GdsFeel,
	#superclass : #Object,
	#classVars : [
		'TypedMap'
	],
	#category : 'GdsFeel-Model-Basic'
}

{ #category : #maintenance }
GdsFeel class >> clearDependents [
	"GdsFeel clearDependents"
	self relatedClasses do: [:clazz | 
		clazz allInstances do: [:obj | obj breakDependents ]].
	Smalltalk garbageCollect.
]

{ #category : #'debug-flags' }
GdsFeel class >> debugConsoleOut [
	^self typedMap booleanFor: #debugConsoleOut.
]

{ #category : #'debug-flags' }
GdsFeel class >> debugConsoleOut: aBoolean [
	self typedMap booleanFor: #debugConsoleOut value: aBoolean.
	
]

{ #category : #'debug-flags' }
GdsFeel class >> dependentEnabled [
	^self typedMap booleanFor: #dependentEnabled default: true.
]

{ #category : #'debug-flags' }
GdsFeel class >> dependentEnabled: aBoolean [
	self typedMap booleanFor: #dependentEnabled value: aBoolean.
	
]

{ #category : #'as yet unclassified' }
GdsFeel class >> directoryPath: aDirectoryPath nextNameFor: aBaseName extension: anExtension [
	| parent pat version versionNumbers nameWithoutExtension |
	parent := aDirectoryPath asFileReference.
	nameWithoutExtension := aBaseName.
	pat := aBaseName, '*.', anExtension.
	versionNumbers := (parent filesMatching: pat) 
		collect: [ :f | self versionNumberFromName: f basename].				
	versionNumbers ifEmpty: [^aBaseName , '.', anExtension].	
	version := versionNumbers max + 1.
	^(nameWithoutExtension , '.', version asString) , '.', anExtension
	
]

{ #category : #'objects from disk' }
GdsFeel class >> fileOutXmlTopElement: aXMLElement toFile: aFileReference [ 
	| doc |
	"self halt."
	aFileReference parent ensureCreateDirectory.
	doc := XMLDocument new version: 1.0 asString.
	doc addNode: aXMLElement.
	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :s |
		  doc printOn: s].
]

{ #category : #'debug-flags' }
GdsFeel class >> fittingRatio [
	^self typedMap numberFor: #fittingRatio default:  GdsViewport defaultFittingRatio.
]

{ #category : #'debug-flags' }
GdsFeel class >> fittingRatio: aFloat [
	self assert: [ aFloat between: 0.5 and: 1.0 ] description: 'fittingRatio specify between 0.5 and 1.0'.
	^ self typedMap numberFor: #fittingRatio value: aFloat
]

{ #category : #debug }
GdsFeel class >> ifDebug: aBlock [
	self debugConsoleOut ifFalse: [^self].
	aBlock value.
	
	
]

{ #category : #debug }
GdsFeel class >> ifDebugOn: aStreamBlock [
	self ifDebug: [
		Transcript cr; show: 
			(String streamContents: [ :stream |
				stream nextPutAll: '***DEBUG***'.
				stream nextPutAll: ' '.
				aStreamBlock value: stream])].
	
]

{ #category : #'class initialization' }
GdsFeel class >> initialize [
	self dependentEnabled: false.
	
]

{ #category : #private }
GdsFeel class >> join: anArray using: joint [
	"TODO: using KFStringUtils #join:using:"
	| path |
	path := String streamContents: [:s |
		anArray do: [:each | 
			s nextPutAll: each.
			s nextPutAll: joint]].
	^path allButLast:  joint size.
]

{ #category : #utilities }
GdsFeel class >> loadExampleZippedDatabaseToLocal [

	| srcFile destFolder destFile |
	srcFile := (FileLocator home / 'Nextcloud' / 'gds' / 'BGHIER.DB')
		           asFileReference.
	srcFile exists 
		ifFalse: [ 
			self inform: srcFile fullName , 'Not found'.
			^ self ].

	destFolder := (Path workingDirectory / 'GdsFeel') asFileReference.
	destFolder ensureCreateDirectory.
	destFile := destFolder / srcFile basename.
	destFile ensureDelete.
	srcFile copyTo: destFile.
	destFile
]

{ #category : #maintenance }
GdsFeel class >> migrateConfigulationValues [
	"self migrateConfigulationValues"
	| lowerCapital |
	TypedMap ifNil: [ TypedMap := TypedConfigulation new ].
	lowerCapital := 
	[ :symbol | 
	| varName |
	varName := symbol asString.
	varName first asString asLowercase , varName allButFirst ].
	(self classVarNames reject: [ :each | each = #TypedMap ]) do: 
		[ :each | 
		(self classPool at: each) ifNotNil: 
			[ :clazzVar | 
			TypedMap 
				instVarNamed: (lowerCapital value: each)
				put: clazzVar copy ] ]
]

{ #category : #documentation }
GdsFeel class >> openReadMe [
	"self openReadMe."

	self environment at: #Workspace ifPresent: [ :clazz |
		(clazz new contents: self readMeContents; yourself) openLabel:
			self readMeTitle ]
]

{ #category : #private }
GdsFeel class >> pathFromComponents: anArray [
	^self join: anArray using: (DiskStore current delimiter asString).
]

{ #category : #filesystem }
GdsFeel class >> projectDirectory [
	^ './GdsFeel' asFileReference ensureCreateDirectory 
]

{ #category : #documentation }
GdsFeel class >> readMeContents [
	^self readMeMaster
]

{ #category : #documentation }
GdsFeel class >> readMeMaster [
	^'
GdsInform reMakeGDSreaderSample .

GdsStation initialize.
GdsStation default openLibraryNamed: ''BGHIER.DB''.
GdsStation default library.
GdsStation default openStructureNamed: GdsStation default library topStructures first name.
GdsStation default structure subStructures  .

(GdsStation default library structureNamed: ''PC'') referencedStructures.
GdsStation default labelString.
GdsStation default library close.
'
]

{ #category : #documentation }
GdsFeel class >> readMeTitle [
	^'README - ', (((self category asString splitOn: '-') allButLast) joinUsing: '-')

]

{ #category : #documentation }
GdsFeel class >> readMeV000 [
	^'
kf 10/8/2009 10:25

- fix: can''t enabled button [OPENLIB]. after [INITLIB] 
'
]

{ #category : #documentation }
GdsFeel class >> readMeV001 [
	^'
kf 10/28/2009 11:49

- add datatype, pathtype
- change layer -> layerNumber.

- fix: GeometryUtils>>#removeDuplicatePoints:on:

'
]

{ #category : #documentation }
GdsFeel class >> readMeV002 [
	^'
V002
______

move GUI configulation methods to GdsFeelMorphic(GdsFeel-Morphic mcz Package).

- #goodiesEnabled
- #goodiesEnabled:
- #debugStretchFeedback 
- #debugStretchFeedback: 
- #debugFindElement 
- #debugFindElement: 
- #debugPathBoundary: 
- #clickSoundEnabled 
- #clickSoundEnabled: 
- #debugPathBoundary 



'
]

{ #category : #documentation }
GdsFeel class >> readMeV003 [
	^'
V003
______

- GdsViewport screen allocate margin attribute.
  defaultFittingRatio => 0.98.

- fix: Can''t effect floating number grid.
'
]

{ #category : #maintenance }
GdsFeel class >> rebuild [
	"GdsFeel rebuild"
	self relatedClasses do: [:clazz | clazz compileAll]
]

{ #category : #maintenance }
GdsFeel class >> relatedClasses [
	"GdsFeel rebuild"
	^(Smalltalk allClasses select: [:clazz |
		#('KF' 'Gds' 'Gpl') anySatisfy: [:each | clazz name beginsWith: each]])

]

{ #category : #'as yet unclassified' }
GdsFeel class >> settingsOn: aBuilder [ 
	<systemsettings>
	(aBuilder group: #GdsFeel)
		with: [
			(aBuilder setting: #dependentEnabled)
				target: self; 
				label: 'Dpendent enabled';
		 		description: 'Use Clasical dependent mechanizm.'.
				]
]

{ #category : #accessing }
GdsFeel class >> typedMap [
	TypedMap ifNil: [ TypedMap := TypedConfigulation new ].
	^ TypedMap
]

{ #category : #'as yet unclassified' }
GdsFeel class >> versionNumberFromName: aName [
	| items verString |
	items := aName findTokens: '.'.
	items ifEmpty: [^0].
	items size = 3 ifFalse: [^0].
	verString := items at: 2.
	verString isAllDigits ifFalse: [^0].
	^verString asNumber
	
]

{ #category : #'objects from disk' }
GdsFeel class >> xmlDocumentFile: aFileReference documentBlock: aBlock [
	"self halt."
	aFileReference readStreamDo: [ :s | | doc |
		doc := [XMLDOMParser parse: s]
			on: Error do: [:ex | ex traceCr. nil].
		doc ifNotNil:[aBlock value: doc] ].

]

{ #category : #utilities }
GdsFeel class >> zipArchive: aFile do: aArchiveBlock [
	#ZipStore asClassIfPresent: [ ^ self zipArchiveModern: aFile do: aArchiveBlock ].
	^ self zipArchiveClassic: aFile do: aArchiveBlock
]

{ #category : #utilities }
GdsFeel class >> zipArchiveClassic: aFile do: aArchiveBlock [
	| result |
	result := nil.
	aFile asFileReference
		readStreamDo: [ :s | 
			s isZipArchive
				ifTrue: [ | ar |
					s binary.
					ar := ZipArchive new readFrom: s.
					result := [ aArchiveBlock value: ar ]
						ensure: [ ar close ] ] ].
	^ result
]

{ #category : #utilities }
GdsFeel class >> zipArchiveModern: aFile do: aArchiveBlock [
	| result |
	result := nil.
	aFile asFileReference binaryReadStreamDo: [ :s | 
		| fixedStram |
		fixedStram := s contents readStream.
		fixedStram isZipArchive
			ifTrue: [ | ar |
				fixedStram binary.
				ar := ZipArchive new readFrom: fixedStram.
				result := [aArchiveBlock value: ar]
					ensure: [ar close]]].
	^result
]

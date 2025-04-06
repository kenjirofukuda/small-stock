Class {
	#name : 'GplHandler',
	#superclass : 'GdsObject',
	#instVars : [
		'evaluator'
	],
	#category : 'GdsFeel-CLI-Handler',
	#package : 'GdsFeel-CLI',
	#tag : 'Handler'
}

{ #category : 'testing' }
GplHandler class >> checkFunctionAllowed: aCommandName [
	"aCommandName = 'SETVIEW' ifTrue: [ self halt. ]."

	| clazz target |
	clazz := self lookupHandlerClass: aCommandName.
	target := clazz ifNil: [ self ] ifNotNil: [ clazz ].
	(target respondsTo: #isFunctionAllowed)
		ifTrue: [ ^ target perform: #isFunctionAllowed ].
	clazz notNil
		ifTrue: [ ^ target perform: #isFunctionAllowed: with: aCommandName ].
	^ false
]

{ #category : 'testing' }
GplHandler class >> checkNiladicAllowed: aCommandName [
	^ self valueTestFor: aCommandName selector: #isNiladicAllowed
]

{ #category : 'accessing' }
GplHandler class >> commandNames [
	^ self
		flattendArray: (self subclasses collect: [ :clazz | clazz commandNames ])
]

{ #category : 'fixFlattenNotFoundPharo20' }
GplHandler class >> flattenCollection: aCollection on: aStream [
	aCollection
		do: [ :each | 
			(each isCollection and: [ each isString not ])
				ifTrue: [ self flattenCollection: each on: aStream ]
				ifFalse: [ aStream nextPut: each ] ]
]

{ #category : 'fixFlattenNotFoundPharo20' }
GplHandler class >> flattendArray: aCollection [
	^ Array
		streamContents: [ :stream | self flattenCollection: aCollection on: stream ]
]

{ #category : 'instance creation' }
GplHandler class >> fromCommand: aCommandName evaluator: aGplEvaluator [
	| clazz |
	clazz := self lookupHandlerClass: aCommandName.
	clazz ifNil: [ ^ nil ].
	^ clazz new evaluator: aGplEvaluator
]

{ #category : 'testing' }
GplHandler class >> hasCommandName: aCommandName [
	"GplHandler hasCommandName: 'BOUNDARY'."

	^ (self lookupHandlerClass: aCommandName) isNil not
]

{ #category : 'testing' }
GplHandler class >> isFunctionAllowed: aCommandName [
	^ false
]

{ #category : 'testing' }
GplHandler class >> isNiladicAllowed: aCommandName [
	^ false
]

{ #category : 'testing' }
GplHandler class >> isVoid: aCommandName [
	(GplToken isBuiltinMethod: aCommandName)
		ifTrue: [ ^ false ].
	^ (self checkFunctionAllowed: aCommandName) not
]

{ #category : 'private' }
GplHandler class >> lookupHandlerClass: aCommandName [
	GplHandler subclasses
		do: [ :clazz | 
			| handlerClass |
			handlerClass := clazz lookupHandlerClass: aCommandName.
			handlerClass ifNotNil: [ ^ handlerClass ] ].
	^ nil
]

{ #category : 'accessing' }
GplHandler class >> methodName [
	^ ''
]

{ #category : 'accessing' }
GplHandler class >> methodNames [
	^ GplMultiHandler methodNames , GplSingleHandler methodNames
]

{ #category : 'testing' }
GplHandler class >> noArgReturnValueEnabled: aCommandName [
	^ (self checkFunctionAllowed: aCommandName)
		and: [ self checkNiladicAllowed: aCommandName ]
]

{ #category : 'testing' }
GplHandler class >> valueTestFor: aCommandName selector: aSelector [
	| clazz target |
	clazz := self lookupHandlerClass: aCommandName.
	target := clazz ifNil: [ self ] ifNotNil: [ clazz ].
	(clazz notNil and: [ aSelector numArgs = 1 ])
		ifTrue: [ ^ target perform: aSelector with: aCommandName ].
	^ false
]

{ #category : 'accessing' }
GplHandler class >> voidCommandNames [
	^ self commandNames select: [ :each | self isVoid: each ]
]

{ #category : 'handler' }
GplHandler >> biContextCall: aToken [
	^ (self isFunctionCall: aToken)
		ifTrue: [ self functionCall: aToken ]
		ifFalse: [ self procedureCall: aToken ]
]

{ #category : 'utility' }
GplHandler >> call: aGplStatement [
	^ evaluator evaluateLine: aGplStatement
]

{ #category : 'private' }
GplHandler >> checkStationInstances: aGdsStationUIs [
	aGdsStationUIs isEmpty
		ifTrue: [ ^ self error: 'STATION DOWN' ].
	aGdsStationUIs size >= 2
		ifTrue: [ ^ self error: 'DUPLICATE STATION ENVIRONMENT ERROR' ].
	aGdsStationUIs first model ifNil: [ ^ self error: 'STATION DOWN' ]
]

{ #category : 'accessing' }
GplHandler >> currentItem [
	| station |
	station := self station.
	station library ifNil: [ ^ self error: 'NO LIBRARY OPEN' ].
	station structure ifNil: [ ^ self error: 'NO STRUCTURE OPEN' ].
	^ station structure currentItem
]

{ #category : 'handler' }
GplHandler >> evaluateToken: aToken [
	
]

{ #category : 'initialize-release' }
GplHandler >> evaluator: aGplEvaluator [
	evaluator := aGplEvaluator
]

{ #category : 'utility' }
GplHandler >> findElementByKeyNumber: aKeyNumber [
	^ self structure liveElements
		detect: [ :el | el keyNumber = aKeyNumber ]
		ifNone: [ ^ self error: 'ELEMENT KEY NOT FOUND: ' , aKeyNumber asString ]
]

{ #category : 'utility' }
GplHandler >> floatVector: aFloatCollection [
	^ (aFloatCollection
		collect: [ :each | GdsFloating fromLiteral: each asString ]) asArray
]

{ #category : 'utility' }
GplHandler >> fullRedraw [
	self structureMorph invalidRect: self structureMorph bounds
]

{ #category : 'checker' }
GplHandler >> illigalCoordinate [
	^ self error: 'ILLIGAL COORDINATE VALUE'
]

{ #category : 'utility' }
GplHandler >> illigalKeyNumbers: errorKeys [
	errorKeys
		ifNotEmpty: [ ^ self
				error:
					'ILLIGAL KEYNUMBERS: '
						, ((errorKeys collect: [ :each | each asString ]) joinUsing: ' ') ]
]

{ #category : 'utility' }
GplHandler >> integerVector: aIntegerCollection [
	^ (aIntegerCollection
		collect: [ :each | GdsInteger fromLiteral: each asString ]) asArray
]

{ #category : 'testing' }
GplHandler >> isFunctionAllowed [
	^ self class isFunctionAllowed
]

{ #category : 'testing' }
GplHandler >> isFunctionCall: aToken [
	^ aToken leftTokens isEmpty not
]

{ #category : 'testing' }
GplHandler >> isNiladicAllowed [
	^ self class isNiladicAllowed
]

{ #category : 'utility' }
GplHandler >> keyNumbers: keyNumbers doWithElement: aKeyAndElementBlock [
	| element |
	keyNumbers
		do: [ :each | 
			element := [ self findElementByKeyNumber: each ]
				on: Error
				do: [ :ex | nil ].
			aKeyAndElementBlock value: each value: element ]
]

{ #category : 'accessing' }
GplHandler >> library [
	| station library |
	station := self station.
	library := station library.
	library ifNil: [ ^ self error: 'NO LIBRARY OPEN' ].
	^ library
]

{ #category : 'marking' }
GplHandler >> markByKeys: keyNumbers [
	| points errorKeys |
	points := OrderedCollection new.
	errorKeys := OrderedCollection new.
	self
		keyNumbers: keyNumbers
		doWithElement: [ :key :element | 
			element
				ifNil: [ errorKeys add: key ]
				ifNotNil: [ points add: element xy ] ].
	self illigalKeyNumbers: errorKeys.
	self markPoints: points asArray
]

{ #category : 'marking' }
GplHandler >> markPoints: aPoints [
	aPoints ifEmpty: [ ^ self ].
	self structureMorph setVisible: true forKey: #mark.
	aPoints do: [ :each | self structureMorph mark: each ].
	self structureMorph invalidRect: self structureMorph bounds
]

{ #category : 'accessing' }
GplHandler >> methodName [
	^ self class methodName
]

{ #category : 'checker' }
GplHandler >> mustBeCoordinatable: aGdsArray [
	(#('CHAR' 'LIST' 'NULL') includes: aGdsArray typeString)
		ifTrue: [ ^ self illigalCoordinate ]
]

{ #category : 'accessing' }
GplHandler >> mustStructureOpen [
	^ self currentItem
]

{ #category : 'checker' }
GplHandler >> mustbeString: aGplValue [
	aGplValue isCharVector
		ifFalse: [ ^ self error: 'ONLY SPECIFIED CHARACTER VECTOR' ]
]

{ #category : 'utility' }
GplHandler >> nullVector [
	^ GdsNull instance
]

{ #category : 'accessing' }
GplHandler >> requireLibraryOpend [
	| station |
	station := self station.
	station library ifNil: [ ^ self error: 'NO LIBRARY OPEN' ].
	^ self nullVector
]

{ #category : 'accessing' }
GplHandler >> station [
	evaluator console ifNotNil: [ ^ GdsStation default ].
	^ self stationUI model
]

{ #category : 'accessing' }
GplHandler >> stationUI [
	| instances |
	instances := self stationUIInstances.
	instances ifEmpty: [ ^ self error: 'STATION DOWN' ].
	self checkStationInstances: instances.
	^ instances first
]

{ #category : 'accessing' }
GplHandler >> stationUIClass [
	Smalltalk garbageCollect.
	^ Smalltalk at: #GdsStationUI ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GplHandler >> stationUIInstances [
	| clazz |
	clazz := self stationUIClass.
	clazz ifNil: [ ^ self error: 'GDSFEEL PACKAGE NOT INSTALLED' ].
	^ clazz noGarbageTargetInstances
]

{ #category : 'utility' }
GplHandler >> stringVector: aByteString [
	^ GdsString fromLiteral: '"' , aByteString , '"'
]

{ #category : 'utility' }
GplHandler >> strings: aByteStringCollection [
	^ self stringVector: (aByteStringCollection joinUsing: String cr)
]

{ #category : 'accessing' }
GplHandler >> structure [
	^ self station structure
]

{ #category : 'accessing' }
GplHandler >> structureMorph [
	| morph |
	evaluator console
		ifNotNil: [ :csl | 
			(Smalltalk at: #GdsConsoleMorph)
				ifNotNil: [ :clazz | 
					(clazz allInstances detect: [ :m | m model == csl ] ifNone: [ nil ])
						ifNotNil: [ :sv | morph := sv overlayMorph ] ] ].
	morph ifNotNil: [ ^ morph ].
	self stationUI
		ifNotNil: [ :ui | ^ ui findDeeplyA: GdsStructureEditorMorph ].
	^ nil
]

{ #category : 'accessing' }
GplHandler >> viewport [
	^ self structureMorph viewport
]

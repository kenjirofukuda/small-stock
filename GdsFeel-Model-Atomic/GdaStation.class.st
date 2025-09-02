Class {
	#name : #GdaStation,
	#superclass : #GdaModel,
	#instVars : [
		'library',
		'structure',
		'items'
	],
	#classVars : [
		'Default'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #'instance creation' }
GdaStation class >> default [

	^ Default ifNil: [ Default := GdaStation basicNew initialize ]
]

{ #category : #examples }
GdaStation class >> exampleSandBox [

	"GdsStation exampleSandBox."

	<example>
	| randomPointGenerator |
	randomPointGenerator := [ :size | size atRandom @ size atRandom ].
	self default ensureSandbox.
	self default currentItem ifNotNil: [ :item | 
		300 timesRepeat: [ 
			item
				putPathFrom: (randomPointGenerator value: 540)
				to: (randomPointGenerator value: 540) ] ].
	self default quit
]

{ #category : #'class initialization' }
GdaStation class >> initialize [

	"GdsStation initialize."

	Default := nil
]

{ #category : #'notification-constants' }
GdaStation class >> libraryDidChangeNotification [

	^ 'GdsStationLibraryDidChangeNotification'
]

{ #category : #'instance creation' }
GdaStation class >> new [

	^ self error: 'use: GdsStation default.'
]

{ #category : #'instance creation' }
GdaStation class >> openDefault [

	^ self new openDefault
]

{ #category : #'instance creation' }
GdaStation class >> quit [

	^ Default ifNotNil: [ Default quit ]
]

{ #category : #'notification-constants' }
GdaStation class >> structureDidChangeNotification [

	^ 'GdsStationStructureDidChangeNotification'
]

{ #category : #maintenance }
GdaStation >> garbageCollect [

	self structure ifNotNil: [ 
		^ self inform: 'Cannt garbageCollect: use structure' ].
	self library ifNotNil: [ 
		^ self inform: 'Cannt garbageCollect: use library' ].
	GdaStructure allInstancesDo: [ :s | s allDispose ].
	GdaLibrary allInstancesDo: [ :l | l allDispose ].
	3 timesRepeat: [ Smalltalk garbageCollect ]
]

{ #category : #initialization }
GdaStation >> initialize [

	super initialize.
	
]

{ #category : #'instance creation' }
GdaStation >> initlibNamed: name [

	^ self initlibNamed: name databaseUnits: 1000 unitString: 'M'
]

{ #category : #'instance creation' }
GdaStation >> initlibNamed: name databaseUnits: dbu unitString: unit [

	| lib |
	lib := GdaLibrary
		       initializeName: name
		       databaseUnits: dbu
		       unitString: unit.
	"lib ifNotNil: [ self changed: #openlibEnabled ]."
	^ lib
]

{ #category : #'instance creation' }
GdaStation >> initlibNamed: name unitString: unit [

	^ self initlibNamed: name databaseUnits: 1000 unitString: unit
]

{ #category : #testing }
GdaStation >> isStation [

	^ true
]

{ #category : #accessing }
GdaStation >> labelString [

	^ String streamContents: [ :s | 
		  s nextPutAll: 'GdsFeel: '.
		  self library ifNotNil: [ 
			  self library dirty ifTrue: [ s nextPutAll: '* ' ] ].
		  s nextPutAll: self labelStringAfter ]
]

{ #category : #accessing }
GdaStation >> labelStringAfter [

	self library ifNil: [ ^ 'NO LIBRARY OPEN' ].
	self structure ifNil: [ 
		^ '[{1}].NO STRUCTURE OPEN' format: { self library libName } ].
	^ '[{1}].[{2}]' format: { 
			  self library libName.
			  self structure name }
]

{ #category : #accessing }
GdaStation >> library [

	^ library
]

{ #category : #accessing }
GdaStation >> library: aGdsLibrary [

	aGdsLibrary ifNotNil: [ aGdsLibrary station: self ].
	library := aGdsLibrary
]

{ #category : #initialization }
GdaStation >> release [

	"self announcer unsubscribe: self."
	structure := nil.
	library := nil.
	super release
]

{ #category : #accessing }
GdaStation >> structure [

	^ structure
]

{ #category : #accessing }
GdaStation >> structure: aGdsStructure [

	structure := aGdsStructure
]

{ #category : #accessing }
GdaStation >> uniqueSandboxLibraryName [

	^ String streamContents: [ :s | 
		  s << 'SB'.
		  s << (Date today yyyymmdd copyReplaceAll: '-' with: '')
		  "s << (Time now print24 copyReplaceAll: ':' with: '')" ]
]

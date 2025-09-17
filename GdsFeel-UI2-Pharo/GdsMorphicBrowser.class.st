Class {
	#name : #GdsMorphicBrowser,
	#superclass : #Model,
	#instVars : [
		'inform',
		'structureListLindex',
		'structureListMorph',
		'structure',
		'structures',
		'elementListIndex',
		'elementListMorph',
		'structureViewMorph'
	],
	#category : #'GdsFeel-UI2-Pharo'
}

{ #category : #'initialize-release' }
GdsMorphicBrowser class >> openAsMorph [
	<script>
	self new openAsMorph
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> buildElementListMorph [
	^ PluggableListMorph 
			on: self 
			list: #elementList 
			selected: #elementListIndex 
			changeSelected: #elementListIndex: 
			menu: #elementListMenu:
		
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> buildStructureListMorph [
	^ PluggableListMorph 
			on: self 
			list: #structureList 
			selected: #structureListIndex 
			changeSelected: #structureListIndex: 
			menu: #structureListMenu:
		
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> buildStructureViewMorph [
	^ GdaStructureViewMorph new
	
]

{ #category : #accessing }
GdsMorphicBrowser >> elementList [
	structure ifNotNil: [ ^ structure elements ].
	^ #()
]

{ #category : #accessing }
GdsMorphicBrowser >> elementListIndex [
	^ elementListIndex
]

{ #category : #accessing }
GdsMorphicBrowser >> elementListIndex: anInteger [
	elementListIndex := anInteger.
	anInteger = 0 ifTrue: [ ^ self ].
	
	self changed: #elementListIndex:
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> elementListMenu: aMenu [
	"aMenu add:  'sort by Name'  action: #sortByName."
	"aMenu add:  'sort by Area' action: #sortByArea."
	^ aMenu
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> initialize [
	super initialize.
	inform := GdsInform sampleAtomicInstance.
	structureListLindex := 0.
	elementListIndex := 0.		
	structure := nil.

]

{ #category : #toolbuilder }
GdsMorphicBrowser >> labelString [
	^ String streamContents: [ :s |
		s nextPutAll: 'GdsFeel: '.
		inform library 
			ifNotNil: [ :lib | s nextPutAll: lib name ].
		structure 
			ifNotNil: [ :struc | 
				s nextPutAll: '/'.
				s nextPutAll: struc name ] ]
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> openAsMorph [
	"GdsMorphicBrowser new openAsMorph"
	| window |
	inform run.
	inform library autoAllocateLayerColors.
	self sortByArea.
	window := (SystemWindow labelled: 'GdsFeel') model: self.
	structureListMorph := self buildStructureListMorph.
	"structureListMorph autoDeselect: false."
	window addMorph: structureListMorph frame: (0@0 corner: 0.15@1.0). 

	elementListMorph := self buildElementListMorph.
	window addMorph: elementListMorph frame: (0.15@0 corner: 0.3@1.0). 
	
	structureViewMorph := self buildStructureViewMorph.
	window addMorph: structureViewMorph frame: (0.3@0 corner: 1.0@1.0). 
	
	window openInWorld.
	
]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> release [
	structureListLindex := nil.
	structureListMorph := nil.
	structure := nil.
	structures := nil.
	elementListIndex := nil.
	elementListMorph := nil.
	structureViewMorph := nil.	
	inform := nil.
	super release
]

{ #category : #actions }
GdsMorphicBrowser >> sortByArea [
	structures := inform library structures
		sorted: [ :a :b | 
			a dataExtentForElements area < b dataExtentForElements area ].
	self changed: #structureList.
]

{ #category : #actions }
GdsMorphicBrowser >> sortByName [
	structures := inform library structures
		sorted: [ :a :b | 
			a name < b name ].
	self changed: #structureList.		
]

{ #category : #accessing }
GdsMorphicBrowser >> structureList [

	^ structures collect: [ :each | each name ]
]

{ #category : #accessing }
GdsMorphicBrowser >> structureListIndex [
	^ structureListLindex
]

{ #category : #accessing }
GdsMorphicBrowser >> structureListIndex: anInteger [
	| structureName |
	structureListLindex := anInteger.
	(anInteger = 0 or: [anInteger > self structureList size ]) ifTrue: [ ^ self ].
	structureName :=self structureList at: anInteger.
	structure := inform library structureNamed: structureName.
	structureViewMorph structure: structure. 
	self changed: #structureListIndex.
	self changed: #elementList.
	self changed: #elementListIndex.
	self changed: #relabel.

]

{ #category : #'initialize-release' }
GdsMorphicBrowser >> structureListMenu: aMenu [
	aMenu add:  'sort by Name'  action: #sortByName.
	aMenu add:  'sort by Area' action: #sortByArea.
	^ aMenu
]

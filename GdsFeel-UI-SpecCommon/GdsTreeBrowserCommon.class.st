"
Common behavior of Spec1 and Spec2. 

Instance Variables
	specImpl:		<GdsTreeBrowser|GdsTreePresenter>
	structureSortBlock:		<BlockClsure>

"
Class {
	#name : #GdsTreeBrowserCommon,
	#superclass : #Object,
	#instVars : [
		'specImpl',
		'structureSortBlock'
	],
	#category : #'GdsFeel-UI-SpecCommon'
}

{ #category : #'*GdsFeel-UI-SpecCommon' }
GdsTreeBrowserCommon class >> allDispose [
	<script>
	Cursor wait
		showWhile: [ 
			GdsStation quit.
			GdsStation initialize.
			GdsLibrary allInstancesDo: [ :l | l allDispose ].
			GdsStructure allInstancesDo: [ :l | l allDispose ].
			10 timesRepeat: [ Smalltalk garbageCollect ] ].
	SmalltalkImage current informSpaceLeftAfterGarbageCollection
]

{ #category : #'*GdsFeel-UI-SpecCommon' }
GdsTreeBrowserCommon class >> gdsMenuOn: aBuilder [

	<worldMenu>
	self class environment at: #GdsTreeBrowser 
		ifPresent: [ :clazz | 
			(aBuilder item: #'Tree Browser (Spec 1)')
				action: [ clazz new openWithSpec ];
				parent: #GdsFeel;
				yourself ].
	self class environment at: #GdsTreePresenter 
		ifPresent: [ :clazz | 
			(aBuilder item: #'Tree Browser (Spec 2)')
				action: [ clazz open ];
				parent: #GdsFeel;
				yourself ].
	(aBuilder item: #'All Dispose')
		action: [ self allDispose ];
		parent: #GdsFeel.
	(aBuilder item: #'Repair sample data')
		action: [ self repairSampleData ];
		parent: #GdsFeel.
		
]

{ #category : #maintenance }
GdsTreeBrowserCommon class >> repairSampleData [
	self allDispose.
	GdsFeel loadExampleZippedDatabaseToLocalForce: true 
	
]

{ #category : #private }
GdsTreeBrowserCommon >> childrenFor: anItem [

	anItem isLibrary
		ifTrue: [ 
			^ anItem topStructures
			  	ifNotEmpty: [ :structures | 
				  	structures , (anItem structures select: [ :s | 
					 	s indirectReferencedStructureNames isEmpty and: [ 
						   (structures includes: s) not ] ]) ]
			  ifEmpty: [ anItem structures ] ].
	anItem isStructure ifTrue: [ ^ anItem subStructures ].
	^ #()
]

{ #category : #initialization }
GdsTreeBrowserCommon >> createAthensStructureView [
	^ (self class environment at: #GdsSceneView ifAbsent: [  ])
		ifNotNil: [ :clazz | clazz new ]
		ifNil: [  ]
]

{ #category : #initialization }
GdsTreeBrowserCommon >> createBalloonView [
	^ GdsStructureEditorMorph new
		defaultToolClass: GdsSelectTool;
		currentToolClass: GdsSelectTool;
		yourself
]

{ #category : #'menu building' }
GdsTreeBrowserCommon >> displayNameHandler: anItem [

	"self halt."

	anItem isLibrary
		ifTrue: [ ^ anItem name ].
	^ TextMorph new
		  contents: (anItem name asText
				   addAttribute:
					   ((anItem valueOfProperty: #visible ifAbsent: [ true ])
						    ifFalse: [ TextEmphasis struckOut ]
						    ifTrue: [ TextEmphasis normal ]);
				   yourself);
		  lock;
		  yourself
]

{ #category : #defaults }
GdsTreeBrowserCommon >> iconFor: anItem [

	| icon |
	icon := (Smalltalk ui icons iconNamed: (self iconKeyFor: anItem))
		        copy.
	anItem isStructure
		ifTrue: [ 
			(anItem valueOfProperty: #visible ifAbsent: [ true ]) 
				ifFalse: [ 
					icon := (icon asFormOfDepth: 32) dimmed: 0.5 ] ].
	^ icon
]

{ #category : #'ui building' }
GdsTreeBrowserCommon >> iconKeyFor: anItem [

	anItem isLibrary
		ifTrue: [ 
			(Smalltalk ui icons respondsTo: #mongoDatabaseIcon) ifTrue: [ 
				^ #mongoDatabaseIcon ].
		^ #databaseIcon ].
	^ #smallObjectsIcon
]

{ #category : #initialization }
GdsTreeBrowserCommon >> initialize [ 
	super initialize.
	structureSortBlock := [ :s1 :s2 | s1 name < s2 name ] asValueHolder.
	structureSortBlock whenChangedDo: [ specImpl updateTree ].
]

{ #category : #'ui building' }
GdsTreeBrowserCommon >> onWindowClosed [
	self station structure:nil.
	self station quit.
]

{ #category : #'action - selection independent' }
GdsTreeBrowserCommon >> openLibrary [

	| file |
	file := GdsFeelMorphic
		        chooseFullFileName: 'Choose GdsFeel Library File .DB'
		        patterns: #( '*.db' ).
	file ifNil: [ ^ self inform: 'Library open Canceld' ].
	file := file asFileReference.
	(GdsLibrary isLibraryFile: file) ifFalse: [
		^ self inform: ('<1p> is not a GdsFeel file' expandMacrosWith: file) ].
	Cursor wait showWhile: [ specImpl registerLibraryFile: file ]
]

{ #category : #'as yet unclassified' }
GdsTreeBrowserCommon >> preferedExtent [
	^ (GdsFeelMorphic actualScreenSize * 0.95) rounded
]

{ #category : #'action - selection independent' }
GdsTreeBrowserCommon >> sortByArea [
	self structureSortBlock: [ :s1 :s2 | s1 dataExtentForElements area > s2 dataExtentForElements area ]
]

{ #category : #'action - selection independent' }
GdsTreeBrowserCommon >> sortByName [
	self structureSortBlock: [ :s1 :s2 | s1 name < s2 name ]
]

{ #category : #accessing }
GdsTreeBrowserCommon >> specImpl [

	^ specImpl
]

{ #category : #accessing }
GdsTreeBrowserCommon >> specImpl: anObject [

	specImpl := anObject
]

{ #category : #accessing }
GdsTreeBrowserCommon >> station [ 
	^ GdsStation default
]

{ #category : #testing }
GdsTreeBrowserCommon >> structureHasChild: aGdsStructure [
	^ aGdsStructure isStructure and: [ aGdsStructure subStructures notEmpty ]
]

{ #category : #api }
GdsTreeBrowserCommon >> structureSortBlock [
	^ structureSortBlock value
]

{ #category : #api }
GdsTreeBrowserCommon >> structureSortBlock: aBlock [
	structureSortBlock value: aBlock
]

{ #category : #private }
GdsTreeBrowserCommon >> treeSelectedLibraryDo: aStructureBlock [ 
	specImpl treeSelectedContentsOfClass: GdsLibrary do: aStructureBlock 
]

{ #category : #private }
GdsTreeBrowserCommon >> treeSelectedStructureDo: aStructureBlock [ 
	specImpl treeSelectedContentsOfClass: GdsStructure do: aStructureBlock 
]

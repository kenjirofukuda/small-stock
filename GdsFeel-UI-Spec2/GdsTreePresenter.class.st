Class {
	#name : #GdsTreePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'menuBar',
		'tree',
		'visibleElementList',
		'inspectorView',
		'tabManager',
		'layers',
		'kinds',
		'statusBar',
		'structureSortBlock'
	],
	#category : #'GdsFeel-UI-Spec2'
}

{ #category : #initialization }
GdsTreePresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		  add: #menuBar height: self toolbarHeight;
		  add: (SpBoxLayout newHorizontal
				   add: #tree;
				   add: (SpBoxLayout newVertical
						    add: #visibleElementList;
						    add: #inspectorView;
						    yourself);
				   add: #tabManager;
				   add: (SpBoxLayout newVertical
						    add: #layers;
						    add: #kinds;
						    yourself);
				   yourself);
		  add: #statusBar height: self toolbarHeight;
		  yourself
]

{ #category : #examples }
GdsTreePresenter class >> open [
	<example>
	self new openWithSpec
]

{ #category : #private }
GdsTreePresenter >> childrenFor: anItem [

	(anItem isKindOf: GdsLibrary) 
		ifTrue: [ 
			^ anItem topStructures
			  	ifNotEmpty: [ :structures | 
				  	structures , (anItem structures select: [ :s | 
					 	s indirectReferencedStructureNames isEmpty and: [ 
						   (structures includes: s) not ] ]) ]
			  ifEmpty: [ anItem structures ] ].
	(anItem isKindOf: GdsStructure) ifTrue: [ ^ anItem subStructures ].
	^ #()
]

{ #category : #initialization }
GdsTreePresenter >> debugMenu [

	^ self newMenu addGroup: [ :aGroup | 
		  aGroup addItem: [ :anItem | 
			  anItem
				  name: 'inspect tree presenter';
				  "icon: (self iconNamed: #open);"
				  action: [ tree inspect ] ].
			aGroup addItem: [ :anItem | 
			  anItem
				  name: 'open example tree';
				  "icon: (self iconNamed: #open);"
				  action: [ self registerExampleTree ] ] ]
]

{ #category : #'menu building' }
GdsTreePresenter >> displayNameHandler: anItem [

	"self halt."

	(anItem isKindOf: GdsLibrary) 
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

{ #category : #initialization }
GdsTreePresenter >> fileMenu [

	^ self newMenu addGroup: [ :aGroup | 
		  aGroup addItem: [ :anItem | 
			  anItem
				  name: 'Open Ziped DB...';
				  icon: (self iconNamed: #open);
				  action: [ self openLibrary ] ] ]
]

{ #category : #defaults }
GdsTreePresenter >> iconFor: anItem [

	| icon |
	icon := (Smalltalk ui icons iconNamed: (self iconKeyFor: anItem))
		        copy.
	(anItem isKindOf: GdsStructure) 
		ifTrue: [ 
			(anItem valueOfProperty: #visible ifAbsent: [ true ]) 
				ifFalse: [ 
					icon := (icon asFormOfDepth: 32) dimmed: 0.5 ] ].
	^ icon
]

{ #category : #'ui building' }
GdsTreePresenter >> iconKeyFor: anItem [

	(anItem isKindOf: GdsLibrary) 
		ifTrue: [ 
			(Smalltalk ui icons respondsTo: #mongoDatabaseIcon) ifTrue: [ 
				^ #mongoDatabaseIcon ].
		^ #databaseIcon ].
	^ #smallObjectsIcon
]

{ #category : #initialization }
GdsTreePresenter >> initializeMenuBar [

	menuBar := self newMenuBar.
	menuBar addGroup: [ :group | "menuBar addKeybindingsTo: self"
		group addItem: [ :item | 
			item
				name: 'File';
				subMenu: self fileMenu ].
		group addItem: [ :item | 
			item
				name: 'Debug';
				subMenu: self debugMenu ] ]
]

{ #category : #initialization }
GdsTreePresenter >> initializePresenters [

	super initializePresenters.
	self initializeMenuBar.
	tree := self newTree.
	"self registerExampleTree ."
	structureSortBlock := [ :s1 :s2 | s1 name < s2 name ] asValueHolder.
	structureSortBlock whenChangedDo: [ tree update ].
	visibleElementList := self newMorph.
	visibleElementList morph: (BorderedMorph new
			 color: Color red;
			 yourself).
	inspectorView := self newMorph.
	inspectorView morph: (BorderedMorph new
			 color: Color green;
			 yourself).
	tabManager := self newMorph.
	tabManager morph: (BorderedMorph new
			 color: Color cyan;
			 yourself).
	layers := self newMorph.
	layers morph: (BorderedMorph new
			 color: Color yellow;
			 yourself).
	kinds := self newMorph.
	kinds morph: (BorderedMorph new
			 color: Color magenta;
			 yourself).
	statusBar := self newMorph.
	statusBar morph: (BorderedMorph new
			 color: Color gray;
			 yourself)
]

{ #category : #initialization }
GdsTreePresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'GDS';
		initialExtent: 800 @ 600
]

{ #category : #'action - selection independent' }
GdsTreePresenter >> openLibrary [
		| file |
	file := GdsFeelMorphic
		chooseFullFileName: 'Choose GdsFeel Library File .DB'
		extensions: #('db').
	file ifNil: [ ^ self inform: 'Library open Canceld' ].
	file := file asFileReference.
	(GdsLibrary isLibraryFile: file)
		ifFalse: [
			^ self inform: ('<1p> is not a GdsFeel file' expandMacrosWith: file) ].
	Cursor wait showWhile: [ self registerLibraryFile: file ]
]

{ #category : #'ui building' }
GdsTreePresenter >> registerExampleTree [
	tree := self newTree.
	tree roots: (Array with: SpPresenter).
	tree display: [ :aClass | aClass name ].
	tree children: [ :aClass | aClass subclasses ].
	tree displayIcon: [ :aClass | self iconNamed: #system ].
	self  update.
]

{ #category : #'ui building' }
GdsTreePresenter >> registerLibraryFile: aFileReference [

	| lib |
	lib := GdsLibrary fromFile: aFileReference.
	self station openLibrary: lib.

	"tree := self newTree."
	tree roots
		ifEmpty: [ tree roots: (Array with: lib) ]
		ifNotEmpty: [ tree roots: tree roots , (Array with: lib) ].

	"tabManager addTab: (self newTabForLibrary: lib)."
	self sortByName.
	tree children: [ :item | 
		(self childrenFor: item) sort: self structureSortBlock ].
	tree display: [ :item | item name "self displayNameHandler: item" ].
	tree displayIcon: [ :item | self iconFor: item ].
	"tree displayIcon: [ :item | self iconNamed: #system ]."
	self update
	"tree doubleClick: [ self handleDoubleClick ]."
	"tree menu: [ :m | self inspectionMenu: m ]."
	"tree whenSelectedItemChanged: [ :item | self treeChangeSelection: item ]"
]

{ #category : #sorting }
GdsTreePresenter >> sortByArea [
	self structureSortBlock: [ :s1 :s2 | s1 dataExtentForElements area > s2 dataExtentForElements area ]
]

{ #category : #sorting }
GdsTreePresenter >> sortByName [
	self structureSortBlock: [ :s1 :s2 | s1 name < s2 name ]
]

{ #category : #accessing }
GdsTreePresenter >> station [ 
	^ GdsStation default
]

{ #category : #accessing }
GdsTreePresenter >> structureSortBlock [
	^ structureSortBlock value
	
]

{ #category : #accessing }
GdsTreePresenter >> structureSortBlock: aBlock [
	structureSortBlock value: aBlock
]

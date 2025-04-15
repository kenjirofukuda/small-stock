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
		'delegate'
	],
	#category : #'GdsFeel-UI-Spec2'
}

{ #category : #layout }
GdsTreePresenter class >> defaultLayout [

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

{ #category : #layout }
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
	self new open
]

{ #category : #initialization }
GdsTreePresenter >> debugMenu [

	^ self newMenu addGroup: [ :aGroup | 
		  aGroup addItem: [ :anItem | 
			  anItem
				  name: 'inspect tree presenter';
				  "icon: (self iconNamed: #open);"
				  action: [ tree inspect ] ].
			 ]
]

{ #category : #initialization }
GdsTreePresenter >> fileMenu [

	^ self newMenu addGroup: [ :aGroup | 
		  aGroup addItem: [ :anItem | 
			  anItem
				  name: 'Open Ziped DB...';
				  icon: (self iconNamed: #open);
				  action: [ delegate openLibrary ] ] ]
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
	delegate := GdsTreeBrowserCommon new specImpl: self.
	GdsFeel loadExampleZippedDatabaseToLocal.
	self initializeMenuBar.
	tree := self newTree.
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
		initialExtent: delegate preferedExtent.
]

{ #category : #'ui building' }
GdsTreePresenter >> registerLibraryFile: aFileReference [

	| lib |
	lib := GdsLibrary fromFile: aFileReference.
	delegate station openLibrary: lib.

	"tree := self newTree."
	tree roots
		ifEmpty: [ tree roots: (Array with: lib) ]
		ifNotEmpty: [ tree roots: tree roots , (Array with: lib) ].

	"tabManager addTab: (self newTabForLibrary: lib)."
	delegate sortByName.
	tree children: [ :item | 
		(delegate childrenFor: item) sort: delegate structureSortBlock ].
	tree display: [ :item | delegate displayNameHandler: item ].
	tree displayIcon: [ :item | delegate iconFor: item ].
	"tree displayIcon: [ :item | self iconNamed: #system ]."
	self update
	"tree doubleClick: [ self handleDoubleClick ]."
	"tree menu: [ :m | self inspectionMenu: m ]."
	"tree whenSelectedItemChanged: [ :item | self treeChangeSelection: item ]"
]

{ #category : #accesing }
GdsTreePresenter >> tree [
	^ tree
]

{ #category : #accesing }
GdsTreePresenter >> updateTree [ 
	tree update
]

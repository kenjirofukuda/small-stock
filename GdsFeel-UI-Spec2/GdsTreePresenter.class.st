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
		'delegate',
		'structureView'
	],
	#category : #'GdsFeel-UI-Spec2'
}

{ #category : #layout }
GdsTreePresenter class >> defaultLayout [

	| infoWidth |
	infoWidth := 160.
	^ SpBoxLayout newVertical
		  add: #menuBar height: self toolbarHeight;
		  add: (SpBoxLayout newHorizontal
				   add: #tree width: infoWidth;
				   add: (SpBoxLayout newVertical
						    add: #visibleElementList;
						    add: #inspectorView;
						    yourself)
				   width: infoWidth;
				   add: #structureView;
				   add: (SpBoxLayout newVertical
						    add: #layers;
						    add: #kinds;
						    yourself)
				   width: infoWidth;
				   yourself);
		  add: #statusBar height: self toolbarHeight;
		  yourself
]

{ #category : #layout }
GdsTreePresenter class >> defaultSpec [

	^ self defaultLayout
]

{ #category : #examples }
GdsTreePresenter class >> open [

	<example>
	self new openWithSpec
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
	structureView := self newMorph.
	structureView morph: delegate createBalloonView.			
	tabManager := self newMorph.
	tabManager morph: (BorderedMorph new
			 color: Color blue;
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
	tree activateOnDoubleClick.
	tree whenActivatedDo: [ :aSelectionMode | self showAsNewTop ].
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

{ #category : #'action - tree' }
GdsTreePresenter >> showAsNewTop [

	delegate treeSelectedStructureDo: [ :structure | 
		| morph |
		morph := structureView morph.
		(morph isKindOf: GdsStructureViewMorph) ifFalse: [ 
			^ self inform: 'Can''t running show as new top on Athens' ].
		morph clearAllProxyMorphs.
		delegate station structure: structure.
		morph
			structure: structure;
			viewFit ]
]

{ #category : #accesing }
GdsTreePresenter >> tree [
	^ tree
]

{ #category : #private }
GdsTreePresenter >> treeSelectedContentsOfClass: aClass do: aContentsBlock [
	tree selectedItem ifNotNil: [ :item | 
		(item isKindOf: aClass) ifTrue: [ aContentsBlock value: item ] ]
]

{ #category : #accesing }
GdsTreePresenter >> updateTree [ 
	tree update
]

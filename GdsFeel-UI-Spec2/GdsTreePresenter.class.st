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
	| newInstance |
	newInstance := self new.
	newInstance perform: ((newInstance respondsTo: #open)
			 ifTrue: [ #open ]
			 ifFalse: [ #openWithSpec ])
]

{ #category : #private }
GdsTreePresenter >> clearUISelection [
	visibleElementList items: #().
	"elementList items: #()."
	"self clearInspector."
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

{ #category : #'action - tree' }
GdsTreePresenter >> duplicateStructure [
	delegate treeSelectedStructureDo: [ :struct | struct duplicate ].
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

{ #category : #private }
GdsTreePresenter >> handleActivatedStructureMorph: aGdsStructureEditorMorph [

	aGdsStructureEditorMorph structure
		ifNil: [ self clearUISelection ]
		ifNotNil: [ :s |
			"elementList items: s elements." "self activateElementInspectorInStructure: s." 
			visibleElementList items: aGdsStructureEditorMorph visibleElements ]
]

{ #category : #'ui building' }
GdsTreePresenter >> handleDoubleClick [
	delegate treeSelectedStructureDo: [ :structure | 
		^ 	Cursor wait 
				showWhile: [.
					self showAsNewTop] ].
	self inform: 'Empty Handler'
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
	visibleElementList := self newList.

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
			 yourself).

	GdsStation default announcer
		when: GdsStructureDuplicated
		do: [ :ann | 
			self revealStructure: ann structure.
			self showAsNewTop ]
]

{ #category : #initialization }
GdsTreePresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'GDS';
		initialExtent: delegate preferedExtent.
]

{ #category : #'menu building' }
GdsTreePresenter >> inspectionMenu: aMenu [
	tree selectedItem ifNil: [ ^ aMenu ].
	aMenu
		addGroup: [ :aGroup | 
			self libraryMenuOnGroup: aGroup.
			self structureMenuOnGroup: aGroup.
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Inspect';
						action: [ tree selectedItem inspect ] ] ].
	^ aMenu
]

{ #category : #'menu building' }
GdsTreePresenter >> libraryMenuOnGroup: aGroup [
	delegate
		treeSelectedLibraryDo: [ :library | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Add Structure...';
						action: [ self addStructure ] ].
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Allocate Layer colors';
						action: [ library autoAllocateLayerColors ] ].
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Expoprt as DXF';
						action: [ library fileOutDxfToDefault ] ].
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Expoprt as JSON';
						action: [ library fileOutJsonToDefault ] ].
			([ #GdsExportAsSVG asClass ]
				on: Error
				do: [ :ex | ex return: nil ])
				ifNotNil: [ :clazz | 
					aGroup
						addItem: [ :anItem | 
							anItem
								name: 'Expoprt as SVG';
								action: [ clazz new perform: #exportLibrary: with: library ] ] ] ]
]

{ #category : #'debugging-use-only' }
GdsTreePresenter >> nodeOfStructure: aGdsStructure [
	| rootItem dataSource path |
	"rootItem inspect."
	dataSource := tree adapter widget dataSource.
	rootItem := dataSource rootItem.
	path := dataSource pathOfItem: aGdsStructure root: rootItem.
	path ifEmpty: [ ^ nil ].
	^ dataSource itemAtPath: path.
]

{ #category : #'debugging-use-only' }
GdsTreePresenter >> nodes [
	| rootItem dataSource |
	"rootItem inspect."
	dataSource := tree adapter widget dataSource.
	rootItem := dataSource rootItem.
	^ rootItem.
	" allNodeMorphs collect: [ :m | m complexContents ] thenReject: #isNil"
]

{ #category : #'debugging-use-only' }
GdsTreePresenter >> pathOfStructure: aGdsStructure [
	| rootItem dataSource |
	"rootItem inspect."
	dataSource := tree adapter widget dataSource.
	rootItem := dataSource rootItem.
	^ dataSource pathOfItem: aGdsStructure root: rootItem
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

	"tree menu: [ :m | self inspectionMenu: m ]."
	tree contextMenu: [ self inspectionMenu: SpMenuPresenter new ].
	
	"tree whenSelectedItemChanged: [ :item | self treeChangeSelection: item ]"
	
	self update.

]

{ #category : #'debugging-use-only' }
GdsTreePresenter >> revealStructure: aGdsStructure [
	self update.
	(self pathOfStructure: aGdsStructure)
		ifNotEmpty: [ :path | 
			tree selectPath: path]
]

{ #category : #'action - tree' }
GdsTreePresenter >> saveStructure [
	delegate treeSelectedStructureDo: [ :struct | struct forceSave ].
]

{ #category : #'action - tree' }
GdsTreePresenter >> showAsNewTop [

	delegate treeSelectedStructureDo: [ :structure | 
		| morph |
		morph := structureView morph.
		(morph isKindOf: GdsStructureViewMorph) 
			ifFalse: [ 
				^ self inform: 'Can''t running show as new top on Athens' ].
		morph clearAllProxyMorphs.
		delegate station structure: structure.
		"TODO: implement"
		"kinds kinds: structure kinds."
		"structure kinds announcer
			when: GdsKindsChanged
			send: #redraw
			to: morph."
		"layers model: structure layers."
		"structure layers announcer
			when: GdsLayersChanged
			send: #redraw
			to: morph."
		"structure announcer
			when: GdsElementRemoved
			send: #updateTree
			to: tree."
		"morph structure ifNotNil: [ :prevStructure | 
			prevStructure kinds announcer unsubscribe: morph.
			prevStructure layers announcer unsubscribe: morph.
			prevStructure announcer unsubscribe: tree ]."

		morph
			structure: structure;
			viewFit.
		morph viewport announcer when: #viewTransformChanged do: [ 
			visibleElementList items: morph visibleElements.
			morph clearAllProxyMorphs ].
		self handleActivatedStructureMorph: morph ]
]

{ #category : #'menu building' }
GdsTreePresenter >> structureMenuOnGroup: aGroup [
	delegate
		treeSelectedStructureDo: [ :struct | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Show As New Top';
						action: [ self showAsNewTop ] ].
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'toggle visible';
						action: [ self toggleVisibleStructure ] ].
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Save';
						action: [ self saveStructure ] ].
					
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Duplicate';
						action: [ self duplicateStructure ] ].
					
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Export as DXF';
						action: [ self todo: 'self fileOutDxf' ] ].
			struct subStructures ifNotEmpty: [ self todo: 'self parentStructureMenuOn: aGroup' ] ]
]

{ #category : #'menu building' }
GdsTreePresenter >> todo: aString [
	^ self inform: 'TODO: ', aString
]

{ #category : #'menu building' }
GdsTreePresenter >> toggleVisibleStructure [
	delegate
		treeSelectedStructureDo: [ :structure | 
			| visibleState |
			visibleState := structure valueOfProperty: #visible ifAbsentPut: [ true ].
			structure setProperty: #visible toValue: visibleState not.
			self update ]
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

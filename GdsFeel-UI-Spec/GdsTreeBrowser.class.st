"
KLayout UI style editor.


GdsTreeBrowser open.


"
Class {
	#name : #GdsTreeBrowser,
	#superclass : #ComposablePresenter,
	#instVars : [
		'tree',
		'menu',
		'elementList',
		'visibleElementList',
		'inspectorMorph',
		'tabManager',
		'layers',
		'kinds',
		'delegate'
	],
	#category : #'GdsFeel-UI-Spec'
}

{ #category : #specs }
GdsTreeBrowser class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newColumn: [ :c | 
			c
				add: #menu height: self toolbarHeight + self toolbarBorderWidth;
				newRow: [ :r | 
					| infoWidth |
					infoWidth := 0.1.
					r add: #tree origin: 0 @ 0 corner: infoWidth @ 1.
					r addSplitter.
					r
						newColumn: [ :c2 | 
							c2 add: #visibleElementList origin: 0 @ 0 corner: 0 @ 0.5.
							c2 addSplitter.
							c2 add: #inspectorView origin: 0 @ 0.5 corner: 1 @ 1 ]
						origin: infoWidth @ 0
						corner: (infoWidth * 2) @ 1.
					"width: 200"
					r addSplitter.
					r
						add: #manager
						origin: (infoWidth * 2) @ 0
						corner: (1 - infoWidth) @ 1.
					r addSplitter.
					r
						newColumn: [ :c3 | 
							c3 add: #layers origin: 0 @ 0 corner: 0 @ 0.5.
							c3 addSplitter.
							c3 add: #kinds origin: 0 @ 0.5 corner: 1 @ 1 ]
						origin: (1 - infoWidth) @ 0
						corner: 1 @ 1 ] ];
		yourself
]

{ #category : #'instance creation' }
GdsTreeBrowser class >> open [
	<example>
	self new openWithSpec
]

{ #category : #constants }
GdsTreeBrowser class >> toolbarBorderWidth [
	^ 4
]

{ #category : #private }
GdsTreeBrowser >> activateElementInspectorInStructure: aGdsStructure [
	aGdsStructure idSelection elements
		ifNotEmpty: [ :elements | 
			elements size = 1
				ifTrue: [ self activateElementProperty: elements first ] ]
]

{ #category : #private }
GdsTreeBrowser >> activateElementProperty: aGdsElement [
	aGdsElement
		ifNotNil: [ 
			(aGdsElement respondsTo: #asMagritteMorph)
				ifTrue: [ 
					| m |
					m := (aGdsElement perform: #asMagritteMorph) morph.
					m hResizing: #spaceFill.
					m vResizing: #shrinkWrap.
					m layoutChanged.
					inspectorMorph scrollTarget: m.
					inspectorMorph layoutChanged ] ]
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> addReference [
	|  reply |
	self
		frontMostStructureEditorDo: [ :morph | 
			| strucName |
			strucName := morph privateChooseStructureName.
			strucName ifNil: [ ^ self ].
			morph
				currentToolClass: GdsClickTestTool
				userInfo: [ :points :tool :worldPoint | 
					reply := self privateClickReplyPoints: points tool: tool worldPoint: worldPoint.
					reply class = Point
						ifTrue: [ 
							self privateAddReferenceNamed2: strucName point: reply.
							tree updateTree.].
					reply = #continue
						ifFalse: [ tool finish ] ] ]
]

{ #category : #'action - selection independent' }
GdsTreeBrowser >> addSampleTab [
	tabManager addTab: self sampleTab
]

{ #category : #'action - tree' }
GdsTreeBrowser >> addStructure [
	| strucName ok default |
	strucName := nil.
	delegate station 
		newStructureNamed:  [
		ok := false.
		default := ''.
		[ok] 
			whileFalse: [
				strucName := UIManager default request: 'Enter structure:' initialAnswer: default . 
				strucName ifNil: [^self].
				strucName := GdsCompatibility default coerceStructureName: strucName.
				strucName = '' 
					ifTrue: [
						strucName := nil.
						ok := true.]
					ifFalse: [
						(delegate station library hasStructureName: strucName)
							ifTrue: [default := strucName]
							ifFalse: [ok := true]].].
		strucName]
	withActivate: false.
	tree updateTree.

]

{ #category : #initialization }
GdsTreeBrowser >> changeGrid [
	self treeActivatedStructureEditorDo: [ :m |
		m requestGridScale ]
]

{ #category : #initialization }
GdsTreeBrowser >> changeGridScale [
	self treeActivatedStructureEditorDo: [ :m |
		m requestGridDisplayMultiply.
		 ]
]

{ #category : #private }
GdsTreeBrowser >> changeTabSelection [
	self updateTitle.
	self selectedTabDo: [  ] ifNil: [ self clearUISelection. ].
	self frontMostStructureEditorDo: [ :morph | 
		self handleActivatedStructureMorph: morph ] 

]

{ #category : #private }
GdsTreeBrowser >> clearInspector [
	inspectorMorph
		scrollTarget:
			(inspectorMorph defaultScrollTarget
				color: Color transparent;
				yourself)
]

{ #category : #private }
GdsTreeBrowser >> clearUISelection [
	visibleElementList items: #().
	elementList items: #().
	self clearInspector.
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> clickTestTool [
	self frontMostStructureEditorDo: [ :morph | morph currentToolClass: GdsClickTestTool ]
]

{ #category : #'menu building' }
GdsTreeBrowser >> contextMenuActionWithTracking: aGdsTracking [

	| contextMenu |
	contextMenu := MenuPresenter new addGroup: [ :group | 
		aGdsTracking structureMorph class = GdsStructureEditorMorph 
			ifTrue: [ 
				aGdsTracking structureMorph idNotEmpty
					ifTrue: [ 
						self
					   	contextMenuForIdSelection: group
					   	tracking: aGdsTracking ] ].
		      self
			   	contextMenuForCommon: group
					tracking: aGdsTracking ].
	Cursor normal show.
	contextMenu openWithSpecAt: aGdsTracking event cursorPoint
]

{ #category : #'menu building' }
GdsTreeBrowser >> contextMenuForCommon: group tracking: aGdsTracking [
		               group addItem: [ :item | 
			               item
				               name: 'Clear markers';
				               action: [ aGdsTracking structureMorph clearMarker ] ].
		               group addItem: [ :item | 
			               item
				               name: 'Fit';
				               shortcut: $f command;
				               action: [ 
					               aGdsTracking structureMorph viewport viewFit ] ]
]

{ #category : #'menu building' }
GdsTreeBrowser >> contextMenuForIdSelection: group tracking: aGdsTracking [

	group addItem: [ :item | 
		item
			name: 'Fit selection' translated;
			action: [ 
				aGdsTracking structureMorph viewport viewBounds:
						aGdsTracking event handler structure dataExtentForIdElements ] ].
	group addItem: [ :item | 
		item
			name: 'Clear selection' translated;
			action: [ 
				aGdsTracking structureMorph structure idSelection idClear ] ].
	group addItem: [ :item | 
		item
			name: 'Inspect selection' translated;
			action: [ 
				| elements |
				elements := aGdsTracking structureMorph structure idSelection
					            elements.
				(elements size = 1
					 ifTrue: [ elements first ]
					 ifFalse: [ elements ]) inspect ] ].
	group addItem: [ :item | item name: '-' ].
	group addItem: [ :item | 
		item
			name: 'Delete' translated;
			action: [ 
				aGdsTracking structureMorph structure idSelection idDelete ] ]
]

{ #category : #initialization }
GdsTreeBrowser >> customMenu [
	"Answer the menu to be presented when the yellow button is pressed while the shift key is down"
	| menuSpec |
	menuSpec := (PragmaMenuBuilder pragmaKeyword: 'gdsStructureEditorMenu' model: self) menuSpec.
	menuSpec items ifEmpty: [ ^ self emptyMenu  ].
	^ MenuPresenter new fromSpec: menuSpec.
]

{ #category : #initialization }
GdsTreeBrowser >> debugMenu [
	^ MenuPresenter new
		autoRefresh: true;
		addGroup: [ :group | 
			self installToolOn: group specSelector: #toolSpecs.
			group
				addItem: [ :item | 
					item
						name: 'Mark element keys' translated;
						action: [ self markElementKeys ] ].
			group
				addItem: [ :item | 
					item
						name: 'Add Structure Reference' translated ;
						action: [ self addReference   ] ] .
			group
				addItem: [ :item | 
					item
						name: 'Selection to new structure';
						action: [ self idStructure  ] ] .
			group
				addItem: [ :item | 
					item
						name: 'Explode selection';
						action: [ self idExplode  ] ] .
					]
]

{ #category : #'action - tree' }
GdsTreeBrowser >> duplicateStructure [
	delegate treeSelectedStructureDo: [ :struct | struct duplicate ].
]

{ #category : #initialization }
GdsTreeBrowser >> editMenu [
	^ MenuPresenter new
		autoRefresh: true;
		addGroup: [ :group | 
			self installToolOn: group specSelector: #toolSpecs.
			group
				addItem: [ :item | 
					item
						name: 'Mark element keys' translated;
						action: [ self markElementKeys ] ].
			group
				addItem: [ :item | 
					item
						name: 'Add Structure Reference' translated ;
						action: [ self addReference   ] ] .
			group
				addItem: [ :item | 
					item
						name: 'Selection to new structure';
						action: [ self idStructure  ] ] .
					]
]

{ #category : #accessing }
GdsTreeBrowser >> elementList [
	^ elementList
]

{ #category : #initialization }
GdsTreeBrowser >> emptyMenu [
	^ MenuPresenter new 
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: 'Empty items';
						action: [ self inform: 'menu is empty' ] ] ]
]

{ #category : #initialization }
GdsTreeBrowser >> environmentMenu [
	^ MenuPresenter new
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: 'Grid';
						action: [ self changeGrid ] ].
			group
				addItem: [ :item | 
					item
						name: 'Grid Scale';
						action: [ self changeGridScale ] ].
					 ]
]

{ #category : #initialization }
GdsTreeBrowser >> fileMenu [

	^ MenuPresenter new addGroup: [ :group | 
		  group
			  addItem: [ :item | 
				  item
					  name: 'Open Ziped DB...';
					  icon: (self iconNamed: #open);
					  action: [ delegate openLibrary ] ];
			  addItem: [ :item | 
				  item
					  name: 'New Library...';
					  action: [ self newLibrary ] ] ]
]

{ #category : #'action - tree' }
GdsTreeBrowser >> fileOutDxf [
	delegate treeSelectedStructureDo: [ :struct | struct fileOutDxfToDefault ].
]

{ #category : #private }
GdsTreeBrowser >> frontMostStructureEditorDo: aMorphBlock [
	self selectedTabDo: [ :morph | 
			morph class = GdsStructureEditorMorph
				ifTrue: [ aMorphBlock value: morph ] ]
]

{ #category : #private }
GdsTreeBrowser >> handleActivatedStructureMorph: aGdsStructureEditorMorph [
	aGdsStructureEditorMorph structure
		ifNil: [ self clearUISelection ]
		ifNotNil: [ :s | 
			elementList items: s elements.
			self activateElementInspectorInStructure: s.
			visibleElementList items: aGdsStructureEditorMorph visibleElements ]
]

{ #category : #private }
GdsTreeBrowser >> handleDoubleClick [
	delegate treeSelectedStructureDo: [ :structure | 
		^ 	Cursor wait 
				showWhile: [.
					self showAsNewTop] ].
	self inform: 'Empty Handler'
]

{ #category : #'action - selection independent' }
GdsTreeBrowser >> idExplode [
	|    |
	self
		frontMostStructureEditorDo: [ :morph | 
			morph structure idExplode.
			tree updateTree ].
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> idStructure [
	| strucName  reply |
	self
		frontMostStructureEditorDo: [ :morph | 
			strucName := self requestStructureName.
			strucName ifNil: [ ^ self inform: 'Cancel''ed' ].
			morph
				currentToolClass: GdsClickTestTool
				userInfo: [ :points :tool :worldPoint |
					reply := self privateClickReplyPoints: points tool: tool worldPoint: worldPoint .
					reply class = Point 
						ifTrue: [
							morph structure idStructureNamed: strucName  origin: reply.
							tree updateTree ].
					(reply = #continue )
						ifFalse: [ tool finish ].
					 ]	]
]

{ #category : #initialization }
GdsTreeBrowser >> initialExtent [
	^ delegate preferedExtent
]

{ #category : #initialization }
GdsTreeBrowser >> initializeMenu [
	menu := self instantiate: MenuPresenter
]

{ #category : #initialization }
GdsTreeBrowser >> initializeMenuPresenter [
	menu
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: 'File';
						subMenu: self fileMenu ].
			group
				addItem: [ :item | 
					item
						name: 'Shape';
						subMenu: self shapeMenu ].
			group
				addItem: [ :item | 
					item
						name: 'Environment';
						subMenu: self environmentMenu ].
			group
			
				addItem: [ :item | 
					item
						autoRefresh: true;
						name: 'Debug';
						subMenu: self debugMenu ].
			group
				addItem: [ :item | 
					item
						name: 'Plugin';
						subMenu: self pluginMenu ].
			group
				addItem: [ :item | 
					item
						name: 'Custom';
						subMenu: self customMenu ] ]
]

{ #category : #initialization }
GdsTreeBrowser >> initializePresenter [
	super initializePresenter.
	GdsFeel loadExampleZippedDatabaseToLocal. 
	tabManager whenTabSelected: [ self changeTabSelection ].
	self initializeMenuPresenter.
	tree autoDeselection: false.
	{elementList.
	visibleElementList}
		do: [ :listModel | 
			listModel autoDeselect: false.
			listModel
				whenSelectedItemChanged: [ :el | el ifNotNil: [ el structure idSelection id: el keyNumber ] ] ].
	self whenWindowChanged: [ :w | w whenClosedDo: [ delegate onWindowClosed ] ].
	GdsStation default announcer
		when: GdsStructureDuplicated
		do: [ :ann | 
			self revealStructure: ann structure.
			self showAsNewTop ]
]

{ #category : #initialization }
GdsTreeBrowser >> initializeWidgets [
	"self instantiateModels: #(tree TreeModel menu MenuModel structure MorphicModel )"
	"@see: createBalloonView."
	delegate := GdsTreeBrowserCommon new specImpl: self.
	delegate station autoCloseLibrary: false.
	self initializeMenu.
	tree := self newTree.
	tabManager := self newTabManager.
	elementList := self newList.
	visibleElementList := self newList.	
	inspectorMorph := GeneralScrollPane new
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	inspectorMorph changeScrollerTableLayout.
	self clearInspector.
	layers := AlignmentMorph new asSpecAdapter.
	kinds := GdsKindsSpecView new.
	layers := GdsLayersSpecView new.
	
	"inspectorMorph layoutFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 1) offsets: (0 @ 25 corner: 0 @ 0))."
]

{ #category : #'menu building' }
GdsTreeBrowser >> inspectionMenu: aMenu [
	tree selectedItem ifNil: [ ^ self ].
	aMenu
		addGroup: [ :aGroup | 
			self libraryMenuOnGroup: aGroup.
			self structureMenuOnGroup: aGroup.
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Explore';
						action: [ tree selectedItem content inspect ] ] ]
]

{ #category : #accessing }
GdsTreeBrowser >> inspectorView [
	^ inspectorMorph asSpecAdapter
]

{ #category : #private }
GdsTreeBrowser >> installToolOn: aMenuGroupModel specSelector: specSelector [

	| userInfo |
	(self perform: specSelector) do: [ :toolSpec | 
		toolSpec isCollection ifTrue: [ 
			userInfo := nil.
			toolSpec size >= 2 ifTrue: [ 
				toolSpec size >= 3 ifTrue: [ userInfo := toolSpec third ].
				aMenuGroupModel addItem: [ :item | 
					item name: toolSpec first.
					item action: [ 
						self treeActivatedStructureEditorDo: [ :m | 
							m currentToolClass: toolSpec second userInfo: userInfo ] ] ] ] ] ]
]

{ #category : #accessing }
GdsTreeBrowser >> kinds [
	^ kinds
]

{ #category : #accessing }
GdsTreeBrowser >> layers [
	^ layers
]

{ #category : #'menu building' }
GdsTreeBrowser >> libraryMenuOnGroup: aGroup [
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

{ #category : #accessing }
GdsTreeBrowser >> manager [
	^ tabManager
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> markElementKeys [
	self
		frontMostStructureEditorDo: [ :m | 
			m markElementKeys ]
]

{ #category : #accessing }
GdsTreeBrowser >> menu [
	^ menu
]

{ #category : #'action - selection independent' }
GdsTreeBrowser >> newLibrary [
	"Gds"

	| name unit msg reply lib |
	name := GdsFeelMorphic requestLibraryName.
	name ifNil: [ ^ self ].
	unit := GdsFeelMorphic chooseUnit.
	unit ifNil: [ ^ self ].
	msg := 'initialize ok?
DB: {1}
UNIT: {2}'
		format:
			{name.
			unit}.
	reply := UIManager default confirm: msg orCancel: [ nil ].
	reply ifNil: [ ^ self ].
	reply
		ifFalse: [ ^ self ].
	lib := delegate station initlibNamed: name unitString: unit.
	lib
		ifNil: [ self inform: 'initialize failed' ]
		ifNotNil: [ 
			self
				inform:
					('{1}
initialized' format: {name}) ]
]

{ #category : #'ui building' }
GdsTreeBrowser >> newTabForLibrary: aGdsLibrary [
	| balloonView athensView |
	balloonView := delegate createBalloonView.
	self window announcer when: WindowResizing do: [:ann | balloonView inspectFastdrawing: ann].
	balloonView 
		bindKeyCombination: Character escape 
		toAction: [ 
			balloonView structure ifNotNil: [ :s | s idSelection idClear] ].
	balloonView contextMenu: [ :tracker | self contextMenuActionWithTracking: tracker ].
	athensView := delegate createAthensStructureView.
	athensView
		ifNotNil: [
			athensView setProperty: #library toValue: aGdsLibrary.
			athensView setProperty: #toggleView toValue: balloonView].
	
	balloonView setProperty: #library toValue: aGdsLibrary.
	balloonView setProperty: #toggleView toValue: athensView.
	^ self newTab
		closeable: false;
		label: (self tabNameForLibrary: aGdsLibrary);
		icon: (delegate iconFor: aGdsLibrary);
		contents: balloonView;
		yourself
]

{ #category : #'debugging-use-only' }
GdsTreeBrowser >> nodeOfStructure: aGdsStructure [
	^ self nodes detect: [ :node | node item == aGdsStructure ] ifNone: [  ]
]

{ #category : #'debugging-use-only' }
GdsTreeBrowser >> nodeOfStructureNamed: aStructureName [

	| lib |
	lib := GdsStation default library.
	^ self nodes
		  detect: [ :node | 
			  node item isStructure and: [ 
				  node item library == lib and: [ 
					  node name sameAs: aStructureName ] ] ]
		  ifNone: [  ]
]

{ #category : #'debugging-use-only' }
GdsTreeBrowser >> nodes [
	^ tree widget widget allNodeMorphs collect: [ :m | m complexContents ] thenReject: #isNil
]

{ #category : #'menu building' }
GdsTreeBrowser >> parentStructureMenuOn: aGroup [
	aGroup
		addItem: [ :anItem | 
			anItem
				name: 'Sort By Area';
				action: [ delegate sortByArea ] ].
	aGroup
		addItem: [ :anItem | 
			anItem
				name: 'Sort By Name';
				action: [ delegate sortByName ] ]
]

{ #category : #initialization }
GdsTreeBrowser >> pluginMenu [
	| classes |
	classes := GdsPlugin new enabledPluginClasses.
	classes ifEmpty: [ ^ self emptyMenu ].
	^ MenuPresenter new
		addGroup: [ :group | 
			classes
				do: [ :clazz | 
					| plugin |
					plugin := clazz new.
					group
						addItem: [ :item | 
							item
								name: plugin caption;
								action: [ plugin entryPoint ] ] ] ]
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> privateAddReferenceNamed2: aName point: aPoint [
	|  |
	self
		frontMostStructureEditorDo: [ :morph | 
			morph structure currentItem sref.
			morph structure currentItem structureName: aName .
			morph structure currentItem ce: aPoint.
			morph structure currentItem put. ]
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> privateAddReferenceNamed: aName point: aPoint [
	| el |
	self
		frontMostStructureEditorDo: [ :morph | 
			el := GdsStructureReference basicNew initialize.
			el structureName: aName.
			el vertices: (Array with: aPoint).
			morph structure addElement: el.
			morph structure pushDirtyReservedArea: el.
			el statusNumber: GdsElement inDatabaseStausNumber.
			morph structure comitDirty.
			morph structure markDirty.
			morph structure update: #dirty.
			morph structure update: #geometry.
			morph structure save: true.
			morph removeOffCanvas.
			morph changed ]
]

{ #category : #private }
GdsTreeBrowser >> privateClickReplyPoints: points tool: tool worldPoint: aWorldPoint [
	|  p pointExpr values|	
	points size >= 2
		ifTrue: [ 
			self inform: 'multiple selection '.
			^ #continue ].
	p := points ifEmpty: [ tool snapedWorldPoint2: aWorldPoint ] ifNotEmpty: [ points first ].
	pointExpr := p x asString , ' ', p y asString.
	self treeActivatedStructureEditorDo: [ :morph |
values := morph 
		privateExpInput: 
			'x y' 
				expandMacros
		defaults: pointExpr.
		 ]	.
			 
	values ifEmpty: [ 
		self inform: 'Cancel''ed'.
		^ #cancel ].
	^ values first @ values second

]

{ #category : #'action - selection independent' }
GdsTreeBrowser >> rebuildMenus [
	self initializeMenu.
	self initializeMenuPresenter.
]

{ #category : #'ui building' }
GdsTreeBrowser >> registerLibraryFile: aFileReference [

	| lib |
	lib := GdsLibrary fromFile: aFileReference.
	delegate station openLibrary: lib.
	tree roots
		ifEmpty: [ tree roots: (Array with: lib) ]
		ifNotEmpty: [ tree roots: tree roots , (Array with: lib) ].
	tabManager addTab: (self newTabForLibrary: lib).
	tree childrenBlock: [ :item | 
		(delegate childrenFor: item) sort: delegate structureSortBlock ].
	tree displayBlock: [ :item | delegate displayNameHandler: item ].
	tree iconBlock: [ :item | delegate iconFor: item ].
	tree doubleClick: [ self handleDoubleClick ].
	tree menu: [ :m | self inspectionMenu: m ].
	tree whenSelectedItemChanged: [ :item | 
		self treeChangeSelection: item ]
]

{ #category : #private }
GdsTreeBrowser >> requestStructureName [
	| strucName ok default |
	strucName := nil.
		ok := false.
		default := ''.
		[ok] 
			whileFalse: [
				strucName := UIManager default request: 'Enter structure:' initialAnswer: default . 
				strucName ifNil: [ ^ strucName].
				strucName := GdsCompatibility default coerceStructureName: strucName.
				strucName = '' 
					ifTrue: [
						strucName := nil.
						ok := true.]
					ifFalse: [
						(delegate station library hasStructureName: strucName)
							ifTrue: [default := strucName]
							ifFalse: [ok := true]].].
	^ strucName.

]

{ #category : #'debugging-use-only' }
GdsTreeBrowser >> revealStructure: aGdsStructure [
	tree updateTree.
	(self nodeOfStructure: aGdsStructure)
		ifNotNil: [ :foundNode | 
			foundNode selected: true.
			"foundNode nodeModel takeHighlight."
			tree selectedItem: foundNode nodeModel ]

]

{ #category : #'ui building' }
GdsTreeBrowser >> sampleTab [
	^ self newTab
		closeable: false;
		label: 'SampleTab';
		contents:
				(BorderedMorph new
						borderWidth: 5;
						borderColor: Color red;
						yourself);
		yourself
]

{ #category : #'action - tree' }
GdsTreeBrowser >> saveStructure [
	delegate treeSelectedStructureDo: [ :struct | struct forceSave ].
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> selectByWindow [
	self
		frontMostStructureEditorDo: [ :morph | 
			morph currentToolClass: GdsIdWindowTool userInfo: #idAdd:.
			self inform: 'idAdd' ]
]

{ #category : #private }
GdsTreeBrowser >> selectTab: aTabModel [
	tabManager widget widget selectTabAt: (tabManager tabs indexOf: aTabModel).
]

{ #category : #'action - front most structure' }
GdsTreeBrowser >> selectTool [
	self
		frontMostStructureEditorDo: [ :morph | 
			morph currentToolClass: GdsSelectTool.
			self inform: 'Select Tool' ]
]

{ #category : #enumerating }
GdsTreeBrowser >> selectedTabDo: tabBlock [ 
	self selectedTabDo: tabBlock ifNil: [ ]
]

{ #category : #enumerating }
GdsTreeBrowser >> selectedTabDo: tabBlock ifNil: emptyTabBlock [
	tabManager selectedTab
		ifNotNil: [ :tab | 
			tab contents
				ifNil: emptyTabBlock
				ifNotNil: [ :contents | tabBlock cull: contents ] ]
		ifNil: emptyTabBlock
]

{ #category : #initialization }
GdsTreeBrowser >> shapeMenu [
	^ MenuPresenter new
		autoRefresh: true;
		addGroup: [ :group | 
			self installToolOn: group specSelector: #shapeToolSpecs ].
]

{ #category : #private }
GdsTreeBrowser >> shapeToolSpecs [
	^ { 
	{ 'Point' . GdsDirectPointTool  }.
	{ 'Segment' . GdsDirectSegmentTool  }.
	{ 'Text' . GdsDirectBoxTextTool  }.
	{ 'Rectangle' . GdsDirectRectangleTool  }.
	 }
]

{ #category : #'action - tree' }
GdsTreeBrowser >> showAsNewTop [

	delegate treeSelectedStructureDo: [ :structure | 
		(self tabForStructure: structure) ifNotNil: [ :tab | 
			| morph |
			morph := tab contents.
			(morph isKindOf: GdsStructureViewMorph) ifFalse: [ 
				^ self inform: 'Can''t running show as new top on Athens' ].
			morph clearAllProxyMorphs.
			delegate station structure: structure.
			kinds kinds: structure kinds.
			structure kinds announcer
				when: GdsKindsChanged
				send: #redraw
				to: morph.
			layers model: structure layers.
			structure layers announcer
				when: GdsLayersChanged
				send: #redraw
				to: morph.
			structure announcer
				when: GdsElementRemoved
				send: #updateTree
				to: tree.
			morph structure ifNotNil: [ :prevStructure | 
				prevStructure kinds announcer unsubscribe: morph.
				prevStructure layers announcer unsubscribe: morph.
				prevStructure announcer unsubscribe: tree ].
			morph
				structure: structure;
				viewFit.
			morph viewport announcer when: #viewTransformChanged do: [ 
				visibleElementList items: tab contents visibleElements.
				morph clearAllProxyMorphs ].
			structure idSelection idsProerpty whenChangedDo: [ 
				self activateElementInspectorInStructure: structure ].
			self handleActivatedStructureMorph: morph.
			World defer: [ self selectTool ].
			self selectTab: tab ] ]
]

{ #category : #'menu building' }
GdsTreeBrowser >> structureMenuOnGroup: aGroup [
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
						name: 'toggle Athens/Balloon';
						action: [ self toggleAthensBallloon ] ].

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
						action: [ self fileOutDxf ] ].
			struct subStructures ifNotEmpty: [ self parentStructureMenuOn: aGroup ] ]
]

{ #category : #private }
GdsTreeBrowser >> tabForStructure: aGdsStructure [
	^ tabManager tabs
		detect: [ :tab | (tab contents valueOfProperty: #library ifAbsent: [  ]) = aGdsStructure library ]
		ifNone: [  ]
]

{ #category : #private }
GdsTreeBrowser >> tabNameForLibrary: aLibrary [
	^ aLibrary name , ' - ' , aLibrary file parent fullName
]

{ #category : #api }
GdsTreeBrowser >> title [
	^ self manager selectedTab ifNil: [ 'Gds Browser' ] ifNotNil: [ :tab | tab label ]
]

{ #category : #'action - tree' }
GdsTreeBrowser >> toggleAthensBallloon [
	delegate
		treeSelectedStructureDo: [ :structure | 
			(self tabForStructure: structure)
				ifNotNil: [ :tab | 
					| prevMorph nextMorph |
					prevMorph := tab contents.
					nextMorph := prevMorph.
					prevMorph class = GdsSceneView
						ifFalse: [ 
							nextMorph := prevMorph
								valueOfProperty: #toggleView
								ifAbsentPut: [ 
									(GdsAthensStructureDrawer openMorphWithStructure: prevMorph structure)
										setProperty: #toggleView toValue: prevMorph;
										yourself ].
							nextMorph valueOfProperty: #toggleView ifAbsentPut: [ prevMorph ] ]
						ifTrue: [ 
							prevMorph syncTransform.
							nextMorph := prevMorph valueOfProperty: #toggleView ].
					nextMorph structure: prevMorph structure.
					tab contents: nextMorph.
					nextMorph viewport updatePortBy: prevMorph viewport	"tab contents 
					model: structure;
					viewFit.
				self selectTab: tab." ] ]
]

{ #category : #'action - tree' }
GdsTreeBrowser >> toggleVisibleStructure [
	delegate
		treeSelectedStructureDo: [ :structure | 
			| visibleState |
			visibleState := structure valueOfProperty: #visible ifAbsentPut: [ true ].
			structure setProperty: #visible toValue: visibleState not.
			tree updateTree.
			(self tabForStructure: structure) ifNotNil: [ :tab | tab contents redraw ] ]
]

{ #category : #'menu building' }
GdsTreeBrowser >> toolSpecs [
	^ { 
	{ 'Select' . GdsSelectTool }.
	{ 'Click Test' . GdsClickTestTool }.
	 }
]

{ #category : #accessing }
GdsTreeBrowser >> tree [
	^ tree
]

{ #category : #'action - tree' }
GdsTreeBrowser >> treeActivatedStructureEditorDo: aBlock [
	delegate
		treeSelectedStructureDo: [ :structure | 
			(self tabForStructure: structure)
				ifNotNil: [ :tab | 
					| morph |
					morph := tab contents.
					(morph isKindOf: GdsStructureEditorMorph)
						ifTrue: [ aBlock value: morph ] ] ]
]

{ #category : #private }
GdsTreeBrowser >> treeChangeSelection: item [ 
	item ifNil: [ ^ self ].
	(item isKindOf: GdsLibrary) ifFalse: [ ^ self ].
	delegate station library: item
]

{ #category : #private }
GdsTreeBrowser >> treeSelectedContentsOfClass: aClass do: aContentsBlock [
	":aGdsStructure [:aTreeNodeItem]"

	tree selectedItem ifNil: [ ^ self ].
	(tree selectedItem content isKindOf: aClass)
		ifTrue: [ aContentsBlock cull: tree selectedItem content cull: tree selectedItem ]
]

{ #category : #accessing }
GdsTreeBrowser >> updateTree [
	tree updateTree
]

{ #category : #accessing }
GdsTreeBrowser >> visibleElementList [
	^ visibleElementList
]

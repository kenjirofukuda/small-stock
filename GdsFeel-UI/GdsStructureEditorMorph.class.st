"
A GdsStructureEditorMorph is GDSII structures editor view morph.

Instance Variables
	feedbackCanvas:	<FormCanvas>
	tool:						<GdsNullTool>
	lastSessionsGrid	<GdsGrid>
	markerPoints 		<Array<Point>>
	lastPoint 				<Point>

feedbackCanvas
	- xxxxx

tool
	- xxxxx

"
Class {
	#name : #GdsStructureEditorMorph,
	#superclass : #GdsStructureViewMorph,
	#instVars : [
		'tool',
		'feedbackCanvas',
		'markerPoints',
		'showsElementKey',
		'lastSessionsGrid',
		'lastPoint',
		'previewMap',
		'viewingCursorForm'
	],
	#category : #'GdsFeel-UI-Morph'
}

{ #category : #accessing }
GdsStructureEditorMorph class >> topmost [
	^ self allInstances last
]

{ #category : #accessing }
GdsStructureEditorMorph >> allLocationPanes [
	^{self locationPane . self deltaLocationPane . self referenceLocationPane }

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> blueButtonDown: anEvent [
	self inform: anEvent asString.
	super blueButtonDown: anEvent.
]

{ #category : #testing }
GdsStructureEditorMorph >> canGridDraw [
	^ (self fastDrawing not) and: [self viewport canGridDraw].
	
]

{ #category : #testing }
GdsStructureEditorMorph >> canGriddedCursor [
	^true.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> ceEnabled [
	self structure ifNil: [^false].
	self currentTool currentItem elementClass ifNil: [^false].
	((self currentTool currentItem isReferenceType) and: [self currentTool currentItem structureName isEmpty])
		ifTrue: [^false].
	^ true"self getElementEnabled."
]

{ #category : #initialization }
GdsStructureEditorMorph >> changeCursorToCross [
	self cursorForm: Cursor crossHair asCursorForm.
]

{ #category : #initialization }
GdsStructureEditorMorph >> changeCursorToViewing [
	self cursorForm: self viewingCursorForm.

]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> chooseLayer [
	| number |
	number := self privateChooseLayer.
	number ifNil:[^self].	
	self structure currentItem layerNumber: number.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> chooseLayerEnabled [
	self structure ifNil: [^false].
	^self structure currentItem layerEnabled.
]

{ #category : #label }
GdsStructureEditorMorph >> chooseLayerLabel [
	^self makeLabel: 'LAYER' withValue: self structure currentItem layerNumber.
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> choosePathType [
	| number |
	number := self privateChoosePathType.
	number ifNil:[^self].	
	self structure currentItem pathtype: number.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> choosePathTypeEnabled [
	self structure ifNil: [^false].
	^self structure currentItem pathTypeEnabled.
]

{ #category : #label }
GdsStructureEditorMorph >> choosePathTypeLabel [
	^self makeLabel: 'PATHTYPE' withValue: self structure currentItem pathtype.
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> chooseStructureName [
	| sname  |
	sname := self privateChooseStructureName.
	sname ifNil:[^self].	
	self structure currentItem structureName: sname.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> chooseStructureNameEnabled [
	self structure ifNil: [ ^ false ].
	self referenceEnabledStructureNames ifEmpty: [ ^ false ].
	^ self structure currentItem isReferenceType
]

{ #category : #label }
GdsStructureEditorMorph >> chooseStructureNameLabel [
	^self makeLabel: 'SNAME' withValue: self structure currentItem structureName.
]

{ #category : #accessing }
GdsStructureEditorMorph >> clearMarker [
	self setVisible: false forKey:  #mark.	
	markerPoints := nil.
	self showsElementKey: false.
	self changed.
]

{ #category : #tools }
GdsStructureEditorMorph >> clearTool [
	tool := nil.
]

{ #category : #accessing }
GdsStructureEditorMorph >> color: aColor [
	super color: aColor.
	(self allLocationPanes reject: [:each | each isNil])
		do: [:each | self setVisibleBorder: each ].

]

{ #category : #drawing }
GdsStructureEditorMorph >> colorForElement: aGdsElement [
	(#(inItem inId) includes: aGdsElement state) 
		ifTrue: [^ self visiblePickingColor].
	^ super colorForElement: aGdsElement

		
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> confirmWipe [
	| reply |
	reply := UIManager default confirm: 'Are you sure ?'.
	reply ifFalse: [^self].
	self structure currentItem wipe.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> confirmWipeEnabled [
	self structure ifNil: [^false].
	^self structure currentItem wipeEnabled.
]

{ #category : #initialization }
GdsStructureEditorMorph >> createLocationPane [
	| sm |
	sm := self locationPaneClass contents: ''.
	self setVisibleBorder: sm.
	sm font: GdsFeelMorphic locationCaptionFont.
	sm emphasis: ((GdsFeelMorphic borderedSensorDisplay) ifTrue: [0] ifFalse: [1]) .
	^sm
]

{ #category : #initialization }
GdsStructureEditorMorph >> createSensorLayer [
	| m sm |
	m := self layerForKey: #mouse.
	m model: self.
	m clipSubmorphs: true.
	m setProperty: #cursorForm toValue: self createViewingCursorForm.
	
	"Realtime"
	sm := self createLocationPane. 
	m addMorph: sm.
 	m setProperty: #locationPane toValue: sm.

	"reference point"
	sm := self createLocationPane. 
	m addMorph: sm.
 	m setProperty: #referenceLocationPane toValue: sm.
	sm visible: false.
	
	"reference point"
	sm := self createLocationPane. 
	m addMorph: sm.
 	m setProperty: #deltaLocationPane toValue: sm.
	sm visible: false.
	
	^m
]

{ #category : #initialization }
GdsStructureEditorMorph >> createViewingCursorForm [
	^(CursorWithMask derivedFrom: GdsFeelMorphic createViewingBaseForm ) asCursorForm .
	
]

{ #category : #initialization }
GdsStructureEditorMorph >> createViewport [
	| vp |
	vp := super createViewport.
	lastSessionsGrid ifNotNil: [vp grid: lastSessionsGrid].
	^vp
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> crossHandCursor [
	^self canGriddedCursor ifTrue: [Cursor blank] ifFalse: [Cursor crossHair].
]

{ #category : #tools }
GdsStructureEditorMorph >> currentTool [
	tool ifNil: [
		self currentToolClass: self defaultToolClass].
	^tool.
]

{ #category : #tools }
GdsStructureEditorMorph >> currentToolClass: aToolClass [
	self currentToolClass: aToolClass userInfo: nil.
]

{ #category : #tools }
GdsStructureEditorMorph >> currentToolClass: aToolClass userInfo: aObject [
	tool := aToolClass new setMorph: self.
	tool userInfo: aObject.
	tool toolDidChange.
	tool changeCursor.
]

{ #category : #initialization }
GdsStructureEditorMorph >> cursorForm [
	^self mouseLayer valueOfProperty: #cursorForm ifAbsent: [Cursor crossHair asCursorForm.].
]

{ #category : #initialization }
GdsStructureEditorMorph >> cursorForm: aForm [
	self mouseLayer setProperty: #cursorForm toValue: aForm.
	
]

{ #category : #defaults }
GdsStructureEditorMorph >> defaultToolClass [
	^ defaultToolClass ifNil: [ defaultToolClass := GdsNullTool ] 
]

{ #category : #tools }
GdsStructureEditorMorph >> defaultToolClass: aToolClass [
	defaultToolClass := aToolClass.
]

{ #category : #rubberband }
GdsStructureEditorMorph >> deltaLocationPane [
 	^self mouseLayer valueOfProperty: #deltaLocationPane ifAbsent: nil
 
]

{ #category : #drawing }
GdsStructureEditorMorph >> drawContentsOn: aCanvas [	
	"Dummy"	
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawElementKeysOn: aLocalCanvas [
	self 
		penColor: self visibleMarkerColor
		during: [
			self visibleElements do: [:e |
				self drawOn: aLocalCanvas text: e keyNumber asString at: e xy]].
	
	
]

{ #category : #drawing }
GdsStructureEditorMorph >> drawGridOn: aCanvas [
	| xSteps ySteps |
	self canGridDraw
		ifFalse: [^self].
	xSteps := self viewport lookupHorizontalGridSteps.
	ySteps := self viewport lookupVerticalGridSteps.
	(xSteps isEmpty and: [ySteps isEmpty])
		ifTrue: [^self].
	self 
		penColor: self gridColor
		during: [
			ySteps do: [:y |
				xSteps do: [:x |
					self drawOn: aCanvas pointAt: x@y]]].
		
	
]

{ #category : #'drawing-pluggable-block' }
GdsStructureEditorMorph >> drawGridOn: localCanvas layerMorph: morph [ 
	| gridOff |
	self viewport ifNil: [^self].
	self canGridDraw ifFalse: [^self].
	
	gridOff :=morph valueOfProperty: #gridOff ifAbsent: nil.
	gridOff 
		ifNil: [
			gridOff := FormCanvas extent: morph extent.
			self drawGridOn: gridOff.
			morph setProperty:  #gridOff toValue: gridOff].
	localCanvas paintImage: gridOff form at: 0@0.
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawIdFeedbackOn: aLocalCanvas [
	self 
		penColor: self visiblePickingColor
		during: [ 	
			self 
				drawOn: aLocalCanvas 
				elements: self structure idSelection elements
				drawingSelector: #strokeOutlineOn:.
	
				(self currentTool isNil not and: [self structure idSelection notEmpty]) 
					ifTrue: [
						self currentTool drawFeedbackOn: aLocalCanvas]].
	
	
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemFeedbackOn: aLocalCanvas [
	self 
		penColor: self visiblePickingColor
		during: [
			self 
				drawOn: aLocalCanvas 
				elements: self structure currentItem feedbackElements
				drawingSelector: #drawItemFeedbackOn:.
		
			self toolFeedbackEnabled 
				ifTrue: [
					self currentTool drawFeedbackOn: aLocalCanvas].

			self drawItemVertexNumbersOn: aLocalCanvas.]
	
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemLineSegmentsOn: aLocalCanvas [
	self drawItemLineSegmentsOn: aLocalCanvas width: 1
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemLineSegmentsOn: aLocalCanvas width: aWidth [
	self model currentItem vertices
	 ifNotEmpty: [: points |
		self drawOn: aLocalCanvas polyLineVertices: points  width: aWidth]
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemReferencesOn: aLocalCanvas [
	self model currentItem vertices
		ifNotEmpty: [ :points |
			points
				do: [:p |
					self drawOn: aLocalCanvas markDiamondPointAt: p.]].
	
	
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemVertexNumbersOn: aLocalCanvas [
	self drawItemVertexNumbersOn: aLocalCanvas zeroBased: false
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemVertexNumbersOn: aLocalCanvas zeroBased: aBoolean [
	| index points |
	index := aBoolean ifTrue: [0] ifFalse: [1].
	points := self model currentItem verticesWithoutClosePoint.
	(points size >= 2)
		ifTrue: [
			points
				do: [:p |
					| indexStr |
					indexStr := '({1})' format: {index}.
					self drawOn: aLocalCanvas text: indexStr at: p.
					index := index + 1]].
	
	
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawItemVerticesOn: aLocalCanvas [
	self model currentItem vertices
		ifNotEmpty: [ :points |
			self drawOn: aLocalCanvas markDiamondPointAt: points first.
			points allButFirst
				do: [:p |
					self drawOn: aLocalCanvas markPointAt: p]].
	
	
]

{ #category : #'drawing-feedback' }
GdsStructureEditorMorph >> drawMarksOn: aLocalCanvas [
	self 
		penColor: self visibleMarkerColor
		during: [
			self markerPoints do: [:each |
			self 
				drawOn: aLocalCanvas
				markDiamondPointAt: each ]]
]

{ #category : #drawing }
GdsStructureEditorMorph >> drawOffOn: aCanvas [ 
	| newFillImage |
	super drawOffOn: aCanvas.
	feedbackCanvas
		ifNotNil: [
			newFillImage := ColorForm 
				mappingWhiteToTransparentFrom: feedbackCanvas form 
				blackAsColor: self visiblePickingColor.
			aCanvas
				image: newFillImage form
				at: self pixelBounds origin
				sourceRect: newFillImage form boundingBox
				rule: Form paint]
]

{ #category : #drawing }
GdsStructureEditorMorph >> drawOn: aCanvas [
	| drawingBlock |
	self viewport ifNil: [^super drawOn: aCanvas].
	drawingBlock := [self drawInlineOn: aCanvas].
	self profileEnabled
		ifTrue: [
			Cursor wait 
				showWhile: [
					TimeProfiler spyAllOn: drawingBlock].
			self profileOff]
		ifFalse: [drawingBlock value].

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> enterArea: anEvent [
	self startStepping.
	GdsFeelMorphic useCustomCursor
		ifTrue: [ 
			self mouseLayer startStepping.
			ActiveHand showTemporaryCursor: self crossHandCursor ]
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> everyEnabled [
	^ true
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> exploreItem [
	self structure currentItem explore.
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> exportPictureBaseName [
	self structure ifNil: [^nil].
	^self structure name.
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> fileOutPicture [
	self exportPictureBaseName
		ifNotNil: [
			self fileOutPictureBaseNamed: self exportPictureBaseName]
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> fileOutPictureBaseNamed: aBaseName [
	self fileOutPictureBaseNamed: aBaseName intoDirectory: GdsFeel projectDirectory.
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> fileOutPictureBaseNamed: aBaseName intoDirectory: aDirectory [
	| fName  |
	fName := GdsFeel 
		directoryPath: aDirectory fullName nextNameFor: aBaseName extension:'png'. 
	PNGReadWriter putForm: self imageForm onFileNamed: (aDirectory / fName).
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> fileOutPictureEnabled [
	^self exportPictureBaseName isNil not

]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> fileOutPreview [
	self structure ifNil: [^nil].
	(self structure previewFile isFile)
		ifFalse: [^self privateFileOutPreview.].
	(self structure dirty)
		ifTrue: [^self privateFileOutPreview.].
		
	
	"Debug:
	(canvas form  magnifyBy: 0.25)  asMorph openInWorld."
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> getElementEnabled [
	self structure ifNil: [^false].
	^self structure currentItem getEnabled.
]

{ #category : #drawing }
GdsStructureEditorMorph >> gridColor [
	^self visibleGridColor.
	
	
]

{ #category : #accessing }
GdsStructureEditorMorph >> gridLayer [
	^(self layerForKey: #grid)
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> handleMouseDown: event [
	"event traceCr."
	^ super handleMouseDown: event
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> handleMouseOver: anEvent [
	"System level event handling."
	
	super handleMouseOver: anEvent.
	(self handlesMouseOver: anEvent) ifTrue:[
		anEvent wasHandled: true.
		self mouseOver: anEvent]
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> hideDrawingLayerDuring: aBlock [
	|  visibleStateMap   |
	"save layer state"
	visibleStateMap := Dictionary new.
	layerMap keysDo: [:each |
		visibleStateMap at: each put: (self layerForKey: each) visible.].

	"hide all layers"
	layerMap keysDo: [:each |
		self setVisible: false forKey: each.].
	
	aBlock value.
		
	"restore layer state"
	layerMap keysDo: [:each |
		self setVisible: (visibleStateMap at: each) forKey: each ].
	"Debug:
	(canvas form  magnifyBy: 0.25)  asMorph openInWorld."
]

{ #category : #rubberband }
GdsStructureEditorMorph >> hideLocationPane: aMorph [
	aMorph ifNil: [ ^ self ].
	aMorph contents: ''.
	aMorph visible: false.

]

{ #category : #rubberband }
GdsStructureEditorMorph >> hideRubberbandLocationPanes [
	{self deltaLocationPane . self referenceLocationPane }
		do: [:each | self hideLocationPane: each].

]

{ #category : #testing }
GdsStructureEditorMorph >> holdsElement [
	self structure ifNil: [^false].
	^self structure currentItem holdsElement.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> holdsPrimitive [
	^self holdsElement and: [self holdsReference not].
]

{ #category : #testing }
GdsStructureEditorMorph >> holdsReference [
	^self holdsElement and: [self structure currentItem elementClass isReference]
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> idClearEnabled [
	^self idNotEmpty
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> idDeleteEnabled [
	^self idNotEmpty
]

{ #category : #testing }
GdsStructureEditorMorph >> idNotEmpty [
	self structure ifNil: [^ false].
	self structure idSelection ifNil: [^ false] .	
	^self structure idSelection notEmpty.
]

{ #category : #initialization }
GdsStructureEditorMorph >> initialize [
	super initialize.
	self initializeLayers.
	self clearMarker.
	self borderWidth: 0.
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeContainerChooserLayer [
	self initializeLibraryChooserLayer.
	self initializeStructureChooserLayer. 
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeContentsLayer [
	| layer |
	layer := self layerForKey: #contents.
	layer setDrawOnBlock: [:localCanvas :morph |
		(self viewport isNil  or: [self structure isNil ]) 
			ifFalse: [self drawContentsOn: localCanvas]]
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeGridLayer [
	| layer |
	layer :=self layerForKey: #grid.
	layer setDrawOnBlock: [:localCanvas :morph |
		self drawGridOn:  localCanvas layerMorph: morph]
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeIdLayer [
	| layer |
	layer := self layerForKey: #id.
	layer setDrawOnBlock: [:localCanvas :morph |
		(self viewport isNil  or: [self structure isNil ]) 
			ifFalse: [self drawIdFeedbackOn: localCanvas]]
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeItemLayer [
	| layer |
	layer := self layerForKey: #item.
	layer setDrawOnBlock: [:localCanvas :morph |
		(self viewport isNil  or: [self structure isNil ]) 
			ifFalse: [self drawItemFeedbackOn: localCanvas]]
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeLayers [
	self initializeGridLayer.
	self initializeIdLayer.
	self initializeItemLayer.
	self initializeMarkLayer.
	GdsFeelMorphic useCustomCursor
		ifTrue: [ self initializeSensorLayer ].
	self initializeContainerChooserLayer
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeLibraryChooserLayer [
	| layer |
	layer :=self layerForKey: #libraryChooser.
	layer color: Color darkGray.
	self setupChooserLayout: layer.
	layer visible: true.
	"layer addMorphCentered: RectangleMorph new."

]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeMarkLayer [
	| layer |
	layer := self layerForKey: #mark.
	layer setDrawOnBlock: [:localCanvas :morph |
		(self viewport isNil  or: [self structure isNil ]) 
			ifFalse: [
				self showsElementKey 
					ifTrue: [self drawElementKeysOn: localCanvas].				
				self drawMarksOn: localCanvas]]
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeSensorLayer [
	| m |
	m := self createSensorLayer .

	m setDrawOnBlock: [:localCanvas :morph |
		self sensorDrawOn: localCanvas layerMorph:  morph].

	m setStepBlock: [:morph |
		self stepSensorLayerMorph: morph].

	m stepTime: 10.
	
]

{ #category : #initialization }
GdsStructureEditorMorph >> initializeStructureChooserLayer [
	| layer |
	layer :=self layerForKey: #structureChooser.
	layer color: Color lightBlue. 
	self setupChooserLayout: layer.
	layer visible: false.

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> isSimulateBlueButtonPressed: anEvent [
	anEvent yellowButtonPressed 
		ifFalse: [ ^ false ].
	Smalltalk os isMacOSX
		ifTrue: [ ^ anEvent commandKeyPressed  ].
	^ anEvent controlKeyPressed 	
	
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> itemDeleteVertexEnabled [
	self structure ifNil: [^false].
	self holdsReference
		ifTrue: [^false].
	self holdsPrimitive
		ifTrue: [^self structure currentItem vertexCount > self structure currentItem editElement class requiredVertexCount].
	^self structure currentItem isEmpty not.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> itemMoveEnabled [
	^self holdsElement.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> itemMovePointEnabled [
	^self holdsPrimitive.
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> itemReverse [
	self structure currentItem reverseVertices.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> itemReverseEnabled [
	self structure ifNil: [ ^ false ].
	^ self structure currentItem itemReverseEnabled
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> itemStretchEnabled [
	^self holdsPrimitive.
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> keyStroke: anEvent [
	GdsFeel ifDebugOn: [ :s | 
		s nextPutAll: anEvent asString].
	(self viewMoveHandled: anEvent) ifTrue: [self fireFirstdrawing . ^self].
	(self viewZoomHandled: anEvent) ifTrue: [self fireFirstdrawing . ^self].	
	(self viewFitHandled: anEvent) ifTrue: [self fireFirstdrawing . ^self].		
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> leaveArea: anEvent [
	ActiveHand showTemporaryCursor: nil.
	Cursor normal show.
	self stopStepping
]

{ #category : #initialization }
GdsStructureEditorMorph >> locationPane [
 	^self mouseLayer valueOfProperty: #locationPane ifAbsent: nil
 
]

{ #category : #initialization }
GdsStructureEditorMorph >> locationPaneClass [
	GdsFeelMorphic borderedSensorDisplay
		ifTrue: [^ Smalltalk at: #BorderedStringMorph ifAbsent: [StringMorph]].
	^StringMorph

]

{ #category : #utility }
GdsStructureEditorMorph >> makeLabel: aLabel withValue: aValueOrBlock [
	| optionalLabel |
	optionalLabel := aValueOrBlock value asString.
	optionalLabel ifEmpty: [^aLabel localizedGdsCaption].
	^String streamContents: [:stream |
		stream nextPutAll: aLabel localizedGdsCaption.
		self structure ifNotNil: [
			stream nextPutAll: ' ('.
			stream nextPutAll: optionalLabel.
			stream nextPutAll: ')']]
]

{ #category : #accessing }
GdsStructureEditorMorph >> mark: aPoint [
	markerPoints ifNil: [markerPoints := OrderedCollection new.].
	(markerPoints includes: aPoint)
		ifFalse: [
			markerPoints add: aPoint].
	self setVisible: true forKey:  #mark.
	
]

{ #category : #'as yet unclassified' }
GdsStructureEditorMorph >> markElementKeys [
	self setVisible: true forKey: #mark.
	self showsElementKey: true.
	self invalidRect: self bounds
]

{ #category : #utility }
GdsStructureEditorMorph >> markPoints: aPoints [
	aPoints ifEmpty: [^self].
	self setVisible: true forKey:  #mark.
	aPoints do: [:each |
		self mark: each.].
	self invalidRect: self bounds.
]

{ #category : #accessing }
GdsStructureEditorMorph >> markerPoints [
	markerPoints ifNil: [markerPoints := OrderedCollection new.].
	^markerPoints asArray.
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> mouseDown: anEvent [
	(self isNavigarionClick: anEvent)
		ifTrue: [ ^ super mouseDown: anEvent ].		 
	self currentTool mouseDown: anEvent.

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> mouseEnter: anEvent [
	super mouseEnter: anEvent.
	self handleEventsBySelf 
		ifFalse: [ ^  self ].
	GdsFeel ifDebugOn: [:s | 
		s nextPutAll: 'mouseEnter: ' .
		s nextPutAll: (anEvent printString)].
	self enterArea: anEvent.

]

{ #category : #accessing }
GdsStructureEditorMorph >> mouseLayer [
	^(self layerForKey: #mouse)
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> mouseLeave: anEvent [
	super mouseLeave: anEvent.
	self handleEventsBySelf 
		ifFalse: [ ^  self ].
	self leaveArea: anEvent.

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> mouseMove: anEvent [
	self trackingObject ifNil: [ self currentTool mouseMove: anEvent ].
	super mouseMove: anEvent.

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> mouseOver: anEvent [
	"self trackingObject ifNil: [" self currentTool mouseOver: anEvent " ]."

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> mouseUp: anEvent [
	self trackingObject ifNil: [ self currentTool mouseUp: anEvent ].
	super mouseUp: anEvent.

]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> openAsAthens [
	(Smalltalk at: #GdsAthensStructureDrawer ifAbsent: [ nil ])
		ifNotNil: [ :clazz |  | view |
			view := clazz openStructure: self structure .
			GdsStation default announcer on: GdsStructureClosed do: [ view delete. ]
			]
]

{ #category : #utility }
GdsStructureEditorMorph >> privateByteStringInput: aMessage defaults: aDefault [
	|  reply  ok |
	ok := false.
	reply := ''.
	[ok]
		whileFalse: 
			[reply := UIManager default request: aMessage initialAnswer: aDefault.
			reply isEmptyOrNil ifTrue: [^''].
			ok := reply isByteString].
	^reply asByteString.
]

{ #category : #private }
GdsStructureEditorMorph >> privateChooseLayer [
	| numbers layerLabels chooseIndex |
	numbers := GdsCompatibility default layerNumberRange asArray.
	layerLabels := numbers collect: [:number | ' ', number asString, ' '].
	chooseIndex := UIManager default chooseFrom: layerLabels.
	^chooseIndex = 0 
		ifTrue: [nil]		
		ifFalse: [numbers at: chooseIndex].
	
]

{ #category : #private }
GdsStructureEditorMorph >> privateChoosePathType [
	| numbers layerLabels chooseIndex |
	numbers := #(0 2).
	layerLabels := numbers collect: [:number | ' ', number asString, ' '].
	chooseIndex := UIManager default chooseFrom: layerLabels.
	^chooseIndex = 0 
		ifTrue: [nil]		
		ifFalse: [numbers at: chooseIndex].
	
]

{ #category : #private }
GdsStructureEditorMorph >> privateChooseStructureName [
	| snames chooseIndex |
	snames := self referenceEnabledStructureNames.
	chooseIndex := UIManager default chooseFrom: snames.
	^ chooseIndex = 0 
		ifTrue: [ nil ]
		ifFalse: [ snames at: chooseIndex ]
]

{ #category : #utility }
GdsStructureEditorMorph >> privateExpInput: aMessage defaults: aDefault [
	|  reply separatedItems values |
	reply := UIManager default request: aMessage initialAnswer: aDefault.
	reply ifNil: [^Array new].
	reply ifEmpty: [^Array new].
	separatedItems := reply findTokens: ' '.
	separatedItems ifEmpty: [^Array new].
	values :=  separatedItems  collect: [:each | Float readFrom: each ].
	^values asArray.
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> privateFileOutPreview [
	| previewFile canvas vp |
	self
		hideDrawingLayerDuring: [vp := self createViewport.
			vp viewFit.
			self pushViewport: vp.
			self removeOffCanvas.
			self changed.
			canvas := FormCanvas extent: self bounds extent.
			canvas
				translateBy: self bounds origin negated
				during: [:localCanvas | self drawOn: localCanvas].
			self popViewport.
			self removeOffCanvas.
			self changed.
			previewFile := self structure previewFile .
			previewFile ensureDelete.
			previewFile parent ensureDirectoryIf.
			PNGReadWriter putForm: canvas form onFileNamed: previewFile]
]

{ #category : #utility }
GdsStructureEditorMorph >> privateStringInput: aMessage defaults: aDefault [
	|  reply  ok |
	ok := false.
	reply := ''.
	[ok]
		whileFalse: 
			[reply := UIManager default request: aMessage initialAnswer: aDefault.
			reply isEmptyOrNil ifTrue: [^''].
			ok := reply isString].
	^reply asByteString.
]

{ #category : #drawing }
GdsStructureEditorMorph >> profileEnabled [
	^self valueOfProperty: #profileEnabled ifAbsent: [false]

]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> profileName [
	^GdsFeel 
		directoryPath: './' asFileReference fullName 
		nextNameFor: 'drawing_profile_'  ,self structure name  
		extension: 'log'
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> profileOff [
	self setProperty: #profileEnabled toValue: false.
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> profileOn [
	self setProperty: #profileEnabled toValue: true.
]

{ #category : #initialization }
GdsStructureEditorMorph >> referenceLocationPane [
 	^self mouseLayer valueOfProperty: #referenceLocationPane ifAbsent: nil
 
]

{ #category : #initialization }
GdsStructureEditorMorph >> release [
	tool := nil.
	feedbackCanvas := nil.
	lastSessionsGrid := nil.
	lastPoint := nil.
	previewMap := nil.
	viewingCursorForm := nil.
	super release.

]

{ #category : #private }
GdsStructureEditorMorph >> removeCachedCanvas [
	super  removeCachedCanvas.
	self removeGridCanvas.
]

{ #category : #drawing }
GdsStructureEditorMorph >> removeFeedbackCanvas [
	feedbackCanvas := nil.
]

{ #category : #drawing }
GdsStructureEditorMorph >> removeGridCanvas [
	self gridLayer setProperty: #gridOff toValue: nil. 
]

{ #category : #drawing }
GdsStructureEditorMorph >> removeOffCanvas [
	super removeOffCanvas.
	feedbackCanvas := nil.

]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestAngle [
	| angleExpr values |
	angleExpr := self structure currentItem angle asString.
	values :=self privateExpInput: 'Enter Angle in Degrees: ' defaults: angleExpr.
	values ifEmpty: [^self].
	self structure currentItem angle: values first.	
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> requestAngleEnabled [
	self structure ifNil: [^false].
	^self structure currentItem isReferenceType.
]

{ #category : #label }
GdsStructureEditorMorph >> requestAngleLabel [
	^self makeLabel: 'ANGLE' withValue: self structure currentItem angle.
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestArrayShape [
	|  ashapeExpr values |
	self structure currentItem ashapeInstalled ifFalse: [^self].
	ashapeExpr := self  structure currentItem ashape asRequestString.
	values :=self 
		privateExpInput: 
			'cols rows [colSpacing rowSpacing]' 
				expandMacros
		defaults: ashapeExpr.
	values ifEmpty: [^self].	
	(#(2 4) includes: values size) ifFalse: [^self].	
	values size = 2
		ifTrue: [
			| xStep yStep placeStructure |
			placeStructure := self  structure library structureNamed: self structure currentItem structureName.
			xStep := placeStructure dataExtentForElements  width.
			yStep := placeStructure dataExtentForElements height.
			values := values, {xStep . yStep}].			
	self  structure currentItem ashape values: values.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> requestArrayShapeEnabled [
	self structure ifNil: [^false].
	self structure currentItem ashapeInstalled ifFalse: [^false].
	^self structure currentItem elementType = #aref

]

{ #category : #label }
GdsStructureEditorMorph >> requestArrayShapeLabel [
	|ashape |
	ashape := self structure currentItem ashape.
	^self makeLabel: 'ASHAPE' withValue: ('{1}x{2}' format: {ashape columnCount . ashape rowCount}). 
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestEnterText [
	|reply default|
	default := self structure currentItem text.
	reply := self privateStringInput: 'Enter Text String:' defaults: default.
	reply ifEmpty: [^self].
	 self structure currentItem text: reply.
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestGridDisplayMultiply [
	|  scaleExpr values |
	scaleExpr := self  viewport grid displayMultiply asString.
	values :=self 
		privateExpInput: 
			'display multiply' 
				expandMacros
		defaults: scaleExpr.
	values ifEmpty: [^self].		
	self  viewport grid displayMultiply: values first.
]

{ #category : #label }
GdsStructureEditorMorph >> requestGridDisplayMultiplyLabel [
	^self makeLabel: 'GRID' withValue: self  viewport grid displayMultiply asString .
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestGridScale [
	|  scaleExpr values |
	scaleExpr := self  viewport grid asRequestString.
	values :=self 
		privateExpInput: 
			'xyScale<n>or<n>xScale yScale<n>or<n>xOffset yOffset xScale yScale' 
				expandMacros
		defaults: scaleExpr.
	values ifEmpty: [^self].		
	self  viewport grid values: values.
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> requestGridScaleEnabled [
	^true
]

{ #category : #label }
GdsStructureEditorMorph >> requestGridScaleLabel [
	^self makeLabel: 'GSCALE' withValue: self  viewport grid asRequestString .
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestMag [
	| magExpr values |
	magExpr := self structure currentItem mag asString.
	values := self privateExpInput: 'Enter Magnification: ' defaults: magExpr.
	values ifEmpty: [^self].			
	self structure currentItem mag: values first abs.	
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> requestMagEnabled [
	self structure ifNil: [^false].
	^self structure currentItem isReferenceType.
]

{ #category : #label }
GdsStructureEditorMorph >> requestMagLabel [
	^self makeLabel: 'MAG' withValue: self structure currentItem mag.
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> requestWidth [
	| widthExpr values |
	widthExpr := self structure currentItem width asString.
	values :=self privateExpInput: 'width:' defaults: widthExpr.
	values ifEmpty: [^self].			
	self structure currentItem width: values first abs.	
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> requestWidthEnabled [
	self structure ifNil: [^false].
	^self structure currentItem widthEnabled.
]

{ #category : #label }
GdsStructureEditorMorph >> requestWidthLabel [
	^self makeLabel: 'WIDTH' withValue: self structure currentItem width.
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> rubberbandPoint: aPoint [ 
	feedbackCanvas ifNil: 
		[ feedbackCanvas := FormCanvas 
			extent: self pixelBounds extent
			depth: 1 ].
	feedbackCanvas fillColor: Color white.

	self 
		penColor: Color black
		during: [
			self currentTool 
				drawRubberBandOn: feedbackCanvas
				currentPoint: aPoint].
				
	lastPoint := aPoint copy
]

{ #category : #'documentation-support' }
GdsStructureEditorMorph >> runProfile [
	self profileOn.
	self removeCachedCanvas.
	self changed.
	
]

{ #category : #'drawing-pluggable-block' }
GdsStructureEditorMorph >> sensorDrawOn: localCanvas layerMorph: morph [ 
	| p hvPoint cursorForm |
	self viewport ifNil: [^ self].
	p := morph valueOfProperty: #worldPoint ifAbsent: 0@0.

	hvPoint := self viewport xy2hv: p.
	cursorForm := self cursorForm.
	localCanvas 
		paintImage:  cursorForm 
		at: hvPoint + (cursorForm offset).
	
	"self locationPane ifNil: [^self]."
	"localCanvas 
		drawString: self locationPane 
		contents  at: (hvPoint + (50@50)) 
		font: nil 
		color: self visibleGridColor. "
				
	"self penColor: self visiblePenColor during: [
			self drawOn: localCanvas markDiamondPointAt: p ]".


]

{ #category : #initialization }
GdsStructureEditorMorph >> setVisibleBorder:  aStringMorph [
	aStringMorph color: self visibleLocationColor.
	(GdsFeelMorphic borderedSensorDisplay)
		ifTrue: [	
			aStringMorph 
				borderColor: (
					aStringMorph color = Color black 
						ifTrue: [Color white] ifFalse:[Color black])].
	
]

{ #category : #initialization }
GdsStructureEditorMorph >> setupChooserLayout: aMorph [
	aMorph changeTableLayout.
	aMorph minCellSize: 45@20.
	aMorph cellSpacing: 20.
	aMorph cellInset: 10.
	aMorph cellPositioning: #center.
	aMorph wrapCentering: #center.
	aMorph listCentering: #center.
	aMorph listDirection: #leftToRight.
	aMorph wrapDirection: #topToBottom.

]

{ #category : #'container chooser' }
GdsStructureEditorMorph >> setupLibraryChooser: aGdsStation [
	(self layerForKey: #libraryChooser)
		ifNotNil: [:chooserMorph |
			chooserMorph removeAllMorphs. 
			GdsLibrary baseNames
				do: [:each | | button|
					button := (PluggableButtonMorph new) 
						label: each ;
						model: aGdsStation;
						action: #openLibraryNamed:;
					 	arguments: (Array with: each);
						yourself.
					chooserMorph addMorphBack: button]].
	self setVisible: true forKey: #libraryChooser.
]

{ #category : #'container chooser' }
GdsStructureEditorMorph >> setupStructureChooser: aGdsStation [
	aGdsStation ifNil: [ ^self ].
	aGdsStation library ifNil: [^self].
	previewMap ifNil: [previewMap := Dictionary new.].
	(self layerForKey: #structureChooser)
		ifNotNil: [:chooserMorph |
			chooserMorph removeAllMorphs. 
			(aGdsStation library structureNames sort: [ :a :b | a < b ])
				do: [:each | | button cellMorph    |
					button := PluggableButtonMorph new label: each font: GdsFeelMorphic  controlCaptionFont .
					button model: aGdsStation.
					button action: #openStructureNamed:.
					button arguments: (Array with: each).
					cellMorph := button.
					"(previewMap includesKey: each)
						ifFalse: [
							struc := aGdsStation library structureNamed: each.
							imagePath := (struc fileDirectoryFoPreview) fullNameFor: 'preview.png'.
							(FileDirectory default fileExists: imagePath)
								ifTrue: [ 
									img := nil.
									[img := ImageReadWriter formFromFileNamed: imagePath] 
										on: Error do: [:ex | img := nil].
									img ifNotNil: [previewMap at: each put: img]]].
					img := previewMap at: each ifAbsent: [nil].
					img ifNotNil: [
						cellMorph := AlignmentMorph newColumn.
						cellMorph addMorphBack: (img magnifyBy: 0.125) asMorph.
						cellMorph addMorphBack: button]."							 
					chooserMorph addMorphBack: cellMorph]].
	self setVisible: true forKey: #structureChooser.
]

{ #category : #rubberband }
GdsStructureEditorMorph >> showLocationPane: aMorph at: aWorldPoint [ 
	self showLocationPane: aMorph at: aWorldPoint contents: nil.

]

{ #category : #rubberband }
GdsStructureEditorMorph >> showLocationPane: aMorph at: aWorldPoint contents: anObject [
	| loc text |
	self viewport ifNil: [ ^ self ].
	text := anObject
		ifNil: [ String
				streamContents: [ :s | 
					s nextPutAll: (aWorldPoint x printShowingDecimalPlaces: 3).
					s space.
					s nextPutAll: (aWorldPoint y printShowingDecimalPlaces: 3) ] ]
		ifNotNil: [ anObject asString ].	"printShowingDecimalPlaces: 3"
	aMorph contents: text.
	aMorph setProperty: #worldPoint toValue: aWorldPoint copy.
	loc := (self viewport xy2hv: aWorldPoint) + self bounds origin + 5 asPoint.
	aMorph position: loc.
	aMorph visible
		ifFalse: [ aMorph visible: true ]
]

{ #category : #testing }
GdsStructureEditorMorph >> showsElementKey [
	showsElementKey ifNil: [showsElementKey := false].
	^showsElementKey
]

{ #category : #accessing }
GdsStructureEditorMorph >> showsElementKey: aBoolean [
	showsElementKey := aBoolean.
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> step [
	| wp2 |
	self viewport ifNil: [ ^ self ].
	offCanvas ifNil: [ ^ self ].
	self handleEventsBySelf
		ifTrue: [ 
			(self bounds containsPoint: Sensor cursorPoint)
				ifTrue: [ 
					self activeHand keyboardFocus == self
						ifFalse: [ self activeHand newKeyboardFocus: self ] ].
			GdsFeelMorphic useCustomCursor
				ifTrue: [ self activeHand showTemporaryCursor: self crossHandCursor ] ].
	Sensor redButtonPressed
		ifTrue: [ ^ self ].
	wp2 := self viewport worldPointFromGlobal: Sensor cursorPoint.
	lastPoint ifNil: [ lastPoint := wp2 copy ].
	lastPoint = wp2
		ifTrue: [ ^ self ].
	self currentTool rubberBandEnabled
		ifTrue: [ self rubberbandPoint: wp2 ]
]

{ #category : #rubberband }
GdsStructureEditorMorph >> stepSensorLayerMorph: aMorph [
	| oldP p |
	self viewport ifNil: [^self].
	p := self viewport worldPointFromGlobal: Sensor cursorPoint.
	oldP := aMorph valueOfProperty: #worldPoint ifAbsent: 0@0. 
	oldP = p ifTrue: [^self].
	aMorph setProperty: #worldPoint toValue: p copy.
	self showLocationPane:  self locationPane at: p.
	self referenceLocationPane visible
		ifTrue: [
			self 
				showLocationPane:  self referenceLocationPane 
				at: (self referenceLocationPane valueOfProperty: #worldPoint).].
	false ifTrue: [^aMorph invalidRect: aMorph bounds].			
	aMorph invalidRect: (self updateBoundsFromPoint1: oldP point2: p).
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> stepTime [
	"| max |
	max := 100000.
	viewport ifNil: [^max].
	offCanvas ifNil:[^max]."
	^200.
]

{ #category : #'as yet unclassified' }
GdsStructureEditorMorph >> structureDidBind [
	viewport := self createViewport.			
	lastSessionsGrid ifNotNil: [viewport grid: lastSessionsGrid].

	GdsFeel dependentEnabled
		ifTrue: [
			viewport grid addDependent: self.
			self model layers addDependent: self.].
	
	self portStack add: viewport.							
	self startStepping.
	self mouseLayer startStepping.
	self setVisible: false forKey: #libraryChooser.
	self setVisible: false forKey: #structureChooser.
	self structure announcer when: GdsElementRemoved send: #redraw to: self.

]

{ #category : #'as yet unclassified' }
GdsStructureEditorMorph >> structureDidChanged [
	super structureDidChanged.
	self clearTool.
	self clearMarker.
	self changed: #fileOutPictureEnabled.

]

{ #category : #accessing }
GdsStructureEditorMorph >> structureDidUnbind [
	self viewport
		ifNotNil: [ lastSessionsGrid := self viewport grid copy.
			lastSessionsGrid removeDependent: self ].
	self releaseViewports.
	self stopStepping.
	self mouseLayer stopStepping.
	(Smalltalk at: #GdsStationUI ifAbsent: [  ])
		ifNotNil: [ :clazz | 
			(self ownerThatIsA: clazz)
				ifNotNil: [ :ui | 
					self setupStructureChooser: ui model.
					self setVisible: true forKey: #structureChooser ] ].
	self structure announcer unsubscribe: self
]

{ #category : #appearance }
GdsStructureEditorMorph >> toggleBackgroundColor [
	self color: (self visiblePenColor = Color black
		ifTrue:[Color black]
		ifFalse:[Color white]).
	self gridLayer invalidRect: self gridLayer bounds.
]

{ #category : #appearance }
GdsStructureEditorMorph >> toggleBackgroundColorEnabled [
	^true
]

{ #category : #'command-handler' }
GdsStructureEditorMorph >> toggleReflect [
	self structure currentItem toggleReflect
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> toggleReflectEnabled [
	self structure ifNil: [^false].
	^self structure currentItem isReferenceType.
]

{ #category : #label }
GdsStructureEditorMorph >> toggleReflectLabel [
	^self 
		makeLabel: 'REFL' 
		withValue: (self structure currentItem isReflected ifTrue: ['Y'] ifFalse: ['N']).
]

{ #category : #drawing }
GdsStructureEditorMorph >> toolFeedbackEnabled [
	^(self currentTool isNil not and: 
		[(self structure currentItem holdsElement) or: 
		[self structure currentItem vertices isEmpty not] ])
]

{ #category : #'testing-enabled' }
GdsStructureEditorMorph >> unIdEnabled [
	^self idNotEmpty
]

{ #category : #updating }
GdsStructureEditorMorph >> update: anObject [
	GdsFeel ifDebugOn: [:s |
		s nextPutAll:  self class printString.
		s nextPutAll: ' recieve: '.
		s nextPutAll: anObject printString.].
	(#(gridScale gridOffset gridDisplayMultiply) includes: anObject)
		ifTrue: [
			self removeGridCanvas.
			self changed: #requestGridScaleLabel.
			self changed: #requestGridDisplayMultiplyLabel.
			self changed].

	(anObject == #put)
		ifTrue: [
			self currentTool
				ifNotNil: [
					self currentTool autoFinishAfterPut 
						ifTrue: [
							self clearTool.
							self hideRubberbandLocationPanes]]].

	({ #geometry . #color . #idDelete . #layerState . #kindState} includes: anObject)
		ifTrue: [
			(anObject = #geometry) ifTrue: [self owner model changed: #relabel].
			self removeOffCanvas.
			^self changed].
	(anObject = #dirty)
		ifTrue: [self owner model changed: #relabel].
	^super update: anObject.
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> viewFitHandled: anEvent [
	| kc doFit |
	kc := anEvent keyCharacter.
	doFit := (kc caseOf: {
		[ Character home ] -> [ true].
	} otherwise: [ nil ]).
	doFit ifNil: [^false].
	self viewport viewFit.
	^true.		
]

{ #category : #'event handling' }
GdsStructureEditorMorph >> viewMoveHandled: anEvent [
	| kc fractionPoint |
	kc := anEvent keyCharacter.
	fractionPoint := (kc caseOf: {
		[ Character arrowDown ] -> [ 0.0 @ -0.2 ].
		[ Character arrowUp ] -> [ 0.0 @ 0.2 ].
		[ Character arrowLeft ] -> [ -0.2 @ 0.0 ].
		[ Character arrowRight ] -> [ 0.2 @ 0.0 ].
	} otherwise: [ nil ]).
	fractionPoint ifNil: [^false].
	self viewport viewMove: fractionPoint.
	^true.

]

{ #category : #'event handling' }
GdsStructureEditorMorph >> viewZoomHandled: anEvent [
	| kc zoomFactor |
	kc := anEvent keyCharacter.
	zoomFactor := (kc caseOf: {
		[ Character pageDown ] -> [ 0.75 ].
		[ Character pageUp ] -> [ 1.25 ].
	} otherwise: [ nil ]).
	zoomFactor ifNil: [^false].
	self viewport zoom: zoomFactor.
	^true.		
]

{ #category : #initialization }
GdsStructureEditorMorph >> viewingCursorForm [
	viewingCursorForm ifNil: [viewingCursorForm := self createViewingCursorForm ].
	^viewingCursorForm.
]

Class {
	#name : #GdsReferenceDrawer,
	#superclass : #GdsElementDrawer,
	#instVars : [
		'refStructure'
	],
	#category : 'GdsFeel-UI-Drawer'
}

{ #category : #testing }
GdsReferenceDrawer >> canDisplayExtent [
	^self subclassResponsibility
]

{ #category : #drawing }
GdsReferenceDrawer >> drawExtentOn: aCanvas [
	morph penColor: morph visiblePenColor during: [
		self strokeVerticesOn: aCanvas points: element dataOutlinePoints.]
]

{ #category : #drawing }
GdsReferenceDrawer >> drawItemFeedbackOn: aCanvas [
	self strokeOutlineOn: aCanvas.
	element ifNotNil: [
		morph drawOn: aCanvas markDiamondPointAt: element xy]

]

{ #category : #drawing }
GdsReferenceDrawer >> elementsDrawOn: aCanvas [
	self pushedPort: 
		[ self visibleElements do: 
			[ :each | 
			morph 
				drawOn: aCanvas
				element: each ] ]
]

{ #category : #drawing }
GdsReferenceDrawer >> fillOutlineOn: aCanvas [
	self pushedPort: [self privateFillOutlineOn: aCanvas] 
]

{ #category : #drawing }
GdsReferenceDrawer >> fullDrawOn: aCanvas [
	element state = #inStructure
		ifTrue: [ 
			self fillOutlineOn: aCanvas ]
		ifFalse: [
			self strokeOutlineOn: aCanvas].
	self optionalDrawOn: aCanvas.	

]

{ #category : #testing }
GdsReferenceDrawer >> isDrawable [
	^ true
]

{ #category : #drawing }
GdsReferenceDrawer >> optionalDrawOn: aCanvas [
	super optionalDrawOn: aCanvas.
	self canDisplayExtent 
		ifTrue: [self drawExtentOn: aCanvas].
]

{ #category : #private }
GdsReferenceDrawer >> privateFillOutlineOn: aCanvas [
	morph 
		drawLocalIgnoreItemOn: aCanvas 
		elements: self visibleElements 
		drawBlock: [ :canvas :el | 
			morph 
				drawOn: aCanvas
				element: el].
]

{ #category : #private }
GdsReferenceDrawer >> privateStrokeOutlineOn: aCanvas color: aColor [
	morph 
		drawLocalIgnoreItemOn: aCanvas 
		elements: self visibleElements 
		drawBlock: [ :canvas :el | 
			morph 
				strokeOn: aCanvas
				element: el 
				color: aColor].	
]

{ #category : #private }
GdsReferenceDrawer >> pushedPort: aBlock [
	self assert: element isNil not.
	morph viewport pushTransform: element transform during: aBlock.
]

{ #category : #accessing }
GdsReferenceDrawer >> refStructure [
	^ element refStructure
	"refStructure ifNil: [
		element ifNotNil: [
			refStructure := morph model library 
				structureNamed: element structureName.]].	
	^refStructure"
]

{ #category : #private }
GdsReferenceDrawer >> shallowStrokeOutlineOn: aCanvas color: aColor [
	morph 
		drawLocalIgnoreItemOn: aCanvas 
		elements: self visibleElements
		drawBlock: [ :canvas :el | 
			el isReference
				ifTrue: [
					morph penColor: aColor during: [
						morph drawOn: aCanvas strokeBounds: el dataBounds]]
				ifFalse: [
					morph 
						strokeOn: aCanvas
						element: el 
						color: aColor]].
				
]

{ #category : #drawing }
GdsReferenceDrawer >> strokeEachColorOutlineOn: aCanvas [
	self refStructure ifNil: [^self].
	self pushedPort: 
		[ self privateStrokeOutlineOn: aCanvas color: nil ]	
]

{ #category : #drawing }
GdsReferenceDrawer >> strokeOutlineOn: aCanvas [
	self strokeSolidColorOutlineOn: aCanvas.
]

{ #category : #drawing }
GdsReferenceDrawer >> strokeSolidColorOutlineOn: aCanvas [
	| color |
	self refStructure ifNil: [^self].
	color := nil.
	element
		ifNotNil: [color := morph colorForElement: element].
	self pushedPort: [
		 self shallowStrokeOutlineOn: aCanvas color: color]. 
]

{ #category : #drawing }
GdsReferenceDrawer >> visibleElements [
	^self refStructure elements select: [:each | 
		each isVisible and: [self isDrawableElement: each] ].
			
]

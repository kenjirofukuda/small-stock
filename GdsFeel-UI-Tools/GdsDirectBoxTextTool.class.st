Class {
	#name : #GdsDirectBoxTextTool,
	#superclass : #GdsQuickBoundsTool,
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsDirectBoxTextTool >> acceptBoundsAction: aRectangle [

	self putBoxText: aRectangle
]

{ #category : #drawing }
GdsDirectBoxTextTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [

	self
		drawRubberBandOn: aLocalCanvas
		currentPoint: aPoint
		boundsBlock: [ :bounds | 
			morph drawOn: aLocalCanvas strokeBounds: bounds.
			morph
				drawOn: aLocalCanvas
				fittingStrokeString: self currentItem text
				bounds: bounds ]
]

{ #category : #private }
GdsDirectBoxTextTool >> putBoxText: aRectangle [

	self currentItem boxtext.
	self currentItem ce: aRectangle origin.
	self currentItem ce: aRectangle corner.
	self currentItem put
]

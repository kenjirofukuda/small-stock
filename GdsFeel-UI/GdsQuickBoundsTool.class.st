Class {
	#name : 'GdsQuickBoundsTool',
	#superclass : 'GdsQuickPointsTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'action' }
GdsQuickBoundsTool >> acceptBoundsAction: aRectangle [
	self subclassResponsibility
]

{ #category : 'action' }
GdsQuickBoundsTool >> acceptFromPoint: aPoint1 toPoint: aPoint2 [
	| bounds |
	bounds := Rectangle encompassing: {  aPoint1.  aPoint2  }.
	self acceptBoundsAction: bounds.
	morph invalidBounds: bounds.
	morph redraw.
]

{ #category : 'drawing' }
GdsQuickBoundsTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [ 
	self
		drawRubberBandOn: aLocalCanvas
		currentPoint: aPoint
		boundsBlock: [:bounds | morph drawOn: aLocalCanvas strokeBounds: bounds]
	
]

{ #category : 'testing' }
GdsQuickBoundsTool >> isAcceptableBounds: aRectangle [
	^ aRectangle area ~= 0
]

{ #category : 'testing' }
GdsQuickBoundsTool >> isAcceptableFromPoint: aPoint1 toPoint: aPoint2 [
	| bounds |
	bounds := Rectangle encompassing: {  aPoint1.  aPoint2  }.
	^self isAcceptableBounds: bounds.
]

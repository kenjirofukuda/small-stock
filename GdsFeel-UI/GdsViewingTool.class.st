Class {
	#name : 'GdsViewingTool',
	#superclass : 'GdsQuickBoundsTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'as yet unclassified' }
GdsViewingTool >> acceptBoundsAction: aRectangle [
	morph viewport viewBounds: aRectangle.		
]

{ #category : 'as yet unclassified' }
GdsViewingTool >> changeCursor [
	morph changeCursorToViewing.
]

{ #category : 'as yet unclassified' }
GdsViewingTool >> isAcceptableBounds: aRectangle [
	| worldSize1 |
	worldSize1 := aRectangle width min: aRectangle height  .
	^ (morph viewport pixelSize: (worldSize1))  > 10
]

{ #category : 'as yet unclassified' }
GdsViewingTool >> rejectBoundsAction: aRectangle [
	morph viewport viewCenter: aRectangle center.
]

{ #category : 'as yet unclassified' }
GdsViewingTool >> rejectFromPoint: aPoint1 toPoint: aPoint2 [
	| bounds |
	bounds := Rectangle encompassing: {  aPoint1.  aPoint2  }.
	self rejectBoundsAction: bounds.
]

{ #category : 'as yet unclassified' }
GdsViewingTool >> samePointEnabled [
	^true
]

Class {
	#name : #GdsDirectPointTool,
	#superclass : #GdsQuickPointsTool,
	#category : #'GdsFeel-UI-ElementAddition'
}

{ #category : #'as yet unclassified' }
GdsDirectPointTool >> eventAction [
	| ce |
	ce := self snapedWorldPoint2.
	self currentItem putPoint: ce.
	morph invalidRect: (self markUpdateBounds: ce).
	
]

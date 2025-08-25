Class {
	#name : #GdsDirectPointTool,
	#superclass : #GdsQuickPointsTool,
	#category : #'GdsFeel-UI-ElementAddition'
}

{ #category : #action }
GdsDirectPointTool >> eventAction [
	| ce |
	ce := self snapedWorldPoint2.
	self currentItem putPoint: ce.
	morph invalidRect: (self markUpdateBounds: ce).
	
]

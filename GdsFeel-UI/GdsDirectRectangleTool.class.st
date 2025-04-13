Class {
	#name : #GdsDirectRectangleTool,
	#superclass : #GdsQuickBoundsTool,
	#category : 'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsDirectRectangleTool >> acceptBoundsAction: aRectangle [
	self putBoundary: aRectangle	
]

{ #category : #action }
GdsDirectRectangleTool >> putBoundary: aRectangle [
	self currentItem putRectangle: aRectangle.
	
]

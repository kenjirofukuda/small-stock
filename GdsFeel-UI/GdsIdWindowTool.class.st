Class {
	#name : 'GdsIdWindowTool',
	#superclass : 'GdsAbstractIdTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'drawing' }
GdsIdWindowTool >> drawFeedbackOn: aLocalCanvas [

]

{ #category : 'drawing' }
GdsIdWindowTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [ 
	self
		drawRubberBandOn: aLocalCanvas
		currentPoint: aPoint
		boundsBlock: [:bounds | morph drawOn: aLocalCanvas strokeBounds: bounds]
]

{ #category : 'action' }
GdsIdWindowTool >> evenAction [
	| bounds idElements |
	"TimeProfiler spyOn: ["
	referencePoint ifNil: [ ^ self ].
	lastPoint := self snapedWorldPoint2.
	lastPoint = referencePoint ifTrue: [ ^ self ].
	bounds := Rectangle encompassing: {  referencePoint. lastPoint  }.
	idElements := (self idEnabledElementsInverted: (self idSelecter = #unId:)) 
		select: [ :each | each dataBounds intersects: bounds ].
	idElements do: [:each |
		 self structure idSelection perform: self idSelecter with: each keyNumber].	
	morph removeFeedbackCanvas.
	referencePoint := nil.	"]"
]

{ #category : 'action' }
GdsIdWindowTool >> eventAction [
	self evenOddAction.

]

{ #category : 'action' }
GdsIdWindowTool >> firstAction [
	
]

{ #category : 'accessing' }
GdsIdWindowTool >> idSelecter [
	^userInfo
]

{ #category : 'action' }
GdsIdWindowTool >> oddAction [
	self  saveReferencePoint.
	
]

{ #category : 'testing' }
GdsIdWindowTool >> rubberBandEnabled [
	^true
]

Class {
	#name : #GdsIdTool,
	#superclass : #GdsAbstractIdTool,
	#category : 'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsIdTool >> eventActionAt: aWorldPoint elementId: aKeyNumber [
	morph structure idSelection perform: self idSelecter with: aKeyNumber.
	
]

{ #category : #accessing }
GdsIdTool >> findNearestElementByPoint: resultPoint [ 
	^ self structure 
		findNearestElementByPoint: resultPoint
		elements: (self idEnabledElementsInverted: self idSelecter = #unId:)
]

{ #category : #accessing }
GdsIdTool >> idSelecter [
	^userInfo
]

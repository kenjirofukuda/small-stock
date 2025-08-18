Class {
	#name : #GdsGetTool,
	#superclass : #GdsNullTool,
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsGetTool >> eventAction [
	self elementDetectAction.
	self finish. "one shot command".
	super eventAction.
	
]

{ #category : #action }
GdsGetTool >> eventActionAt: aWorldPoint element: aGdsElement [
	aGdsElement ifNotNil: [self currentItem get: aGdsElement ].
	GdsFeelMorphic debugFindElement 
		ifTrue: [
			aGdsElement ifNotNil: [(aGdsElement analisys: aWorldPoint) inspect]].		
]

{ #category : #'prompt message' }
GdsGetTool >> nearestPointMessage [
	^'Enter nearest point for element.'.
]

{ #category : #'event handling' }
GdsGetTool >> toolDidChange [
	self prompt: self nearestPointMessage.
]

Class {
	#name : 'GdsItemMoveTool',
	#superclass : 'GdsNullTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'action' }
GdsItemMoveTool >> afterSecondAction [
	self offsetAction: [
		self currentItem translate: self relativeOffset]
]

{ #category : 'prompt message' }
GdsItemMoveTool >> afterSecondMessage [
	^self moveToMessage. 
]

{ #category : 'testing' }
GdsItemMoveTool >> autoFinishAfterPut [
	^true
]

{ #category : 'testing' }
GdsItemMoveTool >> canFinish [
	self currentItem holdsElement ifFalse: [^true].
	^((self currentItem putEnabled) and: [lastPoint = self snapedWorldPoint2])

]

{ #category : 'drawing' }
GdsItemMoveTool >> drawFeedbackOn: aLocalCanvas [
	self markOffsetFeedbackOn: aLocalCanvas.
]

{ #category : 'action' }
GdsItemMoveTool >> eventAction [
	self firstAndSecondAction.
	super eventAction.
	"TODO: caluc update bounds"
	morph invalidRect: (morph bounds).

]

{ #category : 'action' }
GdsItemMoveTool >> firstAction [
	self saveReferencePoint.
]

{ #category : 'prompt message' }
GdsItemMoveTool >> firstMessage [
	^self referenceMessage.
]

{ #category : 'prompt message' }
GdsItemMoveTool >> moveToMessage [
	^'Coordinate to Move to:'.
]

{ #category : 'testing' }
GdsItemMoveTool >> rubberBandEnabled [
	^true.
]

{ #category : 'event handling' }
GdsItemMoveTool >> toolDidChange [
	self prompt: self referenceMessage.
]

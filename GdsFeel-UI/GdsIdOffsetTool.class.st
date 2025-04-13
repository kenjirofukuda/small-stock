Class {
	#name : #GdsIdOffsetTool,
	#superclass : #GdsAbstractIdTool,
	#category : 'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsIdOffsetTool >> afterSecondAction [
	self offsetAction: [
		self structure perform: self offsetOperation with: self relativeOffset]
]

{ #category : #'prompt message' }
GdsIdOffsetTool >> afterSecondMessage [
	^self offsetOperation = #idCopyOffset: 
		ifTrue: [self copyToMessage]
		ifFalse: [self moveToMessage]. 
]

{ #category : #'prompt message' }
GdsIdOffsetTool >> copyToMessage [
	^'Copy to: '.
]

{ #category : #drawing }
GdsIdOffsetTool >> drawFeedbackOn: aLocalCanvas [
	self markOffsetFeedbackOn: aLocalCanvas.
]

{ #category : #action }
GdsIdOffsetTool >> eventAction [
	self firstAndSecondAction.
	"TODO: caluc update bounds"
	morph invalidRect: (morph bounds).
	
]

{ #category : #action }
GdsIdOffsetTool >> firstAction [
	self saveReferencePoint.
]

{ #category : #'prompt message' }
GdsIdOffsetTool >> firstMessage [
	^self referenceMessage.
]

{ #category : #'prompt message' }
GdsIdOffsetTool >> moveToMessage [
	^'Move to: '.
]

{ #category : #accessing }
GdsIdOffsetTool >> offsetOperation [
	^userInfo
]

{ #category : #'prompt message' }
GdsIdOffsetTool >> toolDidChange [
	self prompt: self firstMessage .
]

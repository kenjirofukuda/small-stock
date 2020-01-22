Class {
	#name : #GdsQuickPointsTool,
	#superclass : #GdsNullTool,
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> acceptFromPoint: aPoint1 toPoint: aPoint2 [
	self subclassResponsibility.
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> evenAction [
	referencePoint ifNil: [ ^ self ].
	lastPoint := self snapedWorldPoint2.
	self samePointEnabled
		ifFalse: [
			lastPoint = referencePoint ifTrue: [ ^ self ]].

	(self isAcceptableFromPoint: referencePoint toPoint: lastPoint)  
		ifTrue: [
			self acceptFromPoint: referencePoint toPoint: lastPoint]
		ifFalse: [
			self rejectFromPoint: referencePoint toPoint: lastPoint].		
	morph removeFeedbackCanvas.
	referencePoint := nil.
	self prompt: 'Ce 1:'	
	
]

{ #category : #action }
GdsQuickPointsTool >> eventAction [
	self evenOddAction.
	morph redraw.
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> firstAction [
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> isAcceptableFromPoint: aPoint1 toPoint: aPoint2 [
	^aPoint1 ~= aPoint2.
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> oddAction [
	self  saveReferencePoint.
	self prompt: 'Ce 2:'	
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> rejectFromPoint: aPoint1 toPoint: aPoint2 [
	"self subclassResponsibility."
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> rubberBandEnabled [
	^true
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> samePointEnabled [
	^false
	
]

{ #category : #'as yet unclassified' }
GdsQuickPointsTool >> toolDidChange [
	self prompt: 'Ce 1:'
]

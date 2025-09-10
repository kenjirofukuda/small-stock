Class {
	#name : #GdsAbstractIdTool,
	#superclass : #GdsNullTool,
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #action }
GdsAbstractIdTool >> eventAction [

	self elementDetectAction.
	super eventAction.
	morph structure changedIdGroup
]

{ #category : #action }
GdsAbstractIdTool >> eventActionAt: aWorldPoint element: aGdsElement [

	| keyNumber |
	keyNumber := aGdsElement
		             ifNil: [ 0 ]
		             ifNotNil: [ aGdsElement keyNumber ].
	(keyNumber > 0 and: [ aGdsElement state = #inItem ])
		ifTrue: [ 
			Transcript
				cr;
				show: '*** WARNING *** can''t id select when in item.' ]
		ifFalse: [ self eventActionAt: aWorldPoint elementId: keyNumber ]
]

{ #category : #action }
GdsAbstractIdTool >> eventActionAt: aWorldPoint elementId: aKeyNumber [

	self subclassResponsibility
]

{ #category : #accessing }
GdsAbstractIdTool >> idEnabledElements [

	^ self idEnabledElementsInverted: false
]

{ #category : #accessing }
GdsAbstractIdTool >> idEnabledElementsInverted: aBoolean [

	| targetElements |
	targetElements := morph visibleElements.
	^ aBoolean
		  ifTrue: [ targetElements select: [ :each | each state = #inId ] ]
		  ifFalse: [ 
			  targetElements reject: [ :each | 
				  #( inId inItem ) includes: each state ] ]
]

{ #category : #'prompt message' }
GdsAbstractIdTool >> nearestPointMessage [

	^ 'Enter nearest point for element.'
]

{ #category : #'event handling' }
GdsAbstractIdTool >> toolDidChange [

	self prompt: self nearestPointMessage
]

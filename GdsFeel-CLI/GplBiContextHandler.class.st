Class {
	#name : #GplBiContextHandler,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Handler'
}

{ #category : #accessing }
GplBiContextHandler class >> functionNames [
	^ self methodNames
]

{ #category : #testing }
GplBiContextHandler class >> isFunctionAllowed [
	^ true
]

{ #category : #testing }
GplBiContextHandler class >> isFunctionAllowed: aCommandName [
	^ self isFunctionAllowed
]

{ #category : #accessing }
GplBiContextHandler class >> procedureNames [
	^ self methodNames
]

{ #category : #handler }
GplBiContextHandler >> evaluateToken: aToken [
	^ self biContextCall: aToken
]

{ #category : #handler }
GplBiContextHandler >> functionCall: aToken [
	self subclassResponsibility
]

{ #category : #handler }
GplBiContextHandler >> procedureCall: aToken [
	self subclassResponsibility
]

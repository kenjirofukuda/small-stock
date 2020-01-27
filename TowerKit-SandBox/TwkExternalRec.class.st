Class {
	#name : #TwkExternalRec,
	#superclass : #Object,
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkExternalRec class >> displaySelector [
	^ #label
]

{ #category : #'as yet unclassified' }
TwkExternalRec >> displayString [
	^ self perform: self class displaySelector
]

{ #category : #'as yet unclassified' }
TwkExternalRec >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self displayString printOn: aStream.
	aStream nextPut: $)
]

Class {
	#name : #GdxElement,
	#superclass : #GdxNode,
	#instVars : [
		'vertices',
		'keyNumber'
	],
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxElement >> accept: aGdxVisitor [ 
	self subclassResponsibility.
]

{ #category : #accessing }
GdxElement >> children [
	^ #() copy
]

{ #category : #accessing }
GdxElement >> keyNumber [
	^ keyNumber
]

{ #category : #accessing }
GdxElement >> keyNumber: anInteger [
	keyNumber := anInteger
]

{ #category : #printing }
GdxElement >> printOn: aStream [
	aStream nextPutAll: self typeString.
	aStream nextPut: $(.
	keyNumber ifNotNil: [ aStream nextPutAll: keyNumber asString ].
	self printSelfOn: aStream.
	aStream nextPut: $)
]

{ #category : #printing }
GdxElement >> printSelfOn: aStream [
]

{ #category : #accessing }
GdxElement >> typeString [
	^ 'UNKOWN'
]

{ #category : #accessing }
GdxElement >> vertices [
	^ vertices
]

{ #category : #accessing }
GdxElement >> vertices: aCollection [ 
	vertices := aCollection asArray
]

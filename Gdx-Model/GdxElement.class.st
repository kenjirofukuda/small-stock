Class {
	#name : #GdxElement,
	#superclass : #Object,
	#instVars : [
		'vertices'
	],
	#category : #'Gdx-Model'
}

{ #category : #printing }
GdxElement >> printOn: aStream [
	aStream nextPutAll: self typeString.
]

{ #category : #accessing }
GdxElement >> typeString [
	^ 'UNKOWN'
]

{ #category : #'as yet unclassified' }
GdxElement >> vertices [
	^ vertices
]

{ #category : #'as yet unclassified' }
GdxElement >> vertices: aCollection [ 
	vertices := aCollection asArray
]

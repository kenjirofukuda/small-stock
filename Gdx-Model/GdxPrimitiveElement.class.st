Class {
	#name : #GdxPrimitiveElement,
	#superclass : #GdxElement,
	#instVars : [
		'layerNumber'
	],
	#category : #'Gdx-Model'
}

{ #category : #accessing }
GdxPrimitiveElement >> layerNumber [
	^ layerNumber
]

{ #category : #accessing }
GdxPrimitiveElement >> layerNumber: anInteger [
	layerNumber := anInteger
]

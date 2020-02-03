Class {
	#name : #GdxBoundary,
	#superclass : #GdxPrimitiveElement,
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxBoundary >> accept: aGdxVisitor [ 
	aGdxVisitor visitBoundary: self
]

{ #category : #accessing }
GdxBoundary >> typeString [
	^ 'BOUNDARY'
]

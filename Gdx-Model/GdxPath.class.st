Class {
	#name : #GdxPath,
	#superclass : #GdxPrimitiveElement,
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxPath >> accept: aGdxVisitor [ 
	aGdxVisitor visitPath: self
]

{ #category : #accessing }
GdxPath >> typeString [
	^ 'PATH'
]

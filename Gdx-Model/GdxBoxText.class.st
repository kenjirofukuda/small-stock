Class {
	#name : #GdxBoxText,
	#superclass : #GdxPrimitiveElement,
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxBoxText >> accept: aGdxVisitor [ 
	aGdxVisitor visitBoxText: self
]

{ #category : #accessing }
GdxBoxText >> typeString [
	^ 'BOXTEXT'
]

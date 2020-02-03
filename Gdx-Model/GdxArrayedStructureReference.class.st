Class {
	#name : #GdxArrayedStructureReference,
	#superclass : #GdxStructureReference,
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxArrayedStructureReference >> accept: aGdxVisitor [ 
	aGdxVisitor visitAref: self
]

{ #category : #accessing }
GdxArrayedStructureReference >> typeString [
	^ 'AREF'
]

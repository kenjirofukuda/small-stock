Class {
	#name : #GdxStructureReference,
	#superclass : #GdxReferenceElement,
	#category : #'Gdx-Model'
}

{ #category : #visiting }
GdxStructureReference >> accept: aGdxVisitor [ 
	aGdxVisitor visitSref: self
]

{ #category : #accessing }
GdxStructureReference >> typeString [
	^ 'SREF'
]

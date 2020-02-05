Class {
	#name : #GdxNode,
	#superclass : #GdxObject,
	#category : #'Gdx-Model'
}

{ #category : #accessing }
GdxNode >> children [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdxNode >> parent [ 
	^ self subclassResponsibility 
]

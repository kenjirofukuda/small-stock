Class {
	#name : #GdxElement,
	#superclass : #Object,
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

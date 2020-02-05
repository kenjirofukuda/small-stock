Extension { #name : #GdsPrimitiveElement }

{ #category : #'*Gdx-Model' }
GdsPrimitiveElement >> copyToGdxObject: aGdxElement [
	super copyToGdxObject: aGdxElement.
	aGdxElement layerNumber: self layerNumber.
]

Extension { #name : #GdsLibrary }

{ #category : #'*Gdx-Model' }
GdsLibrary >> copyToGdxObject: aGdxObject [
	aGdxObject name: self name copy.
	aGdxObject
		structures: (self structures copy collect: [ :each | each asGdxObject ])
]

Extension { #name : #GdsLibrary }

{ #category : #'*Gdx-Model' }
GdsLibrary >> copyToGdxObject: aGdxLibrary [
	aGdxLibrary name: self name copy.
	aGdxLibrary
		structures: (self structures copy collect: [ :each | each asGdxObject ])
]

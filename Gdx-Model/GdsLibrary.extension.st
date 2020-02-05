Extension { #name : #GdsLibrary }

{ #category : #'*Gdx-Model' }
GdsLibrary >> copyToGdxObject: aGdxLibrary [
	aGdxLibrary name: self name.
	aGdxLibrary
		structures:
			(self structures
				collect: [ :each | each asGdxObject ]
				thenSelect: [ :each | each notNil ])
]

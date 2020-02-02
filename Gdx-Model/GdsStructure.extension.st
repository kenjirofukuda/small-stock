Extension { #name : #GdsStructure }

{ #category : #'*Gdx-Model' }
GdsStructure >> copyToGdxObject: aGdxStructure [
	aGdxStructure name: self name.
	aGdxStructure
		elements:
			(self elements
				collect: [ :each | each asGdxObject ]
				thenSelect: [ :each | each notNil ])
]

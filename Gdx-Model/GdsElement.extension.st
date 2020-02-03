Extension { #name : #GdsElement }

{ #category : #'*Gdx-Model' }
GdsElement >> asGdxObject [
	self gdxClassName 
		asClassIfPresent: [ :clazz | 
			| copied |
			copied := clazz new.
			self copyToGdxObject: copied.
			^ copied ].
	^ nil
]

{ #category : #'*Gdx-Model' }
GdsElement >> copyToGdxObject: aGdxElement [
	aGdxElement vertices: self vertices
]

{ #category : #'*Gdx-Model' }
GdsElement >> gdxClassName [
	^ (self class name asString copyReplaceAll:  'Gds' with: 'Gdx') asSymbol
]

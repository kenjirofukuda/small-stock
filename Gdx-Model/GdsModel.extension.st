Extension { #name : #GdsModel }

{ #category : #'*Gdx-Model' }
GdsModel >> asGdxObject [
	self gdxClassName 
		asClassIfPresent: [ :clazz | 
			| copied |
			copied := clazz new.
			self copyToGdxObject: copied.
			^ copied ].
	^ nil
]

{ #category : #'*Gdx-Model' }
GdsModel >> copyToGdxObject: aGdxObject [ 
	self subclassResponsibility
]

{ #category : #'*Gdx-Model' }
GdsModel >> gdxClassName [
	^ (self class name asString copyReplaceAll:  'Gds' with: 'Gdx') asSymbol
]

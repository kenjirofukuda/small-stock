Extension { #name : #RSComposite }

{ #category : #'*Gdx-Roassal3' }
RSComposite >> updateBaseRectangle [
	| g |
	(self children reject: [ :each | each isKindOf: RSComposite ])
		ifNotEmpty: [ :elems | 
			g := RSGroup withAll: elems.
			baseRectangle := g encompassingRectangle ].
	(self children select: [ :each | each isKindOf: RSComposite ])
		do: [ :each2 | each2 updateBaseRectangle ].

]

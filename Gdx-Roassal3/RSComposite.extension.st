Extension { #name : #RSComposite }

{ #category : #'*Gdx-Roassal3' }
RSComposite >> updateBaseRectangle [
	| g |
	g := RSGroup withAll: self shapes.
	baseRectangle := g encompassingRectangle.
]

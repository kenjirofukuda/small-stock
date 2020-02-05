Extension { #name : #GdsStructureReference }

{ #category : #'*Gdx-Model' }
GdsStructureReference >> copyToGdxObject: aGdxStructureReference [
	super copyToGdxObject: aGdxStructureReference.
	aGdxStructureReference referenceName: self structureName.
	aGdxStructureReference structureTransform: self strans
]

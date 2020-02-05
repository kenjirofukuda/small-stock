Extension { #name : #GdsArrayedStructureReference }

{ #category : #'*Gdx-Model' }
GdsArrayedStructureReference >> copyToGdxObject: aGdxArrayedStructureReference [
	super copyToGdxObject: aGdxArrayedStructureReference.
	aGdxArrayedStructureReference arrayShapeInfo 
		rowCount: self rowCount;
		columnCount: self columnCount;
		xStep: self xStep;
		yStep: self yStep.
]

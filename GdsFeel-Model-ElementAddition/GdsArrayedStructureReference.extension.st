Extension { #name : #GdsArrayedStructureReference }

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsArrayedStructureReference >> asDxfShape [
	| dxfShape |
	dxfShape := super asDxfShape.
	dxfShape rowCount: self rowCount.
	dxfShape columnCount: self columnCount.	
	dxfShape rowSpacing: self yStep.
	dxfShape columnSpacing: self xStep.	
	^ dxfShape	
]

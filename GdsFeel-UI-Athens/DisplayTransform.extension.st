Extension { #name : #DisplayTransform }

{ #category : #'*GdsFeel-UI-Athens-extension' }
DisplayTransform >> asAthensAT [
	^ GdsAthensStructureDrawer athensTransformFromMatrix2x3: self asMatrixTransform2x3
]

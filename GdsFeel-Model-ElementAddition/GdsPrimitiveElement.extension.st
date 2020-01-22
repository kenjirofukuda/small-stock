Extension { #name : #GdsPrimitiveElement }

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsPrimitiveElement >> setLayerNameToDxf: aDxfShape [
	"see: stanLayerTable2"
	| gdsLayer |
	gdsLayer := self structure layers atNumber: self layerNumber.
	aDxfShape layerName: gdsLayer exportName	
]

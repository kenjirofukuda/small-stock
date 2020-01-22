Class {
	#name : #DxfPoint,
	#superclass : #DxfShape,
	#category : #'KFDxf-Model'
}

{ #category : #converting }
DxfPoint >> asPoint [
	^ (self centerX @ self centerY)
]

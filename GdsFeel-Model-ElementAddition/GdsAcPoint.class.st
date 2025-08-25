Class {
	#name : #GdsAcPoint,
	#superclass : #GdsPrimitiveElement,
	#category : #'GdsFeel-Model-ElementAddition'
}

{ #category : #'as yet unclassified' }
GdsAcPoint class >> drawerClass [
	^ GdsAcPointDrawer
]

{ #category : #accessing }
GdsAcPoint class >> type [
	^ #point
]

{ #category : #'as yet unclassified' }
GdsAcPoint >> asDxfShape [
	| dxfShape |
	dxfShape := DxfPoint new.
	dxfShape initializeDefaults.
	self setLayerNameToDxf: dxfShape.
	dxfShape setLineStyleToByLayer.
	dxfShape colorNumber: 256.
	dxfShape setCode: 370 data: '  -1'.
	dxfShape addCode: 100 data: 'AcDbPoint'.
	dxfShape firstX: self centerPoint x.
	dxfShape firstY: self centerPoint y.
	dxfShape firstZ: 0.0.
	^ dxfShape
]

{ #category : #accessing }
GdsAcPoint >> centerPoint [
	^ self xy
]

{ #category : #accessing }
GdsAcPoint >> centerPoint: aPoint [
	^ self setXy: 	aPoint
]

{ #category : #'as yet unclassified' }
GdsAcPoint >> dist: aPoint [
	self
		deprecated: 'Use #distanceTo: instead.'
		on: '9 February 2021'
		in: #Pharo9
		transformWith: '`@receiver dist: `@arg' -> '`@receiver distanceTo: `@arg'.
	^ self distanceTo: aPoint
]

{ #category : #'as yet unclassified' }
GdsAcPoint >> distanceTo: aPoint [

	^ self centerPoint distanceTo: aPoint
]

{ #category : #initialize }
GdsAcPoint >> initialize [
	super initialize.
	self centerPoint: 0@0.
	
]

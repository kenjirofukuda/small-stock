Class {
	#name : 'GdsArrayedStructureReferenceDrawer',
	#superclass : 'GdsStructureReferenceDrawer',
	#category : 'GdsFeel-UI-Drawer',
	#package : 'GdsFeel-UI',
	#tag : 'Drawer'
}

{ #category : 'testing' }
GdsArrayedStructureReferenceDrawer >> canDisplayBorder [
	^self canDisplayKindForKey: 'AB'
]

{ #category : 'testing' }
GdsArrayedStructureReferenceDrawer >> canDisplayExtent [
	^self canDisplayKindForKey: 'AE'
]

{ #category : 'testing' }
GdsArrayedStructureReferenceDrawer >> canDisplayOrigin [
	^ self canDisplayKindForKey: 'AO'
]

{ #category : 'drawing' }
GdsArrayedStructureReferenceDrawer >> drawBorderOn: aCanvas [
	self pushedPort: [
		morph penColor: morph visiblePenColor during: [
			|points|
			"points := element dataOutlinePoints."
			points :=  GeometryUtils verticesFromBounds: element refStructure dataExtentForElements..
			self strokeVerticesOn: aCanvas points: points.]].
]

{ #category : 'drawing' }
GdsArrayedStructureReferenceDrawer >> optionalDrawOn: aCanvas [
	super optionalDrawOn: aCanvas.
	self canDisplayBorder 
		ifTrue: [self drawBorderOn: aCanvas]
		
]

{ #category : 'private' }
GdsArrayedStructureReferenceDrawer >> pushedPort: aBlock [
	| transforms |
	self assert: element isNil not.
	transforms := element repeatTransforms.
	transforms do: [:each |	
		morph viewport pushTransform: each during: aBlock]
]

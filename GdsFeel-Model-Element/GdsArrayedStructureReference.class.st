"
A GdsArrayedStructureReference is GDS II's AREF.

Instance Variables

"
Class {
	#name : #GdsArrayedStructureReference,
	#superclass : #GdsStructureReference,
	#instVars : [
		'ashape'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #accessing }
GdsArrayedStructureReference class >> type [

	^ #aref
]

{ #category : #visiting }
GdsArrayedStructureReference >> accept: aVisitor [
	^ aVisitor visitAref: self
]

{ #category : #private }
GdsArrayedStructureReference >> baseLocalBounds [
	^super lookupLocalBounds.

]

{ #category : #accessing }
GdsArrayedStructureReference >> columnCount [
	^ ashape columnCount
]

{ #category : #accessing }
GdsArrayedStructureReference >> columnCount: anInteger [ 
	ashape columnCount: anInteger
]

{ #category : #private }
GdsArrayedStructureReference >> fromItemContext: aGdsItemContext atIndex: aVerticesIndex [
	super fromItemContext:  aGdsItemContext atIndex: aVerticesIndex.
	self columnCount: aGdsItemContext ashape columnCount.
	self rowCount: aGdsItemContext ashape rowCount.
	self xStep: aGdsItemContext ashape xStep.
	self yStep: aGdsItemContext ashape yStep.	
	
]

{ #category : #initialization }
GdsArrayedStructureReference >> initialize [
	super initialize.
	ashape := GdsAShapeContext new propertyOwner: self
]

{ #category : #'objects from disk' }
GdsArrayedStructureReference >> loadFromXmlNode: aXMLNode [
	super loadFromXmlNode: aXMLNode.
	aXMLNode elementsDo: [:node |
		node name = #ashape
			ifTrue: [
				ashape loadFromXmlNode: node].]


]

{ #category : #private }
GdsArrayedStructureReference >> lookupLocalBounds [
	^ ashape lookupLocalBounds: super lookupLocalBounds
]

{ #category : #accessing }
GdsArrayedStructureReference >> offsets [
	^ ashape offsets
]

{ #category : #private }
GdsArrayedStructureReference >> rebuildVertices [
]

{ #category : #accessing }
GdsArrayedStructureReference >> relativeTransforms [
	^ ashape relativeTransforms
]

{ #category : #accessing }
GdsArrayedStructureReference >> rowCount [
	^ ashape rowCount
]

{ #category : #accessing }
GdsArrayedStructureReference >> rowCount: anInteger [ 
	ashape rowCount: anInteger
]

{ #category : #sizing }
GdsArrayedStructureReference >> stepToOwnSize [
	self xStepToOwnSize.
	self yStepToOwnSize.
	
]

{ #category : #accessing }
GdsArrayedStructureReference >> xStep [
	^ ashape xStep
]

{ #category : #accessing }
GdsArrayedStructureReference >> xStep: aFloat [ 
	ashape xStep: aFloat.
	self rebuildVertices.
	
]

{ #category : #private }
GdsArrayedStructureReference >> xStepToOwnSize [
	self xStep: self baseLocalBounds width.
]

{ #category : #'xml/json data exchange' }
GdsArrayedStructureReference >> xmlElementOn: aXmlElement [
	super xmlElementOn: aXmlElement.
	aXmlElement addNode: ashape asXmlElement.
	


]

{ #category : #accessing }
GdsArrayedStructureReference >> yStep [
	^ ashape yStep
]

{ #category : #accessing }
GdsArrayedStructureReference >> yStep: aFloat [ 
	ashape yStep: aFloat.
	self rebuildVertices.

]

{ #category : #sizing }
GdsArrayedStructureReference >> yStepToOwnSize [
	self yStep: self baseLocalBounds height.
]

Class {
	#name : #GdsStructureWalker,
	#superclass : #Object,
	#instVars : [
		'depth'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #accessing }
GdsStructureWalker >> depth [
	
	^ depth
]

{ #category : #accessing }
GdsStructureWalker >> depth: anObject [
	
	depth := anObject
]

{ #category : #initialize }
GdsStructureWalker >> initialize [
	depth := 0.
]

{ #category : #action }
GdsStructureWalker >> walk: aStructure do: aBlock [
	aBlock cull: aStructure.
	(aStructure directReferenceElements)
		do: [ :e |
			depth := depth + 1.
			self walk: e refStructure do: aBlock.
			depth := depth - 1.
			].
		
]

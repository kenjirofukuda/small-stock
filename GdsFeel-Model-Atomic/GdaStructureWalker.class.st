Class {
	#name : #GdaStructureWalker,
	#superclass : #Object,
	#instVars : [
		'depth'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #accessing }
GdaStructureWalker >> depth [

	^ depth
]

{ #category : #accessing }
GdaStructureWalker >> depth: anObject [

	depth := anObject
]

{ #category : #initialize }
GdaStructureWalker >> initialize [

	depth := 0
]

{ #category : #action }
GdaStructureWalker >> walk: aStructure do: aBlock [

	aBlock cull: aStructure.
	aStructure directReferenceElements do: [ :e | 
		depth := depth + 1.
		self walk: e refStructure do: aBlock.
		depth := depth - 1 ]
]

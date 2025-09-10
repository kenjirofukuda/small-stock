Class {
	#name : #GdaLayers,
	#superclass : #Model,
	#instVars : [
		'layers',
		'numbers'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #accessing }
GdaLayers >> all [
	^ self numbers collect: [ :i | self atNumber: i ].
]

{ #category : #accessing }
GdaLayers >> atName: aString [
	| layer |
	self numbers do: [ :i | 
		layer := self atNumber: i.
		(layer name sameAs: aString)
			ifTrue: [ ^ layer ] ].
	layer := self atNumber: (self numbers max + 1).
	layer name: aString.
	^ layer
]

{ #category : #accessing }
GdaLayers >> atNumber: anInteger [

	| newLayer create result |
	layers ifNil: [ layers := Dictionary new ].
	create := false.
	result := layers at: anInteger ifAbsentPut: [ 
		          newLayer := GdaLayer fromLayerNumber: anInteger.
		          create := true.
		          newLayer ].
	create ifTrue: [ 
		numbers := nil.
		self changed: #newLayer with: result ].
	^ result
]

{ #category : #testing }
GdaLayers >> colorAllocated [

	layers ifNil: [ ^ false ].
	^ (layers values allSatisfy: [ :layer | layer color = Color white ])
		  not
]

{ #category : #accessing }
GdaLayers >> lookupNumbers [

	layers ifNil: [ ^ #(  ) ].
	^ layers keys sort
]

{ #category : #accessing }
GdaLayers >> numbers [

	numbers ifNil: [ numbers := self lookupNumbers ].
	^ numbers
]

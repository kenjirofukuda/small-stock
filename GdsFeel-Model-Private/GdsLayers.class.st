Class {
	#name : #GdsLayers,
	#superclass : #Model,
	#traits : 'TGdsExchange',
	#classTraits : 'TGdsExchange classTrait',
	#instVars : [
		'layers',
		'numbers',
		'announcer'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #accessing }
GdsLayers >> all [
	^ self numbers collect: [ :i | self atNumber: i ].
]

{ #category : #announcement }
GdsLayers >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ].
]

{ #category : #accessing }
GdsLayers >> atName: aString [
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
GdsLayers >> atNumber: anInteger [
	| newLayer create result |
	layers ifNil: [layers := Dictionary new.].
	create := false.
	result := layers 
		at: anInteger 
		ifAbsentPut: [
			newLayer := GdsLayer fromLayerNumber: anInteger.
			newLayer selectableProperty whenChangedDo: [ self fireChanged ].
			newLayer visibleProperty whenChangedDo: [ self fireChanged ].
			newLayer nameProperty whenChangedDo: [ self fireChanged ].
			newLayer layerNumberProperty whenChangedDo: [ self fireChanged ].
			newLayer colorProperty whenChangedDo: [ self fireChanged ].
			create := true.
			self fireChanged.
			newLayer].
	create 
		ifTrue: [
			numbers := nil.
			self changed: #newLayer with: result].
	^result.
]

{ #category : #testing }
GdsLayers >> colorAllocated [
	layers ifNil: [ ^ false ].
	^(layers values allSatisfy: [ :layer | layer color = Color white]) not
]

{ #category : #deprecated }
GdsLayers >> fillDefault [
	GdsCompatibility default layerNumberRange do: [:number |
		self atNumber: number.].
]

{ #category : #'as yet unclassified' }
GdsLayers >> fireChanged [
	self announcer announce: (GdsLayersChanged new).
]

{ #category : #'xml/json data exchange' }
GdsLayers >> jsonElementsOn: aDictionary [
	"override. own elements"
	| map | 
	map := Dictionary new.
	layers keysAndValuesDo: [ :key :value |
		map at: key asString put: value.
		].
	aDictionary at: 'layers' put: map.
	
]

{ #category : #'xml/json data exchange' }
GdsLayers >> jsonOn: aStream [
	| map |
	map := Dictionary new.
	self attributesOn: map.
	self jsonElementsOn: map.
	map jsonOn: aStream.
	
]

{ #category : #'objects from disk' }
GdsLayers >> loadFromXmlDocument: aXMLDocument [
	| topNode  layer layerNumber  |
	topNode := aXMLDocument findElementNamed: #layers.
	topNode
		elementsDo: [ :node |
			layerNumber := (node attributes at: 'gdsno') asInteger.
			layer := self atNumber: layerNumber.
			layer loadFromXmlNode: node]

]

{ #category : #accessing }
GdsLayers >> lookupNumbers [
	layers ifNil: [^#()].
	^layers keys sort.
]

{ #category : #accessing }
GdsLayers >> numbers [
	numbers ifNil: [numbers := self lookupNumbers].
	^numbers.
]

{ #category : #'xml/json data exchange' }
GdsLayers >> topElementName [
	^'layers'

]

{ #category : #'xml/json data exchange' }
GdsLayers >> xmlElementOn: aXmlElement [
	self numbers do: [:num |
		aXmlElement addNode: (self atNumber: num) asXmlElement.].

]

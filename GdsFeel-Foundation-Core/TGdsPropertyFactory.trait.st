Trait {
	#name : #TGdsPropertyFactory,
	#category : #'GdsFeel-Foundation-Core'
}

{ #category : #factory }
TGdsPropertyFactory >> boolNamed: aPropertyName [
	^ GdsBooleanProperty named: aPropertyName owner: self
]

{ #category : #factory }
TGdsPropertyFactory >> collectionNamed: aPropertyName [
	^ self collectionNamed: aPropertyName elementType: Object
]

{ #category : #factory }
TGdsPropertyFactory >> collectionNamed: aPropertyName elementType: aClass [
	^ GdsCollectionProperty
		named: aPropertyName
		owner: self
		elementType: aClass
]

{ #category : #factory }
TGdsPropertyFactory >> degreeNamed: aPropertyName [
	^ GdsDegreesProperty named: aPropertyName owner: self
]

{ #category : #factory }
TGdsPropertyFactory >> floatNamed: aPropertyName [
	^ GdsFloatProperty named: aPropertyName owner: self
]

{ #category : #factory }
TGdsPropertyFactory >> integerNamed: aPropertyName [
	^ GdsIntegerProperty named: aPropertyName owner: self
]

{ #category : #factory }
TGdsPropertyFactory >> stringNamed: aPropertyName [
	^ GdsStringProperty named: aPropertyName owner: self
]

{ #category : #factory }
TGdsPropertyFactory >> symbolNamed: aPropertyName [
	^ GdsSymbolProperty named: aPropertyName owner: self
]

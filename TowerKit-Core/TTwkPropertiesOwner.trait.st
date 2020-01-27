Trait {
	#name : #TTwkPropertiesOwner,
	#category : #'TowerKit-Core'
}

{ #category : #'t-propertiesOwner properties counting' }
TTwkPropertiesOwner >> count: aSelector property: aSymbol [ 
	"self propertyCounter at: (aSelector->aSymbol) ifAbsentPut: [0].
	self propertyCounter at: (aSelector->aSymbol) put: (self propertyCounter at: (aSelector->aSymbol) ) + 1."

]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> hasProperty: aSymbol [ 
	"Answer whether the receiver has the property named aSymbol"
	self count: #hasProperty: property: aSymbol.
	^ self properties includesKey: aSymbol
]

{ #category : #'t-propertiesOwner properties counting' }
TTwkPropertiesOwner >> propertyCounter [ 
	^ self properties at: #propertyCounter ifAbsentPut: [ Dictionary new]
]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> removeProperty: aSymbol [ 
	"removes the property named aSymbol if it exists"
	self count: #removeProperty: property: aSymbol.
	self properties removeKey: aSymbol ifAbsent: [  ]
]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> setProperty: aSymbol toValue: anObject [ 
	"change the receiver's property named aSymbol to anObject"
	self count: #setProperty: property: aSymbol.
	self properties at: aSymbol put: anObject
]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> valueOfProperty: aSymbol [
	"answer the value of the receiver's property named aSymbol"
	self count: #valueOfProperty: property: aSymbol.
	^ self valueOfProperty: aSymbol ifAbsent: [  ]
]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> valueOfProperty: aSymbol ifAbsent: aBlock [ 
	"if the receiver possesses a property of the given name, answer  
	its value. If not then evaluate aBlock and answer the result of  
	this block evaluation"
	self count: #valueOfProperty:ifAbsent: property: aSymbol.
	^ self properties at: aSymbol ifAbsent: [^ aBlock value]
]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> valueOfProperty: aSymbol ifAbsentPut: aBlock [ 
	"If the receiver possesses a property of the given name, answer  
	its value. If not, then create a property of the given name, give 
	it the value obtained by evaluating aBlock, then answer that  
	value"
	self count: #valueOfProperty:ifAbsentPut: property: aSymbol.
	^ self properties at: aSymbol ifAbsentPut: aBlock
]

{ #category : #'t-propertiesOwner properties managing' }
TTwkPropertiesOwner >> valueOfProperty: aSymbol ifPresentDo: aBlock [ 
	"If the receiver has a property of the given name, evaluate  
	aBlock on behalf of the value of that property"
	self count: #valueOfProperty:ifPresentDo: property: aSymbol.
	^ aBlock value: (self valueOfProperty: aSymbol ifAbsent: [^ self])
]

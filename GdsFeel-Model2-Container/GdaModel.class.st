Class {
	#name : #GdaModel,
	#superclass : #Model,
	#instVars : [
		'properties'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #'accessing - properties' }
GdaModel >> hasProperty: aSymbol [
	"Answer whether the receiver has the property named aSymbol"

	"self count: #hasProperty: property: aSymbol."
	^ self properties includesKey: aSymbol
]

{ #category : #testing }
GdaModel >> isElement [

	^ false
]

{ #category : #testing }
GdaModel >> isLibrary [

	^ false
]

{ #category : #testing }
GdaModel >> isStation [

	^ false
]

{ #category : #testing }
GdaModel >> isStructure [

	^ false
]

{ #category : #accessing }
GdaModel >> properties [

	^ properties ifNil: [ properties := IdentityDictionary new ]
]

{ #category : #initialization }
GdaModel >> release [
	properties := nil.
	super release
]

{ #category : #'accessing - properties' }
GdaModel >> removeProperty: aSymbol [
	"removes the property named aSymbol if it exists"

	"self count: #removeProperty: property: aSymbol."
	self properties removeKey: aSymbol ifAbsent: [  ]
]

{ #category : #'accessing - properties' }
GdaModel >> setProperty: aSymbol toValue: anObject [
	"change the receiver's property named aSymbol to anObject"

	"self count: #setProperty: property: aSymbol."
	self properties at: aSymbol put: anObject
]

{ #category : #'accessing - properties' }
GdaModel >> valueOfProperty: aSymbol [
	"answer the value of the receiver's property named aSymbol"

	"self count: #valueOfProperty: property: aSymbol."
	^ self valueOfProperty: aSymbol ifAbsent: [  ]
]

{ #category : #'accessing - properties' }
GdaModel >> valueOfProperty: aSymbol ifAbsent: aBlock [
	"if the receiver possesses a property of the given name, answer  
	its value. If not then evaluate aBlock and answer the result of  
	this block evaluation"

	"self count: #valueOfProperty:ifAbsent: property: aSymbol."
	^ self properties at: aSymbol ifAbsent: [ ^ aBlock value ]
]

{ #category : #'accessing - properties' }
GdaModel >> valueOfProperty: aSymbol ifAbsentPut: aBlock [
	"If the receiver possesses a property of the given name, answer  
	its value. If not, then create a property of the given name, give 
	it the value obtained by evaluating aBlock, then answer that  
	value"

	"self count: #valueOfProperty:ifAbsentPut: property: aSymbol."
	^ self properties at: aSymbol ifAbsentPut: aBlock
]

{ #category : #'accessing - properties' }
GdaModel >> valueOfProperty: aSymbol ifPresentDo: aBlock [
	"If the receiver has a property of the given name, evaluate  
	aBlock on behalf of the value of that property"

	"self count: #valueOfProperty:ifPresentDo: property: aSymbol."
	^ aBlock value: (self valueOfProperty: aSymbol ifAbsent: [ ^ self ])
]

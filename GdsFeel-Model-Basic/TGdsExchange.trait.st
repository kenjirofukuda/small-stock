Trait {
	#name : #TGdsExchange,
	#category : #'GdsFeel-Model-Basic'
}

{ #category : #'as yet unclassified' }
TGdsExchange >> asJsonMap [
	| map |
	map := Dictionary new.
	self attributesOn: map.
	self jsonElementsOn: map.
	^ map
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> asXmlElement [
	| elmt attrDict |
	attrDict := Dictionary new.
	self xmlAttributesOn: attrDict.
	elmt := XMLElement name: self topElementName attributes: attrDict.
	self xmlElementOn: elmt.
	^elmt.

]

{ #category : #'xml/json data exchange' }
TGdsExchange >> attributesOn: aDictionary [ 
	"override hear"
	"scalar property value only".
	"multi value implements: #jsonElementsOn: aDictionary"
]

{ #category : #'as yet unclassified' }
TGdsExchange >> isMultiValue: aValue [
	^ (aValue isCollection) or: [ aValue isDictionary] 
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> jsonElementsOn: aDictionary [
	"override. own elements"
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> jsonOn: aStream [
	self asJsonMap  jsonOn: aStream.
	
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> neoJsonOn: neoJSONWriter [
	neoJSONWriter writeMap: self asJsonMap
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> topElementName [
	^'mustOverrideName'

]

{ #category : #'xml/json data exchange' }
TGdsExchange >> valueAsStringOn: aDictionary [ 
	aDictionary keysAndValuesDo: [ :key :value |
		(self isMultiValue: value)
			ifFalse: [ aDictionary at: key asString put: value asString ]].
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> xmlAttributesOn: aDictionary [ 
	self attributesOn: aDictionary.
	self valueAsStringOn: aDictionary.
]

{ #category : #'xml/json data exchange' }
TGdsExchange >> xmlElementOn: aXmlElement [
	"optional element attribute hear"
]

Class {
	#name : #GdsLayer,
	#superclass : #GdsState,
	#instVars : [
		'layerNumber',
		'color',
		'name'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #'as yet unclassified' }
GdsLayer class >> fromLayerNumber: anInteger [
	^self new layerNumber: anInteger asInteger.
]

{ #category : #'objects from disk' }
GdsLayer >> attributesFrom: aDictionary [
	super attributesFrom: aDictionary.
	self layerNumber: (aDictionary at: 'gdsno') asInteger.	
	self name: (aDictionary at: 'name'). 

]

{ #category : #'xml/json data exchange' }
GdsLayer >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'gdsno' put: self layerNumber.	
	aDictionary at: 'name' put: self name.	

]

{ #category : #accessing }
GdsLayer >> color [
	color value ifNil: [ color value: Color white].
	^ color value 
	
]

{ #category : #accessing }
GdsLayer >> color: aColor [
	color value: aColor.
	
]

{ #category : #'api-valueHolder' }
GdsLayer >> colorProperty [
	^ color
]

{ #category : #accessing }
GdsLayer >> exportName [
	^ self name isEmptyOrNil 
		ifTrue: [ self layerNumber asString]
		ifFalse: [ self name ]
	
]

{ #category : #'initialize-release' }
GdsLayer >> initialize [
	super initialize.
	self setSelectable: true.
	self setVisible: true.
	layerNumber := 1 asValueHolder.
	name := '' asValueHolder.
	color := nil asValueHolder.
	
]

{ #category : #'xml/json data exchange' }
GdsLayer >> jsonElementsOn: aDictionary [
	| map |
	map := Dictionary new.
	GdsColorUtils rgbaAttributesOn: map color: self color.
	aDictionary at: 'color' put: map.
]

{ #category : #accessing }
GdsLayer >> layerNumber [
	^ layerNumber value.
	
]

{ #category : #private }
GdsLayer >> layerNumber: aInteger [.
	layerNumber value: aInteger asInteger.
	
]

{ #category : #'api-valueHolder' }
GdsLayer >> layerNumberProperty [
	^ layerNumber
]

{ #category : #'objects from disk' }
GdsLayer >> loadFromXmlNode: aXMLNode [
	self attributesFrom: aXMLNode attributes.
	aXMLNode
		elementsDo: [:colorNode |
			self color: (GdsColorUtils  fromAttributes:  colorNode attributes)].
		
	
]

{ #category : #accessing }
GdsLayer >> name [
	^ name value
]

{ #category : #accessing }
GdsLayer >> name: aString [
	name value: aString
	
]

{ #category : #'api-valueHolder' }
GdsLayer >> nameProperty [
	^ name
]

{ #category : #printing }
GdsLayer >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self layerNumber printString.
	aStream nextPut: $).
	
]

{ #category : #'xml/json data exchange' }
GdsLayer >> topElementName [
	^'layer'

]

{ #category : #'xml/json data exchange' }
GdsLayer >> xmlElementOn: aXmlElement [
	| attrDict colorElmt |
	attrDict := Dictionary new.
	GdsColorUtils rgbaAttributesOn: attrDict color: self color. 
	self valueAsStringOn: attrDict.
	colorElmt := XMLElement name: 'color' attributes: attrDict.
	aXmlElement addNode: colorElmt.
]

Class {
	#name : #GdaLayer,
	#superclass : #GdsState,
	#instVars : [
		'layerNumber',
		'color',
		'name'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #'as yet unclassified' }
GdaLayer class >> fromLayerNumber: anInteger [
	^self new layerNumber: anInteger asInteger.
]

{ #category : #'objects from disk' }
GdaLayer >> attributesFrom: aDictionary [
	super attributesFrom: aDictionary.
	self layerNumber: (aDictionary at: 'gdsno') asInteger.	
	self name: (aDictionary at: 'name'). 

]

{ #category : #'xml/json data exchange' }
GdaLayer >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'gdsno' put: self layerNumber.	
	aDictionary at: 'name' put: self name.	

]

{ #category : #accessing }
GdaLayer >> color [
	color value ifNil: [ color value: Color white].
	^ color value 
	
]

{ #category : #accessing }
GdaLayer >> color: aColor [
	color value: aColor.
	
]

{ #category : #'api-valueHolder' }
GdaLayer >> colorProperty [
	^ color
]

{ #category : #accessing }
GdaLayer >> exportName [
	^ self name isEmptyOrNil 
		ifTrue: [ self layerNumber asString]
		ifFalse: [ self name ]
	
]

{ #category : #'initialize-release' }
GdaLayer >> initialize [
	super initialize.
	self setSelectable: true.
	self setVisible: true.
	layerNumber := 1 asValueHolder.
	name := '' asValueHolder.
	color := nil asValueHolder.
	
]

{ #category : #'xml/json data exchange' }
GdaLayer >> jsonElementsOn: aDictionary [
	| map |
	map := Dictionary new.
	GdsColorUtils rgbaAttributesOn: map color: self color.
	aDictionary at: 'color' put: map.
]

{ #category : #accessing }
GdaLayer >> layerNumber [
	^ layerNumber value.
	
]

{ #category : #private }
GdaLayer >> layerNumber: aInteger [.
	layerNumber value: aInteger asInteger.
	
]

{ #category : #'api-valueHolder' }
GdaLayer >> layerNumberProperty [
	^ layerNumber
]

{ #category : #'objects from disk' }
GdaLayer >> loadFromXmlNode: aXMLNode [
	self attributesFrom: aXMLNode attributes.
	aXMLNode
		elementsDo: [:colorNode |
			self color: (GdsColorUtils  fromAttributes:  colorNode attributes)].
		
	
]

{ #category : #accessing }
GdaLayer >> name [
	^ name value
]

{ #category : #accessing }
GdaLayer >> name: aString [
	name value: aString
	
]

{ #category : #'api-valueHolder' }
GdaLayer >> nameProperty [
	^ name
]

{ #category : #printing }
GdaLayer >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self layerNumber printString.
	aStream nextPut: $).
	
]

{ #category : #'xml/json data exchange' }
GdaLayer >> topElementName [
	^'layer'

]

{ #category : #'xml/json data exchange' }
GdaLayer >> xmlElementOn: aXmlElement [
	| attrDict colorElmt |
	attrDict := Dictionary new.
	GdsColorUtils rgbaAttributesOn: attrDict color: self color. 
	self valueAsStringOn: attrDict.
	colorElmt := XMLElement name: 'color' attributes: attrDict.
	aXmlElement addNode: colorElmt.
]

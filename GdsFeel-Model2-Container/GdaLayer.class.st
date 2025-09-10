Class {
	#name : #GdaLayer,
	#superclass : #GdaState,
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

{ #category : #accessing }
GdaLayer >> color [

	^ color
]

{ #category : #accessing }
GdaLayer >> color: aColor [
	color := aColor.
	
]

{ #category : #accessing }
GdaLayer >> exportName [

	^ self name isEmptyOrNil
		  ifTrue: [ self layerNumber asString ]
		  ifFalse: [ self name ]
]

{ #category : #'initialize-release' }
GdaLayer >> initialize [
	super initialize.
	self setSelectable: true.
	self setVisible: true.
	layerNumber := 1.
	name := ''.
	color := Color white.
	
]

{ #category : #accessing }
GdaLayer >> layerNumber [
	^ layerNumber
	
]

{ #category : #private }
GdaLayer >> layerNumber: anInteger [
	layerNumber := anInteger
	
]

{ #category : #accessing }
GdaLayer >> name [
	^ name
]

{ #category : #accessing }
GdaLayer >> name: aString [
	name := aString
	
]

{ #category : #printing }
GdaLayer >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self layerNumber printString.
	aStream nextPut: $).
	
]

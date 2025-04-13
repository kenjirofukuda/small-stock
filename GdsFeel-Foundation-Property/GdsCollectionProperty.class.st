Class {
	#name : 'GdsCollectionProperty',
	#superclass : 'GdsObjectProperty',
	#instVars : [
		'elementType'
	],
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'as yet unclassified' }
GdsCollectionProperty class >> named: aPropertyName owner: anObject elementType: aClass [
	^(super named: aPropertyName owner: anObject) elementType: aClass.
]

{ #category : 'as yet unclassified' }
GdsCollectionProperty class >> typeClass [
	^Collection
]

{ #category : 'check' }
GdsCollectionProperty >> checkType: aCollection [
	super checkType: aCollection.
	(aCollection
		detect: [ :v | (v isKindOf: elementType) not ]
		ifNone: [  ])
		ifNotNil: [ :found | 
			^ self
				error: found printString , ' not kind of: ' , elementType asString ]
]

{ #category : 'accessing' }
GdsCollectionProperty >> elementType [
	^elementType ifNil: [ elementType := Object].
]

{ #category : 'accessing' }
GdsCollectionProperty >> elementType: aClass [
	elementType := aClass.
]

{ #category : 'initialize-release' }
GdsCollectionProperty >> initialize [
	super initialize.
	initialValue := OrderedCollection new.
]

{ #category : 'check' }
GdsCollectionProperty >> newValue: aCollection [
	^(super newValue: aCollection) asArray.
]

{ #category : 'check' }
GdsCollectionProperty >> oldValue [
	^super oldValue asArray.
]

{ #category : 'check' }
GdsCollectionProperty >> valueAssign: newCollectionValue [
	propertyValue := OrderedCollection new.
	propertyValue addAll: newCollectionValue.
	
]

Class {
	#name : #TwkStanNode,
	#superclass : #TwkStanObject,
	#instVars : [
		'point3d',
		'legIndex'
	],
	#category : #'TowerKit-STAN'
}

{ #category : #accessing }
TwkStanNode class >> csvHeaderOn: s [
	s nextPut: #x.
	s nextPut: #y.
	s nextPut: #z.	
]

{ #category : #'as yet unclassified' }
TwkStanNode class >> unitNumber [
	^ 1000
]

{ #category : #'objects from disk' }
TwkStanNode >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'position' put: self point3d.
	aDictionary at: 'legIndex' put: self legIndex.

]

{ #category : #accessing }
TwkStanNode >> csvDataOn: s [
	s nextPutAll: (((self point3d asArray roundedForStan) * 0.1 ) collect: [ :each | each printShowingDecimalPlaces: 4  ])
]

{ #category : #initialization }
TwkStanNode >> initialize [
	super initialize.
	point3d := Array with: 0.0 with: 0.0 with: 0.0 .
	legIndex := -1.
]

{ #category : #accessing }
TwkStanNode >> legIndex [
	^ legIndex
]

{ #category : #accessing }
TwkStanNode >> legIndex: anInteger [
	legIndex := anInteger
]

{ #category : #accessing }
TwkStanNode >> point3d [
	^ point3d
]

{ #category : #accessing }
TwkStanNode >> point3d: aArray3 [
	point3d := aArray3
]

{ #category : #printing }
TwkStanNode >> printOn: aStream [ 
	aStream << 'SNODE['.
	aStream << self name.
	aStream << ',('.
	aStream << 'x: '.
	aStream << self x asString.
	aStream << ', '.
	aStream << 'y: '.
	aStream << self y asString.
	aStream << ', '.
	aStream << 'z: '.
	aStream << self z asString.
	aStream << ')]'	
	
]

{ #category : #accessing }
TwkStanNode >> x [
	^ self point3d first.
]

{ #category : #accessing }
TwkStanNode >> y [
	^ self point3d second.
]

{ #category : #accessing }
TwkStanNode >> z [
	^ self point3d third.
]

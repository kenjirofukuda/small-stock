Class {
	#name : #TwkPassivePlane,
	#superclass : #TwkPlane,
	#instVars : [
		'passiveWidth'
	],
	#category : #'TowerKit-Core'
}

{ #category : #private }
TwkPassivePlane >> clearCache [
	passiveWidth := nil.
	super clearCache.
]

{ #category : #accessing }
TwkPassivePlane >> columnValue [
	^ self passiveWidth
]

{ #category : #'as yet unclassified' }
TwkPassivePlane >> defaultRealMaterial [
	^ false
]

{ #category : #accessing }
TwkPassivePlane >> halfPoint [
	^ (self value * 0.5) @ self height
]

{ #category : #printing }
TwkPassivePlane >> inspectMarker [
	^ '- - -'
]

{ #category : #testing }
TwkPassivePlane >> isPassive [
	^ true
]

{ #category : #'as yet unclassified' }
TwkPassivePlane >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(passiveWidth); yourself 
]

{ #category : #'as yet unclassified' }
TwkPassivePlane >> lookupPassiveWidth [
	^ self parent lookupPassiveWidthOfHeight: self height
]

{ #category : #accessing }
TwkPassivePlane >> outCode [
	^'PASSIVE'

]

{ #category : #accessing }
TwkPassivePlane >> passiveWidth [
	^ passiveWidth ifNil: [ passiveWidth := self lookupPassiveWidth  ]
]

{ #category : #accessing }
TwkPassivePlane >> typeSymbol [
	^ '='
]

{ #category : #accessing }
TwkPassivePlane >> value [
	^ self passiveWidth
]

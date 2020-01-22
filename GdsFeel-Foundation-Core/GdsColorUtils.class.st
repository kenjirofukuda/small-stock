Class {
	#name : #GdsColorUtils,
	#superclass : #Object,
	#category : #'GdsFeel-Foundation-Core'
}

{ #category : #'as yet unclassified' }
GdsColorUtils class >> fromAttributes: aDictionary [ 
	| a r g b |
	a := (aDictionary at: 'a' ifAbsent: [1.0]) asNumber.		
	r := (aDictionary at: 'r' ifAbsent: [1.0]) asNumber.		
	g := (aDictionary at: 'g' ifAbsent: [1.0]) asNumber.		
	b := (aDictionary at: 'b' ifAbsent: [1.0]) asNumber.
	^Color r: r g: g b: b alpha: a. 										
]

{ #category : #'as yet unclassified' }
GdsColorUtils class >> rgbaAttributesOn: aDictionary color: aColor [
	aDictionary at: 'r' put: aColor red.
	aDictionary at: 'g' put: aColor green.
	aDictionary at: 'b' put: aColor blue.
	(aColor alpha closeTo: 1.0)
		ifFalse: [
			aDictionary at: 'a' put: aColor alpha].
	 
]

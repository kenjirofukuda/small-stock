Class {
	#name : #TwkStanObject,
	#superclass : #TwkNode,
	#instVars : [
		'number',
		'sequenceId',
		'tags',
		'type',
		'subType'
	],
	#category : #'TowerKit-STAN'
}

{ #category : #accessing }
TwkStanObject class >> arrayForCsvHeader [
	^ Array
		streamContents: [ :s | 
			self csvHeaderSharedOn: s.
			self csvHeaderOn: s.
			 ]
]

{ #category : #accessing }
TwkStanObject class >> csvHeaderSharedOn: s [
	s nextPut: #number.
	s nextPut: #tags.
	s nextPut: #type.

]

{ #category : #adding }
TwkStanObject >> addTag: aTag [ 
	tags add: aTag 
]

{ #category : #accessing }
TwkStanObject >> arrayForCsv [
	^ Array
		streamContents: [ :s | 
			self csvSharedOn: s.
			self csvDataOn: s.
			 ]
]

{ #category : #'objects from disk' }
TwkStanObject >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'number' put: self number.
	aDictionary at: 'brick' put: self parent name.
	aDictionary at: 'tags' put: self tags.		
	aDictionary at: 'type' put: self type.
		
	
]

{ #category : #accessing }
TwkStanObject >> csvSharedOn: s [
	s nextPut: self name.
	s nextPut: self tagsString.
	s nextPut: self type.

]

{ #category : #initialization }
TwkStanObject >> initialize [
	super initialize.
	number := -1.
	tags := Set new.
]

{ #category : #accessing }
TwkStanObject >> number [
	^ number
]

{ #category : #accessing }
TwkStanObject >> number: anInteger [
	number := anInteger.
	self name: number asString.
]

{ #category : #initialization }
TwkStanObject >> sequenceId [
	^ sequenceId
]

{ #category : #initialization }
TwkStanObject >> sequenceId: anInteger [
	sequenceId ifNotNil: [ self error: 'cant duplicate assign' ]. 
	sequenceId := anInteger
]

{ #category : #accessing }
TwkStanObject >> subType [
	^ subType 
]

{ #category : #accessing }
TwkStanObject >> subType: aString [
	subType := aString
]

{ #category : #accessing }
TwkStanObject >> tags [ 
	^ tags asSet asArray
]

{ #category : #accessing }
TwkStanObject >> tagsString [
	"P18 larger then B18"
	^ (self tags sort: [:a :b | a > b ]) joinUsing: ';' 
	
]

{ #category : #accessing }
TwkStanObject >> type [
	^ type
]

{ #category : #accessing }
TwkStanObject >> type: aString [
	type := aString
]

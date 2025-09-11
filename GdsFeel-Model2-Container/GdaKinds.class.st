Class {
	#name : #GdaKinds,
	#superclass : #Model,
	#instVars : [
		'kinds',
		'keyOrder'
	],
	#category : #'GdsFeel-Model2-Container'
}

{ #category : #accessing }
GdaKinds >> all [
	^ self keys collect: [ :key |  self atKey: key ]
]

{ #category : #accessing }
GdaKinds >> atKey: aKey [

	^ kinds at: aKey ifAbsent: [ nil ]
]

{ #category : #initialization }
GdaKinds >> initialize [
	keyOrder := OrderedCollection new.
	kinds := Dictionary new.
	self specRecords
		do: [ :triplet | 
			| kind |
			kind := GdaKind new initWithKey: triplet first description: triplet second.
			kind setVisible: triplet last.
			kind setSelectable: true.
			keyOrder add: triplet first.
			kinds at: triplet first put: kind.
			"kind selectableProperty whenChangedDo: [ self fireChanged ]."
			"kind visibleProperty whenChangedDo: [ self fireChanged ]" ].
	keyOrder := keyOrder asArray
]

{ #category : #accessing }
GdaKinds >> keys [
	^keyOrder
]

{ #category : #defaults }
GdaKinds >> specRecords [
	^ Array streamContents: [ :s |
		s nextPutAll: self specRecords1.
		(Smalltalk hasClassNamed: 'GdsAcPoint')
			ifTrue: [ s nextPut: {'PT' .  'POINT' . true}  ] .
		s nextPutAll: self specRecords2 ]

]

{ #category : #defaults }
GdaKinds >> specRecords1 [
	^{
	{'BD' .  'BOUNDARY' . true} . 
	{'PC' .  'PATH CENTER' . true} . 
	{'PB' .  'PATH BOUNDARY' . true} . 
	{'TX' .  'TEXT' . true} .
	{'TO' .  'TEXT ORIGIN' . false} .
	}
]

{ #category : #defaults }
GdaKinds >> specRecords2 [
	^{
	{'SO' .  'STRUCTURE ORIGIN' . false} .
	{'SE' .  'STRUCTURE EXTENT' . false} .
	{'AO' .  'ARRAY ORIGIN' . false} . 
	{'AB' .  'ARRAY BORDER'. false} .
	{'AE' .  'ARRAY EXTENT'. false} . 
	{'SL' .  'SEGMENT LENGTH'. false} . 
	{'PL' .  'POINT LOCATION'. false}
	"{'EX' . 'EXTERIOR DATA (STICKS)'. false}"
	}

]

Class {
	#name : #GdsKinds,
	#superclass : #Model,
	#instVars : [
		'kinds',
		'keyOrder',
		'announcer'
	],
	#category : #'GdsFeel-Model-Private'
}

{ #category : #accessing }
GdsKinds >> all [
	^ self keys collect: [ :key |  self atKey: key ]
]

{ #category : #accessing }
GdsKinds >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ].
]

{ #category : #'as yet unclassified' }
GdsKinds >> atKey: aKey [
	^kinds at: aKey ifAbsent: [nil]
]

{ #category : #'as yet unclassified' }
GdsKinds >> fireChanged [
	self announcer announce: (GdsKindsChanged new).
	
]

{ #category : #initialization }
GdsKinds >> initialize [
	keyOrder := OrderedCollection new.
	kinds := Dictionary new.
	self specRecords
		do: [ :triplet | 
			| kind |
			kind := GdsKind new initWithKey: triplet first description: triplet second.
			kind setVisible: triplet last.
			kind setSelectable: true.
			keyOrder add: triplet first.
			kinds at: triplet first put: kind.
			kind selectableProperty whenChangedDo: [ self fireChanged ].
			kind visibleProperty whenChangedDo: [ self fireChanged ] ].
	keyOrder := keyOrder asArray
]

{ #category : #accessing }
GdsKinds >> keys [
	^keyOrder
]

{ #category : #'as yet unclassified' }
GdsKinds >> specRecords [
	^ Array streamContents: [ :s |
		s nextPutAll: self specRecords1.
		(Smalltalk hasClassNamed: 'GdsAcPoint')
			ifTrue: [ s nextPut: {'PT' .  'POINT' . true}  ] .
		s nextPutAll: self specRecords2 ]

]

{ #category : #'as yet unclassified' }
GdsKinds >> specRecords1 [
	^{
	{'BD' .  'BOUNDARY' . true} . 
	{'PC' .  'PATH CENTER' . true} . 
	{'PB' .  'PATH BOUNDARY' . true} . 
	{'TX' .  'TEXT' . true} .
	{'TO' .  'TEXT ORIGIN' . false} .
	}
]

{ #category : #'as yet unclassified' }
GdsKinds >> specRecords2 [
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

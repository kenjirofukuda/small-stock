Class {
	#name : #TwkWire,
	#superclass : #Object,
	#instVars : [
		'name',
		'size',
		'unitWeight'
	],
	#category : #'TowerKit-Magritte'
}

{ #category : #'as yet unclassified' }
TwkWire class >> catalog [
	^ 'AC 45	8.7	0.3049
ACSR 200	20.3	0.9117
LP-AC 150	16.0	0.7152
NS-AC 220	18.9	1.0180
NS-ACSR/AC 410x2	28.5	1.5690
NS-OPGW 200	18.9	1.0130
OPGW 160	16.9	0.9424
TACSR/AC 160	18.2	0.6854
'

]

{ #category : #'as yet unclassified' }
TwkWire class >> exampleInstances [
	<script>
	self lookupInstances explore
]

{ #category : #'as yet unclassified' }
TwkWire class >> lookupInstances [
	^ self catalog lines collect: [ :line | | items |
		items := line findTokens: Character tab asString.
		TwkWire new
			name: (items at: 1);
			size: (items at: 2);
			unitWeight: (items at: 3);
			yourself. ]
]

{ #category : #'accessing-description' }
TwkWire >> descriptionName [
	<magritteDescription>
	^ MAStringDescription new
		priority: 10;
		label: '線種';
		accessor: #name;
		comment: 'ケーブル名称';
		yourself
]

{ #category : #'accessing-description' }
TwkWire >> descriptionSize [
	<magritteDescription>
	^ MANumberDescription new
		priority: 20;
		label: '外径';
		accessor: #size;
		comment: 'ケーブルの直径';
		yourself	
]

{ #category : #'accessing-description' }
TwkWire >> descriptionUnitWeight [
	<magritteDescription>
	^ MANumberDescription new
		priority: 20;
		label: '単位重量';
		accessor: #unitWeight;
		comment: 'ケーブルの単位重量 kg/m';
		yourself	
]

{ #category : #initialization }
TwkWire >> initialize [
	super initialize.
	size := 0.0.
	name := ''.
	unitWeight := 0.0.
]

{ #category : #accessing }
TwkWire >> name [
	^ name
]

{ #category : #accessing }
TwkWire >> name: aString [
	name := aString
]

{ #category : #printing }
TwkWire >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $).
	
]

{ #category : #accessing }
TwkWire >> size [
	^ size
]

{ #category : #accessing }
TwkWire >> size: aNumber [
	size := aNumber asNumber
	
]

{ #category : #accessing }
TwkWire >> unitWeight [
	^ unitWeight 
]

{ #category : #accessing }
TwkWire >> unitWeight: aNumber [
	unitWeight := aNumber asNumber
]

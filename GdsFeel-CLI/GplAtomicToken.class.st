Class {
	#name : #GplAtomicToken,
	#superclass : #GdsObject,
	#instVars : [
		'start',
		'end',
		'type',
		'parser',
		'fragment'
	],
	#category : #'GdsFeel-CLI-Kernel'
}

{ #category : #testing }
GplAtomicToken >> = aGplToken [
	^((self start = aGplToken start)
	and: [self end = aGplToken end])
	and: [self parser source = aGplToken parser  source]
	
]

{ #category : #accessing }
GplAtomicToken >> end [
	^end
]

{ #category : #accessing }
GplAtomicToken >> end: anInteger [
	end := anInteger.
	fragment := nil.
]

{ #category : #accessing }
GplAtomicToken >> fragment [
	^ fragment ifNil: [fragment := parser fragmentOfRange: self].
]

{ #category : #accessing }
GplAtomicToken >> length [
	^end - start + 1
]

{ #category : #accessing }
GplAtomicToken >> parser [
	^parser
]

{ #category : #accessing }
GplAtomicToken >> parser: aGplParser2 [
	parser := aGplParser2.

]

{ #category : #printing }
GplAtomicToken >> printOn: aStream [
	"fragment = #cr ifTrue: [^aStream nextPutAll: 'CR']".
	aStream nextPutAll: '['.	
	aStream nextPutAll: self start printString.
	self start = self end 
		ifFalse: [
			aStream nextPutAll: ','.	
			aStream nextPutAll: self end printString ].
	aStream nextPutAll: ']'.
	aStream nextPutAll: '('.
	aStream nextPutAll: self type printString.
	aStream nextPutAll: ','.
	aStream nextPutAll: self fragmentForInspect printString.
	aStream nextPutAll: ')'.	
	
]

{ #category : #accessing }
GplAtomicToken >> start [
	^start
]

{ #category : #accessing }
GplAtomicToken >> start: anInteger [
	start := anInteger.
	fragment := nil.
]

{ #category : #accessing }
GplAtomicToken >> start: startInteger end: endInteger type: typeSymbol [
	start := startInteger.
	end := endInteger.
	type := typeSymbol
]

{ #category : #accessing }
GplAtomicToken >> type [
	^type
]

{ #category : #accessing }
GplAtomicToken >> type: aSymbol [
	type := aSymbol
]

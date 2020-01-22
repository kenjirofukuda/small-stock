"
A GdsList is GDSII's LIST data structure.

Instance Variables
	elements:		<GdsDataStructure>

elements
	- xxxxx

"
Class {
	#name : #GdsList,
	#superclass : #GdsDataStructure,
	#instVars : [
		'elements'
	],
	#category : #'GdsFeel-CLI-Data'
}

{ #category : #accessing }
GdsList class >> mode [
	^6
]

{ #category : #'instance creation' }
GdsList class >> withAll: aGplValues [
	| newInstance |
	newInstance := self new.
	aGplValues do: [:each | newInstance add: each copy].
	^newInstance
]

{ #category : #'initialize-release' }
GdsList >> add: aGdsDataStructure [ 
	self assert: (aGdsDataStructure isKindOf: GdsDataStructure).
	(aGdsDataStructure isMemberOf: GdsList) 
		ifTrue: [aGdsDataStructure elements do: [:each | elements add: each]]
		ifFalse: [elements add: aGdsDataStructure]
]

{ #category : #convert }
GdsList >> asVector [
	^self runtimeError: 'ILLIGAL DATA MODE'.
]

{ #category : #accessing }
GdsList >> at: anIndex [
	((1 to: self elements size) includes: anIndex)
		ifFalse: [^self runtimeError: 'SUBSCRIPT OUT OF BOUNDS'].
	^self elements at: anIndex.
]

{ #category : #accessing }
GdsList >> atPutUsage [
	^'Only: [{Integer}] := {Array}'.
	
	
	
	
]

{ #category : #accessing }
GdsList >> atSubscript: aGdsDataStructure [
	| indexes list |
	(aGdsDataStructure asVector size = 1)
		ifFalse: [^self runtimeError: 'ILLIGAL DATA RANK. List subscription only scalar value'].
	indexes := self indexesOfSubscript: aGdsDataStructure.
	list := self class withAll: (self indexedValues: indexes).
	^list length = 1 ifTrue: [list at: 1] ifFalse: [list].
]

{ #category : #accessing }
GdsList >> atSubscript: aSubscript put: aGdsValue [
	| index |
	"subscipt := self subscriptArgumentCheck:  aSubscript."
	(aGdsValue isKindOf: GdsList)
		ifTrue: [^self error: self atPutUsage ].
	index := aSubscript asSmalltalkValue.
	((1 to: elements size) includes: index) 
		ifFalse: [^self error: 'SUBSCRIPT OUT OF RANGE'].
	elements at: index put: aGdsValue.
	
	
	
	
	
]

{ #category : #convert }
GdsList >> displayUnit [
	^4.
	

]

{ #category : #accessing }
GdsList >> elements [
	^elements asArray.
]

{ #category : #convert }
GdsList >> gplString [
	| numRepeat rem allUnits |
	allUnits := OrderedCollection new.
	numRepeat := self elements size quo: (self displayUnit).
	(0 to: (numRepeat - 1)) do: [:index |
		| start |
		start := (index * (self displayUnit)) + 1.
		allUnits add: (self elements copyFrom: start to:  (start + (self displayUnit) - 1))].
	rem := self elements size rem: (self displayUnit).
	(rem > 0) ifTrue: [allUnits add: (self elements  last: rem)].
	^(allUnits collect: [:each | self gplStringUnit: each]) joinUsing: (String cr, String cr). 

]

{ #category : #convert }
GdsList >> gplStringUnit: aCollection [
	| nRow nCol colWidth mat colStart cols spaceSize |
	spaceSize := 2.
	nRow := (aCollection collect: [:each | each gplString lines size]) max.
	colWidth := aCollection collect: [:each | 
		each gplString isEmpty
			ifTrue: [0]
			ifFalse: [
				(each gplString lines 
					collect: [:each2 | each2 size]) max]].
	nCol := colWidth sum + ((aCollection size * spaceSize) - 1).
	mat := Matrix rows: nRow columns: nCol element: Character space.
	colStart := 1.
	aCollection doWithIndex: [:each :index| 
		| lines iCol  |
		lines := each gplString lines.
		lines doWithIndex: [:each2 :index2 |
			iCol := colStart.
	  		each2 asArray do: [:ch |
				mat at: index2 at: iCol put: ch.
				iCol := iCol + 1.].].
		colStart := colStart + (colWidth at: index) + spaceSize.].
	cols := OrderedCollection new.
	(1 to: mat rowCount)  do: [:index | cols add: (String withAll: (mat atRow: index)) ].
	^cols joinUsing: String cr.
]

{ #category : #'initialize-release' }
GdsList >> initialize [
	elements := OrderedCollection new.
	
]

{ #category : #testing }
GdsList >> isList [
	^true
]

{ #category : #accessing }
GdsList >> length [
	^self elements size.
]

{ #category : #printing }
GdsList >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	self elements do: [:each | 
		aStream nextPutAll: each gplSourceString.
		aStream nextPut: $;.].
	aStream skip: -1.
	aStream nextPutAll: ')'.
	
]

{ #category : #accessing }
GdsList >> rank [
	^self runtimeError: 'ILLIGAL DATA MODE'.
]

{ #category : #accessing }
GdsList >> shape [
	^self runtimeError: 'ILLIGAL DATA MODE'.
]

{ #category : #accessing }
GdsList >> size [
	^self runtimeError: 'ILLIGAL DATA MODE'.
]

{ #category : #accessing }
GdsList >> subscriptCheckForAssign:  aSubscript [
	| subscipt |
	subscipt := aSubscript.
	(aSubscript isMemberOf: GdsVector)
		ifTrue: [aSubscript size = 1
			ifTrue: [subscipt := aSubscript at: 1]
			ifFalse: [^self error: self atPutUsage ]].
	(aSubscript isKindOf: GdsScalar)
		ifFalse: [^self error: self atPutUsage ].
	(subscipt isKindOf: GdsIntegral)
		ifFalse: [^self error: self atPutUsage ].
	^self subscriptCheckFor: subscipt
	
	
	
]

{ #category : #accessing }
GdsList >> typeString [
	^'LIST'
]

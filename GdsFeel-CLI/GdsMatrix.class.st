"
A GdsDataMatrix is GPLII's Matrix.

Instance Variables
	stMatrix:		<Matrix<GdsDglType>>

stMatrix
	- sclar elements Smallk's value holder 

"
Class {
	#name : #GdsMatrix,
	#superclass : #GdsArray,
	#instVars : [
		'stMatrix'
	],
	#category : #'GdsFeel-CLI-Data'
}

{ #category : #'as yet unclassified' }
GdsMatrix class >> fromGdsVector: aGdsDataVector col: aColCount [
	^ self fromGdsVector: aGdsDataVector row: 1 col: aColCount
]

{ #category : #'as yet unclassified' }
GdsMatrix class >> fromGdsVector: aGdsDataVector row: aRowCount col: aColCount [
	| size fillSize appends total fillCount vector |
	vector := aGdsDataVector asVector.
	size := aColCount * aRowCount.
	fillSize := 0.
	total := OrderedCollection new.
	appends := #().
	vector size < size
		ifTrue: [ fillSize := size rem: vector size.
			fillCount := size quo: vector size.
			fillCount timesRepeat: [ total addAll: vector elements ].
			appends := fillSize > 0
				ifTrue: [ vector copyFrom: 1 to: fillSize ]
				ifFalse: [ appends ] ]
		ifFalse: [ total addAll: (vector copyFrom: 1 to: size) ].
	total addAll: appends.
	^ self new rows: aRowCount columns: aColCount contents: total
]

{ #category : #'as yet unclassified' }
GdsMatrix class >> fromOrigin: anOrigin corner: aCorner [
	| gplVec |
	gplVec := {anOrigin x.
	anOrigin y.
	aCorner x.
	aCorner y} asGdsValue.
	^ GdsMatrix fromGdsVector: gplVec row: 2 col: 2
]

{ #category : #'as yet unclassified' }
GdsMatrix class >> fromRectangle: aRectangle [
	^ self fromOrigin: aRectangle origin corner: aRectangle corner
]

{ #category : #accessing }
GdsMatrix class >> rank [
	^ 2
]

{ #category : #arithmetic }
GdsMatrix >> applySymbol: aSymbol to: aObject [
	| target calcedVec |
	self applySymbolCheck: aSymbol to: aObject.
	self assert: [ self isScalar not ].
	target := aObject.
	((aObject isKindOf: GdsScalar) or: [ aObject isMemberOf: GdsMatrix ])
		ifTrue: [ target := aObject asVector: self size ]
		ifFalse: [ self shape = aObject shape
				ifFalse: [ ^ self error: 'INVALID SHAPE ' ] ].
	calcedVec := self asVector applySymbol: aSymbol to: target.
	^ self fromGdsVector: calcedVec
]

{ #category : #convert }
GdsMatrix >> asGdsFloating [
	^ self fromGdsVector: super asGdsFloating
]

{ #category : #convert }
GdsMatrix >> asVector [
	^ self vectorClass withAll: stMatrix contents copy
]

{ #category : #accessing }
GdsMatrix >> at: aInteger [
	^ [ self asVector at: aInteger ]
		on: Error
		do: [ :ex | self runtimeError: 'SUBSCRIPTION OUT OF RANGE' ]
]

{ #category : #accessing }
GdsMatrix >> at: rowIndex at: columnIndex [
	^ stMatrix at: rowIndex at: columnIndex
]

{ #category : #accessing }
GdsMatrix >> atSubscript: aSubscript [
	| mat result |
	"self subscriptArgumentCheck: aSubscript."
	mat := self subscriptMatrix: aSubscript.
	(mat rowCount = 1 and: [ mat columnCount = 1 ])
		ifTrue: [ ^ (mat at: 1 at: 1) copy ].
	(mat rowCount = 1 and: [ mat columnCount ~= 1 ])
		ifTrue: [ ^ self vectorClass withAll: (mat atRow: 1) ].
	(mat rowCount ~= 1 and: [ mat columnCount = 1 ])
		ifTrue: [ ^ self vectorClass withAll: (mat atColumn: 1) ].
	result := self class new.
	result instVarNamed: 'stMatrix' put: mat copy.
	^ result
]

{ #category : #accessing }
GdsMatrix >> atSubscript: aSubscript put: aGdsValue [
	| mat pair pairs reshapedValue |
	"self subscriptArgumentCheck: aSubscript."
	mat := self subscriptIndexMatrix: aSubscript.
	reshapedValue := aGdsValue.
	(mat rowCount = 1 and: [ mat columnCount = 1 ])
		ifTrue: [ (aGdsValue isKindOf: GdsScalar)
				ifFalse: [ self error: 'ONLY: [r;c] := {Scalar}' ].
			pair := mat at: 1 at: 1.
			stMatrix at: pair first at: pair second put: aGdsValue copy.
			^ aGdsValue ].
	(mat rowCount = 1 and: [ mat columnCount ~= 1 ])
		ifTrue: [ (aGdsValue isKindOf: GdsScalar)
				ifTrue: [ reshapedValue := aGdsValue asVector: stMatrix columnCount ].
			(reshapedValue isKindOf: GdsVector)
				ifFalse: [ ^ self error: 'ONLY: [r; ] := {Vector}' ].
			reshapedValue size = stMatrix columnCount
				ifFalse: [ ^ self
						error:
							'VECTOR SIZE MUST: ' , stMatrix columnCount asString , ' BUT: '
								, reshapedValue size asString ].
			pairs := mat atRow: 1.
			pairs
				do: [ :each | stMatrix atRow: each first put: reshapedValue elements ].
			^ aGdsValue ].
	(mat rowCount ~= 1 and: [ mat columnCount = 1 ])
		ifTrue: [ (aGdsValue isKindOf: GdsScalar)
				ifTrue: [ reshapedValue := aGdsValue asVector: stMatrix rowCount ].
			(reshapedValue isKindOf: GdsVector)
				ifFalse: [ ^ self error: 'ONLY: [;c] := {Vector}' ].
			reshapedValue size = stMatrix rowCount
				ifFalse: [ ^ self
						error:
							'VECTOR SIZE MUST: ' , stMatrix rowCount asString , ' BUT: '
								, aGdsValue size asString ].
			pairs := mat atColumn: 1.
			pairs
				do: [ :each | stMatrix atColumn: each second put: reshapedValue elements ].
			^ aGdsValue ].
	(aGdsValue isKindOf: GdsScalar)
		ifTrue: [ reshapedValue := GdsMatrix
				fromGdsVector: aGdsValue
				row: mat rowCount
				col: mat columnCount ].
	(Array with: mat rowCount with: mat columnCount) = aGdsValue shape
		ifFalse: [ ^ self error: 'SUBSCRIPT SHAPE MISS MATCH MUST: ' ].
	(1 to: mat rowCount)
		do: [ :ri | 
			(1 to: mat columnCount)
				do: [ :ci | 
					pair := mat at: ri at: ci.
					stMatrix
						at: pair first
						at: pair second
						put: (reshapedValue at: ri at: ci) copy ] ].
	^ aGdsValue
]

{ #category : #accessing }
GdsMatrix >> columnCount [
	^ stMatrix columnCount
]

{ #category : #accessing }
GdsMatrix >> elements [
	^ stMatrix readStream contents asArray
]

{ #category : #'instance creation' }
GdsMatrix >> fromGdsScalar: aGdsScalar [
	self assert: [ aGdsScalar isKindOf: GdsScalar ].
	^ self class
		fromGdsVector: (aGdsScalar asVector: self size)
		row: self rowCount
		col: self columnCount
]

{ #category : #'instance creation' }
GdsMatrix >> fromGdsVector: aGdsVector [
	self
		assert: [ (aGdsVector isMemberOf: GdsVector) or: [ aGdsVector isCharVector ] ].
	^ self class
		fromGdsVector: aGdsVector
		row: self rowCount
		col: self columnCount
]

{ #category : #accessing }
GdsMatrix >> gplString [
	(self typeString beginsWith: 'REAL')
		ifTrue: [ ^ self gplStringFloating ].
	^ self gplStringNonFloating
]

{ #category : #private }
GdsMatrix >> gplStringFloating [
	| maxWidths strings |
	(stMatrix contents
		anySatisfy: [ :each | each gplString includes: $E ])
		ifTrue: [ ^ self gplStringNonFloating ].
	maxWidths := self maxGplStringWidthPair.
	strings := OrderedCollection new.
	1 to: stMatrix rowCount do: [ :index | 
		strings
			add:
				(GdsVector
					gplStringValues: (stMatrix atRow: index)
					paddLeftWidth: maxWidths first
					rightWidth: maxWidths second) ].
	^ strings joinUsing: String cr
]

{ #category : #private }
GdsMatrix >> gplStringNonFloating [
	| strings maxWidth |
	maxWidth := self maxGplStringWidth.
	strings := OrderedCollection new.
	1 to: stMatrix rowCount do: [ :index | 
		strings
			add:
				(GdsVector
					gplStringValues: (stMatrix atRow: index)
					paddWidth: maxWidth) ].
	^ strings joinUsing: String cr
]

{ #category : #convert }
GdsMatrix >> gplValueOfShape [
	^ GdsVector
		withAll:
			{(GdsInteger fromLiteral: stMatrix rowCount).
			(GdsInteger fromLiteral: stMatrix columnCount)}
]

{ #category : #private }
GdsMatrix >> indexesOf: aGdsDataStructure at: aIndex [
	| indexes gplValue ranges outRanges |
	ranges := 1 to:
		(aIndex = 1
			ifTrue: [ self rowCount ]
			ifFalse: [ self columnCount ]).
	indexes := ranges asArray.
	gplValue := aGdsDataStructure at: aIndex.
	gplValue rank = 0
		ifTrue: [ indexes := Array with: gplValue asSmalltalkValue ].
	(gplValue rank = 1 and: [ gplValue ~= GdsNull instance ])
		ifTrue: [ indexes := gplValue asSmalltalkValue ].
	outRanges := indexes reject: [ :each | ranges includes: each ].
	outRanges isEmpty
		ifFalse: [ ^ self error: 'SUBSCRIPT OUT OF RANGE ' , outRanges printString ].
	^ indexes
]

{ #category : #private }
GdsMatrix >> maxGplStringWidth [
	^ (stMatrix contents collect: [ :each | each gplString size ]) max
]

{ #category : #private }
GdsMatrix >> maxGplStringWidthPair [
	"{ leftWidth . rightWidth }"

	| leftMax rightMax |
	leftMax := 0.
	rightMax := 0.
	stMatrix contents
		do: [ :each | 
			| s items |
			s := each gplString.
			items := {(s copyFrom: 1 to: (s indexOf: $.) - 1).
			(s copyFrom: (s indexOf: $.) + 1 to: s size)}.
			leftMax := leftMax max: items first size.
			rightMax := rightMax max: items second size ].
	^ Array with: leftMax with: rightMax
]

{ #category : #accessing }
GdsMatrix >> mode [
	stMatrix ifNil: [ ^ GdsNull mode ].
	stMatrix asOrderedCollection ifEmpty: [ ^ GdsNull mode ].
	^ stMatrix asOrderedCollection first mode
]

{ #category : #convert }
GdsMatrix >> mostCompactValue [
	^ self fromGdsVector: super mostCompactValue
]

{ #category : #private }
GdsMatrix >> newElementSelector: aSelector [
	| gdsArray |
	gdsArray := super newElementSelector: aSelector.
	^ self class
		fromGdsVector: gdsArray
		row: self rowCount
		col: self columnCount
]

{ #category : #printing }
GdsMatrix >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	(1 to: stMatrix rowCount)
		do: [ :index | 
			aStream nextPut: $[.
			aStream
				nextPutAll: (GdsVector gplStringValues: (stMatrix atRow: index)).
			aStream nextPut: $].
			aStream nextPut: $, ].
	aStream skip: -1.
	aStream nextPut: $)
]

{ #category : #accessing }
GdsMatrix >> rowCount [
	^ stMatrix rowCount
]

{ #category : #'initialize-release' }
GdsMatrix >> rows: rows columns: columns contents: anArray [
	stMatrix := Matrix rows: rows columns: columns contents: anArray
]

{ #category : #accessing }
GdsMatrix >> shape [
	^ Array with: stMatrix rowCount with: stMatrix columnCount
]

{ #category : #accessing }
GdsMatrix >> size [
	^ stMatrix size
]

{ #category : #accessing }
GdsMatrix >> subscriptCheckFor: aSubscript [
	(aSubscript isMemberOf: GdsList)
		ifFalse: [ ^ self error: 'ILLIGAL SUBSCRIPT ACCESS. only [row;col]' ].
	aSubscript length = 2
		ifFalse: [ ^ self error: 'ILLIGAL SUBSCRIPT ACCESS. only [row;col]' ].
	super subscriptCheckFor: (aSubscript at: 1).
	super subscriptCheckFor: (aSubscript at: 2).
	^ aSubscript
]

{ #category : #private }
GdsMatrix >> subscriptIndexMatrix: aGdsDataStructure [
	| rowIndexes columnIndexes mat |
	rowIndexes := self indexesOf: aGdsDataStructure at: 1.
	columnIndexes := self indexesOf: aGdsDataStructure at: 2.
	mat := Matrix rows: rowIndexes size columns: columnIndexes size.
	rowIndexes
		doWithIndex: [ :ra :ri | 
			columnIndexes
				doWithIndex: [ :ca :ci | mat at: ri at: ci put: (Array with: ra with: ca) ] ].
	^ mat
]

{ #category : #private }
GdsMatrix >> subscriptMatrix: aGdsDataStructure [
	| rowIndexes columnIndexes mat |
	rowIndexes := self indexesOf: aGdsDataStructure at: 1.
	columnIndexes := self indexesOf: aGdsDataStructure at: 2.
	mat := Matrix rows: rowIndexes size columns: columnIndexes size.
	rowIndexes
		doWithIndex: [ :ra :ri | 
			columnIndexes
				doWithIndex: [ :ca :ci | mat at: ri at: ci put: (stMatrix at: ra at: ca) ] ].
	^ mat
]

{ #category : #accessing }
GdsMatrix >> typeString [
	stMatrix ifNil: [ ^ GdsNull typeString ].
	stMatrix asOrderedCollection ifEmpty: [ ^ GdsNull typeString ].
	^ stMatrix asOrderedCollection first typeString
]

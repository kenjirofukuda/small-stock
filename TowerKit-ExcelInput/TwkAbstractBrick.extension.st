Extension { #name : #TwkAbstractBrick }

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> attachWidths: aWidthValues forFace: aTwkFace [
	| lastIndex |
	lastIndex := 0.
	aWidthValues
		doWithIndex: [ :each :index | 
			| nSkip |
			nSkip := 0.
			each isNumber			
				ifTrue: [ 
					lastIndex = 0
						ifFalse: [ 
							nSkip := index - lastIndex.
							self logCr: ('<1p> skip count: <2p>' expandMacrosWith: aTwkFace with: nSkip). ].
					nSkip > 0
						ifTrue: [ aTwkFace skipSpans: nSkip ].
					aTwkFace addWidth: each.
					lastIndex := index ] ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> crossOrdersExcelInput [
	^ self subclassResponsibility 
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelCrossValues: aDictionary [
	self crossOrdersExcelInput
		do: [ :inf | 
			(self faceAt: inf first)
				ifNotNil: [ :face | 
					| crosses |
					crosses := Array new: self spanValues size.
					crosses doWithIndex: [ :each :index | crosses at: index put: OrderedCollection new ].
					inf allButFirst
						do: [ :index2 | 
							| vals |
							vals := aDictionary at: 'spanFaceCrosses' , index2 asString.
							vals doWithIndex: [ :each :index3 | each ifNotEmpty: [ (crosses at: index3) add: each asSymbol ] ] ].
					face crossValues: crosses ] ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelDepthSectionUsing: aDictionary [
	|  map |
	map := Dictionary new.
	(aDictionary at: 'spanSectionNames')
		doWithIndex: [ :each :index | 
			| col |
			each
				ifNotEmpty: [ 
					col := map at: each ifAbsentPut: [ OrderedCollection new ].
					col add: index ] ].
	map keysAndValuesDo: [ :key :value | self sectionUsing: key depthIndexes: value ].
	

]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelInputMap: aDictionary builder: aTwkBuilderForExcel [
	self spanValues: (aDictionary at: 'spanVolumes').
	self fromExcelSectionUsing: aDictionary.
	self fromExcelDepthSectionUsing: aDictionary.
	self fromExcelCrossValues: aDictionary.
	self fromExcelRoundFrame: aDictionary.
	self fromExcelSliceWidth: aDictionary.
	self fromExcelSections: aDictionary.
	self fromExcelStanZOffset: aDictionary.
	aTwkBuilderForExcel autoAllocateNumbers
		ifFalse: [ 
			self fromExcelNodeNumbers: aDictionary.
			self fromExcelSegmentNumbers: aDictionary ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelNodeNumbers: aDictionary [
	(aDictionary at: 'topNodeNumbers')
		keysAndValuesDo: [ :key :value | 
			| numberOrContinue |
			numberOrContinue := value = 'continue'
				ifTrue: [ value asSymbol ]
				ifFalse: [ value ].
			self topNodeNumber: numberOrContinue for: key asSymbol ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelRoundFrame: aDictionary [
	| indexes |
	self defaultPlaneRealMaterial: false.
	indexes := OrderedCollection new.
	(aDictionary at: 'hasRoundFrame')
		doWithIndex: [ :each :index | 
			each ~= 0
				ifTrue: [ indexes add: index ] ].
	self realMaterial: true indexes: indexes asArray
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelSectionUsing: aDictionary [
	|  map |
	map := Dictionary new.
	(aDictionary at: 'sectionNames')
		doWithIndex: [ :each :index | 
			| col |
			each
				ifNotEmpty: [ 
					col := map at: each ifAbsentPut: [ OrderedCollection new ].
					col add: index ] ].
	map keysAndValuesDo: [ :key :value | self sectionUsing: key indexes: value ].
	

]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelSections: aDictionary [
	(aDictionary at: 'sections')
		do: [ :map | 
			self
				addSection: [ :section | 
					section name: (map at: 'name').
					section crossValues: ((map at: 'crossValues') collect: [ :each | each asSymbol ]).
					(map at: 'useSpan') = 1
						ifTrue: [ section depthSplit: true ] ] ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelSegmentNumbers: aDictionary [
	(aDictionary at: 'topSegmentNumbers')
		keysAndValuesDo: [ :key :value | 
			| numberOrContinue |
			numberOrContinue := value = 'continue'
				ifTrue: [ value asSymbol ]
				ifFalse: [ value ].
			self topSegmentNumber: numberOrContinue for: key asSymbol ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelSliceWidth: aDictionary [
	| vals |
	vals := aDictionary at: 'widthFront'.
	self frontSymbols do: [ :each | self attachWidths: vals forFace: (self faceAt: each) ].
	vals := aDictionary at: 'widthSide'.
	self sideSymbols do: [ :each | self attachWidths: vals forFace: (self faceAt: each) ]
]

{ #category : #'*TowerKit-ExcelInput' }
TwkAbstractBrick >> fromExcelStanZOffset: aDictionary [
	(aDictionary at: 'stanZOffset' ifAbsent: [  ])
		ifNotNil: [ :value | 
			value isNumber
				ifTrue: [ self setProperty: #stanZOffset toValue: value ] ]
]

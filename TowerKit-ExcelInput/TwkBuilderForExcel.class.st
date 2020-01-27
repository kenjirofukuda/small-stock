Class {
	#name : #TwkBuilderForExcel,
	#superclass : #Object,
	#instVars : [
		'inputParamMap',
		'autoAllocateNumbers',
		'compositBrick',
		'standaloneName'
	],
	#category : #'TowerKit-ExcelInput'
}

{ #category : #'as yet unclassified' }
TwkBuilderForExcel class >> runFromCommandLine [
	<script>
	| excelOutFile builder |
	self logCr: '----- runFromCommandLine -----'.
	TwkCross initialize.
	excelOutFile := FileLocator documents / 'TowerKit' / 'input_params.json'.
	excelOutFile isFile
		ifFalse: [ ^ self inform: excelOutFile name , ' not found' ].
	builder := TwkBuilderForExcel new
		fromExcelParamFile: excelOutFile;
		yourself.
	builder run.
	ThisOSProcess isHeadless
		ifFalse: [ builder explore ].
	self logCr: '----- /runFromCommandLine -----'.
	self logCr: ''.
	self logCr: ''
]

{ #category : #private }
TwkBuilderForExcel >> addBrick [
	(inputParamMap at: 'posts')
		detect: [ :m | (m at: 'name') sameAs: self standaloneName ]
		ifFound: [ :m2 | compositBrick addPostNamed: (m2 at: 'name') ]
		ifNone: [ 
			(inputParamMap at: 'beams')
				detect: [ :m | (m at: 'name') sameAs: self standaloneName ]
				ifFound: [ :m2 | compositBrick addBeamNamed: (m2 at: 'name') ]
				ifNone: [  ] ]
]

{ #category : #private }
TwkBuilderForExcel >> addBricks [
	((inputParamMap at: 'posts') collect: [ :m | m at: 'name' ])
		do: [ :each | compositBrick addPostNamed: each ].
	((inputParamMap at: 'beams') collect: [ :m | m at: 'name' ])
		do: [ :each | compositBrick addBeamNamed: each ].

]

{ #category : #analisys }
TwkBuilderForExcel >> analisysMap [
	| map |
	map := Dictionary new.
	compositBrick allBricks
		do: [ :brick | 
			| subMap |
			subMap := Dictionary new.
			subMap at: 'nodes' put: (self analisysMapOfBrick: brick selector: #stanNodes ).
			subMap at: 'segs' put: (self analisysMapOfBrick: brick selector: #stanSegments ).			
			map at: brick name put: subMap ].
	^ map
]

{ #category : #analisys }
TwkBuilderForExcel >> analisysMapOfBrick: aTwkAbstractBrick selector: aGetNodesSelector [
	| map nodesOfBrick types |
	map := Dictionary new.
	nodesOfBrick := aTwkAbstractBrick perform: aGetNodesSelector.
	types := (nodesOfBrick collect: [ :node | node subType ]) asSet.
	types do: [ :type | 
		map at: type put: (nodesOfBrick count: [ :node | node subType = type ]) ].
	^ map
]

{ #category : #accessing }
TwkBuilderForExcel >> autoAllocateNumbers [
	^ autoAllocateNumbers
]

{ #category : #accessing }
TwkBuilderForExcel >> autoAllocateNumbers: aBoolean [
	autoAllocateNumbers := aBoolean
]

{ #category : #analisys }
TwkBuilderForExcel >> fileOutAnalisys [
	| map |
	map := self analisysMap.
	map
		keysAndValuesDo: [ :brickName :subMap | 
			| file |
			file := compositBrick projectFolder / ('<1s>.analisys.txt' expandMacrosWith: brickName).
			file ensureDelete.
			file
				mbWriteStreamDo: [ :s | 
					| writer |
					writer := NeoCSVWriter on: s.
					writer fieldWriter: #raw.
					writer separator: Character tab.
					writer nextPut: #(#kind #category #count).
					subMap
						keysAndValuesDo: [ :kind :subMap2 | 
							subMap2
								keysAndValuesDo:
									[ :category :count | writer nextPut: (Array with: kind with: category with: count) ] ] ] ]
]

{ #category : #private }
TwkBuilderForExcel >> fileOutInputParams [
	compositBrick projectFolder / 'input_params.json'
		ifNotNil: [ :file | 
			file
				ensureDelete;
				mbWriteStreamDo: [ :s | 
					(NeoJSONWriter on: s)
						prettyPrint: true;
						nextPut: inputParamMap ] ]
]

{ #category : #running }
TwkBuilderForExcel >> fillAll [
	self addBricks.
	self linkBricks.
	self fillBricks.
]

{ #category : #private }
TwkBuilderForExcel >> fillBrick [
	(inputParamMap at: 'posts')
		do: [ :m | 
			((m at: 'name') sameAs: self standaloneName)
				ifTrue: [ ^ (compositBrick postNamed: (m at: 'name')) fromExcelInputMap: m builder: self ] ].

	(inputParamMap at: 'beams')
		do: [ :m | 
			((m at: 'name') sameAs: self standaloneName)
				ifTrue: [ ^ (compositBrick beamNamed: (m at: 'name')) fromExcelInputMap: m builder: self ] ]
]

{ #category : #private }
TwkBuilderForExcel >> fillBricks [
	(inputParamMap at: 'posts') do: [ :m | (compositBrick postNamed: (m at: 'name')) fromExcelInputMap: m builder: self].
	(inputParamMap at: 'beams') do: [ :m | (compositBrick beamNamed: (m at: 'name')) fromExcelInputMap: m builder: self].
	

]

{ #category : #running }
TwkBuilderForExcel >> fillStandalone [
	self addBrick.
	self fillBrick.

]

{ #category : #initalize }
TwkBuilderForExcel >> fromExcelParamFile: aFileReference [ 
	| map |
	map := (NeoJSONReader on:  aFileReference asFileReference  readStream ) next.
	inputParamMap := map.
]

{ #category : #initalize }
TwkBuilderForExcel >> initialize [
	super initialize.
	autoAllocateNumbers := false.
	standaloneName := ''.
]

{ #category : #testing }
TwkBuilderForExcel >> isStandalone [
	^ self standaloneName isEmptyOrNil not
]

{ #category : #private }
TwkBuilderForExcel >> linkBricks [
	| sortedPosts sortedBeams |
	sortedPosts := compositBrick posts sort: [ :a :b | a number < b number ].
	sortedBeams := compositBrick beams sort: [ :a :b | a number < b number ].
	sortedBeams size > sortedPosts size
		ifTrue: [ 
			sortedBeams := [ sortedBeams copyFrom: 1 to: sortedPosts size ]
				on: Error
				do: [ :ex | #() ] ].

	sortedBeams
		doWithIndex: [ :each :index | 
			each from: (sortedPosts at: index).
			sortedPosts size >= (index + 1)
				ifTrue: [ each to: (sortedPosts at: index + 1) ] ]
]

{ #category : #running }
TwkBuilderForExcel >> publishThreeJs [
	self threeJsTemplateDirectory
		ifNotNil: [ :srcDir | 
			srcDir isDirectory
				ifTrue: [ | dstDir |
					dstDir := compositBrick projectFolder / 'public_html'.
					dstDir isDirectory
						ifFalse: [ 
							dstDir ensureCreateDirectory.
							srcDir copyAllTo: dstDir ] ] ]
]

{ #category : #running }
TwkBuilderForExcel >> run [
	compositBrick := TwkCompositBrick new.
	compositBrick name: (inputParamMap at: 'projectName').
	compositBrick setProperty: #excelTimestamp toValue: (inputParamMap at: 'timestamp').
	compositBrick fileOutDxfEnabled: (inputParamMap at: 'fileOutDxf' ifAbsent: [ true ]).
	self autoAllocateNumbers: (inputParamMap at: 'allocateAutoNumber').
	self standaloneName: (inputParamMap at: 'standaloneName' ifAbsent: [ '' ]).
	self isStandalone
		ifTrue: [ self fillStandalone ]
		ifFalse: [ self fillAll ].
	compositBrick verify.
	Cursor wait
		showWhile: [ 
			self publishThreeJs.
			compositBrick buildOutputFiles.
			 self fileOutInputParams ].
	self autoAllocateNumbers
		ifTrue: [ self fileOutAnalisys ]
]

{ #category : #accessing }
TwkBuilderForExcel >> standaloneName [
	^ standaloneName
]

{ #category : #accessing }
TwkBuilderForExcel >> standaloneName: aString [
	standaloneName := aString
]

{ #category : #accessing }
TwkBuilderForExcel >> threeJsTemplateDirectory [
	^ (FileLocator image parent / 'public_html' )  
]

Extension { #name : #TwkCompositBrick }

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick class >> fileNameForThreejsData [
	^ 'tower-data.js'.
	
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> fileOutForStan [
	| nodeBlock segmentBlock |
	nodeBlock := [ self stanFileOutNodes ].
	segmentBlock := [ self stanFileOutSegments ].
	ThisOSProcess isHeadless
		ifTrue: [ 
			nodeBlock
				on: Error
				do: [ :ex | 
					self inform: (String tab
						join:
							{'TowerKit:'.
							'FileOpend'.
							(self projectFolder / 'NODES.csv') asString})  ].
			segmentBlock
				on: Error
				do: [ :ex | 
					self inform: (String tab
						join:
							{'TowerKit:'.
							'FileOpend'.
							(self projectFolder / 'SEGS.csv') asString})  ] 					 ]
		ifFalse: [ 
			nodeBlock value.
			segmentBlock value ] .
		self stanFileOutThreejs
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> nodeCenter [
	^ self
		valueOfProperty: #nodeCenter
		ifAbsentPut: [ 
			TwkStanNodeCenter new
				parent: self;
				yourself ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> privateStanNodes [
	^ Array streamContents: [ :s | self allBricks do: [ :b | s nextPutAll: b stanNodes ] ].

]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> privateStanSegments [
	^ Array
		streamContents: [ :s | 
			self allBricks
				do: [ :b | s nextPutAll: b stanSegments ]
				displayingProgress: 'Make Segments ...' ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanEdgeNumbers [
	^ Array streamContents: [ :s | self allBricks do: [ :b | s nextPutAll: b stanEdgeNumbers ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanFileOutNodes [
	| file |
	file := self projectFolder / 'NODES.csv'.
	file ensureDelete.	
	file
		mbWriteStreamDo: [ :s | 
			| writer |
			writer := NeoCSVWriter on: s.
			writer fieldWriter: #raw.
			writer nextPut: TwkStanNode arrayForCsvHeader.
			self nodeCenter stanNodes 
				do: [ :each |  
					writer nextPut: each arrayForCsv ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanFileOutSegments [
	| file |
	file := self projectFolder / 'SEGS.csv'.
	file ensureDelete.
	file
		mbWriteStreamDo: [ :s | 
			| writer |
			writer := NeoCSVWriter on: s.
			writer fieldWriter: #raw.
			writer nextPut: TwkSegment arrayForCsvHeader.
			self stanSegments 
				do: [ :each |  
					writer nextPut: each arrayForCsv ] 
				displayingProgress: 'Output SEGS.csv']	 
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanFileOutSeparated [
	|  outFileBlock |
	outFileBlock := [:brick :part | | f |
		f := self projectFolder / (((Array with: brick name with: 'STAN' with: part ) joinUsing: '_'), '.csv').
		f].
	
	self allBricks do: [ :brick | 
		(outFileBlock value: brick value: 'SLOPE') 
			mbWriteStreamDo: [ :s |
				brick writeStanSlopeCsvOutputTo: s withHeader: true].
		(outFileBlock value: brick value: 'MIDPOINT') 
			mbWriteStreamDo: [ :s |
				brick writeStanFacePointCsvOutputTo: s withHeader: true].
		(outFileBlock value: brick value: 'SECTION') 
			mbWriteStreamDo: [ :s |
				brick writeStanSectionCenterCsvOutputTo: s withHeader: true] ] 	 
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanFileOutThreejs [
	| defaultOut |
	defaultOut := self projectFolder / 'public_html'.
	defaultOut isDirectory
		ifTrue: [ 
			| file jsData |
			file := defaultOut / self class fileNameForThreejsData.
			jsData := self threejsData.
			file
				ensureDelete;
				mbWriteStreamDo: [ :s | 
					self
						threejsOn: s
						during: [ (NeoJSONWriter on: s)
								prettyPrint: true;
								nextPut: jsData ] ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanNodes [
	self privateStanNodes.
	^ self nodeCenter stanNodes.
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanNodesFinal [
	|   |
	self stanNodes.
	self allBricks do: [ :each | each stanFillNodeNumbers ].		
	^ self nodeCenter stanNodes
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanNodesForBeamSlope [
	^ (self beams collect: [ :each | each stanNodesForSlope ]) flattened
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanNodesForPostSlope [
	^ (self posts collect: [ :each | each stanNodesForSlope ]) flattened
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanPoints: aPoints JavascriptOn: aWriteStream [
	self threejsOn: aWriteStream during: [ 
	(NeoJSONWriter on: aWriteStream)
		prettyPrint: true;
		nextPut: aPoints.
 ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> stanSegments [
	| segs allNodes |
	segs := self privateStanSegments.
	allNodes := self nodeCenter stanNodes.
	^ segs collect: [ :seg |
		| startNode endNode |
		"self haltIf: [ seg to number = 453 ]."
		startNode := allNodes detect: [ :node | node number = seg from number ] ifNone: [  ]. 
		startNode
			ifNil: [ 
				startNode := allNodes detect: [ :node | node point3d = seg from point3d ] ifNone: [  ].  
				startNode
					ifNotNil: [ 
						seg from: startNode ]
					ifNil: [ self error: 'segment from: not in nodes: ', (seg from point3d asString) ]
					.
				].
		endNode := allNodes detect: [ :node | node number = seg to number ] ifNone: [  ]. 
		endNode
			ifNil: [ 
				endNode := allNodes detect: [ :node | node point3d = seg to point3d ] ifNone: [  ].  
				endNode
					ifNotNil: [ 
						seg to: endNode ]
					ifNil: [ self error: 'segment to: not in nodes: ', (seg to point3d asString) ]
				].
		seg
		 ]
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> threejsData [
	| map |
	map := Dictionary new.
	self 
		valueOfProperty: #excelTimestamp 
		ifPresentDo: [ :timestamp | map at: 'timestamp' put: timestamp ].
	map
		at: 'nodes'
		put:
			(self stanNodes
				collect: [ :n | 
					| m |
					m := Dictionary new.
					n attributesOn: m.
					m ]).
	map
		at: 'segments'
		put:
			(self stanSegments
				collect: [ :n | 
					| m |
					m := Dictionary new.
					n attributesOn: m.
					m ]).
	^ map
]

{ #category : #'*TowerKit-STAN' }
TwkCompositBrick >> threejsOn: aWriteStream during: aBlock [
	aWriteStream nextPutAll: 'function towerData(){'.
	aWriteStream cr.
	aWriteStream nextPutAll: 'return '.
	aBlock value.
	aWriteStream nextPutAll: ';'.
	aWriteStream cr.
	aWriteStream nextPutAll: '}'
]

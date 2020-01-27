Extension { #name : #TwkTowerKit }

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> basenameForV1: aNumber [
	^ ('stan-outv1-' , aNumber asString , '.csv').

]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> basenameForV2: aNumber [
	^ ('stan-outv2-' , aNumber asString , '.csv').

]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> exploreIdCrossHalfWidth [
	<script>
	| points |
	points := self idCrossHalfWidth.
	StanPointsCollection ifNil: [ StanPointsCollection := OrderedCollection new ].
	StanPointsCollection add: points.
	points explore.
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> segmentAngle: aLineSegment [
	| seg angle |
	seg := aLineSegment asStandDirection asDownDirection.
	angle := seg direction angle radiansToDegrees.
	((seg start x < 0.0 and: [seg end x < 0.0]) and: [ seg isVertical ])
		ifTrue: [ ^ angle - 180.0 ].	
	^ angle
	 
	
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> segmentAngleFrom: aPoint1 to: aPoint2 [
	^ self segmentAngle: (LineSegment from: aPoint1 to: aPoint2)
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanDefaultOutputFolder [
	^ (FileLocator documents / 'TowerKit-STAN')
		ensureCreateDirectory;
		yourself

]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanLocal3DPointsForHorizontalFrontPoints: col1 sidePoints: col2 [
	^ self local3DPointsForHorizontalFrontPoints: col1 sidePoints: col2 
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanLocal3DPointsForVerticalFrontPoints: col1 sidePoints: col2 [
	| scales ncol1 ncol2 d3points |
	ncol1 := self zeroRejectButFirst: col1.
	ncol2 := self zeroRejectButFirst: col2.
	self assert: ncol1 size = ncol2 size.
	d3points := OrderedCollection new.
	scales := {(1 @ -1).
	(-1 @ -1).
	(-1 @ 1).
	(1 @ 1)}.
	ncol1
		doWithIndex: [ :frontP :index | 
			| sideP baseLoc |
			sideP := ncol2 at: index.
			baseLoc := frontP x @ sideP x.	"index = 1
				ifTrue: [ d3points add: (Array with: baseLoc x with: baseLoc y with: sideP y) ]
				ifFalse: [ "	"((baseLoc x closeTo: 0.0) or: [ baseLoc y closeTo: 0.0 ])
				ifFalse: [ 
					frontP y = sideP y
						ifTrue: [ "
			scales
				do: [ :scale | 
					| scaledLoc |
					scaledLoc := baseLoc * scale.
					d3points add: (Array with: scaledLoc x with: scaledLoc y with: sideP y)	"]"	"]" ] ].
	^ d3points
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanOut2Number: aNumber col1: col1 col2: col2 xOffset: xoffset nodeTopNumber: nodeTopNumber [
	| file scales count ncol1 ncol2 |
	ncol1 := self zeroRejectButFirst: col1.
	ncol2 := self zeroRejectButFirst: col2.	
	self assert: (ncol1 size = ncol2 size).
	scales := {(1 @ -1).
	(-1 @ -1).
	(-1 @ 1).
	(1 @ 1)}.
	count := 0.
	file := self stanDefaultOutputFolder / self basenameForV2: aNumber.
	file
		mbWriteStreamDo: [ :stream | 
			| writer |
			writer := (NeoCSVWriter on: stream)
				fieldWriter: #raw;
				nextPut: #(#node #x #y #z);
				yourself.
			ncol1
				doWithIndex: [ :frontP :index | 
					| sideP baseLoc |
					sideP := ncol2 at: index.
					baseLoc := frontP x @ sideP x.
					index = 1
						ifTrue: [ 
							writer
								nextPut:
									{(nodeTopNumber + count).
									(baseLoc x + xoffset).
									(baseLoc y).
									(sideP y)}.
							count := count + 1 ]
						ifFalse: [ 
							((baseLoc x closeTo: 0.0) or: [ baseLoc y closeTo: 0.0 ])
								ifFalse: [ 
									frontP y = sideP y
										ifTrue: [ 
											scales
												do: [ :scale | 
													| scaledLoc |
													scaledLoc := baseLoc * scale.
													writer
														nextPut:
															{(nodeTopNumber + count).
															(scaledLoc x + xoffset).
															(scaledLoc y).
															(sideP y)}.
													count := count + 1 ] ] ] ] ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanOutNumber: aNumber col1: col1 col2: col2 [
	| file |
	file := self stanDefaultOutputFolder / (self basenameForV1: aNumber).
	file
		mbWriteStreamDo: [ :stream | 
			self writePartialOutputTo: stream frontPoints: col1 sidePoints: col2 ]
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanOutputV1All [
	<script>
	| items |
	items := StanPointsCollection allButFirst: (StanPointsCollection size - 6). 
	self stanOutNumber: 10 col1: (items at: 1) col2: (items at: 2).
	self stanOutNumber: 11 col1: (items at: 3) col2: (items at: 4).
	self stanOutNumber: 12 col1: (items at: 5) col2: (items at: 6).
	 
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanOutputV2All [
	<script>
	| items |
	items := StanPointsCollection allButFirst: (StanPointsCollection size - 6). 
	self stanOut2Number: 10 col1: (items at: 1) col2: (items at: 2) xOffset: 0 nodeTopNumber: 100.
	self stanOut2Number: 11 col1: (items at: 3) col2: (items at: 4) xOffset: 16000 nodeTopNumber: 200.
	self stanOut2Number: 12 col1: (items at: 5) col2: (items at: 6) xOffset: 32000 nodeTopNumber: 300.
	 
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> stanRoundValue [
	^ 0.0001
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> writeD3Points: aPoints topNumber: aNumber on: aStream withHeader: aBoolean [
	|  nodeNumber  writer  |	
	nodeNumber := aNumber.
	writer := (NeoCSVWriter on: aStream).
	writer fieldWriter: #raw.
		aBoolean ifTrue: [writer nextPut: #(#node #x #y #z)].
	aPoints
		do: [ :arrayPoint3 | 
			writer nextPut: (Array with: nodeNumber) , arrayPoint3.
			nodeNumber := nodeNumber + 1 ]	
	
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> writePartialOutputTo: aStream frontPoints: col1 sidePoints: col2 [
	| writer |
	self assert: col1 size = col2 size.
	writer := (NeoCSVWriter on: aStream)
		fieldWriter: #raw;
		nextPut: #(#fx #fy #sx #sy);
		yourself.
	col1
		doWithIndex: [ :frontP :index | 
			| sideP |
			sideP := col2 at: index.
			writer
				nextPut:
					{(frontP x).
					(frontP y).
					(sideP x).
					(sideP y)} ]
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> writeStanCsvTo: aStream frontPoints: col1 sidePoints: col2 offset: aArray3D nodeTopNumber: nodeTopNumber [
	^ self writeStanVerticalCsvTo: aStream frontPoints: col1 sidePoints: col2 offset: aArray3D nodeTopNumber: nodeTopNumber 	
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> writeStanHorizontalCsvTo: aStream frontPoints: col1 sidePoints: col2 offset: aArray3D nodeTopNumber: nodeTopNumber [
	| d3points |
	self assert: col1 size = col2 size.
	d3points := self stanLocal3DPointsForHorizontalFrontPoints: col1 sidePoints: col2.
	self writeD3Points: d3points topNumber: nodeTopNumber on: aStream withHeader: true.
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> writeStanVerticalCsvTo: aStream frontPoints: col1 sidePoints: col2 offset: aArray3D nodeTopNumber: nodeTopNumber [
	| d3points |
	self assert: col1 size = col2 size.
	d3points := self stanLocal3DPointsForVerticalFrontPoints: col1 sidePoints: col2.
	self writeD3Points: d3points topNumber: nodeTopNumber on: aStream withHeader: true.
]

{ #category : #'*TowerKit-STAN' }
TwkTowerKit class >> zeroRejectButFirst: aPointCollection [
	^ (Array with:aPointCollection first), (aPointCollection allButFirst reject: [ :p | p x closeTo: 0.0 ])
]

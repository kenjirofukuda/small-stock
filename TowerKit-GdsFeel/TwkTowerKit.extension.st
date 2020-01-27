Extension { #name : #TwkTowerKit }

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> activeStructureMorph [
	^ (GdsStructureEditorMorph allInstances reverse detect: [ :each | each model == GdsStation default structure  ])
		
	
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit >> caption [
	^ 'Mesh View'
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> enabled [
	^ (Smalltalk at: #DxfFile ifAbsent: [  ]) notNil.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit >> entryPoint [
	self class roassalIdPoints  
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdCrossHeightArray [
	<script>
	| col |
	col := 	self idCrossHeightArray.
	Clipboard clipboardText: ((col collect: [ :v | v asString ]) joinUsing: String cr).
	col explore.	
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdCrossPoints [
	<script>
	self idCrossPoints sort explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdCrossWidthArray [
	<script>
	| col |
	col := 	self idCrossWidthArray.
	Clipboard clipboardText: ((col collect: [ :v | v asString ]) joinUsing: String cr).
	col explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdElements [
	<script>
	GdsStation default idSelection elements explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdHeightArray [
	<script>
	| col |
	col := 	self idHeightArray reversed.
	Clipboard clipboardText: ((col collect: [ :v | v asString ]) joinUsing: String cr).
	col explore.	
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdLines [
	<script>
	|   |
	self idLines explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdPoints [
	<script>
	self idPoints explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdXRunArray [
	<script>
	self idXRunArray  explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdXRunAssociations [
	<script>
	self idXRunAssociations  explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> exploreIdXValuesArray [
	<script>
	self idXValues explore.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> gdsEditorMenuOn: aBuilder [
	<gdsStructureEditorMenu>
	(TwkTowerKit pragmaCollector collected sort: [ :a :b  | a method selector < b method selector ])
		do: [ :pragma | 
			| selName |
			selName := pragma method selector asString.
			"fixed: Pharo 3.0"
			selName := [selName asCapitalizedPhrase] on: Error do: [:ex | ex return: selName ].
			(aBuilder item: selName)
				target: pragma methodClass baseClass ;
				selector: pragma method selector ]
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idAtomicSegments: aCrossPoints [
	| allSegs |
	allSegs := OrderedCollection new.
	self idLines
		do: [ :line | 
			line
				lineSegmentsDo: [ :seg | 
					allSegs addAll: 
						(GeometryUtils 
							splitSegment: seg 
							crossPoints: aCrossPoints 
							epsilon: self epsilon) ] ].
	^ allSegs asSet asArray
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idCrossHalfWidth [
	| points bounds originY originX offset | 
	points := (self idCrossPoints collect: [:p | (p roundTo: (TwkTowerKit stanRoundValue ))]) asSet asArray.
	points := points sort: [ :a :b | (a y) > (b y) ].
	bounds := GeometryUtils lookupDataBounds: points.
	originY := points last y.
	originX := (bounds extent * 0.5) x.
	offset := originX @ originY.
	^( points collect: [ :p | p - offset ]) select: [ :p | p x >= 0 ]
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idCrossHeightArray [
	^ (self yValuesOf: self idCrossPoints) sort offsetValues.

]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idCrossPoints [
	^ GdsElement crossPointsOfElements: self idLines.
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idCrossWidthArray [
	^ (self xValuesOf: self idCrossPoints) sort offsetValues.

]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idHeightArray [
	^ self idYValues sort offsetValues.

]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idLines [
	^ GdsStation default idSelection elements select: [:e | e type = #path ] .

]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idPoints [
	| paths allPoints |
	 paths := self idLines.
	allPoints :=  Array streamContents: [ :s | 
		paths do: [ :e |	
			s nextPutAll: e vertices .
	 	]
 	].
	^ allPoints asSet asArray 

]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idXRunArray [
	^ RunArray newFrom: (self xValuesOf: self idCrossPoints)
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idXRunAssociations [
	^(Array streamContents: [ :s |	self idXRunArray runsAndValuesDo: [ :run :value |
		s nextPut: run -> value
		 ] ]) sort: [ :a :b | a key > b key ]

]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idXValues [
	^ self xValuesOf: self idPoints
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> idYValues [
	^ self yValuesOf: self idPoints
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> markCrossPoints [
	<script>
	(self activeStructureMorph)
		ifNotNil: [ :view |
			view markPoints: self idCrossPoints .
			 ]
	
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> pluginOn: aBuilder [
	<gdsPlugin>
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> pragmaCollector [
	^ (PragmaCollector filter: [ :pragma | (pragma methodClass asString beginsWith: 'Twk') and: [pragma keyword = #script] ])
		reset.	
]

{ #category : #'*TowerKit-GdsFeel' }
TwkTowerKit class >> putTextSegment [
	<script>
	| textAttr |
	textAttr := TwkText new.
	textAttr textHeight: 200 * 3.
	textAttr contents: 'L##x#'.
	GdsStation default structure currentItem
		ifNotNil: [ :item | 
			self idLines
				do: [ :line | 
					line
						lineSegmentsDo: [ :seg | 
							textAttr basePoint: seg midPoint.
							item layerNumber: 1.
							item text: textAttr contents.
							item angle: (TwkTowerKit segmentAngle: seg).
							item putBoxText: textAttr boundsByCenter ] ] ]
		ifNil: [ self halt ]
]

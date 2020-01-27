Extension { #name : #TwkTowerKit }

{ #category : #'*TowerKit-Roassal' }
TwkTowerKit class >> roassalIdPoints [
	<script>
	"TimeProfiler spyOn: [ "self roassalIdPointsPrivate" ]"
]

{ #category : #'*TowerKit-Roassal' }
TwkTowerKit class >> roassalIdPointsPrivate [
	| v points builder nodes aloneElements bounds ellipseSize lineSize maxSide |
	v := RTView new.
	builder := DistanceContextExamples new .
	points := (self idCrossPoints , self idPoints ) asSet asArray.
	bounds := GeometryUtils lookupDataBounds: points.
	maxSide := bounds width max: bounds height.
	ellipseSize := (maxSide / 80.0) .
	lineSize := (maxSide / 240.0) .
	nodes := OrderedCollection new .
	points do: [ :p |
		| node |
		node := (RTEllipse new
				size: ellipseSize;
				color: (Color blue alpha: 0.3)) elementOn: p.
		node @ RTDraggable.
		nodes add: node.
		self update: node position: p.
		 ].
	v addAll: nodes.
	(self idAtomicSegments: points) do: [ :seg |  | start end |
		start := nodes detect: [ :n | (n model dist: seg start) < self epsilon ] ifNone: [ nil ].
		end := nodes detect: [ :n | (n model dist: seg end) < self epsilon ] ifNone: [ nil ].
		(start notNil and: [ end notNil ] )
			ifTrue: [ 
				| edge |
				edge := RTLine new 
					color: (Color red alpha: 0.3); 
					width: lineSize;
					edgeFrom: start to: end.
				v add: edge].		
		 ].
	aloneElements := v elements select: [ :e | (e incomingEdges size + e outgoingEdges size) < 2 ]. 
	v removeElements: aloneElements.
	v signalUpdate.
	v @ RTZoomableView.
	v @ RTDraggableView .
	v canvas camera focusOnCenterScaled.
	v explore.
	^ v
]

{ #category : #'*TowerKit-Roassal' }
TwkTowerKit class >> update: aRTCompositShape position: aPoint [
	aRTCompositShape model: aPoint .
	aRTCompositShape translateTo: aRTCompositShape model yFliped.
	"aRTCompositShape trachelShape shapes second text: aRTCompositShape model asString."
	aRTCompositShape signalUpdate.
	
]

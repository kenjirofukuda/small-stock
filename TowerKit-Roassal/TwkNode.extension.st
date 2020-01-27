Extension { #name : #TwkNode }

{ #category : #'*TowerKit-Roassal' }
TwkNode >> gtInspectorRoassalIn: composite [
	<gtInspectorPresentationOrder: 40>
	^ composite roassal2
		title: 'Roassal';
		painting: [ :view |
			self renderRoassalOn: view
			]
]

{ #category : #'*TowerKit-Roassal' }
TwkNode >> openRoassalView [
	| v       |
	v := RTView new.
	self renderRoassalOn: v.
	^ v
]

{ #category : #'*TowerKit-Roassal' }
TwkNode >> postRoassalOn: aRTView [
	aRTView signalUpdate.
	aRTView @ RTZoomableView.
	aRTView @ RTDraggableView.
	aRTView canvas camera focusOnCenterScaled.

]

{ #category : #'*TowerKit-Roassal' }
TwkNode >> renderRoassalOn: aRTView [
]

{ #category : #'*TowerKit-Roassal' }
TwkNode >> renderRoassalOn: aRTView points: aPoints segments: aSegments ellipseSize: aEllipseSize lineSize: aLineSize [
	self renderRoassalOn: aRTView points: aPoints segments: aSegments ellipseSize: aEllipseSize lineSize: aLineSize epsilon: TwkTowerKit epsilon

]

{ #category : #'*TowerKit-Roassal' }
TwkNode >> renderRoassalOn: aRTView points: aPoints segments: aSegments ellipseSize: aEllipseSize lineSize: aLineSize epsilon: anEpsilon [
	|  nodes |
	nodes := OrderedCollection new.
	aPoints
		do: [ :p | 
			| node |
			node := (RTEllipse new
				size: aEllipseSize;
				color: (Color blue alpha: 1.0)) elementOn: p.
			node @ RTDraggable.
			nodes add: node.
			self update: node position: p ].
	aSegments do: [ :seg |  | start end |
		start := nodes detect: [ :n | (n model dist: seg start) < anEpsilon ] ifNone: [ nil ].
		start ifNil: [ ('start seg not found: <1p>' expandMacrosWith: seg) logCr.  ].
		end := nodes detect: [ :n | (n model dist: seg end) < anEpsilon ] ifNone: [ nil ].
		end ifNil: [ ('end seg not found: <1p>' expandMacrosWith: seg) logCr.  ].
		(start notNil and: [ end notNil ] )
			ifTrue: [ 
				| edge |
				edge := RTLine new 
					color: (Color red alpha: 1.0); 
					width: aLineSize;
					edgeFrom: start to: end.
				aRTView add: edge].		
		 ].
	aRTView addAll: nodes.

]

{ #category : #'*TowerKit-Roassal' }
TwkNode >> update: aRTCompositShape position: aPoint [
	aRTCompositShape model: aPoint .
	aRTCompositShape translateTo: aRTCompositShape model * (1 @ -1).
	"aRTCompositShape trachelShape shapes second text: aRTCompositShape model asString."
	aRTCompositShape signalUpdate.
]

Extension { #name : #TwkTrussWorld }

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> openDiagram [
	| v |
	v := RTView new.
	self renderRoassalOuterLoadsOn: v.
	self renderRoassalInnerLoadsOn: v.
	self postRoassalOn: v.
	v explore.
]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> renderRoassalDiagramOn: aRTView [
	self renderRoassalOuterLoadsOn: aRTView.
	self postRoassalOn: aRTView

]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> renderRoassalInnerLoadsOn: aRTView [
	| segments pts bounds maxSide ellipseSize lineSize |
	segments := self innerPoints flatCollect: [ :each | each valueOfProperty: #segments].
	pts := (segments flatCollect: [ :each | each controlPoints ]) asSet asArray.
	bounds := GeometryUtils lookupDataBounds: pts.
	maxSide := bounds width max: bounds height.
	ellipseSize := maxSide / 40.0.
	lineSize := maxSide / 240.0.
	self
		renderRoassalOn: aRTView
		points: pts
		segments: segments
		ellipseSize: ellipseSize
		lineSize: lineSize
		epsilon: 1e-6
]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> renderRoassalOn: aRTView [
	| pts bounds maxSide ellipseSize lineSize  |
	pts := self positions.
	bounds := GeometryUtils lookupDataBounds: pts.
	maxSide := bounds width max: bounds height.
	ellipseSize := maxSide / 40.0.
	lineSize := maxSide / 240.0.

	self 
		renderRoassalOn: aRTView 
		joints: joints 
		members: members 
		ellipseSize: ellipseSize 
		lineSize: lineSize.

	self postRoassalOn: aRTView

]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> renderRoassalOn: aRTView joints: aJoints members: aMembers ellipseSize: aEllipseSize lineSize: aLineSize [
	|  nodes |
	nodes := OrderedCollection new.
	aJoints
		do: [ :joint | 
			| node label labelNode |
			node := (RTEllipse new
				size: aEllipseSize;
				color: (Color blue alpha: 0.8)) elementOn: joint.
			label := RTLabel new text: joint name; height: (aEllipseSize).
			nodes add: node.
			labelNode := label elementOn: joint.
			nodes add: labelNode.
			self update: node joint: joint.
			self updateShape: labelNode position: (joint position + (0 @ aEllipseSize) )].
	aMembers do: [ :member |  | start end |
		start := nodes detect: [ :n | (n model position dist: member startPosition) < TwkTowerKit epsilon ] ifNone: [ nil ].
		end := nodes detect: [ :n | (n model position dist: member endPosition) < TwkTowerKit epsilon ] ifNone: [ nil ].
		(start notNil and: [ end notNil ] )
			ifTrue: [ 
				| edge |
				edge := (RTLine new 
					color: (Color red alpha: 0.8); 
					width: aLineSize;
					edgeFrom: start to: end).
				aRTView add: edge].		
		 ].
	aRTView addAll: nodes.

]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> renderRoassalOuterLoadsOn: aRTView [
	| pts bounds maxSide ellipseSize lineSize  segments |
	pts := self outerPoints collect: [:each | each asPoint].
	bounds := GeometryUtils lookupDataBounds: pts.
	segments := GeometryUtils lineSegmentsFormPointArray: pts.
	segments traceCr.
	maxSide := bounds width max: bounds height.
	ellipseSize := maxSide / 40.0.
	lineSize := maxSide / 240.0.

	self 
		renderRoassalOn: aRTView 
		points: pts 
		segments: segments 
		ellipseSize: ellipseSize 
		lineSize: lineSize
		epsilon: 1e-6.

]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> update: aRTCompositShape joint: aTwkJoint [
	aRTCompositShape model: aTwkJoint .
	aRTCompositShape translateTo: aRTCompositShape model asPoint yFliped.
	"aRTCompositShape trachelShape shapes second text: aRTCompositShape model asString."
	aRTCompositShape signalUpdate.
]

{ #category : #'*TowerKit-Roassal' }
TwkTrussWorld >> updateShape: aRTCompositShape position: aPoint [
	aRTCompositShape translateTo: aPoint yFliped.
	aRTCompositShape signalUpdate.
]

Class {
	#name : #TwkTowerKit,
	#superclass : #Object,
	#classVars : [
		'StanPointsCollection'
	],
	#classInstVars : [
		'InstanceMap'
	],
	#category : #'TowerKit-Core'
}

{ #category : #utility }
TwkTowerKit class >> beFontTo: aFontName [
	| fontFamilyName font |
	fontFamilyName := aFontName.
	FreeTypeSystemSettings loadFt2Library: true.
	FreeTypeFontProvider current updateFromSystem.
	font := [ :fontSize | LogicalFont familyName: fontFamilyName pointSize: fontSize ].
	StandardFonts defaultFont: (font value: 10).
	StandardFonts codeFont: (font value: 10).
	StandardFonts listFont: (font value: 10).
	StandardFonts menuFont: (font value: 10).
	StandardFonts buttonFont: (font value: 10).
	StandardFonts windowTitleFont: (font value: 12).
	StandardFonts balloonFont: (font value: 9).
	StandardFonts haloFont: (font value: 9)
]

{ #category : #scripts }
TwkTowerKit class >> beIPAGothic [
	<script>
	self beFontTo: 'IPAGothic'
]

{ #category : #utility }
TwkTowerKit class >> clearInstanceMap [
	InstanceMap := nil.
]

{ #category : #'objects from disk' }
TwkTowerKit class >> defaultFolder [
	^ (FileLocator documents / 'TowerKit') asFileReference ensureCreateDirectory.

]

{ #category : #accessing }
TwkTowerKit class >> epsilon [
	^ 0.1
]

{ #category : #accessing }
TwkTowerKit class >> epsilonForCrossPoint [
	^ 1e-12
]

{ #category : #scripts }
TwkTowerKit class >> foo [
	<script>
	GdsStation default idSelection elements explore.
]

{ #category : #'as yet unclassified' }
TwkTowerKit class >> icon16x16 [
	^ (Form
	extent: (16@16)
	depth: 32
	fromArray: #( 0 0 0 0 0 0 0 1023410176 1023410176 0 0 0 0 0 0 0 0 0 0 0 0 0 1207959552 3523215360 3523215360 1207959552 0 0 0 0 0 0 0 0 0 0 0 0 2617245696 3019898880 3019898880 2617245696 0 0 0 0 0 0 0 0 0 0 0 0 1577058304 3355443200 3288334336 1644167168 0 0 0 0 0 0 0 0 0 0 0 0 956301312 1929379840 1778384896 1090519040 0 0 0 0 0 0 0 0 0 0 0 0 1627389952 1291845632 1157627904 1761607680 0 0 0 0 0 0 0 0 0 0 0 0 2432696320 503316480 369098752 2566914048 0 0 0 0 0 0 0 0 0 0 0 33554432 3019898880 117440512 117440512 3036676096 33554432 0 0 0 0 0 0 0 0 0 0 2533359616 3254779904 3070230528 3070230528 3254779904 2533359616 0 0 0 0 0 0 0 0 0 0 2248146944 2902458368 3741319168 3741319168 2902458368 2248146944 0 0 0 0 0 0 0 0 0 100663296 3036676096 1140850688 1879048192 1879048192 1140850688 3036676096 100663296 0 0 0 0 0 0 0 0 1711276032 3338665984 3170893824 3003121664 3003121664 3170893824 3338665984 1711276032 0 0 0 0 0 0 0 251658240 3053453312 33554432 805306368 2097152000 2097152000 805306368 33554432 3053453312 251658240 0 0 0 0 0 0 2365587456 989855744 1493172224 2667577344 822083584 822083584 2667577344 1493172224 989855744 2365587456 0 0 0 0 0 687865856 2667577344 67108864 3070230528 16777216 0 0 16777216 3070230528 67108864 2667577344 687865856 0 0 0 0 2785017856 3170893824 3003121664 2030043136 0 0 0 0 2030043136 3003121664 3170893824 2785017856 0 0)
	offset: (0@0))
]

{ #category : #utility }
TwkTowerKit class >> instanceMap [
	^ InstanceMap ifNil: [ InstanceMap := Dictionary new ]
]

{ #category : #utility }
TwkTowerKit class >> intersectSegment1: seg1 segment2: seg2 hasCrossBlock: aCrossPointBlock [
	self intersectSegment1: seg1 segment2: seg2 hasCrossBlock: aCrossPointBlock ifNone: [ ] 
]

{ #category : #utility }
TwkTowerKit class >> intersectSegment1: seg1 segment2: seg2 hasCrossBlock: aCrossPointBlock ifNone: aNoneBlock [
	LineSegment intersectSegment1: seg1 segment2: seg2 hasCrossBlock: aCrossPointBlock ifNone: aNoneBlock epsilon: self epsilon 
]

{ #category : #'no messages' }
TwkTowerKit class >> layerNumberForPoint [
	^ 1
]

{ #category : #'accessing - 3d' }
TwkTowerKit class >> local3DPointsForHorizontalFrontPoints: col1 sidePoints: col2 [
	| d3points scales |
	self assert: col1 size = col2 size.
	d3points := OrderedCollection new.
	scales := Array
		with: -1 @ 1
		with: -1 @ -1
		with: 1 @ -1
		with: 1 @ 1.
	col1
		doWithIndex: [ :frontP :index | 
			| sideP baseLoc |
			sideP := col2 at: index.
			baseLoc := sideP y @ frontP y.
			scales
				do: [ :scale | 
					| scaledLoc |
					scaledLoc := baseLoc * scale.
					d3points add: (Array with: frontP x with: scaledLoc x with: scaledLoc y) ] ].
	^ d3points
]

{ #category : #'accessing - 3d' }
TwkTowerKit class >> local3DPointsForVerticalFrontPoints: col1 sidePoints: col2 [
	| scales d3points |
	self assert: col1 size = col2 size.
	d3points := OrderedCollection new.
	scales := Array
		with: 1 @ -1
		with: -1 @ -1
		with: -1 @ 1
		with: 1 @ 1.
	col1
		doWithIndex: [ :frontP :index | 
			| sideP baseLoc |
			sideP := col2 at: index.
			baseLoc := frontP x @ sideP x.
			scales
				do: [ :scale | 
					| scaledLoc |
					scaledLoc := baseLoc * scale.
					d3points add: (Array with: scaledLoc x with: scaledLoc y with: sideP y) ] ].
	^ d3points
]

{ #category : #utility }
TwkTowerKit class >> offsetPoints: aCollection offset: offset [
	^ aCollection
		collect: [ :p3 | 
			Array 
				with: p3 first + offset first 
				with: p3 second + offset second 
				with: p3 third + offset third ]
]

{ #category : #TODO }
TwkTowerKit class >> todo [
'
TwkBrickStack>>ggPool (GGPool is Undeclared) 

TwkBrickStack>>sliceCommands (GGAtom is Undeclared) 

TwkBrickStack>>slopeCommands (GGAtom is Undeclared) 

TwkBrickStack>>widthSpecCommands (GGAtom is Undeclared) 

TwkCompositBrick class>>towerkitMenuOn: (TwkExamplesY13TO17V2 is Undeclared) 

TwkCompositBrick class>>towerkitMenuOn: (TwkExamplesY04TO09V4 is Undeclared) 

TwkCompositBrick class>>towerkitMenuOn: (TwkExamples is Undeclared) 

TwkCompositBrick class>>towerkitMenuOn: (TwkExamples is Undeclared) 

TwkCompositBrick class>>towerkitMenuOn: (TwkExamples is Undeclared) 

TwkCompositBrick>>initialize (TwkStanNodeCenter is Undeclared) 

TwkFace>>fillPassivePlane (realMaterialInfo is Undeclared) 

TwkFace>>fillPassivePlane (realMaterialInfo is Undeclared) 

TwkFace>>fillPassivePlane (realMaterialInfo is Undeclared) 

'
]

{ #category : #'as yet unclassified' }
TwkTowerKit class >> towerkitMenuOn: aBuilder [ 
	<worldMenu>
	(aBuilder item: #TowerKit)
		order: 5.0;
		help: 'Tower Kit';
		icon: self icon16x16;
		yourself.
]

{ #category : #utility }
TwkTowerKit class >> xValuesOf: aPointArray [
	^ (aPointArray collect: [ :p | p x ]) asSet asArray sort.
]

{ #category : #utility }
TwkTowerKit class >> yValuesOf: aPointArray [
	^ (aPointArray collect: [ :p | p y ]) asSet asArray sort.
]

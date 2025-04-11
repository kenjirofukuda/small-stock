Class {
	#name : 'GdsPathDrawer',
	#superclass : 'GdsPrimitiveDrawer',
	#category : 'GdsFeel-UI-Drawer',
	#package : 'GdsFeel-UI',
	#tag : 'Drawer'
}

{ #category : 'as yet unclassified' }
GdsPathDrawer class >> radiansFor45 [
	^45 degreeSin
]

{ #category : 'as yet unclassified' }
GdsPathDrawer class >> radiansFor90 [
	^90 degreeSin
]

{ #category : 'testing' }
GdsPathDrawer >> canDisplaySegmentLength [
	^ self canDisplayKindForKey: 'SL'
]

{ #category : 'testing' }
GdsPathDrawer >> canFill [
	| pixelSize |
	morph fastDrawing ifTrue: [ ^ false ].
	
	element width <= 0.0 ifTrue: [ ^ false ].
	pixelSize := self pixelSize: element width.
	^ pixelSize >= 3.0 and: [self canStrokePathBoundaryWithKind].
]

{ #category : 'testing' }
GdsPathDrawer >> canStrokePathBoundary [
	| pixelSize |
	morph fastDrawing ifTrue: [ ^ element width > 0.0 ].
	element width <= 0.0 ifTrue: [ ^ false ].
	pixelSize := self pixelSize: element width.
	^ pixelSize >= 2.0
]

{ #category : 'drawing' }
GdsPathDrawer >> canStrokePathBoundaryWithKind [
	^(self canStrokePathBoundary and: [(element structure kinds atKey: 'PB') isVisible])
	
	
]

{ #category : 'testing' }
GdsPathDrawer >> canStrokePathCenter [
	morph fastDrawing 
		ifTrue: [ ^ element width <= 0.0 ].
	^(element structure kinds atKey: 'PC') isVisible or: [self canStrokePathBoundary not]
	
]

{ #category : 'drawing-utility' }
GdsPathDrawer >> drawOn: strokeCanvas intersctAt: aPoint index: aIndex [
	morph drawOn: strokeCanvas markDiamondPointAt: aPoint.
	morph drawOn: strokeCanvas text: aIndex at: aPoint..
	
]

{ #category : 'drawing' }
GdsPathDrawer >> drawSegmentLengthOn: aCanvas [
	| p1 p2 points center proxyMorph |
	points := self element vertices.
	points ifEmpty: [ ^ self ].
	1 to: points size - 1 do: [ :index |
		| length angle seg mPos |
		p1 := points at: index.
		p2 := points at: index + 1.
		center := (p1 + p2) * 0.5.
		seg := (LineSegment from: p1 to: p2).
		length := seg length printShowingDecimalPlaces: 4. 
		angle := seg asStandDirection asDownDirection direction angle radiansToDegrees.
		mPos := morph innerBounds origin + (morph viewport xy2hv: center).
		proxyMorph := self element valueOfProperty: #proxyMorph ifAbsentPut: [ 
			| m flex |
			morph submorphCount <= 100 ifTrue: [
			m := length asMorph.
			m color: Color white.
			morph addMorph: m.
			m center: mPos.
			flex := m addFlexShell.
			flex rotationDegrees: angle negated.
			flex]
			ifFalse: [nil]].
		proxyMorph ifNotNil: [proxyMorph center: mPos].
		"morph drawOn: aCanvas text: length asString at: center".
		"self drawOn: aCanvas lineFrom: p1 to: p2 width: aWidth ".].
		
]

{ #category : 'caliculate' }
GdsPathDrawer >> intersectionPoints: segs1 other: segs2 [
	^ Array streamContents: [ :s | 
		segs1 do: [:seg1 |
			segs2 do: [:seg2 | | p |
				p := seg1 intersectionWith: seg2.
				p ifNotNil: [s nextPut: p] ] ] ]
]

{ #category : 'drawing' }
GdsPathDrawer >> optionalDrawOn: aCanvas [
	super optionalDrawOn: aCanvas.
	self canDisplaySegmentLength
		ifTrue: [ self drawSegmentLengthOn: aCanvas ]
		ifFalse: [ (self element valueOfProperty: #proxyMorph ifAbsent: [  ])
				ifNotNil: [ :m | morph removeMorph: m ].
			self element removeProperty: #proxyMorph ]
]

{ #category : 'caliculate' }
GdsPathDrawer >> outlineSegment: aLineSegment offsetRadians: offsetRadians r: r [
 	^element outlineSegmentsOf: aLineSegment offsetRadians: offsetRadians r: r.
	
]

{ #category : 'drawing' }
GdsPathDrawer >> strokeOutlineOn: aCanvas [
	(self canStrokePathBoundaryWithKind)
		ifTrue: [self strokePathBoundaryOn: aCanvas].		
	(self canStrokePathCenter)
		ifTrue: [self strokePathCenterOn: aCanvas].
	
	
]

{ #category : 'drawing-utility' }
GdsPathDrawer >> strokePathBoundaryOn: aCanvas [
	self strokeVerticesOn: aCanvas points: element dataOutlinePoints 
]

{ #category : 'drawing-utility' }
GdsPathDrawer >> strokePathCenterOn: aCanvas [
	self strokeVerticesOn: aCanvas points: element vertices 	
]

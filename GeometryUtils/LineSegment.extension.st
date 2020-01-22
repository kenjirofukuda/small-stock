Extension { #name : #LineSegment }

{ #category : #'*GeometryUtils' }
LineSegment >> outlineSegments: offsetRadians r: r do: aLineSegmentBlock [
	GeometryUtils pointArray: (self outlinePoints: offsetRadians  r: r)  lineSegmentsDo: aLineSegmentBlock
	
]

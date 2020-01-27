Extension { #name : #TwkDepthSpan }

{ #category : #'*TowerKit-Roassal' }
TwkDepthSpan >> renderRoassalDepthIndexOn: aRTView textHeight: aTextHeight [ 
	| points |
	points := self wallSideIndexedPoints.
	points size >= 9
		ifTrue: [ 
			| label |
			label := ((RTLabel new text: self depthIndex asString ) height: aTextHeight; elementOn: (points at: 9)).
			label translateTo: ((points at: 9) yFliped).
			aRTView add:label.
			 ].

]

{ #category : #'*TowerKit-Roassal' }
TwkDepthSpan >> renderRoassalOn: aRTView [
	| points bounds maxSide ellipseSize lineSize  |
	points := self wallSideIndexedPoints.
	bounds := GeometryUtils lookupDataBounds: points.
	maxSide := bounds width max: bounds height.
	ellipseSize := maxSide / 40.0.
	lineSize := maxSide / 240.0.

	self 
		renderRoassalOn: aRTView 
		points: points 
		segments: (self slopeSegments, self crossSegments, self sliceSegments) 
		ellipseSize: (maxSide / 40.0) 
		lineSize: (maxSide / 240.0).

	self renderRoassalDepthIndexOn: aRTView textHeight: maxSide / 5.

	self postRoassalOn: aRTView

]

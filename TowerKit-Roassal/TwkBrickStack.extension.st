Extension { #name : #TwkBrickStack }

{ #category : #'*TowerKit-Roassal' }
TwkBrickStack >> renderRoassalOn: aRTView [
	| points  sliceSegments slopeSegments bounds maxSide ellipseSize lineSize segments  crossSegments aloneElements|
	points := Array streamContents: [ :s | self depthSpans do: [ :span | s nextPutAll: span wallSideIndexedPoints ]].
	points := points asSet asArray.
	bounds := GeometryUtils lookupDataBounds: points.
	slopeSegments := Array streamContents: [ :s | self depthSpans do: [ :span | s nextPutAll: span slopeSegments ]].
	sliceSegments := Array streamContents: [ :s | self depthSpans do: [ :span | s nextPutAll: span sliceSegments ]].
	crossSegments := Array streamContents: [ :s | self depthSpans do: [ :span | s nextPutAll: span crossSegments ]].
	
	
	segments := (slopeSegments, crossSegments, sliceSegments) asSet asArray.
	maxSide := bounds width max: bounds height.
	
	ellipseSize := maxSide / 100.0.
	lineSize := maxSide / 240.0.

	self renderRoassalOn: aRTView points: points segments: segments  ellipseSize: ellipseSize lineSize: lineSize.
		
	aloneElements := aRTView elements select: [ :e | (e incomingEdges size + e outgoingEdges size) = 0 ]. 
	aRTView removeElements: aloneElements.
		
	"self depthSpans do: [ :span | span renderRoassalDepthIndexOn: aRTView textHeight: maxSide / 40 ]."
		
	self postRoassalOn: aRTView

]

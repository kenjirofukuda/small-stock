Extension { #name : #TwkForce }

{ #category : #'*TowerKit-Roassal' }
TwkForce >> renderRoassalOn: aRTView [
	| shape1 shape2 e1 e2 pt1 pt2 l |
	pt1 := 0 @ 0.
	pt2 := Point r: 1 degrees: self angleDegress.
	shape1 := RTEllipse new
		color: (Color purple alpha: 0.2);
		size: 0.1.
	e1 := shape1 elementOn: pt1.
	shape2 := RTEllipse new
		color: (Color purple alpha: 0.2);
		size: 0.1.
	e2 := shape1 elementOn: pt2.
	aRTView add: e1.
	aRTView add: e2.
	self update: e1 position: pt1.
	self update: e2 position: pt2.
	l := RTEdge from: e2 to: e1.
	l
		+
			(RTLine new
				width: 0.01;
				color: Color red)
		+
			(RTSimpleArrowHead new
				color: Color red;
				baseSize: 0.02;
				size: 0.1;
				width: 0.01;
				yourself).
	aRTView add: l.
	self postRoassalOn: aRTView
]

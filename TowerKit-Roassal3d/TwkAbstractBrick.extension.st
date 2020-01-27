Extension { #name : #TwkAbstractBrick }

{ #category : #'*TowerKit-Roassal3d' }
TwkAbstractBrick >> r3ShowSlopePoints [
	| view  e points |
	view := R3View new.
	
	points := self stanLocal3DPointsForSlope collect: [:p | p * 0.01 ]. 
	points do: [ :p |
		e := R3CubeShape  element.
		e translateToX: p first y: p second z: p third.
		view add: e.].
	
	view addInteraction: R3MKControl.
	view addInteraction: KFR3KeyControl.
	view adjustCamera.

	view open.
	^ view	
]

Class {
	#name : #GdsHatchTestMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'hatch'
	],
	#category : #'GdsFeel-Developer-Morphic'
}

{ #category : #'as yet unclassified' }
GdsHatchTestMorph class >> example [
	"self example"
	self new openInWorld.
]

{ #category : #'as yet unclassified' }
GdsHatchTestMorph >> drawOn: aCanvas [
	| cp sp theta |
	super drawOn: aCanvas.
	cp := self innerBounds center.
	sp := Sensor cursorPoint.
	theta := (sp - cp) theta.
	aCanvas clipBy: self innerBounds during: [:clipedCanvas |
	(hatch lineSegmentsOf: self innerBounds from: cp  to:  sp) do: [:seg |
		clipedCanvas line: seg first to:seg second  width: 1 color: Color black]].
	aCanvas drawString:   theta asString at:  cp .
	aCanvas drawString:   (theta radiansToDegrees  roundTo: 0.01 )asString at:  cp + (0@15).	
	
	aCanvas drawString:   (((sp - cp) normalized) roundTo: 0.01 )asString at:  cp + (0@30)	
	
]

{ #category : #'as yet unclassified' }
GdsHatchTestMorph >> drawOnBackup: aCanvas [
	| t step from to stepPoint i maxSide |
	super drawOn: aCanvas.
	maxSide := self innerBounds width max: self innerBounds height.
	t := MatrixTransform2x3 identity .
	"t := t composedWithLocal: ( MatrixTransform2x3 withOffset: (self innerBounds extent // 2)negated ).	"
	t := t composedWithLocal: ( MatrixTransform2x3 withOffset: ( self innerBounds origin) ).
	t := t composedWithLocal: ( MatrixTransform2x3 withAngle: hatch angle).	
	step := (maxSide ) // (hatch linesPerScreen).	
		from := 0@0.
		to := (maxSide) @(from y).
		stepPoint := 0@step.
	stepPoint isZero ifTrue: [^self].
	aCanvas asBalloonCanvas transformBy: t during: [:localCanvas |
		i := 0.
		(0 to: (maxSide) by: step)
			do: [:v|
				i := i + 1.
				i > 2000 ifTrue: [^self].
				from := from + stepPoint.
				to :=to + stepPoint.
				localCanvas line:  from to: to color: Color black. ]
		].
]

{ #category : #'as yet unclassified' }
GdsHatchTestMorph >> initialize [
	super initialize.
	hatch := GdsHatch new setName: 'A' angle: 30.
	
]

{ #category : #'as yet unclassified' }
GdsHatchTestMorph >> step [
	self changed.
]

{ #category : #'as yet unclassified' }
GdsHatchTestMorph >> stepTime [
	^500
]

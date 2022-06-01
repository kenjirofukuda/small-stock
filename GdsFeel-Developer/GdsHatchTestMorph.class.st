Class {
	#name : #GdsHatchTestMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'hatch'
	],
	#category : #'GdsFeel-Developer-Morphic'
}

{ #category : #examples }
GdsHatchTestMorph class >> example [
	"self example"
	self new openInWorld.
]

{ #category : #accessing }
GdsHatchTestMorph >> drawOn: aCanvas [

	| cp sp theta |
	super drawOn: aCanvas.
	cp := self innerBounds center.
	sp := self activeHand cursorPoint.
	theta := (sp - cp) theta.
	aCanvas clipBy: self innerBounds during: [ :clipedCanvas | 
		(hatch lineSegmentsOf: self innerBounds from: cp to: sp) do: [ :seg | 
			clipedCanvas
				line: seg first
				to: seg second
				width: 1
				color: Color black ] ].
	aCanvas drawString: theta greaseString at: cp.
	aCanvas
		drawString: (theta radiansToDegrees roundTo: 0.01) greaseString
		at: cp + (0 @ 15).

	aCanvas
		drawString: ((sp - cp) normalized roundTo: 0.01) greaseString
		at: cp + (0 @ 30)
]

{ #category : #initialization }
GdsHatchTestMorph >> initialize [
	super initialize.
	hatch := GdsHatch new setName: 'A' angle: 30.
	
]

{ #category : #initialization }
GdsHatchTestMorph >> step [
	self changed.
]

{ #category : #initialization }
GdsHatchTestMorph >> stepTime [
	^500
]

Class {
	#name : #DistanceContextMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'startPointMorph',
		'endPointMorph',
		'testPointMorph'
	],
	#category : #'GdsFeel-Foundation-Core'
}

{ #category : #'as yet unclassified' }
DistanceContextMorph class >> open [
	"self open"
	StandardWindow new 
		addMorph: self new fullFrame: LayoutFrame identity;
		openInWorld.						

]

{ #category : #'as yet unclassified' }
DistanceContextMorph >> dragVertexEvent: anEvent fromHandle: handle [
	| p |
	p := anEvent cursorPoint.
	handle position: p - (handle extent // 2).	
]

{ #category : #'as yet unclassified' }
DistanceContextMorph >> initialize [
	"DistanceContextMorph  new openInWorld."
	super initialize.
	startPointMorph := EllipseMorph new
		color: Color red;
		extent: 15@15;
		yourself.
	endPointMorph := BorderedMorph new
		color: Color blue;
		extent: 15@15;
		yourself.
	testPointMorph := EllipseMorph new
		color: Color yellow;
		extent: 15@15;
		yourself.
		{ startPointMorph . endPointMorph .  testPointMorph} do: [ :handle |
			handle
				on: #mouseMove
				send: #dragVertexEvent:fromHandle:
				to: self].	
		
	self addMorph: 	startPointMorph.
	self addMorph: 	endPointMorph.
	self addMorph: 	testPointMorph.
	self color: Color lightGray.
]

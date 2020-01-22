Class {
	#name : #DistanceContextExamples,
	#superclass : #Object,
	#category : #'GdsFeel-UI-Roassal'
}

{ #category : #examples }
DistanceContextExamples class >> exampleCrossPoint [
	self new exampleCrossPoint
]

{ #category : #examples }
DistanceContextExamples class >> exampleDistance [
	self new exampleDistance
]

{ #category : #'as yet unclassified' }
DistanceContextExamples >> edgeElements [
	"self new example1"
	|  startElement  endElement   edge |

	startElement := self makePointColor: Color red size: 20.
	endElement := self makePointColor: Color cyan size: 20.

	edge := RTEdge from: startElement to: endElement.
	edge + (RTArrowedLine color: Color black).
	^ Array with: startElement with: endElement with: edge
]

{ #category : #accessing }
DistanceContextExamples >> exampleCrossPoint [
	"self new exampleCrossPoint"

	| v edgeElements1 edgeElements2 crossElement |
	v := RTView new.
	edgeElements1 := self edgeElements.
	edgeElements2 := self edgeElements.
	crossElement := self makePointColor: Color orange size: 10.
	edgeElements1 allButLast , edgeElements2 allButLast
		do: [ :each | 
			each @ RTDraggable.
			each
				when: TRMouseDragging
				do: [ :event | 
					| seg1 seg2 |
					self update: each position: each position.
					seg1 := LineSegment
						from: edgeElements1 first model
						to: edgeElements1 second model.
					seg2 := LineSegment
						from: edgeElements2 first model
						to: edgeElements2 second model.
					(seg1 intersectionWith: seg2 virtualAllowed: true)
						ifNotNil: [ :cross | self update: crossElement position: cross ] ] ].
	v addAll: edgeElements1.
	v addAll: edgeElements2.
	v add: crossElement.
	v explore
]

{ #category : #accessing }
DistanceContextExamples >> exampleCrossPoint2 [
	"self new exampleCrossPoint2"
	| v edgeElements1 edgeElements2  crossElement |
	v := RTView new.

	edgeElements1 := self edgeElements.
	edgeElements2 := self edgeElements.
	crossElement := self makePointColor: Color orange  size: 10.
	
	(edgeElements1 allButLast, edgeElements2 allButLast)
		do: [ :each | 
			each @ RTDraggable.
			each
				when: TRMouseDragging
				do: [ :event | | seg1 seg2 |
					self update: each position: each position.
					seg1 := LineSegment from: edgeElements1 first model to: edgeElements1 second model.
					seg2 := LineSegment from: edgeElements2 first model to: edgeElements2 second model.
					(seg1 intersectionWith: seg2 virtualAllowed: false )
						ifNil: [ crossElement visible: false. ]
						ifNotNil: [ :cross |
							 crossElement visible: true.
							self update: crossElement position: cross].
					 ] ].
	v addAll: edgeElements1.
	v addAll: edgeElements2.
	v add: crossElement.
	v explore
]

{ #category : #'as yet unclassified' }
DistanceContextExamples >> exampleDistance [
	"self new exampleCrossPoint"
	| v disttanceContext edgeElements startElement crossElement endElement testElement virtualCrossElement edge |
	v := RTView new.

	edgeElements := self edgeElements.
	startElement := edgeElements first.
	endElement := edgeElements second.

	testElement := self makePointColor: Color yellow size: 20.
	virtualCrossElement := self makePointColor: Color purple size: 10.
	crossElement := self makePointColor: Color orange size: 10.
	disttanceContext := DistanceContext new.

	edge := edgeElements last.

	{startElement.
	endElement.
	testElement}
		do: [ :each | 
			"each translateBy: 0 @ 0."
			each @ RTDraggable.
			each
				when: TRMouseDragging
				do: [ :event | 
					self update: each position: each position.
					disttanceContext startPoint: startElement model.
					disttanceContext endPoint: endElement model.
					disttanceContext testPoint: testElement model.
					self update: virtualCrossElement position: disttanceContext virtualCrossPoint.
					self update: crossElement position: disttanceContext crossPoint.
					 ] ].
	v addAll: edgeElements.
	v add: testElement.
	v add: virtualCrossElement.
	v add: crossElement.
	self update: startElement position: (0@0).
	self update: endElement position: (0@100).
	self update: testElement position: (-50@0).
	v explore
]

{ #category : #'as yet unclassified' }
DistanceContextExamples >> makePointColor: aColor size: aSize [
	| c |
	c := RTCompositeShape new.
	c
		add:
			(RTEllipse new
				size: aSize;
				color: aColor).
	c add: RTLabel new.
	"c vertical."
	^ c elementOn: 0 @ 0 .
	

]

{ #category : #'as yet unclassified' }
DistanceContextExamples >> update: aRTCompositShape position: aPoint [
	aRTCompositShape model: aPoint copy.
	aRTCompositShape translateTo: aRTCompositShape model.
	aRTCompositShape trachelShape shapes second text: aRTCompositShape model asString.
	aRTCompositShape signalUpdate.
	
]

"
A GdsSceneView is Athens based sene view.

"
Class {
	#name : #GdsSceneView,
	#superclass : #AthensInteractiveScene,
	#instVars : [
		'viewport',
		'lockTransformUpdate'
	],
	#category : #'GdsFeel-UI-Athens'
}

{ #category : #colors }
GdsSceneView >> backgroundColor [
	^ (scene
		ifNotNil: [ scene ]
		ifNil: [ super ]) backgroundColor

]

{ #category : #viewport }
GdsSceneView >> createViewport [
	| vp |
	vp := GdsViewport new.
	vp model: self structure.
	vp pixelBoundsSelector: #innerBounds.
	vp pixelBoundsTarget: self.
	vp announcer 
		when: #viewTransformChanged 
		do: [ 
			self viewTransformChanged ].
	^ vp
]

{ #category : #accessing }
GdsSceneView >> lockTransformUpdate [
	^ lockTransformUpdate ifNil: [ lockTransformUpdate := false ]
]

{ #category : #accessing }
GdsSceneView >> lockTransformUpdate: aBoolean [
	lockTransformUpdate := aBoolean 
]

{ #category : #drawing }
GdsSceneView >> redraw [
	self changed
]

{ #category : #accessing }
GdsSceneView >> scene: aScene [
	super scene: aScene.
	(aScene respondsTo: #sceneView:)
		ifTrue: [ aScene perform: #sceneView: with: self ].
	
]

{ #category : #'as yet unclassified' }
GdsSceneView >> sine: aSine [
	super sine: aSine.
	
]

{ #category : #'zoom animation' }
GdsSceneView >> step [

	self inState: #zooming do: [ :zoomState |
		| now start end center targetZoom factor |
		now := Time millisecondClockValue.
		start := zoomState at: 4.
		end := zoomState at: 5.
		
		(now between: start and:end) ifFalse: [ now := end.
			self resetState: #zooming.
			self stopStepping ].
		
		transform := (zoomState at: 2) copy.
		center := zoomState at: 1.
		
		factor :=  (now-start)/(end - start ).
		targetZoom := zoomState at: 3.
		targetZoom := 1* (1-factor) + (targetZoom * factor).
		
		transform
			translateBy: center;
			scaleBy:targetZoom;
			translateBy: center negated.
	].
	self changed.

]

{ #category : #accessing }
GdsSceneView >> structure [
	^ scene structure
]

{ #category : #accessing }
GdsSceneView >> structure: aGdsStructure [
	self scene: (GdsAthensStructureDrawer new initWithStructure: aGdsStructure)
]

{ #category : #'as yet unclassified' }
GdsSceneView >> syncTransform [
	self lockTransformUpdate: true.
	[  
	self viewport viewScale: transform scale x.
	self viewport viewCenter: transform translation.
	"self viewport portCenter: transform a11."
	] ensure: [
		self lockTransformUpdate: false.]
]

{ #category : #'zoom animation' }
GdsSceneView >> updateZoom: zoom cursor: cursorPoint [

	| zoomState targetZoom start end now fraction newCenter localPoint |
	zoomState := state at:#zooming.
		
	"change the target zoom and increase time a bit"
	targetZoom := zoomState at: 3.
	
	start := zoomState at: 4.
	end := zoomState at: 5.
		
	now := Time millisecondClockValue.
	
	(now > end) ifTrue: [  now := end ].
	
	 "interpolate linearly the target zoom factor over time start ... end"
	fraction := (now - start) / (end - start).
	
	"zoom goes from 1..target zoom"
	targetZoom := 1*(1-fraction) + (targetZoom * fraction).

	self step. "to update transform"
	zoomState at: 3 put: targetZoom * zoom.
	localPoint := (cursorPoint - bounds origin).
		self lockTransformUpdate: true.
		self viewport portCenter: localPoint.		
		self lockTransformUpdate: false.
			
		
	newCenter :=   transform inverseTransform: localPoint.
	zoomState at: 1 put: newCenter.
	zoomState at: 2 put: transform copy.
	zoomState at: 4 put: now.
	zoomState at: 5 put: now + 250 .

]

{ #category : #viewing }
GdsSceneView >> viewFit [
	self viewport ifNil: [^self].
	self viewport viewFit
]

{ #category : #'as yet unclassified' }
GdsSceneView >> viewTransformChanged [
	self lockTransformUpdate ifTrue: [ ^ self ].
	transform := self viewport transform asAthensAT
]

{ #category : #accessing }
GdsSceneView >> viewport [
	^ viewport ifNil: [ viewport := self createViewport ]
	
]

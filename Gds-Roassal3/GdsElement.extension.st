Extension { #name : #GdsElement }

{ #category : #'*Gds-Roassal3' }
GdsElement >> asRoassal3Renderer [
	^ GdsRedererRoassal3 forElement: self.
]

{ #category : #'*Gds-Roassal3' }
GdsElement >> gtInspectorViewIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite roassal3
		title: 'Canvas';
		initializeCanvas: [ self asRoassal3Renderer render ]
]

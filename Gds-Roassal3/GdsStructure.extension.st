Extension { #name : #GdsStructure }

{ #category : #'*Gds-Roassal3' }
GdsStructure >> asRoassal3Renderer [
	^ GdsRedererRoassal3 forStructure: self.
]

{ #category : #'*Gds-Roassal3' }
GdsStructure >> gtInspectorViewIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite roassal3
		title: 'Canvas';
		initializeCanvas: [ self asRoassal3Renderer render ]
]

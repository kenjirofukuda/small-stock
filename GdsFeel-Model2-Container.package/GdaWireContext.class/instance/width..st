accessing - basic
width: aFloat

	width = aFloat ifTrue: [ ^ self ].
	width := aFloat.
	self removeGeometryCache
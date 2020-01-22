Extension { #name : #Collection }

{ #category : #'*GdsFeel-CLI' }
Collection >> asGdsValue [
	self isEmpty ifTrue: [^ GdsNull fromSmalltalkObject: self].
	^ GdsVector fromSmalltalkObject: self
]

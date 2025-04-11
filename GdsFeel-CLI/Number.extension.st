Extension { #name : 'Number' }

{ #category : '*GdsFeel-CLI' }
Number >> asGdsValue [
	^ ((self isInteger and: [ self = 1 or: [ self = 0 ] ])
		ifTrue: [ GdsBoolean ]
		ifFalse: [ GdsNumber ]) fromSmalltalkObject: self
]

Extension { #name : #Character }

{ #category : #'*GdsFeel-CLI' }
Character >> asGdsValue [
	^ GdsCharacter fromSmalltalkObject: self
]

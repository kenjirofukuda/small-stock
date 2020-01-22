Extension { #name : #Boolean }

{ #category : #'*GdsFeel-CLI' }
Boolean >> asGdsValue [
	^GdsBoolean fromSmalltalkObject: self.

]

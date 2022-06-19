Extension { #name : #Object }

{ #category : #'*GdsFeel-CLI' }
Object >> asGdsValue [
	^ GdsDataStructure cantConvertSmalltalkObject: self
]

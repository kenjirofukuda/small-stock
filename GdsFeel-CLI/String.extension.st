Extension { #name : #String }

{ #category : #'*GdsFeel-CLI' }
String >> asGdsValue [
	self isEmpty
		ifTrue: [ ^ GdsNull fromSmalltalkObject: self ].
	^ GdsString fromSmalltalkObject: self
]

{ #category : #'*GdsFeel-CLI' }
String >> isAllHex [
	^ self isAllInsideChars: '0123456789ABCDEF'
]

{ #category : #'*GdsFeel-CLI' }
String >> isAllInsideChars: aString [
	self
		do: [ :c | 
			(aString includes: c)
				ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'*GdsFeel-CLI' }
String >> isAllOctal [
	^ self isAllInsideChars: '01234567'
]

accessing
recordSize

	| buff |
	self ensureReadStream.
	stream atEnd ifTrue: [ ^ -1 ].
	buff := (stream next: 2) asByteArray.
	^ buff unsignedShortAt: 1 bigEndian: true
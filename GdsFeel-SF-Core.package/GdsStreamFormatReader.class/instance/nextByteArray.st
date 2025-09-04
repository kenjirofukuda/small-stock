api
nextByteArray

	| restSize bytes recordSize |
	recordSize := self recordSize.
	recordSize < 0 ifTrue: [ ^ #(  ) ].
	restSize := recordSize - 2.
	restSize <= 0 ifTrue: [ ^ #(  ) ].
	bytes := (stream next: restSize) asByteArray.
	^ bytes
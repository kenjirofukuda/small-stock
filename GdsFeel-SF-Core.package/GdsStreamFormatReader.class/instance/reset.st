api
reset

	"stream reset."
	stream ifNotNil: [ stream closed ifFalse: [ stream close ] ].
	stream := self ensureReadStream.
	self assert: [ stream position = 0 ]
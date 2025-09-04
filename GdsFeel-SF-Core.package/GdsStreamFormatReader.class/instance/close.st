api
close

	stream ifNotNil: [ stream closed ifFalse: [ stream close ] ].
	stream := nil
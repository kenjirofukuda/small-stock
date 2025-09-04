updating
refreshBounds

	offsets := nil.
	transforms := nil.
	element ifNil: [ ^ self ].
	element refreshBounds
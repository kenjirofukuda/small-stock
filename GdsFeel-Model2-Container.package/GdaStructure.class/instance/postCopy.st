copying
postCopy

	super postCopy.
	elements := elements collect: [ :e | e copy ].
	layers := layers copy
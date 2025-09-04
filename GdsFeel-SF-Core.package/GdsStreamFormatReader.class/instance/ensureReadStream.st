initialization - private
ensureReadStream
	^ stream ifNil: [ stream := self openForReadFileNamed: self streamFormatPath ].
	
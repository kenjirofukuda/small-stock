logging
endLog

	logStream ifNil: [ ^ self ].
	logStream position = 0 ifTrue: [ ^ self ].
	Smalltalk at: #UIManager
		ifPresent: [ :clazz | 
			clazz edit: logStream contents label: self category asString ]
		ifAbsent: [  ]
Class {
	#name : #Gpl2Scanner,
	#superclass : #SmaCCScanner,
	#category : #'GdsFeel-SmaCC'
}

{ #category : #'generated-initialization' }
Gpl2Scanner class >> initializeKeywordMap [

	keywordMap := Dictionary new.
	#( #( 4 'SIZE' 10 ) ) do: [ :each | 
		(keywordMap at: each first ifAbsentPut: [ Dictionary new ])
			at: (each at: 2)
			put: each last ].
	^ keywordMap
]

{ #category : #generated }
Gpl2Scanner >> emptySymbolTokenId [

	^ 20
]

{ #category : #generated }
Gpl2Scanner >> errorTokenId [

	^ 21
]

{ #category : #generated }
Gpl2Scanner >> nameId [

	^ 4
]

{ #category : #generated }
Gpl2Scanner >> numberId [

	^ 3
]

{ #category : #generated }
Gpl2Scanner >> scan1 [

	self step.
	currentCharacter isDigit ifTrue: [ ^ self scan2 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan10 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan11 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan11 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan12 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan12 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan13 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan13 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan14 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan14 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan15 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan15 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan16 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan16 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ 
		self recordMatch: #( 4 ).
		self step.
		(currentCharacter isDigit or: [ 
			 currentCharacter == $$ or: [ 
				 (currentCharacter between: $A and: $Z) or: [ 
					 currentCharacter == $_ ] ] ]) ifTrue: [ 
			self recordMatch: #( 4 ).
			self step.
			(currentCharacter isDigit or: [ 
				 currentCharacter == $$ or: [ 
					 (currentCharacter between: $A and: $Z) or: [ 
						 currentCharacter == $_ ] ] ]) ifTrue: [ 
				self recordMatch: #( 4 ).
				self step.
				(currentCharacter isDigit or: [ 
					 currentCharacter == $$ or: [ 
						 (currentCharacter between: $A and: $Z) or: [ 
							 currentCharacter == $_ ] ] ]) ifTrue: [ 
					self recordMatch: #( 4 ).
					self step.
					(currentCharacter isDigit or: [ 
						 currentCharacter == $$ or: [ 
							 (currentCharacter between: $A and: $Z) or: [ 
								 currentCharacter == $_ ] ] ]) ifTrue: [ 
						self recordMatch: #( 4 ).
						self step.
						(currentCharacter isDigit or: [ 
							 currentCharacter == $$ or: [ 
								 (currentCharacter between: $A and: $Z) or: [ 
									 currentCharacter == $_ ] ] ]) ifTrue: [ 
							self recordMatch: #( 4 ).
							self step.
							(currentCharacter isDigit or: [ 
								 currentCharacter == $$ or: [ 
									 (currentCharacter between: $A and: $Z) or: [ 
										 currentCharacter == $_ ] ] ]) ifTrue: [ 
								self recordMatch: #( 4 ).
								self step.
								(currentCharacter isDigit or: [ 
									 currentCharacter == $$ or: [ 
										 (currentCharacter between: $A and: $Z) or: [ 
											 currentCharacter == $_ ] ] ]) ifTrue: [ 
									self recordMatch: #( 4 ).
									self step.
									(currentCharacter isDigit or: [ 
										 currentCharacter == $$ or: [ 
											 (currentCharacter between: $A and: $Z) or: [ 
												 currentCharacter == $_ ] ] ]) ifTrue: [ 
										self recordMatch: #( 4 ).
										self step.
										(currentCharacter isDigit or: [ 
											 currentCharacter == $$ or: [ 
												 (currentCharacter between: $A and: $Z) or: [ 
													 currentCharacter == $_ ] ] ]) ifTrue: [ 
											self recordMatch: #( 4 ).
											self step.
											(currentCharacter isDigit or: [ 
												 currentCharacter == $$ or: [ 
													 (currentCharacter between: $A and: $Z) or: [ 
														 currentCharacter == $_ ] ] ]) ifTrue: [ 
												self recordMatch: #( 4 ).
												self step.
												(currentCharacter isDigit or: [ 
													 currentCharacter == $$ or: [ 
														 (currentCharacter between: $A and: $Z) or: [ 
															 currentCharacter == $_ ] ] ]) ifTrue: [ 
													self recordMatch: #( 4 ).
													self step.
													(currentCharacter isDigit or: [ 
														 currentCharacter == $$ or: [ 
															 (currentCharacter between: $A and: $Z) or: [ 
																 currentCharacter == $_ ] ] ]) ifTrue: [ 
														self recordMatch: #( 4 ).
														self step.
														(currentCharacter isDigit or: [ 
															 currentCharacter == $$ or: [ 
																 (currentCharacter between: $A and: $Z) or: [ 
																	 currentCharacter == $_ ] ] ]) ifTrue: [ 
															self recordMatch: #( 4 ).
															self step.
															(currentCharacter isDigit or: [ 
																 currentCharacter == $$ or: [ 
																	 (currentCharacter between: $A and: $Z) or: [ 
																		 currentCharacter == $_ ] ] ]) ifTrue: [ 
																self recordMatch: #( 4 ).
																self step.
																(currentCharacter isDigit or: [ 
																	 currentCharacter == $$ or: [ 
																		 (currentCharacter between: $A and: $Z) or: [ 
																			 currentCharacter == $_ ] ] ]) ifTrue: [ 
																	self recordMatch: #( 4 ).
																	self step.
																	(currentCharacter isDigit or: [ 
																		 currentCharacter == $$ or: [ 
																			 (currentCharacter between: $A and: $Z) or: [ 
																				 currentCharacter == $_ ] ] ]) ifTrue: [ 
																		self recordMatch: #( 4 ).
																		self step.
																		(currentCharacter isDigit or: [ 
																			 currentCharacter == $$ or: [ 
																				 (currentCharacter between: $A and: $Z) or: [ 
																					 currentCharacter == $_ ] ] ]) ifTrue: [ 
																			self recordMatch: #( 4 ).
																			self step.
																			(currentCharacter isDigit or: [ 
																				 currentCharacter == $$ or: [ 
																					 (currentCharacter between: $A and: $Z) or: [ 
																						 currentCharacter == $_ ] ] ]) ifTrue: [ 
																				self recordMatch: #( 4 ).
																				self step.
																				(currentCharacter isDigit or: [ 
																					 currentCharacter == $$ or: [ 
																						 (currentCharacter between: $A and: $Z) or: [ 
																							 currentCharacter == $_ ] ] ]) ifTrue: [ 
																					self recordMatch: #( 4 ).
																					self step.
																					(currentCharacter isDigit or: [ 
																						 currentCharacter == $$ or: [ 
																							 (currentCharacter between: $A and: $Z) or: [ 
																								 currentCharacter == $_ ] ] ]) ifTrue: [ 
																						^ self recordAndReportMatch: #( 4 ) ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan2 [

	[ 
	self recordMatch: #( 3 ).
	self step.
	currentCharacter == $E ifTrue: [ ^ self scan3 ].
	currentCharacter isDigit ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan3 [

	self step.
	currentCharacter isDigit ifTrue: [ 
		[ 
		self recordMatch: #( 3 ).
		self step.
		currentCharacter isDigit ] whileTrue.
		^ self reportLastMatch ].
	('+-' includes: currentCharacter) ifTrue: [ 
		self step.
		currentCharacter isDigit ifTrue: [ 
			[ 
			self recordMatch: #( 3 ).
			self step.
			currentCharacter isDigit ] whileTrue ] ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan4 [

	self recordMatch: #( 3 ).
	self step.
	currentCharacter == $. ifTrue: [ ^ self scan2 ].
	currentCharacter == $E ifTrue: [ ^ self scan3 ].
	currentCharacter isDigit ifTrue: [ 
		[ 
		self step.
		currentCharacter == $. ifTrue: [ ^ self scan2 ].
		currentCharacter == $E ifTrue: [ ^ self scan3 ].
		currentCharacter isDigit ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan5 [

	[ 
	self recordMatch: #( 3 ).
	self step.
	currentCharacter == $. ifTrue: [ ^ self scan2 ].
	currentCharacter == $E ifTrue: [ ^ self scan3 ].
	currentCharacter isDigit ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan6 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan7 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan7 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan8 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan8 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan9 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scan9 [

	self recordMatch: #( 4 ).
	self step.
	(currentCharacter isDigit or: [ 
		 currentCharacter == $$ or: [ 
			 (currentCharacter between: $A and: $Z) or: [ 
				 currentCharacter == $_ ] ] ]) ifTrue: [ ^ self scan10 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scanForToken [

	self step.
	currentCharacter == $% ifTrue: [ ^ self recordAndReportMatch: #( 9 ) ].
	currentCharacter == $* ifTrue: [ ^ self recordAndReportMatch: #( 6 ) ].
	currentCharacter == $+ ifTrue: [ ^ self recordAndReportMatch: #( 7 ) ].
	currentCharacter == $, ifTrue: [ ^ self recordAndReportMatch: #( 8 ) ].
	currentCharacter == $- ifTrue: [ ^ self scanForTokenX1 ].
	currentCharacter == $. ifTrue: [ ^ self scan1 ].
	currentCharacter == $0 ifTrue: [ ^ self scan4 ].
	currentCharacter isDigit ifTrue: [ ^ self scan5 ].
	(currentCharacter between: $A and: $Z) ifTrue: [ ^ self scan6 ].
	(currentCharacter isSeparator or: [ 
		 currentCharacter == Character pageUp ]) ifTrue: [ 
		self scanForTokenX2 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scanForTokenX1 [

	self recordMatch: #( 5 ).
	self step.
	currentCharacter == $. ifTrue: [ ^ self scan1 ].
	currentCharacter == $0 ifTrue: [ ^ self scan4 ].
	currentCharacter isDigit ifTrue: [ ^ self scan5 ].
	^ self reportLastMatch
]

{ #category : #generated }
Gpl2Scanner >> scanForTokenX2 [

	self recordMatch: #( 1 2 ).
	self step.
	(currentCharacter isSeparator or: [ 
		 currentCharacter == Character pageUp ]) ifTrue: [ 
		[ 
		self recordMatch: #( 2 ).
		self step.
		currentCharacter isSeparator or: [ 
			currentCharacter == Character pageUp ] ] whileTrue ]
]

{ #category : #generated }
Gpl2Scanner >> tokenActions [

	^ #( nil #whitespace )
]

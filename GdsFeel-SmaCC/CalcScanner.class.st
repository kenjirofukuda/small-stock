Class {
	#name : #CalcScanner,
	#superclass : #SmaCCScanner,
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
CalcScanner class >> states [
	^ #(#default)
]

{ #category : #generated }
CalcScanner >> emptySymbolTokenId [
	^ 6
]

{ #category : #generated }
CalcScanner >> errorTokenId [
	^ 7
]

{ #category : #generated }
CalcScanner >> scanForToken [
	self step.
	currentCharacter == $+
		ifTrue: [ ^ self recordAndReportMatch: #(1) ].
	(currentCharacter between: $0 and: $9)
		ifTrue: [ [ self recordMatch: #(2).
			self step.
			currentCharacter == $.
				ifTrue: [ [ self recordMatch: #(2).
					self step.
					currentCharacter between: $0 and: $9 ] whileTrue.
					^ self reportLastMatch ].
			currentCharacter between: $0 and: $9 ] whileTrue.
			^ self reportLastMatch ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ [ self recordMatch: #(3).
			self step.
			currentCharacter isSeparator
				or: [ currentCharacter == Character pageUp ] ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
CalcScanner >> tokenActions [
	^ #(nil nil #whitespace)
]

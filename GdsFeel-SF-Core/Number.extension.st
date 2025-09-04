Extension { #name : #Number }

{ #category : #'*GdsFeel-SF-Core' }
Number >> asUserFromDBU: aDatabaseUnit [
	| fdbu |
	fdbu := aDatabaseUnit asFloat.
	^ (self * fdbu reciprocal * fdbu) rounded / fdbu
]

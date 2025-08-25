Extension { #name : #Number }

{ #category : #'*GdsFeel-Foundation-StreamFormat' }
Number >> asUserFromDBU: aDatabaseUnit [
	| fdbu |
	fdbu := aDatabaseUnit asFloat.
	^ (self * fdbu reciprocal * fdbu) rounded / fdbu
]

Extension { #name : #Number }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Any' }
Number >> asUserFromDBU: aDatabaseUnit [
	| fdbu |
	fdbu := aDatabaseUnit asFloat.
	^ (self * fdbu reciprocal * fdbu) rounded / fdbu
]

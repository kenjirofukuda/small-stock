*GdsFeel-SF-Core
asUserFromDBU: aDatabaseUnit
	| fdbu |
	fdbu := aDatabaseUnit asFloat.
	^ (self * fdbu reciprocal * fdbu) rounded / fdbu
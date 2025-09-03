Extension { #name : #Point }

{ #category : #'*GdsFeel-SF-Core' }
Point >> asUserFromDBU: aDatabaseUnit [
	^ (x asUserFromDBU: aDatabaseUnit) @ (y asUserFromDBU: aDatabaseUnit)
]

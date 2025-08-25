Extension { #name : #Point }

{ #category : #'*GdsFeel-Foundation-StreamFormat' }
Point >> asUserFromDBU: aDatabaseUnit [
	^ (x asUserFromDBU: aDatabaseUnit) @ (y asUserFromDBU: aDatabaseUnit)
]

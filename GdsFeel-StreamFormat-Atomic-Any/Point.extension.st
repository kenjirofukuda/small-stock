Extension { #name : #Point }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Any' }
Point >> asUserFromDBU: aDatabaseUnit [
	^ (x asUserFromDBU: aDatabaseUnit) @ (y asUserFromDBU: aDatabaseUnit)
]

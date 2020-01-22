Extension { #name : #Point }

{ #category : #'*GdsFeel-Foundation' }
Point >> angleDegress [
	^ self angle radiansToDegrees .
]

{ #category : #'*GdsFeel-Foundation' }
Point >> asArray [
	^ Array with: self x with: self y 
]

{ #category : #'*GdsFeel-Foundation' }
Point >> asUserFromDBU: aDatabaseUnit [
	^ (x asUserFromDBU: aDatabaseUnit) @ (y asUserFromDBU: aDatabaseUnit)
]

{ #category : #'*GdsFeel-Foundation' }
Point >> fixNegativeZero [
	^ self x fixNegativeZero @ self y fixNegativeZero
]

{ #category : #'*GdsFeel-Foundation' }
Point >> horizontalMirrored [
	^ self x @ self y negated
]

{ #category : #'*GdsFeel-Foundation' }
Point >> rightRotatedInModel [
	^ self leftRotated
]

{ #category : #'*GdsFeel-Foundation' }
Point >> rotateInModelBy: radians about: center [ 
	"Even though Point.theta is measured CW, this rotates with the more conventional CCW interpretateion of angle."
	| p r theta |
	p := self - center.
	r := p r.
	theta := radians asFloat - p theta negated.
	^ (center x asFloat + (r * theta cos)) @ (center y asFloat + (r * theta sin))
]

{ #category : #'*GdsFeel-Foundation' }
Point >> setR: rho radians: radians [ 
	x := rho asFloat * radians cos.
	y := rho asFloat * radians sin.
]

{ #category : #'*GdsFeel-Foundation' }
Point >> verticalMirrored [
	^ self x negated @ self y
]

{ #category : #'*GdsFeel-Foundation' }
Point >> yFliped [
	^ self * (1 @ -1)
]

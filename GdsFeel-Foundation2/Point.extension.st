Extension { #name : #Point }

{ #category : #'*GdsFeel-Foundation2' }
Point >> angleDegress [

	^ self angle radiansToDegrees
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> asArray [

	^ Array with: self x with: self y
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> fixNegativeZero [

	^ self x fixNegativeZero @ self y fixNegativeZero
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> horizontalMirrored [

	^ self x @ self y negated
]

{ #category : #'*GdsFeel-Foundation2' }
Point class >> r: rho radians: radians [

	"Answer an instance of me with polar coordinates rho and theta."

	^ self basicNew setR: rho radians: radians
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> rightRotatedInModel [

	^ self leftRotated
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> rotateInModelBy: radians about: center [

	"Even though Point.theta is measured CW, this rotates with the more conventional CCW interpretateion of angle."

	| p r theta |
	p := self - center.
	r := p r.
	theta := radians asFloat - p theta negated.
	^ center x asFloat + (r * theta cos)
	  @ (center y asFloat + (r * theta sin))
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> setR: rho radians: radians [

	x := rho asFloat * radians cos.
	y := rho asFloat * radians sin
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> verticalMirrored [

	^ self x negated @ self y
]

{ #category : #'*GdsFeel-Foundation2' }
Point >> yFliped [

	^ self * (1 @ -1)
]

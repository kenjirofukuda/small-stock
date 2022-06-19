Class {
	#name : #GplDateTimeHandler,
	#superclass : #GplMultiHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplDateTimeHandler class >> associateArray [
	^ {('TOD' -> #tod:).
	('DAY' -> #day:)}
]

{ #category : #testing }
GplDateTimeHandler class >> isFunctionAllowed [
	^ true
]

{ #category : #testing }
GplDateTimeHandler class >> isFunctionAllowed: aCommandName [
	^ true
]

{ #category : #testing }
GplDateTimeHandler class >> isNiladicAllowed [
	^ true
]

{ #category : #handler }
GplDateTimeHandler >> day: aToken [
	| date |
	date := Date today.
	^ GdsVector
		withAll:
			(self
				integerVector:
					{date monthIndex.
					date dayOfMonth.
					date year asString})
]

{ #category : #handler }
GplDateTimeHandler >> tod: aToken [
	| time |
	time := Time now.
	^ GdsVector
		withAll:
			(self
				integerVector:
					{time hour.
					time minute.
					time second})
]

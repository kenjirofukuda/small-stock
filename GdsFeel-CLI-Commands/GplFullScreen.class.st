Class {
	#name : #GplFullScreen,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplFullScreen class >> methodName [
	^ 'FULLSCREEN'
]

{ #category : #handler }
GplFullScreen >> evaluateToken: aToken [
	self stationUI
		expandBoxHit;
		comeToFront.
	^ self nullVector
]

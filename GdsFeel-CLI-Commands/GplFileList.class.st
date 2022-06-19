Class {
	#name : #GplFileList,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplFileList class >> methodName [
	^ 'FLIST'
]

{ #category : #handler }
GplFileList >> evaluateToken: aToken [
	| names |
	names := GdsLibrary archivedNames.
	^ self strings: names
]

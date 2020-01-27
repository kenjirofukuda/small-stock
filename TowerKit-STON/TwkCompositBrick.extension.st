Extension { #name : #TwkCompositBrick }

{ #category : #'*TowerKit-STON' }
TwkCompositBrick >> fileOutAsSton [
	self stonOutputFile asFileReference
		ensureDelete;
		mbWriteStreamDo: [ :s | STON put: self onStreamPretty: s ]
]

{ #category : #'*TowerKit-STON' }
TwkCompositBrick class >> fromStonFile: aFileReference [
	aFileReference asFileReference 
		readStreamDo: [ :s |
			^ self fromStonStream: s
			 ]
]

{ #category : #'*TowerKit-STON' }
TwkCompositBrick class >> fromStonStream: aStonStream [
	^ (STON reader on: aStonStream) next
]

{ #category : #'*TowerKit-STON' }
TwkCompositBrick class >> projectStonFiles [
	"self projectStonFiles explore"
	^ TwkTower defaultFolder allFiles select: [ :f | f basename sameAs: 'input-data.ston' ]
]

{ #category : #'*TowerKit-STON' }
TwkCompositBrick >> stonOutputFile [
	^ self projectFolder / 'input-data.ston'
]

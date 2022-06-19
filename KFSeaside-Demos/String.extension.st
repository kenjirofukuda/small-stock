Extension { #name : #String }

{ #category : #'*KFSeaside-Demos' }
String >> tabWidth2 [
	^ self copyReplaceAll: Character tab asString with: '  '
]

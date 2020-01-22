Class {
	#name : #HikiFarmSite,
	#superclass : #HikiSite,
	#category : #'Hiki-Core'
}

{ #category : #'instance-creation' }
HikiFarmSite class >> hikifarm [
	"self hikifarm"
	^ HikiFarmSite new folder: self lolipopFolder / 'hikifarm'
]

{ #category : #initalize }
HikiFarmSite >> initialize [
	super initialize.
	self cgiConfFilename: 'hikifarm.conf'
]

{ #category : #'as yet unclassified' }
HikiFarmSite >> siteFolders [
	^ self dataFolder directories select: [ :dir | (dir / 'hiki.conf') exists ]
]

{ #category : #'as yet unclassified' }
HikiFarmSite >> sites [
	"HikiFarmSite hikifarm sites"
	^ self siteFolders collect: [ :f | HikiSite new folder: f; farm: self; yourself]
]

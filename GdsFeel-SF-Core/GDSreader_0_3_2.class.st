"
I represents GDSreader.0.3.2 guest project.
C language implemeted gdsii external tool.

please extract binary package archive
- https://ftp.netbsd.org/pub/pkgsrc/distfiles/GDSreader.0.3.2.tar.gz

of github repository
- https://github.com/makoto-fujiwara/GDSreader.git 
"
Class {
	#name : #'GDSreader_0_3_2',
	#superclass : #Object,
	#category : #'GdsFeel-SF-Core'
}

{ #category : #'verification - archive' }
GDSreader_0_3_2 class >> archiveFileSize [

	^ 155648
]

{ #category : #'verification - archive' }
GDSreader_0_3_2 class >> archiveMD5sum [

	^ 'a1a4c054d87e042a4cbee4a1d60c3f94'
]

{ #category : #'internet resource' }
GDSreader_0_3_2 class >> binaryPackageURL [

	^ 'https://ftp.netbsd.org/pub/pkgsrc/distfiles/GDSreader.0.3.2.tar.gz'
]

{ #category : #accessing }
GDSreader_0_3_2 class >> directoryEntry [

	"self directoryEntry"

	^ ('./' asDirectoryEntry / 'GdsFeel' / self projectName)
		  fullPrintString asDirectoryEntry assureExistence.
]

{ #category : #'verification - gdsfile' }
GDSreader_0_3_2 class >> fileSize [

	^ 155648
]

{ #category : #'internet resource' }
GDSreader_0_3_2 class >> githubRepositoryURL [

	^ 'https://github.com/makoto-fujiwara/GDSreader'
]

{ #category : #'verification - gdsfile' }
GDSreader_0_3_2 class >> md5sum [

	^ 'a1a4c054d87e042a4cbee4a1d60c3f94'
]

{ #category : #'verification - gdsfile' }
GDSreader_0_3_2 class >> numberOfRecords [

	^ 15155
]

{ #category : #accessing }
GDSreader_0_3_2 class >> projectName [

	^ 'GDSreader.0.3.2'
]

{ #category : #accessing }
GDSreader_0_3_2 class >> sampleBaseName [

	^ 'test.gds'
]

{ #category : #'internet resource' }
GDSreader_0_3_2 class >> sampleFileBinaryURL [

	^ self githubRepositoryURL , '/raw/master/test.gds'
]

{ #category : #accessing }
GDSreader_0_3_2 class >> sampleFileEntry [

	"self sampleFileEntry"
	| dirEnt |
	dirEnt := self directoryEntry.
	^ (dirEnt respondsTo: #//)
		ifTrue: [dirEnt // self sampleBaseName]	  "only Cuis"
		ifFalse: [dirEnt / self sampleBaseName]  "Squeak, Pharo"
]

{ #category : #'see class side' }
GDSreader_0_3_2 >> seeClassSide [
	
]

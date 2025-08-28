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
	#category : #'GdsFeel-StreamFormat-Atomic-Any'
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

{ #category : #'internet resource' }
GDSreader_0_3_2 class >> sampleFileBinaryURL [

	^ self githubRepositoryURL , '/raw/master/test.gds'
]

{ #category : #'see class side' }
GDSreader_0_3_2 >> seeClassSide [
	
]

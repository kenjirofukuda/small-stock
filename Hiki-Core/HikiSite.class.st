Class {
	#name : #HikiSite,
	#superclass : #Object,
	#instVars : [
		'folder',
		'pages',
		'dataFolder',
		'confFilename',
		'farm',
		'name'
	],
	#category : #'Hiki-Core'
}

{ #category : #utilities }
HikiSite class >> contentsOfFile: aFileReference encoding: encoding [
	aFileReference readStreamDo: [ :s |
		s converter: (TextConverter newForEncoding: encoding) .
		^ s contents]
]

{ #category : #utilities }
HikiSite class >> decodePercentAsByteArray: aString [
	|  stringStream |  
	stringStream := aString readStream.
	^ ByteArray streamContents: [ :byteStream | 
		ZnPercentEncoder new decode: stringStream to: byteStream ].

]

{ #category : #example }
HikiSite class >> example [
	"self example"
	HikiSite note explore.
]

{ #category : #'as yet unclassified' }
HikiSite class >> lolipopFolder [
	"self lolipopFolder"
	^ FileLocator home / 'Documents' / 'lolipop'
]

{ #category : #'instance-creation' }
HikiSite class >> note [
	^ HikiSite new folder: self lolipopFolder / 'note'
]

{ #category : #'instance-creation' }
HikiSite class >> yota [
	^ HikiSite new folder: self lolipopFolder / 'yota'
]

{ #category : #'accessing folder' }
HikiSite >> attachedFolder [
	^ self dataFolder / 'cache' / 'attach'
]

{ #category : #accessing }
HikiSite >> cgiConf [
	^ self contentsOfFile: self cgiConfFile.
]

{ #category : #accessing }
HikiSite >> cgiConfFile [
	self isFarm
		ifTrue: [ ^ self farm cgiConfFile ].
	^ folder / self cgiConfFilename.
]

{ #category : #accessing }
HikiSite >> cgiConfFilename [
	^ confFilename ifNil: [ confFilename := 'hikiconf.rb' ]
]

{ #category : #initalize }
HikiSite >> cgiConfFilename: aFilename [
	confFilename := aFilename
]

{ #category : #private }
HikiSite >> contentsOfFile: aFileReference [
	^ self class contentsOfFile: aFileReference encoding: self encoding
]

{ #category : #'accessing folder' }
HikiSite >> cssFiles [
	^ Array 
		with: self themeFolder / 'hiki_base.css' 
		with: self themeFolder / 'hiki' / 'hiki.css'
]

{ #category : #'accessing folder' }
HikiSite >> dataFolder [
	^ dataFolder ifNil: [ dataFolder := self lookupDataFolder  ]
]

{ #category : #accessing }
HikiSite >> encoding [
	^ 'euc-jp'
]

{ #category : #accessing }
HikiSite >> farm [
	^ farm
]

{ #category : #accessing }
HikiSite >> farm: aHikiFarmSite [
	farm := aHikiFarmSite
]

{ #category : #accessing }
HikiSite >> folder [
	^ folder
]

{ #category : #initalize }
HikiSite >> folder: aFolder [
	folder := aFolder asFileReference .
	
]

{ #category : #accessing }
HikiSite >> frontPage [
	^ self pageNamed: 'FrontPage'
]

{ #category : #inspector }
HikiSite >> gtInspectorHikiSiteCgiConfIn: composite [
	<gtInspectorPresentationOrder: 100>
	composite text
		title: 'CGI Configuration';
		display: [ self cgiConf ]

]

{ #category : #inspector }
HikiSite >> gtInspectorHikiSiteConfIn: composite [
	<gtInspectorPresentationOrder: 100>
	composite text
		title: 'Site Configuration';
		display: [ self siteConf ]

]

{ #category : #inspector }
HikiSite >> gtInspectorHikiSitePagesIn: composite [
	<gtInspectorPresentationOrder: 100>
	^ composite table 
		title: 'Pages';
		display: [ self pages ];
		column: 'Name' evaluated: [ :each | each decordedFileName  ];
		column: 'Attached' evaluated: [ :each | each attachedCountString  ] width: 20;
		column: 'Creation' evaluated: [ :each | 
			self timeCaption: each file creationTime ];
		column: 'Modification' evaluated: [ :each | 
			self timeCaption: each file modificationTime  ];
		yourself

]

{ #category : #initalize }
HikiSite >> initialize [
	super initialize.
	confFilename := 'hikiconf.rb'
]

{ #category : #testing }
HikiSite >> isFarm [
	^ farm notNil
]

{ #category : #private }
HikiSite >> lookupClassicDataFolder [
	(self cgiConf lines 
		detect: [ :line | (line beginsWith: '@data_path') or: [line beginsWith: 'data_path']] 
		ifNone: [])
		ifNotNilDo: [ :dataLine | | folderName |
			folderName := (((dataLine findTokens: ' ') last )findTokens: '/') last.
			folderName := folderName trimBoth: [ :char | {$" . $'} includes: char ].
			^ (self class lolipopFolder / folderName) resolve ].
	^ nil
]

{ #category : #private }
HikiSite >> lookupDataFolder [
	^ self isFarm
		ifTrue: [ self lookupFarmDataFolder ]
		ifFalse: [ self lookupClassicDataFolder ]
]

{ #category : #private }
HikiSite >> lookupFarmDataFolder [
	^ self folder 
]

{ #category : #private }
HikiSite >> lookupPages [
	^ self textFolder children collect: [ :f | HikiPage new file: f; site: self; yourself ]
]

{ #category : #private }
HikiSite >> lookupSiteName [
	(self siteConf lines 
		detect: [ :line | line beginsWith: 'site_name'] 
		ifNone: [])
		ifNotNilDo: [ :dataLine | | siteName |
			siteName := (dataLine findTokens: '=') last trim.
			siteName := siteName trimBoth: [ :char | {$" . $'} includes: char ].
			^ siteName ].
	^ self dataFolder basename
]

{ #category : #accessing }
HikiSite >> name [
	^ name ifNil: [ name := self lookupSiteName ]
]

{ #category : #accessing }
HikiSite >> pageNamed: aPageName [
	^ self pages detect: [ :page | page name sameAs: aPageName ] ifNone: [ ]
]

{ #category : #accessing }
HikiSite >> pages [
	^ pages ifNil: [ pages := self lookupPages ]
]

{ #category : #'accessing folder' }
HikiSite >> parserFolder [
	^ self dataFolder / 'cache' / 'parser'
]

{ #category : #printing }
HikiSite >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self name printOn: aStream.
	aStream nextPut: $).	
]

{ #category : #accessing }
HikiSite >> sideMenu [
	^ self pageNamed: 'SideMenu'
]

{ #category : #accessing }
HikiSite >> siteConf [
	^ self contentsOfFile: self dataFolder  / 'hiki.conf'
]

{ #category : #'accessing folder' }
HikiSite >> textFolder [
	^ self dataFolder /  'text'
]

{ #category : #'accessing folder' }
HikiSite >> themeFolder [
	^ self cgiConfFile parent / 'theme'
]

{ #category : #inspector }
HikiSite >> timeCaption: aTime [
	^ String
		streamContents: [ :s | 
			aTime printYMDOn: s.
			s nextPut: Character space.
			aTime printHMSOn: s ]
]

Class {
	#name : #ConfigurationOfKFImaging,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad',
		'LocalPackagePath'
	],
	#category : #ConfigurationOfKFImaging
}

{ #category : #'development support' }
ConfigurationOfKFImaging class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #utility }
ConfigurationOfKFImaging class >> availableSyncServices [
	^ #('Nextcloud' 'Dropbox')
]

{ #category : #private }
ConfigurationOfKFImaging class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #'development support' }
ConfigurationOfKFImaging class >> checkDependent [
	"self checkDependent."
	<scripts>
	| pkgs loader |
	loader := (self project version: #bleedingEdge) ignoreImage: true; record: #('default').
	pkgs := OrderedCollection new.
	loader loadDirective packageDirectivesDo: [:directive | pkgs add: directive spec file ]. 
	pkgs explore.

]

{ #category : #utility }
ConfigurationOfKFImaging class >> directoryExixts: aLocalPathName [
	^(Smalltalk at: #FileDirectory ifAbsent: []) 
		ifNotNil: [:classFD |
			(classFD perform: #default) perform: #directoryExists: with: aLocalPathName ]
		ifNil: [(aLocalPathName perform: #asFileReference) perform: #exists]
	
]

{ #category : #private }
ConfigurationOfKFImaging class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfKFImaging class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfKFImaging class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfKFImaging class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfKFImaging class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfKFImaging class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #utility }
ConfigurationOfKFImaging class >> localPackageCache [
	self availableSyncServices
		do: [ :subfolderName | 
			| fref |
			fref := FileLocator home / subfolderName / 'package-cache'.
			fref isDirectory ifTrue: [ ^ fref ] ].
	^ nil
]

{ #category : #utility }
ConfigurationOfKFImaging class >> localPackagePath [
	"self localPackagePath"

	^ LocalPackagePath 
		ifNotNil: [ LocalPackagePath ] 
		ifNil: [ self localPackageCache fullName ]
]

{ #category : #utility }
ConfigurationOfKFImaging class >> localPackagePath: aPathToLocalPackage [
	LocalPackagePath := aPathToLocalPackage
]

{ #category : #accessing }
ConfigurationOfKFImaging class >> project [

	^self new project
]

{ #category : #utility }
ConfigurationOfKFImaging class >> projectPackagePath [
	"self localPackagePath"
	^ self localPackagePath
]

{ #category : #utility }
ConfigurationOfKFImaging class >> remotePackagePath [
	"self remotePackagePath"
	^ 'http://smalltalkhub.com/mc/KenjiroFukuda/GdsFeel/main'
]

{ #category : #'development support' }
ConfigurationOfKFImaging class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #workspace }
ConfigurationOfKFImaging class >> workspace [

((ConfigurationOfKFImaging project version: '0.6-baseline')  record: (#'Net')) loadDirective.

ConfigurationOfKFImaging project version: '0.6-baseline'.

[ 
	| pkgs loader |
	loader := ((Smalltalk at: #ConfigurationOfKFImaging) project version: '0.6-baseline')
		ignoreImage: true;
		record.
	pkgs := OrderedCollection new.
	loader loadDirective packageDirectivesDo: [ :directive | pkgs add: directive spec file ].
	pkgs ] value.

(ConfigurationOfKFImaging project version: '0.6-baseline') fetch loadDirective.

"ConfigurationOfMetacello load."	"if squeak 3.10.2"
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline01: spec [ 
	<version: '0.1-baseline'>
	spec 
		for: #common
		do: 
			[ spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'StringExtension'
				with: [ spec repository: 'http://www.squeaksource.com/GdsFeel' ].
			spec 
				package: 'TrueType'
				with: [ spec repository: 'http://ss3.gemstone.com/ss/Pharo14' ].
			spec 
				package: 'KFImaging'
				with: [ spec requires: #('TrueType' 'StringExtension') ].

			spec 
				group: 'default'
				with: #('KFImaging' ) ]
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline02: spec [ 
	<version: '0.2-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'StringExtension'
				with: [ spec repository: 'http://www.squeaksource.com/GdsFeel/' ].

			spec 
				package: 'KFImaging'
				with: [ spec requires: #('StringExtension') ].

			spec
				repository: 'http://squeaksource.com/HTML/'; 
				package: 'HTML'.

			spec 
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('HTML' 'KFImaging') ].

			spec 
				group: 'Net'
				with: #('KFImagingNet');
				group: 'default'
				with: #('KFImaging' ) ].
	spec
		for: #'pharo'
		do: [
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'TrueType'
				with: [ spec repository: 'http://ss3.gemstone.com/ss/Pharo14/' ].
			spec 
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('TrueType' 'StringExtension') ].
		].
	
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline03: spec [ 
	<version: '0.3-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'StringExtension'
				with: [ spec repository: 'http://www.squeaksource.com/GdsFeel/' ].

			spec 
				package: 'KFImaging'
				with: [ spec requires: #('StringExtension') ].

			spec
				repository: self class projectPackagePath; 
				package: 'HTML-Base'.

			spec 
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('HTML-Base' 'KFImaging') ].

			spec 
				group: 'Net'
				with: #('KFImagingNet');
				group: 'default'
				with: #('KFImaging' ) ].
	spec
		for: #'pharo'
		do: [
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'TrueType'
				with: [ spec repository: 'http://ss3.gemstone.com/ss/Pharo14/' ].
			spec 
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('TrueType' 'StringExtension') ].
		].
	
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline04: spec [ 
	<version: '0.4-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'StringExtension'
				with: [ spec repository: 'http://www.squeaksource.com/GdsFeel/' ].

			spec 
				package: 'KFImaging'
				with: [ spec requires: #('StringExtension') ].

			spec
				repository: self class projectPackagePath; 
				package: 'HTML-Base'.

			spec 
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('HTML-Base' 'KFImaging') ].

			spec 
				group: 'Net'
				with: #('KFImagingNet');
				group: 'default'
				with: #('KFImaging' ) ].
	spec
		for: #'pharo'
		do: [
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('StringExtension') ].
		].
	
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline05: spec [ 
	<version: '0.5-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'StringExtension'
				with: [ spec repository: 'http://www.squeaksource.com/GdsFeel/' ].

			spec 
				package: 'KFImaging'
				with: [ spec requires: #('StringExtension') ].

			spec 
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('HTML-Base' 'KFImaging') ].

			spec 
				group: 'Net'
				with: #('KFImagingNet');
				group: 'default'
				with: #('KFImaging' ) ].
	spec
		for: #'pharo'
		do: [
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec 
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('StringExtension') ].
		].
	
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline06: spec [
	<version: '0.6-baseline'>
	spec
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec package: 'GeometryUtils' with: [ spec repository: self class projectPackagePath ].
			spec package: 'HTML' with: [ spec repository: 'http://www.squeaksource.com/HTML/' ].
			spec project: 'Soup' with: [ 
				spec repository: 'http://www.squeaksource.com/Soup/'.
				 spec className: 'ConfigurationOfSoup' ].
			spec package: 'StringExtension' with: [ spec repository: 'http://www.squeaksource.com/GdsFeel/' ].
			spec package: 'KFImaging' with: [ 
				spec requires: #('GeometryUtils' 'StringExtension') ].
			spec
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec repository: 'http://www.squeaksource.com/HTML/'.
					spec requires: #('HTML' 'Soup' 'KFImaging') ].
			spec
				group: 'Net' with: #('KFImagingNet');
				group: 'default' with: #('KFImaging') ].
	spec
		for: #'pharo1.x'
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec project: 'ZincHTTPComponents' with: [
				spec repository: 'http://www.squeaksource.com/ZincHTTPComponents'.
				spec className: 'ConfigurationOfZincHTTPComponents' .
				spec loads: #('Core' 'Zodiac')].
			spec project: 'FileMan' with: [
				spec repository: self class projectPackagePath.
				spec className: 'ConfigurationOfFileMan' ].
			spec
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('GeometryUtils' 'StringExtension'  'ZincHTTPComponents' 'FileMan') ] .
			spec
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec repository: 'http://www.squeaksource.com/HTML/'.
					spec requires: #('HTML' 'Soup' 'KFImaging') ].
				].
	spec
		for: #'pharo2.x'
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec project: 'FileMan' with: [
				spec repository: self class projectPackagePath.
				spec className: 'ConfigurationOfFileMan' ].
			spec
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('GeometryUtils' 'StringExtension' 'FileMan') ] .
			spec
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec repository: 'http://www.squeaksource.com/HTML/'.
					spec requires: #('HTML' 'Soup' 'KFImaging') ].
				]			
]

{ #category : #versions }
ConfigurationOfKFImaging >> baseline07: spec [
	<version: '0.7-baseline'>
	spec
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec package: 'GeometryUtils' with: [ spec repository: self class projectPackagePath ].
			spec
				project: 'Soup'
				with: [ 
					spec repository: 'http://www.squeaksource.com/Soup/'.
					spec className: 'ConfigurationOfSoup' ].
			spec package: 'StringExtension' with: [ spec repository: 'http://www.squeaksource.com/GdsFeel/' ].
			spec package: 'KFImaging' with: [ spec requires: #('GeometryUtils' 'StringExtension') ].
			spec
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec repository: 'http://www.squeaksource.com/HTML/'.
					spec requires: #('Soup' 'KFImaging') ].
			spec
				group: 'Net' with: #('KFImagingNet');
				group: 'default' with: #('KFImaging') ].
	spec
		for: #'pharo1.x'
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec
				project: 'ZincHTTPComponents'
				with: [ 
					spec repository: 'http://www.squeaksource.com/ZincHTTPComponents'.
					spec className: 'ConfigurationOfZincHTTPComponents'.
					spec loads: #('Core' 'Zodiac') ].
			spec
				project: 'FileMan'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfFileMan' ].
			spec
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('GeometryUtils' 'StringExtension' 'ZincHTTPComponents' 'FileMan') ].
			spec
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec repository: 'http://www.squeaksource.com/HTML/'.
					spec requires: #('HTML' 'Soup' 'KFImaging') ] ].
	spec
		for: #(#'pharo2.x' #'pharo3.x')
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec
				project: 'FileMan'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfFileMan' ].
			spec
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('GeometryUtils' 'StringExtension' 'FileMan') ].
			spec
				package: 'KFImagingNet'
				with: [ 
					spec repository: self class projectPackagePath.
					spec repository: 'http://www.squeaksource.com/HTML/'.
					spec requires: #('HTML' 'Soup' 'KFImaging') ] ].
	spec
		for:  #(#'pharo4.x' #'pharo5.x' #'pharo6.x')
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.
			spec
				project: 'FileMan'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfFileMan' ].
			spec
				package: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec requires: #('GeometryUtils' 'StringExtension' 'FileMan' 'Soup') ] ]
]

{ #category : #accessing }
ConfigurationOfKFImaging >> project [
	| projectAttributes |
	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		projectAttributes := OrderedCollection new.	
		projectAttributes 
			add: ((Smalltalk at: #FileDirectory ifAbsent: []) isNil
					ifTrue: [#'FileDirectoryNoPresent']
					ifFalse: [#'FileDirectoryPresent']).
		project projectAttributes: projectAttributes asArray.		
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

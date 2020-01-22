Class {
	#name : #ConfigurationOfGdsFeel,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfGdsFeel
}

{ #category : #'development support' }
ConfigurationOfGdsFeel class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #utility }
ConfigurationOfGdsFeel class >> attachLocalRepository [
	"self attachLocalRepository"
	<script>
	| repo |
	repo := self lookupLocalRepository.
	self attachRepository: repo.
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> attachRemoteRepository [
	"self attachRemoteRepository"
	<script>
	| repo |
	repo := self lookupRemoteRepository.
	self attachRepository: repo.
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> attachRepository: aRepository [
	"self attachLocalRepository"
	<script>
	| myWorkings |
	aRepository ifNil: [ ^ self inform: 'repository not found' ].
	myWorkings := self myWorkingCopies.
	myWorkings do: [ :wc | | reply |
		reply := wc repositoryGroup repositories 
			detect: [ :repo | repo description = aRepository description ] 
			ifNone: []. 
		reply 
			ifNil: [ 
				 wc repositoryGroup addRepository: aRepository].
		 ]
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> availableSyncServices [
	^ #('Nextcloud' 'Dropbox')
]

{ #category : #private }
ConfigurationOfGdsFeel class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #'development support' }
ConfigurationOfGdsFeel class >> checkDependent [
	"TimeProfiler spyOn: [self checkDependent.]"
	| pkgs loader |
	loader := (self project version: #bleedingEdge) ignoreImage: true; record.
	pkgs := OrderedCollection new.
	loader loadDirective packageDirectivesDo: [:directive | pkgs add: directive spec file ]. 
	pkgs explore.

]

{ #category : #private }
ConfigurationOfGdsFeel class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfGdsFeel class >> ensureMetacelloBaseConfiguration [

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
ConfigurationOfGdsFeel class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> isMyWorkingCopy: aMCWorkingCopy [
	(aMCWorkingCopy package name asString sameAs: 'ConfigurationOfGdsFeel')
		ifTrue: [ ^ true ].
	^ #('KF' 'Gds') anySatisfy: [:prefix | 
		aMCWorkingCopy package name asString beginsWith: prefix].
]

{ #category : #loading }
ConfigurationOfGdsFeel class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfGdsFeel class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfGdsFeel class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> localPackageCache [
	self availableSyncServices
		do: [ :subfolderName | 
			| fref |
			fref := FileLocator home / subfolderName / 'package-cache'.
			fref isDirectory ifTrue: [ ^ fref ] ].
	^ nil
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> localPackagePath [
	"self localPackagePath"
	^ self localPackageCache fullName.
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> lookupLocalRepository [
	| pc |
	pc := self localPackageCache.
	^ MCRepositoryGroup default repositories 
		detect: [ :repo | repo description sameAs: pc fullName ]  
		ifNone: [].

]

{ #category : #utility }
ConfigurationOfGdsFeel class >> lookupRemoteRepository [
	^ MCRepositoryGroup default repositories 
		detect: [ :repo | repo description sameAs: self remotePackagePath ]  
		ifNone: [].

]

{ #category : #utility }
ConfigurationOfGdsFeel class >> myWorkingCopies [
	"self myWorkingCopies."
	^ MCWorkingCopy allManagers  select: [ :wc | self isMyWorkingCopy: wc]  
]

{ #category : #accessing }
ConfigurationOfGdsFeel class >> project [

	^self new project
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> projectPackagePath [
	"self localPackagePath"
	^ self localPackagePath
]

{ #category : #utility }
ConfigurationOfGdsFeel class >> remotePackagePath [
	"self remotePackagePath"
	^ 'http://smalltalkhub.com/mc/KenjiroFukuda/GdsFeel/main/'
]

{ #category : #'development support' }
ConfigurationOfGdsFeel class >> validate [
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
ConfigurationOfGdsFeel class >> workspace [

(ConfigurationOfGdsFeel project version: '1.0') record loadDirective .

(ConfigurationOfGdsFeel project version: '1.0-baseline') .


[| pkgs loader |
loader := ((Smalltalk at: #ConfigurationOfGdsFeel) project version: '1.0') ignoreImage: true; record.
pkgs := OrderedCollection new.
loader loadDirective packageDirectivesDo: [:directive |pkgs add: directive spec file ]. pkgs.] value.

(ConfigurationOfGdsFeel project version: '1.0') fetch loadDirective.

"ConfigurationOfMetacello load." "if squeak 3.10.2"
]

{ #category : #versions }
ConfigurationOfGdsFeel >> baseline10: spec [ 
	<version: '1.0-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.

			spec
				project: 'NeoJSON'
				with: [
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
					spec className: 'ConfigurationOfNeoJSON'].

			spec
				project: 'NeoCSV'
				with: [
					spec className: 'ConfigurationOfNeoJSON'.
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'. ].

			spec 
				project: 'INIFile'
				with: [
					spec className: 'ConfigurationOfINIFile'. 
					spec repository: 'http://smalltalkhub.com/mc/TorstenBergmann/INIFile/main'. ].
			spec 
				project: 'Soup'
				with: [ 
					spec repository: 'http://smalltalkhub.com/mc/PharoExtras/Soup/main'.
					spec className: 'ConfigurationOfSoup' ].
			spec 
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #(
							'NeoJSON'
							'NeoCSV'
							'INIFile'
							'Soup'
						)  ].
				
			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: [  ].

			spec 
				package: 'GdsFeel-Model'
				with: 
					[ spec requires: #(
							'GdsFeel-Foundation'
						) ].
			spec 
				project: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfKFImaging' ].
			"spec 
				package: 'CSV'
				with: [ spec repository: 'http://www.squeaksource.com/CSV' ]."
			spec 
				package: 'GdsFeel-UI'
				with: 
					[ spec requires: #(
							'KFImaging'
							'NeoCSV'
							"'CSV'"
							'GdsFeel-Model'
						) ].
			spec 
				package: 'GdsFeel-Developer'
				with: 
					[ spec requires: #('GdsFeel-UI')].
			spec 
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].

			spec 
				project: 'CommandShell'
				with: 
					[ spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
					spec className: 'ConfigurationOfCommandShell' ].
				
			spec 
				package: 'KFConsole'	
				with: 
					[ ].
				
			spec 
				package: 'GdsFeel-CLI'	
				with: 
					[ spec requires: #('GdsFeel-Developer' 'CommandShell') ].

			spec 
				package: 'GdsFeel-CLI-Commands'	
				with: 
					[ spec requires: #('GdsFeel-CLI') ].

			spec 
				package: 'GdsFeel-CLI-Console'	
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].

			spec 
				project: 'GlamourCore' 
				with: [
					spec
						className: 'ConfigurationOfGlamour';
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main/' ].

			spec 
				package: 'GdsFeel-CLI-Glamour'	
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			
			spec 
				package: 'GdsFeel-SpecUI'	
				with: [ spec requires: #('GdsFeel-UI') ].
								
			"spec 
				package: 'GdsFeel-Seaside' 
				with: [  ]."
				
			spec
				group: 'Foundation'
					with: #('GdsFeel-Foundation' );
				group: 'Model'
					with: #('GdsFeel-Model' );
				group: 'UI'
					with: #('GdsFeel-UI' 'GdsFeel-SpecUI' );
				group: 'Developer'
					with: #('GdsFeel-Developer' );
				group: 'CLI'
					with: #('GdsFeel-CLI-Console').
					
			spec 
				group: 'default'
				with: #('Model' 'UI' 'CLI' ) ].
			
	spec 
		for: #'pharo3.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
	spec 
		for: #'pharo4.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ]		
]

{ #category : #versions }
ConfigurationOfGdsFeel >> baseline10p4: spec [ 
	<version: '1.0-p4-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.

			spec
				project: 'NeoJSON'
				with: [
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfNeoJSON'].

			spec
				project: 'NeoCSV'
				with: [
					spec className: 'ConfigurationOfNeoJSON'.
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'. ].

			spec 
				project: 'INIFile'
				with: [
					spec className: 'ConfigurationOfINIFile'. 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'. ].
			spec 
				project: 'Soup'
				with: [ 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfSoup' ].
			spec 
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #(
							'NeoJSON'
							'NeoCSV'
							'INIFile'
							'Soup'
						)  ].
				
			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: [  ].

			spec 
				package: 'GdsFeel-Model'
				with: 
					[ spec requires: #(
							'GdsFeel-Foundation'
						) ].
			spec 
				project: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfKFImaging' ].
			"spec 
				package: 'CSV'
				with: [ spec repository: 'http://www.squeaksource.com/CSV' ]."
			spec 
				package: 'GdsFeel-UI'
				with: 
					[ spec requires: #(
							'KFImaging'
							'NeoCSV'
							"'CSV'"
							'GdsFeel-Model'
						) ].
			spec 
				package: 'GdsFeel-Developer'
				with: 
					[ spec requires: #('GdsFeel-UI')].
			spec 
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].

			spec 
				project: 'CommandShell'
				with: 
					[ spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
					spec className: 'ConfigurationOfCommandShell' ].
				
			spec 
				package: 'KFConsole'	
				with: 
					[ ].
				
			spec 
				package: 'GdsFeel-CLI'	
				with: 
					[ spec requires: #('GdsFeel-Developer' 'CommandShell') ].

			spec 
				package: 'GdsFeel-CLI-Commands'	
				with: 
					[ spec requires: #('GdsFeel-CLI') ].

			spec 
				package: 'GdsFeel-CLI-Console'	
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].

			spec 
				project: 'GlamourCore' 
				with: [
					spec
						className: 'ConfigurationOfGlamour';
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main/' ].

			spec 
				package: 'GdsFeel-CLI-Glamour'	
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			
			spec 
				package: 'GdsFeel-SpecUI'	
				with: [ spec requires: #('GdsFeel-UI') ].
								
			"spec 
				package: 'GdsFeel-Seaside' 
				with: [  ]."
				
			spec
				group: 'Foundation'
					with: #('GdsFeel-Foundation' );
				group: 'Model'
					with: #('GdsFeel-Model' );
				group: 'UI'
					with: #('GdsFeel-UI' 'GdsFeel-SpecUI' );
				group: 'Developer'
					with: #('GdsFeel-Developer' );
				group: 'CLI'
					with: #('GdsFeel-CLI-Console').
					
			spec 
				group: 'default'
				with: #('Model' 'UI' 'CLI' ) ].
			
	spec 
		for: #'pharo3.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
	spec 
		for: #'pharo4.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ]		
]

{ #category : #versions }
ConfigurationOfGdsFeel >> baseline11p4: spec [ 
	<version: '1.1-p4-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.

			spec
				project: 'NeoJSON'
				with: [
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfNeoJSON'].

			spec
				project: 'NeoCSV'
				with: [
					spec className: 'ConfigurationOfNeoJSON'.
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'. ].

			spec 
				project: 'INIFile'
				with: [
					spec className: 'ConfigurationOfINIFile'. 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'. ].
			spec 
				project: 'Soup'
				with: [ 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfSoup' ].
			spec 
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #(
							'NeoJSON'
							'NeoCSV'
							'INIFile'
							'Soup'
						)  ].
				
			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: [  ].

			spec 
				package: 'GdsFeel-Model'
				with: 
					[ spec requires: #(
							'GdsFeel-Foundation'
						) ].
			spec 
				project: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfKFImaging' ].
			"spec 
				package: 'CSV'
				with: [ spec repository: 'http://www.squeaksource.com/CSV' ]."
			spec 
				package: 'GdsFeel-UI'
				with: 
					[ spec requires: #(
							'KFImaging'
							'NeoCSV'
							"'CSV'"
							'GdsFeel-Model'
						) ].
			spec 
				package: 'GdsFeel-Developer'
				with: 
					[ spec requires: #('GdsFeel-UI')].
			spec 
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].

			spec 
				project: 'CommandShell'
				with: 
					[ spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
					spec className: 'ConfigurationOfCommandShell' ].
				
			spec 
				package: 'KFConsole'	
				with: 
					[ ].
				
			spec 
				package: 'GdsFeel-CLI'	
				with: 
					[ spec requires: #('GdsFeel-Developer' 'CommandShell') ].

			spec 
				package: 'GdsFeel-CLI-Commands'	
				with: 
					[ spec requires: #('GdsFeel-CLI') ].

			spec 
				package: 'GdsFeel-CLI-Console'	
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].

			spec 
				project: 'GlamourCore' 
				with: [
					spec
						className: 'ConfigurationOfGlamour';
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main/' ].

			spec 
				package: 'GdsFeel-CLI-Glamour'	
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			
			spec 
				package: 'GdsFeel-UI-Spec'	
				with: [ spec requires: #('GdsFeel-UI') ].
								
			"spec 
				package: 'GdsFeel-Seaside' 
				with: [  ]."
				
			spec
				group: 'Foundation'
					with: #('GdsFeel-Foundation' );
				group: 'Model'
					with: #('GdsFeel-Model' );
				group: 'UI'
					with: #('GdsFeel-UI' 'GdsFeel-UI-Spec' );
				group: 'Developer'
					with: #('GdsFeel-Developer' );
				group: 'CLI'
					with: #('GdsFeel-CLI-Console').
					
			spec 
				group: 'default'
				with: #('Model' 'UI' 'CLI' ) ].
			
	spec 
		for: #'pharo3.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
	spec 
		for: #'pharo4.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ]		
]

{ #category : #versions }
ConfigurationOfGdsFeel >> baseline11p5: spec [ 
	<version: '1.1-p5-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.

			spec
				project: 'NeoJSON'
				with: [
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfNeoJSON'].

			spec
				project: 'NeoCSV'
				with: [
					spec className: 'ConfigurationOfNeoJSON'.
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'. ].

			spec 
				project: 'INIFile'
				with: [
					spec className: 'ConfigurationOfINIFile'. 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'. ].
			spec 
				project: 'Soup'
				with: [ 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfSoup' ].
			spec 
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #(
							'NeoJSON'
							'NeoCSV'
							'INIFile'
							'Soup'
						)  ].
				
			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: [  ].

			spec 
				package: 'GdsFeel-Model'
				with: 
					[ spec requires: #(
							'GdsFeel-Foundation'
						) ].
			spec 
				project: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfKFImaging' ].
			"spec 
				package: 'CSV'
				with: [ spec repository: 'http://www.squeaksource.com/CSV' ]."
			spec 
				package: 'GdsFeel-UI'
				with: 
					[ spec requires: #(
							'KFImaging'
							'NeoCSV'
							"'CSV'"
							'GdsFeel-Model'
						) ].
			spec 
				package: 'GdsFeel-Developer'
				with: 
					[ spec requires: #('GdsFeel-UI')].
			spec 
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].

			spec 
				project: 'CommandShell'
				with: 
					[ spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
					spec className: 'ConfigurationOfCommandShell' ].
				
			spec 
				package: 'KFConsole'	
				with: 
					[ ].
				
			spec 
				package: 'GdsFeel-CLI'	
				with: 
					[ spec requires: #('GdsFeel-Developer' 'CommandShell') ].

			spec 
				package: 'GdsFeel-CLI-Commands'	
				with: 
					[ spec requires: #('GdsFeel-CLI') ].

			spec 
				package: 'GdsFeel-CLI-Console'	
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].

			spec 
				project: 'GlamourCore' 
				with: [
					spec
						className: 'ConfigurationOfGlamour';
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main/' ].

			spec 
				package: 'GdsFeel-CLI-Glamour'	
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			
			spec 
				package: 'GdsFeel-UI-Spec'	
				with: [ spec requires: #('GdsFeel-UI') ].
								
			"spec 
				package: 'GdsFeel-Seaside' 
				with: [  ]."
				
			spec
				group: 'Foundation'
					with: #('GdsFeel-Foundation' );
				group: 'Model'
					with: #('GdsFeel-Model' );
				group: 'UI'
					with: #('GdsFeel-UI' 'GdsFeel-UI-Spec' );
				group: 'Developer'
					with: #('GdsFeel-Developer' );
				group: 'CLI'
					with: #('GdsFeel-CLI-Console').
					
			spec 
				group: 'default'
				with: #('Model' 'UI' 'CLI' ) ].
			
	spec 
		for: #'pharo3.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
	spec 
		for: #'pharo4.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].		
	spec 
		for: #'pharo5.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
				
]

{ #category : #versions }
ConfigurationOfGdsFeel >> baseline11p6: spec [ 
	<version: '1.1-p6-baseline'>
	spec 
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec repository: self class projectPackagePath.

			spec
				project: 'NeoJSON'
				with: [
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo60/main'.
					spec className: 'ConfigurationOfNeoJSON'].

			spec
				project: 'NeoCSV'
				with: [
					spec className: 'ConfigurationOfNeoJSON'.
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo60/main'. ].

			spec 
				project: 'INIFile'
				with: [
					spec className: 'ConfigurationOfINIFile'. 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo60/main'. ].
			spec 
				project: 'Soup'
				with: [ 
					spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main'.
					spec className: 'ConfigurationOfSoup' ].
			spec 
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #(
							'NeoJSON'
							'NeoCSV'
							'INIFile'
							'Soup'
						)  ].
				
			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: [  ].

			spec 
				package: 'GdsFeel-Model'
				with: 
					[ spec requires: #(
							'GdsFeel-Foundation'
						) ].
			spec 
				project: 'KFImaging'
				with: [ 
					spec repository: self class projectPackagePath.
					spec className: 'ConfigurationOfKFImaging' ].
			"spec 
				package: 'CSV'
				with: [ spec repository: 'http://www.squeaksource.com/CSV' ]."
			spec 
				package: 'GdsFeel-UI'
				with: 
					[ spec requires: #(
							'KFImaging'
							'NeoCSV'
							"'CSV'"
							'GdsFeel-Model'
						) ].
			spec 
				package: 'GdsFeel-Developer'
				with: 
					[ spec requires: #('GdsFeel-UI')].
			spec 
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].

			spec 
				project: 'CommandShell'
				with: 
					[ spec repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main'.
					spec className: 'ConfigurationOfCommandShell' ].
				
			spec 
				package: 'KFConsole'	
				with: 
					[ ].
				
			spec 
				package: 'GdsFeel-CLI'	
				with: 
					[ spec requires: #('GdsFeel-Developer' 'CommandShell') ].

			spec 
				package: 'GdsFeel-CLI-Commands'	
				with: 
					[ spec requires: #('GdsFeel-CLI') ].

			spec 
				package: 'GdsFeel-CLI-Console'	
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].

			spec 
				project: 'GlamourCore' 
				with: [
					spec
						className: 'ConfigurationOfGlamour';
						repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main/' ].

			spec 
				package: 'GdsFeel-CLI-Glamour'	
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			
			spec 
				package: 'GdsFeel-UI-Spec'	
				with: [ spec requires: #('GdsFeel-UI') ].
								
			"spec 
				package: 'GdsFeel-Seaside' 
				with: [  ]."
				
			spec
				group: 'Foundation'
					with: #('GdsFeel-Foundation' );
				group: 'Model'
					with: #('GdsFeel-Model' );
				group: 'UI'
					with: #('GdsFeel-UI' 'GdsFeel-UI-Spec' );
				group: 'Developer'
					with: #('GdsFeel-Developer' );
				group: 'CLI'
					with: #('GdsFeel-CLI-Console').
					
			spec 
				group: 'default'
				with: #('Model' 'UI' 'CLI' ) ].
			
	spec 
		for: #'pharo3.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
	spec 
		for: #'pharo4.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].		
	spec 
		for: #'pharo5.x'
		do: [
			spec
				group: 'UI'
				with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ) ].
				
]

{ #category : #accessing }
ConfigurationOfGdsFeel >> project [
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

{ #category : #'symbolic version' }
ConfigurationOfGdsFeel >> stable: spec [ 
	<symbolicVersion: #stable>
	spec for: #'pharo3.x'    version: '1.0'.
	spec for: #'pharo4.x'    version: '1.1'.

]

{ #category : #versions }
ConfigurationOfGdsFeel >> version10: spec [ 
	<version: '1.0' imports: #('1.0-baseline')>
	spec 
		for: #common
		do: [ 
			spec blessing: #development.
			spec 
				project: 'INIFile'
				with: [ spec version: #stable ].
			spec 
				project: 'NeoJSON'
				with: [ spec version: #stable ].
			spec 
				project: 'NeoCSV'
				with: [ spec version: #stable ].
			spec 
				project: 'XMLParser'
				with: [ spec version: #stable ].
			spec 
				project: 'XPath'
				with: [ spec version: #stable ].
			spec 
				project: 'Soup'
				with: [ spec version: #stable ].

			spec 
				project: 'GlamourCore'
				with: [ spec version: #stable ].

			spec 
				package: 'GdsFeel-Foundation'
				with: 'GdsFeel-Foundation-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-Model'
				with: 'GdsFeel-Model-KenjiroFukuda'.
				
			spec project: 'KFImaging' with: [ spec version: #bleedingEdge ].

			spec 
				package: 'KFConsole'
				with: 'KFConsole-KenjiroFukuda'.

			spec 
				project: 'NeoCSV'
				with: [ spec version: #stable ].
			"spec 
				package: 'CSV'
				with: 'CSV-JohnnyT.10'."			
			spec 
				package: 'GdsFeel-UI'
				with: 'GdsFeel-UI-KenjiroFukuda'.
			spec 
				package: 'GdsFeel-SpecUI'
				with: 'GdsFeel-SpecUI-KenjiroFukuda'.
			spec 
				package: 'GdsFeel-Developer'
				with: 'GdsFeel-Developer-KenjiroFukuda'.
			spec 
				project: 'CommandShell'
				with: [ spec version: #development ].
			spec 
				package: 'GdsFeel-CLI'
				with: 'GdsFeel-CLI-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-CLI-Commands'
				with: 'GdsFeel-CLI-Commands-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-CLI-Console'
				with: 'GdsFeel-CLI-Console-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: 'GdsFeel-CLI-Glamour-KenjiroFukuda'.
				 ].
	spec
		for: #'pharo3.x'
		do: [ 
			spec 
				package: 'GdsFeel-UI-Athens'
				with: 'GdsFeel-UI-Athens-KenjiroFukuda'. ].
	spec
		for: #'pharo4.x'
		do: [ 
			spec 
				package: 'GdsFeel-UI-Athens'
				with: 'GdsFeel-UI-Athens-KenjiroFukuda'. ]

]

{ #category : #versions }
ConfigurationOfGdsFeel >> version11: spec [ 
	<version: '1.1' imports: #('1.1-p5-baseline')>	
	spec 
		for: #common
		do: [ 
			spec blessing: #development.
			spec 
				project: 'INIFile'
				with: [ spec version: #stable ].
			spec 
				project: 'NeoJSON'
				with: [ spec version: #stable ].
			spec 
				project: 'NeoCSV'
				with: [ spec version: #stable ].
			spec 
				project: 'XMLParser'
				with: [ spec version: #stable ].
			spec 
				project: 'XPath'
				with: [ spec version: #stable ].
			spec 
				project: 'Soup'
				with: [ spec version: #stable ].

			spec 
				project: 'GlamourCore'
				with: [ spec version: #stable ].

			spec 
				package: 'GdsFeel-Foundation'
				with: 'GdsFeel-Foundation-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-Model'
				with: 'GdsFeel-Model-KenjiroFukuda'.
				
			spec project: 'KFImaging' with: [ spec version: #bleedingEdge ].

			spec 
				package: 'KFConsole'
				with: 'KFConsole-KenjiroFukuda'.

			spec 
				project: 'NeoCSV'
				with: [ spec version: #stable ].
			"spec 
				package: 'CSV'
				with: 'CSV-JohnnyT.10'."			
			spec 
				package: 'GdsFeel-UI'
				with: 'GdsFeel-UI-KenjiroFukuda'.
			spec 
				package: 'GdsFeel-UI-Spec'
				with: 'GdsFeel-UI-Spec-KenjiroFukuda'.
			spec 
				package: 'GdsFeel-Developer'
				with: 'GdsFeel-Developer-KenjiroFukuda'.
			spec 
				project: 'CommandShell'
				with: [ spec version: #development ].
			spec 
				package: 'GdsFeel-CLI'
				with: 'GdsFeel-CLI-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-CLI-Commands'
				with: 'GdsFeel-CLI-Commands-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-CLI-Console'
				with: 'GdsFeel-CLI-Console-KenjiroFukuda'.

			spec 
				package: 'GdsFeel-CLI-Glamour'
				with: 'GdsFeel-CLI-Glamour-KenjiroFukuda'.
				 ].
	spec
		for: #'pharo3.x'
		do: [ 
			spec 
				package: 'GdsFeel-UI-Athens'
				with: 'GdsFeel-UI-Athens-KenjiroFukuda'. ].
	spec
		for: #'pharo4.x'
		do: [ 
			spec 
				package: 'GdsFeel-UI-Athens'
				with: 'GdsFeel-UI-Athens-KenjiroFukuda'. ].
	spec
		for: #'pharo5.x'
		do: [ 
			spec 
				package: 'GdsFeel-UI-Athens'
				with: 'GdsFeel-UI-Athens-KenjiroFukuda'. ]

]

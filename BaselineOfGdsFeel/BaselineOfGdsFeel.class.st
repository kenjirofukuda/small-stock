Class {
	#name : #BaselineOfGdsFeel,
	#superclass : #BaselineOf,
	#category : #BaselineOfGdsFeel
}

{ #category : #baselines }
BaselineOfGdsFeel >> baseline: spec [

	<baseline>
	self baselineFileMan: spec.
	self baselineStreamFormatAtomic: spec.
	self baselineGuest: spec.
	self baselineMagritte: spec.
	self baselineKFImaging: spec.
	spec for: #common do: [ 
		
		spec for: #menubar do: [ 
			spec postLoadDoIt: #fixMenubarBuilding ].
		
		spec
			package: 'GdsFeel-Foundation'
			with: [ spec requires: #( 'NeoJSON' 'NeoCSV' 'INIFile' ) ].
		spec package: 'KFDxf-Model'.
		spec package: 'KFDxf-Tests'.
		spec package: 'GdsFeel-Foundation-Property'.
		spec package: 'GdsFeel-Foundation-Notification'.
		spec package: 'GdsFeel-Foundation-Core'.
		spec package: 'GdsFeel-Foundation-Tests'.

		spec package: 'GdsFeel-CLI-Glamour'.
		spec package: 'GdsFeel-Model-Basic' with: [ 
			spec requires: #( 'GdsFeel-Foundation' 'GdsFeel-Foundation-Core'
				   'GdsFeel-Foundation-Property' 'GdsFeel-Foundation-Notification'
				   'GdsFeel-Foundation-Tests' 'XMLParser' ) ].
		spec package: 'GdsFeel-Model-Container'.
		spec package: 'GdsFeel-Model-EditSpace'.
		spec package: 'GdsFeel-Model-Element'.
		spec
			package: 'GdsFeel-Model-ElementAddition'
			with: [ spec requires: #( 'KFDxf-Model' 'KFDxf-Tests' ) ].
		spec package: 'GdsFeel-Model-Sandbox'.
		spec package: 'GdsFeel-Model-Private'.
		spec package: 'GdsFeel-Model-Viewing'.
		spec package: 'GdsFeel-Model-Tests'.
		spec package: 'GdsFeel-UI' with: [ 
			spec requires: #( 'KFImaging' 'NeoCSV' 'Model' )
			"'CSV'" ].
		spec
			package: 'GdsFeel-Developer'
			with: [ spec requires: #( 'GdsFeel-UI' ) ].
		spec
			package: 'GdsFeel-UI-Athens'
			with: [ spec requires: #( 'GdsFeel-UI' ) ].
		spec baseline: 'CommandShell' with: [ 
			spec
				repository: 'github://dtlewis290/CommandShell-Tonel/src';
				loads: #( 'CommandShell' ) ].
		spec package: 'KFConsole'.
		spec
			package: 'GdsFeel-CLI'
			with: [ spec requires: #( 'GdsFeel-Developer' ) "'OSProcess'" ].
		spec
			package: 'GdsFeel-CLI-Commands'
			with: [ spec requires: #( 'GdsFeel-CLI' ) ].
		spec
			package: 'GdsFeel-CLI-Console'
			with: [ spec requires: #( 'GdsFeel-CLI-Commands'
			   'KFConsole' ) ].
		spec
			baseline: 'GlamourCore'
			with: [ spec repository: 'github://moosetechnology/glamour/src' ].
		spec
			package: 'GdsFeel-CLI-Glamour'
			with: [ spec requires: #( 'GdsFeel-CLI' 'GlamourCore' ) ].
		spec
			package: 'GdsFeel-UI-ElementAddition'
			with: [ spec requires: #( 'GdsFeel-Model-ElementAddition' ) ].
		spec package: 'GdsFeel-UI-SpecCommon'.
		spec package: 'GdsFeel-UI-Spec' with: [ 
			spec requires: #( 'GdsFeel-UI' 'GdsFeel-UI-ElementAddition'
				   'GdsFeel-UI-SpecCommon' ) ].
		spec package: 'GdsFeel-Magritte' with: [ 
			spec requires:
				#( 'GdsFeel-UI' 'Magritte' 'GdsFeel-Model-ElementAddition' ) ].
		spec
			group: 'Foundation'
			with: #( 'GdsFeel-Foundation' 'GdsFeel-Foundation-Core'
				   'GdsFeel-Foundation-Notification'
				   'GdsFeel-Foundation-Property' );
			group: 'Model'
			with: #( 'GdsFeel-Model-Basic' 'GdsFeel-Model-Container'
				   'GdsFeel-Model-EditSpace' 'GdsFeel-Model-Element'
				   'GdsFeel-Model-ElementAddition' 'GdsFeel-Model-Private'
				   'GdsFeel-Model-Sandbox' 'GdsFeel-Model-Tests'
				   'GdsFeel-Model-Viewing' );
			group: 'UI'
			with: #( 'GdsFeel-UI' 'GdsFeel-Magritte'
				   'GdsFeel-UI-ElementAddition' );
			group: 'Developer' with: #( 'GdsFeel-Developer' );
			group: 'CLI'
			with: #( 'GdsFeel-CLI-Console' ).
		spec group: 'UI' with: #( 'GdsFeel-UI' 'GdsFeel-UI-Athens' ).
		spec group: 'default' with: #( 'Model' 'UI' ) ].
	self baselineFixZip: spec.

  spec for: #( #'pharo6.x' #'pharo7.x' #'pharo8.x' #'pharo9.x' ) do: [
		spec package: 'GdsFeel-Magritte-P6P7P8'.
		spec package: 'GdsFeel-Magritte' with: [
			spec requires:
				#( 'GdsFeel-UI' 'Magritte' 'GdsFeel-Model-ElementAddition' 'GdsFeel-Magritte-P6P7P8') ].
	].

  spec for: #(  #'pharo6.x' #'pharo7.x' #'pharo8.x' #'pharo9.x' ) do: [ 
		spec package: 'GdsFeel-UI-Spec' with: [ 
			spec requires: #( 'GdsFeel-UI' 'GdsFeel-UI-ElementAddition'
				   'GdsFeel-UI-SpecCommon' ) ].
		spec
			group: 'UI'
			with: #( 'GdsFeel-UI' 'GdsFeel-UI-Spec' 'GdsFeel-Magritte'
				   'GdsFeel-UI-ElementAddition' ) ].
           
	spec for: #(  #'pharo9.x' #'pharo10.x' #'pharo11.x' #'pharo12.x' ) do: [ 
		spec package: 'GdsFeel-UI-Spec2' with: [ 
			spec requires: #( 'GdsFeel-UI' 'GdsFeel-UI-ElementAddition'
				   'GdsFeel-UI-SpecCommon' ) ].
		spec
			group: 'UI'
			with: #( 'GdsFeel-UI' 'GdsFeel-UI-Spec2' 'GdsFeel-Magritte'
				   'GdsFeel-UI-ElementAddition' ) ].
]

{ #category : #baselines }
BaselineOfGdsFeel >> baselineFileMan: spec [
	"https://github.com/magritte-metamodel/magritte/releases"
	spec for: #common do: [
		spec baseline: 'FileMan' with: [
			spec
				repository: 'github://mumez/FileMan';
				loads: #(Core)
		].
	].

	spec for: #'pharo6.x', #'pharo7.x', #'pharo8.x' do: [
		spec baseline: 'FileMan' with: [
			spec
				repository: 'github://kenjirofukuda/FileMan:StillFileStream';
				loads: #(Core)
		].
	].

	spec for: #'pharo9.x', #'pharo10.x', #'pharo11.x', #'pharo12.x', #'pharo13.x', #'pharo14.x' do: [
		spec baseline: 'FileMan' with: [
			spec
				repository: 'github://kenjirofukuda/FileMan:NoFileStream';
				loads: #(Core)
		].
	].
]

{ #category : #baselines }
BaselineOfGdsFeel >> baselineFixZip: spec [

	| basicDepends basicGroup |
	basicDepends := #( 'GdsFeel-Foundation' 'GdsFeel-Foundation-Core'
	                   'GdsFeel-Foundation-Property'
	                   'GdsFeel-Foundation-Notification'
	                   'GdsFeel-Foundation-Tests'
	                   'XMLParser' ).
	basicGroup := #( 'GdsFeel-Foundation' 'GdsFeel-Foundation-Core'
	                 'GdsFeel-Foundation-Notification'
	                 'GdsFeel-Foundation-Property' ).
	
	spec package: 'GdsFeel-Foundation-ZipP6P7'.
	spec for: #( #'pharo6.x' #'pharo7.x' ) do: [ 
		spec
			package: 'GdsFeel-Model-Basic'
			with: [ 
			spec requires: basicDepends , #( 'GdsFeel-Foundation-ZipP6P7' ) ].

		spec
			group: 'Foundation'
			with: basicGroup , #( 'GdsFeel-Foundation-ZipP6P7' ) ].
		
	spec package: 'GdsFeel-Foundation-ZipP8P9'.
	spec for: #( #'pharo8.x' #'pharo9.x' ) do: [ 
		spec
			package: 'GdsFeel-Model-Basic'
			with: [ 
			spec requires: basicDepends , #( 'GdsFeel-Foundation-ZipP8P9' ) ].

		spec
			group: 'Foundation'
			with: basicGroup , #( 'GdsFeel-Foundation-ZipP8P9' ) ].		

]

{ #category : #baselines }
BaselineOfGdsFeel >> baselineGuest: spec [
	spec for: #common do: [
		spec
			baseline: 'NeoJSON'
			with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
		spec
			baseline: 'NeoCSV'
			with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].
		spec
			baseline: 'INIFile'
			with: [ spec repository: 'github://astares/Pharo-INIFile:main/src' ].
		spec
			baseline: 'XMLParser'
			with: [
			spec repository: 'github://pharo-contributions/XML-XMLParser/src' ] ].

]

{ #category : #baselines }
BaselineOfGdsFeel >> baselineKFImaging: spec [

	spec for: #common do: [
		spec
			baseline: 'KFImaging'
			with: [ spec repository: 'github://kenjirofukuda/imaging-pharo' ] ].
	spec for: #(#'pharo6.x' #'pharo7.x' #'pharo8.x' #'pharo9.x') do: [
		spec
			baseline: 'KFImaging'
			with: [ spec repository: 'github://kenjirofukuda/imaging-pharo:MorphicModel' ] ].

]

{ #category : #baselines }
BaselineOfGdsFeel >> baselineMagritte: spec [
	"https://github.com/magritte-metamodel/magritte/releases"
	spec for: #common do: [
		spec baseline: 'Magritte' with: [
			spec
				repository: 'github://magritte-metamodel/magritte';
				loads: #( Core 'Magritte-Morph' )
		].
	].
	spec for: #'pharo6.x' do: [
		spec baseline: 'Magritte' with: [
			spec
				repository: 'github://magritte-metamodel/magritte:v3.5.2';
				loads: #( Core  'Magritte-Morph' )
		].
	].
	spec for: #'pharo7.x' do: [
		spec baseline: 'Magritte' with: [
			spec
				repository: 'github://magritte-metamodel/magritte:v3.5.3';
				loads: #( Core  'Magritte-Morph' )
		].
	].
	spec for: #'pharo8.x' do: [
		spec baseline: 'Magritte' with: [
			spec
				repository: 'github://magritte-metamodel/magritte:v3.6';
				loads: #( Core  'Magritte-Morph' )
		].
	].
	spec for: #'pharo9.x' do: [
		spec baseline: 'Magritte' with: [
			spec
				repository: 'github://magritte-metamodel/magritte:v3.7';
				loads: #( Core  'Magritte-Morph' )
		].
	].
	spec for: #'pharo10.x' do: [
		spec baseline: 'Magritte' with: [
			spec
				repository: 'github://magritte-metamodel/magritte:v3.8';
				loads: #( Core  'Magritte-Morph' )
		].
	]
]

{ #category : #baselines }
BaselineOfGdsFeel >> baselineStreamFormatAtomic: spec [

	spec for: #common do: [ 
		spec
			package: 'GdsFeel-StreamFormat-Atomic'
			with: [ spec requires: #( 'FileMan' ) ].

		spec package: 'GdsFeel-StreamFormat-Atomic-Any'.
		spec package: 'GdsFeel-StreamFormat-Atomic-Pharo'.
		spec package: 'GdsFeel-StreamFormat-Atomic-UI-Pharo'.

		spec package: 'GdsFeel-StreamFormat-Atomic-Tests'. ]
]

{ #category : #accessing }
BaselineOfGdsFeel >> customProjectAttributes [
	"Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttributes "

	| attributes |
	attributes := OrderedCollection new.
	(Smalltalk globals includesKey: #MenubarMorph)
		ifTrue: [ attributes add: #menubar ].
	(Smalltalk globals includesKey: #FileStream)
		ifTrue: [ attributes add: #fileStream ].
	^ attributes asArray.
	

]

{ #category : #'post loading' }
BaselineOfGdsFeel >> fixMenubarBuilding [

	Transcript
		cr;
		show: 'fire Menubar rebuidding.'.
	UIManager default defer: [ 
		MenubarMorph reset.
		Transcript
			cr;
			show: 'done Menubar rebuidding.' ]
]

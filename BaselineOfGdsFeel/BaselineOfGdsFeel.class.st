Class {
	#name : #BaselineOfGdsFeel,
	#superclass : #BaselineOf,
	#category : #BaselineOfGdsFeel
}

{ #category : #baseline }
BaselineOfGdsFeel >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			spec
				project: 'NeoJSON'
				with: [ spec repository: 'github://svenvc/NeoJSON/repository'.
					spec baseline: 'NeoJSON' ].
			spec
				project: 'NeoCSV'
				with: [ spec repository: 'github://svenvc/NeoCSV/repository'.
					spec baseline: 'NeoCSV' ].
			spec
				project: 'INIFile'
				with: [ spec baseline: 'INIFile'.
					spec repository: 'github://astares/Pharo-INIFile/src' ].
			spec
				package: 'GdsFeel-Foundation'
				with: [ spec requires: #('NeoJSON' 'NeoCSV' 'INIFile')	"'Soup'" ].
			spec package: 'GdsFeel-Foundation-Property'.
			spec package: 'GdsFeel-Foundation-Notification'.
			spec package: 'GdsFeel-Foundation-Core'.
			spec package: 'GdsFeel-Foundation-Tests'.
			spec package: 'GdsFeel-CLI-Glamour'.
			spec package: 'GdsFeel-Model-Basic'.
			spec package: 'GdsFeel-Model-Container'.
			spec package: 'GdsFeel-Model-EditSpace'.
			spec package: 'GdsFeel-Model-Element'.
			spec package: 'GdsFeel-Model-Sandbox'.
			spec package: 'GdsFeel-Model-Private'.
			spec package: 'GdsFeel-Model-Viewing'.
			spec package: 'GdsFeel-Model-Tests'.
			spec
				package: 'GdsFeel-Basic'
				with: [ spec requires: #('GdsFeel-Foundation') ].
			spec
				project: 'KFImaging'
				with: [ spec repository: 'github://kenjirofukuda/imaging-pharo'.
					spec baseline: 'KFImaging' ].
			spec
				package: 'GdsFeel-UI'
				with: [ spec requires: #('KFImaging' 'NeoCSV' 'Model')
					"'CSV'" ].
			spec
				package: 'GdsFeel-Developer'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				package: 'GdsFeel-UI-Athens'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				project: 'CommandShell'
				with: [ spec repository: 'github://dtlewis290/CommandShell-Tonel/src'.
					spec baseline: 'CommandShell' ].
			spec package: 'KFConsole'.
			spec
				package: 'GdsFeel-CLI'
				with: [ spec requires: #('GdsFeel-Developer' 'CommandShell') ].
			spec
				package: 'GdsFeel-CLI-Commands'
				with: [ spec requires: #('GdsFeel-CLI') ].
			spec
				package: 'GdsFeel-CLI-Console'
				with: [ spec requires: #('GdsFeel-CLI-Commands' 'KFConsole') ].
			spec
				project: 'GlamourCore'
				with: [ spec
						baseline: 'GlamourCore';
						repository: 'github://moosetechnology/glamour/src' ].
			spec
				package: 'GdsFeel-CLI-Glamour'
				with: [ spec requires: #('GdsFeel-CLI' 'GlamourCore') ].
			spec
				package: 'GdsFeel-UI-Spec'
				with: [ spec requires: #('GdsFeel-UI') ].
			spec
				group: 'Foundation'
					with:
					#('GdsFeel-Foundation' 'GdsFeel-Foundation-Core' 'GdsFeel-Foundation-Notification' 'GdsFeel-Foundation-Property');
				group: 'Model'
					with:
					#('GdsFeel-Model-Basic' 'GdsFeel-Model-Container' 'GdsFeel-Model-EditSpace' 'GdsFeel-Model-Element' 'GdsFeel-Model-Private' 'GdsFeel-Model-Sandbox' 'GdsFeel-Model-Tests' 'GdsFeel-Model-Viewing');
				group: 'UI' with: #('GdsFeel-UI' 'GdsFeel-UI-Spec');
				group: 'Developer' with: #('GdsFeel-Developer');
				group: 'CLI' with: #('GdsFeel-CLI-Console').
			spec group: 'UI' with: #('GdsFeel-UI' 'GdsFeel-UI-Athens').
			spec group: 'default' with: #('Model' 'UI' 'CLI') ]
]

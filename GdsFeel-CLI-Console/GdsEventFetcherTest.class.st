"
A GdsEventFetcherTest is a test class for testing the behavior of GdsEventFetcher
"
Class {
	#name : #GdsEventFetcherTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-CLI-Console-Tests'
}

{ #category : #accessing }
GdsEventFetcherTest >> testFoo [
	| fetcher panel buttonsMap|
	fetcher := GdsEventFetcher new.
	fetcher installEventLoop.
	panel := GdsToolsBuilder buildByJsons.
	buttonsMap := panel valueOfProperty: #buttonsMap .
	buttonsMap keysAndValuesDo: [ :cmdName :button | 
		button actionBlock: [
			fetcher addHandler: [
				self inform: cmdName. 
				(Delay forSeconds: 2) wait]]].
	(buttonsMap at: 'QUIT')
		ifNotNil: [ :b |
			b actionBlock: [ 
				b enabled: false.
				fetcher quitAfter: [
					panel delete.
					self inform: 'FINISHED']]].
	panel announcer 
		on: MorphDeleted 
		do: [ fetcher terminateEventLoop ]
	

]

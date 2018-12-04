Class {
	#name : #PSMapview,
	#superclass : #RHModule,
	#instVars : [
		'map',
		'running'
	],
	#category : #'PolySLAM-Viz'
}

{ #category : #sync }
PSMapview >> initialize [
	running := false
]

{ #category : #sync }
PSMapview >> synchronize [
	self announcer when: MapAvailableEvent do:[:e|
		map ifNil: [ map := e data ].
		self announcer unsubscribe: self
	].
	[ self draw ]
]

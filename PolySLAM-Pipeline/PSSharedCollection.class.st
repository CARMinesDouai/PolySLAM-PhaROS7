Class {
	#name : #PSSharedCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'lock',
		'ptr'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #initialization }
PSSharedCollection >> add: el [
	"use put not add"
	self lock critical: [ super add: el ]
]

{ #category : #initialization }
PSSharedCollection >> atEnd [
	^ptr = self size
]

{ #category : #initialization }
PSSharedCollection >> initialize [
	super initialize.
	ptr := 0
]

{ #category : #initialization }
PSSharedCollection >> last [
	self lock critical: [ 
		self size = 0 ifTrue:[^nil].
		^super last ]
]

{ #category : #accessing }
PSSharedCollection >> lock [
	lock ifNil: [ lock := Semaphore forMutualExclusion  ].
	^ lock
]

{ #category : #initialization }
PSSharedCollection >> next [
	self atEnd ifTrue:[^nil].
	self lock critical: [ 
		ptr := ptr + 1.
		^self at: ptr
	]
]

{ #category : #initialization }
PSSharedCollection >> reset [
	self lock critical: [super reset. ptr := 0 ]
]

{ #category : #initialization }
PSSharedCollection >> resetPointer [
	self lock critical:[ptr := 0].
	
]

"
This class stores two points that have been matched as corresponding points of two point collections. 



Public API and Key Messages

- squaredDistance
	returns the squared (euclidean) distance between the two points. used to compute the matching score at the VMICP object
- outlier
	returns a boolean, indicating whether or not this pair is considered an outlier and should be ignored
- outlier: aBoolean
	sets the status of the pair as outlier (true) or inlier (false)
- first
	shorthand for 'at: 1'
- second
	shorthand for 'at: 2'


"
Class {
	#name : #VMMatchPair,
	#superclass : #Array,
	#type : #variable,
	#instVars : [
		'outlier'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'as yet unclassified' }
VMMatchPair class >> pointA: pA pointB: pB [
	^(self new: 2)
		initialize; "not called automatically, since 'Array new:' calls a primitive and bypasses normal initialization"
		at: 1 put: pA;
		at: 2 put: pB;
		yourself.
]

{ #category : #'as yet unclassified' }
VMMatchPair >> = aMatchPair [
	self == aMatchPair ifTrue: [ ^true ].
	self species == aMatchPair species ifFalse: [ ^false ].
	
	self first = aMatchPair first ifFalse: [ ^false ].
	self second = aMatchPair second ifFalse: [ ^false ].
	self outlier = aMatchPair outlier ifFalse: [ ^false ].
	
	^true.

]

{ #category : #accessing }
VMMatchPair >> bounds [
	self first ifNil: [
		self second ifNil: [ ^nil ].
		^self second bounds
	].

	self second ifNil: [ ^ self first bounds ].
	^ self first bounds merge: self second bounds
]

{ #category : #accessing }
VMMatchPair >> first [
	^self at: 1.
]

{ #category : #'as yet unclassified' }
VMMatchPair >> hash [
	^super hash bitXor: outlier hash
]

{ #category : #initialization }
VMMatchPair >> initialize [
	super initialize.
	outlier := false.
]

{ #category : #accessing }
VMMatchPair >> outlier [
	^outlier.
]

{ #category : #accessing }
VMMatchPair >> outlier: aBoolean [
	outlier := aBoolean.
]

{ #category : #accessing }
VMMatchPair >> second [
	^self at: 2.
]

{ #category : #'as yet unclassified' }
VMMatchPair >> squaredDistance [
	^(self at:1) squaredDistanceTo: (self at: 2).
]

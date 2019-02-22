Class {
	#name : #PSVertexKeyX,
	#superclass : #PSVertexKey,
	#instVars : [
		'origin'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSVertexKeyX >> compare: anotherKey [
	point x = anotherKey point x ifTrue: [
		"point type = anotherKey point type ifTrue: [ ^0 ].
		point type < anotherKey point type ifTrue:[^1] ifFalse:[^-1]."
		point y = anotherKey point y ifTrue: [
			point type = anotherKey point type ifTrue: [ 
				"multiple key at a vertex"
				point segments = anotherKey point segments
					ifTrue: [ ^0 ]
					ifFalse:[
							point segments first value length > anotherKey point segments first value length
								ifTrue:[^1]
								ifFalse:[^ -1]
					]
			].
			point type < anotherKey point type ifTrue:[^1] ifFalse:[^-1].
		].
		point y < anotherKey point y ifTrue: [ ^ -1 ].
		^ 1
	].
	point x < anotherKey point x ifTrue: [ ^ -1 ].
	^ 1
]

{ #category : #accessing }
PSVertexKeyX >> point: v [
	point := v.
	origin ifNil: [ origin := point ]
]

{ #category : #accessing }
PSVertexKeyX >> reset [
	point := origin.
]

{ #category : #accessing }
PSVertexKeyX >> switchTo: p [
	point setX: p x setY:p y.
]

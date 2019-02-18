Class {
	#name : #PSVertexKeyX,
	#superclass : #PSVertexKey,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSVertexKeyX >> compare: anotherKey [
	point x = anotherKey point x ifTrue: [
		point type = anotherKey point type ifTrue: [ ^0 ].
		point type < anotherKey point type ifTrue:[^1] ifFalse:[^-1].
	].
	point x < anotherKey point x ifTrue: [ ^ -1 ].
	^ 1
]

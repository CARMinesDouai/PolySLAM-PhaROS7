Class {
	#name : #PSVertexKeyY,
	#superclass : #PSVertexKey,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSVertexKeyY >> compare: anotherKey [
	point y = anotherKey point y ifTrue: [
		point x = anotherKey point x ifTrue: [
			"point type = anotherKey point type ifTrue: [ ^0 ]."
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
		point x < anotherKey point x ifTrue: [ ^ -1 ].
		^ 1
	].
	point y < anotherKey point y ifTrue: [ ^ -1 ].
	^ 1
]

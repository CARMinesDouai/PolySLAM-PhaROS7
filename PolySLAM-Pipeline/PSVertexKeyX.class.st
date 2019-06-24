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
	primary x = anotherKey primary x ifTrue: [
		"point type = anotherKey point type ifTrue: [ ^0 ].
		point type < anotherKey point type ifTrue:[^1] ifFalse:[^-1]."
		primary y = anotherKey primary y ifTrue: [
			"point vertexType = anotherKey point vertexType ifTrue: [ "
				"multiple key at a vertex"
				secondary = anotherKey secondary
					ifTrue: [ ^0 ]
					ifFalse:[
							secondary x = anotherKey secondary x ifTrue:[
								secondary y < anotherKey secondary y
									ifTrue:[ ^ -1 ] ifFalse:[^ 1]
							] ifFalse:[
								secondary x < anotherKey secondary x
									ifTrue:[ ^ -1 ] ifFalse:[^ 1]
							].
					].
			"]."
		].
		primary y < anotherKey primary y ifTrue: [ ^ -1 ].
		^ 1
	].
	primary x < anotherKey primary x ifTrue: [ ^ -1 ].
	^ 1
]

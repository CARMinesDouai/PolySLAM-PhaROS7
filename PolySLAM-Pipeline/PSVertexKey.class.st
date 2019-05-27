Class {
	#name : #PSVertexKey,
	#superclass : #PSKey,
	#instVars : [
		'primary',
		'secondary'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSVertexKey class >> from: aPoint [
	^ self new primary: aPoint asPoint; secondary: (aPoint segments first vertexFarestOf:aPoint ) asPoint; yourself
]

{ #category : #accessing }
PSVertexKey >> primary [
	^ primary
]

{ #category : #accessing }
PSVertexKey >> primary: anObject [
	primary := anObject
]

{ #category : #accessing }
PSVertexKey >> secondary [
	^ secondary
]

{ #category : #accessing }
PSVertexKey >> secondary: anObject [
	secondary := anObject
]

Class {
	#name : #PSVertexKey,
	#superclass : #Object,
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
PSVertexKey >> < anotherPoint [
	^ (self compare: anotherPoint) = -1
]

{ #category : #accessing }
PSVertexKey >> <= anotherPoint [
	^ (self < anotherPoint) | (self = anotherPoint)
]

{ #category : #accessing }
PSVertexKey >> = anotherKey [
	^ ((self compare: anotherKey) = 0) "and: (point vertexType = anotherKey point vertexType )"
]

{ #category : #accessing }
PSVertexKey >> > anotherPoint [
	^ (self compare: anotherPoint) = 1
]

{ #category : #accessing }
PSVertexKey >> >= anotherPoint [
	^ (self > anotherPoint) | (self = anotherPoint)
]

{ #category : #accessing }
PSVertexKey >> compare: aNotherPoint [
	^ self subclassResponsibility 
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

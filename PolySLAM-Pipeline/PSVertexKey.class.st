Class {
	#name : #PSVertexKey,
	#superclass : #Object,
	#instVars : [
		'point'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSVertexKey class >> from: aPoint [
	^ self new point: aPoint; yourself
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
	^ ((self compare: anotherKey) = 0) and: (point vertexType = anotherKey point vertexType )
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
PSVertexKey >> point [
	^ point
]

{ #category : #accessing }
PSVertexKey >> point: anObject [
	point := anObject
]

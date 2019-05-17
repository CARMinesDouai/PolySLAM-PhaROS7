Class {
	#name : #PSVertexDirectionKey,
	#superclass : #PSVertexKey,
	#instVars : [
		'unit'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSVertexDirectionKey class >> from: aPoint unitVector: vector [
	^ (self from: aPoint) unit: vector; yourself
]

{ #category : #accessing }
PSVertexDirectionKey >> compare: aNotherKey [
	"compare two point using unit vector"
	|seg vec scalar|
	self primary asPoint = aNotherKey primary asPoint 
		ifTrue:[^0].
	seg := PSLinkedEdge from: self primary  to: aNotherKey primary  type: 3.
	vec := seg directionVector.
	
	scalar := vec dotProduct: unit.
	
	scalar = 0 ifTrue:[^0].
	scalar <  0 ifTrue:[^1].
	^ -1
]

{ #category : #accessing }
PSVertexDirectionKey >> unit [
	^ unit
]

{ #category : #accessing }
PSVertexDirectionKey >> unit: anObject [
	unit := anObject
]

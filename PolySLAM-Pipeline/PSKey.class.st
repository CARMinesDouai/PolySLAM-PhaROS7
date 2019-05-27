Class {
	#name : #PSKey,
	#superclass : #Object,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSKey class >> from: aValue [
	^ self new from: aValue; yourself.
]

{ #category : #comparing }
PSKey >> < anotherKey [
	^ (self compare: anotherKey) = -1
]

{ #category : #comparing }
PSKey >> <= anotherKey [
	^ (self < anotherKey) | (self = anotherKey)
]

{ #category : #comparing }
PSKey >> = anotherKey [
	^ ((self compare: anotherKey) = 0) "and: (point vertexType = anotherKey point vertexType )"
]

{ #category : #comparing }
PSKey >> > anotherKey [
	^ (self compare: anotherKey) = 1
]

{ #category : #comparing }
PSKey >> >= anotherKey [
	^ (self > anotherKey) | (self = anotherKey)
]

{ #category : #accessing }
PSKey >> compare: aNotherPoint [
	^ self subclassResponsibility 
]

{ #category : #'instance creation' }
PSKey >> from: aValue [
	^ self subclassResponsibility 
]

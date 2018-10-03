"
This class stores vectors in a way that we can easily find vectors that have the same start/end points (in either order). We use this functionality to find vectors that are reversed and not necessarily have the same type.


Public API and Key Messages

- asOrderedCollection
	does as the name implies. used for debugging and visualization
- add: <aVector>
	adds a vector to the storage
- remove: <aVector>
	removes a vector from the storage. removing a vector that is not in the storage does nothing (e.g. no signals, etc. )
- collect: <aBlock>
	works like the normal #collect: method, returns an OrderedCollection instance
- findSimilarVectors: <aVector>
	returns a collection (OrderedCollection or empty Array) that contains all 'similar' vectors

	
Private Messages

- container
	returns a Dictionary instance that contains all vectors
- initialize
	creates the Dictionary instance


Instance Variables
	container:		<Dictionary>
		storage for the vectors

"
Class {
	#name : #VMVectorStorage,
	#superclass : #Object,
	#instVars : [
		'container'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #adding }
VMVectorStorage >> add: aVector [
	| key |
	
	key := self vectorHash: aVector.
	container
		at: key
		ifPresent: [ :vectorCollection |
			(vectorCollection includes: aVector) ifFalse: [
				vectorCollection add: aVector.
			].
		] ifAbsent: [ | vectorCollection |
			vectorCollection := OrderedCollection new.
			vectorCollection add: aVector.
			container at: key put: vectorCollection.
		].
	
]

{ #category : #adding }
VMVectorStorage >> addAll: aVectorCollection [
	aVectorCollection do: [ :aVector |
		self add: aVector
	].
	
]

{ #category : #converting }
VMVectorStorage >> asOrderedCollection [
	| result |
	
	result := OrderedCollection new.
	container do: [ :collection | result addAll: collection ].
	
	^ result
]

{ #category : #enumerating }
VMVectorStorage >> collect: aBlock [
	| result |
	
	result := OrderedCollection new.
	container
		do: [ :collection |
			result addAll: (collection collect: aBlock)
		].
	
	^ result
]

{ #category : #accessing }
VMVectorStorage >> container [
	^ container
]

{ #category : #helper }
VMVectorStorage >> findSimilarVectors: aVector [
	"returns a collection of vectors that share the same hash according to #vectorHash:.
	note (1): returns an empty collection if no vector with the same key are stored.
	note (2): if aVector is stored here, it will also be part of the returned collection.
	note (3): collections should not be modified, as changes will reflect here as well. create a
	copy if you need to modify the collection. same goes for the vectors in the collection.
	"
	| key |
	
	key := self vectorHash: aVector.
	container
		at: key
		ifPresent: [ :collection | ^ collection ]
		ifAbsent: [ ^{} ].
]

{ #category : #initialization }
VMVectorStorage >> initialize [
	super initialize.
	
	container := Dictionary new.
]

{ #category : #removing }
VMVectorStorage >> remove: aVector [
	| key |
	
	key := self vectorHash: aVector.
	container
		at: key
		ifPresent: [ :vectorCollection | vectorCollection remove: aVector ifAbsent: [] ]
	
]

{ #category : #helper }
VMVectorStorage >> vectorHash: aVector [
	^ aVector pointA hash bitXor: aVector pointB hash
]

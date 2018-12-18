Class {
	#name : #VMVectorChainCollection,
	#superclass : #OrderedCollection,
	#category : #'PolySLAM-Core-Line- & Vector Approximation'
}

{ #category : #'as yet unclassified' }
VMVectorChainCollection class >> fromTypelessVectorCollection: aCollection [
	^(self new)
		fromTypelessVectorCollection: aCollection;
		yourself.
]

{ #category : #'as yet unclassified' }
VMVectorChainCollection class >> fromVectorCollection: aCollection [
	^(self new)
		fromVectorCollection: aCollection;
		yourself.
]

{ #category : #'as yet unclassified' }
VMVectorChainCollection >> fromTypelessVectorCollection: aCollection [
	"takes a collection of vectors, seperates the collection into chains (collection of consecetive
	vectors of any type) and stores the chains."

	self add: VMVectorChain new.
	aCollection ifEmpty: [ ^self ].
	
	self first add: aCollection first.
	
	aCollection allButFirstDo: [ :vec |
		((vec pointA = self last last pointB) and: [vec type = self last last type]) ifFalse: [ self add: VMVectorChain new. ].
		self last add: vec.
	].
	
	self size > 1 ifTrue: [
		self last last pointB = self first first pointA ifTrue: [
			self last addAll: self first.
			self at:1 put: self last.
			self removeLast.
		]
	].
	
]

{ #category : #'as yet unclassified' }
VMVectorChainCollection >> fromVectorCollection: aCollection [
	"takes a collection of vectors, seperates the collection into chains (collection of consecetive
	vectors that also share the same type) and stores the chains."

	self add: VMVectorChain new.
	aCollection ifEmpty: [ ^self ].
	
	self first add: aCollection first.
	
	aCollection allButFirstDo: [ :vec |
		((vec pointA = self last last pointB) and: [vec type = self last last type]) ifFalse: [ self add: VMVectorChain new. ].
		self last add: vec.
	].	
	
]

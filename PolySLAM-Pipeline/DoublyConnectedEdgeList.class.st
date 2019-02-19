Class {
	#name : #DoublyConnectedEdgeList,
	#superclass : #DoubleLinkedList,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #enumerating }
DoublyConnectedEdgeList >> close [
	head ifNil: [ ^self ].
	head previousLink: tail.
	tail ifNil: [ ^self ].
	tail nextLink: head.	

]

{ #category : #enumerating }
DoublyConnectedEdgeList >> linksDo: block [
	"Execute block for each of the links that I hold internally."
	
	| current |
	head ifNil: [^ self].
	current := head.
	[ 
		block value: current.
		current := current nextLink.
		current isNil or: current = head 
	] whileFalse: [ ]
]

Class {
	#name : #VMDoubleEndedCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'offset'
	],
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> addFirst: obj [
	"this #addFirst causes the collection to grow into negative indices"
	offset := offset + 1.
	^ super addFirst: obj
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> at: index [
	"note: always returns an OrderedCollection instance, since #checkBoundaries will
	ensure that the index is valid."
	| newIndex |
	
	self checkBoundaries: index.
	
	newIndex := index + offset.
	^ super at: newIndex
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> at: index ifAbsent: aBlock [
	| newIndex |
	
	(index + offset) < (lastIndex - firstIndex) ifTrue: [ aBlock value. ^ nil ].
	(index + offset) < 0 ifTrue: [ aBlock value. ^ nil ].
	
	"self checkBoundaries: index."
	
	newIndex := index + offset.
	^ super at: newIndex
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> at: index put: obj [
	| newIndex |
	
	self checkBoundaries: index.
	newIndex := index + offset.
	^ super at: newIndex put: obj
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> checkBoundaries: index [
	| newIndex |
	newIndex := index + offset.
	
	"expand boundaries if necessary. we insert empty OrderedCollection instances into newly created entries"
	[newIndex < firstIndex]
		whileTrue: [
			self addFirst: OrderedCollection new.
			"#addFirst modifies 'offset'."
			newIndex := index + offset. ].
	[newIndex > (lastIndex - firstIndex)] whileTrue: [ self add: OrderedCollection new. ].

]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> initialize [
	offset := 0.
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> offset [
	^ offset
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> reset [
	super reset.
	offset ifNil: [ offset := 0. ].
]

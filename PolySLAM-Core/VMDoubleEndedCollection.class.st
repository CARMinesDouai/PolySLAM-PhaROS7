Class {
	#name : #VMDoubleEndedCollection,
	#superclass : #Object,
	#instVars : [
		'storage',
		'offset',
		'newEntryBlock'
	],
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #'instance creation' }
VMDoubleEndedCollection class >> newWithEntryBlock: entryBlock [
	^ self new
		newEntryBlock: entryBlock;
		yourself
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> addFirst: entry [
	storage addFirst: entry.
	offset := offset + 1.
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> addLast: entry [
	storage add: entry.
]

{ #category : #accessing }
VMDoubleEndedCollection >> at: index [
	| newIndex |
	
	self checkBoundary: index.
	newIndex := index + offset.
	
	^ storage at: newIndex

]

{ #category : #accessing }
VMDoubleEndedCollection >> at: index ifAbsent: aBlock [
	| newIndex |
	newIndex := index + offset.
	^ storage at: newIndex ifAbsent: [ aBlock value. ^ nil ]
]

{ #category : #accessing }
VMDoubleEndedCollection >> at: index put: entry [
	| newIndex |
	
	self checkBoundary: index.
	newIndex := index + offset.
	
	^ storage at: newIndex put: entry

]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollection >> checkBoundary: index [
	| newIndex |
	newIndex := index + offset.
	
	"expand boundaries if necessary. we insert 'newEntryBlock value' into newly created entries"
	[newIndex < 1]
		whileTrue: [
			"note: #addFirst modifies 'offset'."
			self addFirst: newEntryBlock value.
			newIndex := index + offset. ].
	
	[newIndex > (storage size)] whileTrue: [ self addLast: newEntryBlock value. ].

]

{ #category : #enumerating }
VMDoubleEndedCollection >> do: aBlock [
	storage do: aBlock.

]

{ #category : #enumerating }
VMDoubleEndedCollection >> doWithIndex: aBlock [
	| index |
	index := 1 - offset.
	storage do: [ :entry |
		aBlock cull: entry cull: index.
		index := index + 1. ].
]

{ #category : #initialization }
VMDoubleEndedCollection >> initialize [
	super initialize.
	
	storage := OrderedCollection new.
	offset := 2.
	newEntryBlock := [ OrderedCollection new ]
]

{ #category : #accessing }
VMDoubleEndedCollection >> newEntryBlock: aBlock [
	"Transcript show: 'setting newEntryBlock'; cr."
	newEntryBlock := aBlock.
]

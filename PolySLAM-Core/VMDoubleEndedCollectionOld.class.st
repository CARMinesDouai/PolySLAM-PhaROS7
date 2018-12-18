"
This is an OrderedCollection-based collection that can grow in both sides, allowing negative indices.

note: newly created entries duo to growth are initialized to contain 'newEntryBlock value' (default
creates an OrderedCollection instance) instead of nil. this is for convenience at the class that employs
VMDoubleEndedCollection: the VMNNVectorGrid class


Instance Variables
	offset: <Number>
		this is the offset to translate from external index to internal index.
		for example, with offset := 4, a ""at: 1"" call would translate to an internal index of 1 + 4 = 5
	newEntryBlock
		a BlockClosure instance that is called every time a new empty entry is created while the
		double-ended collection is growing
		
Examples:
	""creates a double-ended collection. each cell contains 'nil' by default""
	dec := VMDoubleEndedCollection newWithEntryBlock: [ nil ].
	dec at: 3 put: 1.
	dec at: 3. ""answers '3'""
	dec at: 1. ""answers 'nil'""

	""creates a 2D matrix that can grow in any Direction. Each cell contains an OrderedCollection instance by default""
	VMDoubleEndedCollection newWithEntryBlock: [VMDoubleEndedCollection new].

	""creates a 2D matrix that can grow in any Direction. Each cell contains 0 by default""
	VMDoubleEndedCollection newWithEntryBlock: [VMDoubleEndedCollection newWithEntryBlock:[ 0 ]].


"
Class {
	#name : #VMDoubleEndedCollectionOld,
	#superclass : #OrderedCollection,
	#instVars : [
		'offset',
		'newEntryBlock'
	],
	#category : #'PolySLAM-Core-Collections'
}

{ #category : #'instance creation' }
VMDoubleEndedCollectionOld class >> new [
	^ super new
		initialize;
		yourself
]

{ #category : #'instance creation' }
VMDoubleEndedCollectionOld class >> newWithEntryBlock: aBlock [
	"allows to set a custom block closure that is called when the collection grows to set the newly created entries"
	^self new
		newEntryBlock: aBlock;
		yourself
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> addFirst: obj [
	"this #addFirst causes the collection to grow into negative indices"
	offset := offset + 1.
	^ super addFirst: obj
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> at: index [
	"note: always returns an OrderedCollection instance (or whatever newEntryBlock creates),
	since #checkBoundaries will ensure that the index is valid."
	| newIndex |
	
	self checkBoundaries: index.
	
	newIndex := index + offset.
	^ super at: newIndex
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> at: index ifAbsent: aBlock [
	| newIndex |
	
	(index + offset) > (lastIndex) ifTrue: [ aBlock value. ^ nil ].
	(index + offset) < firstIndex ifTrue: [ aBlock value. ^ nil ].
	
	"self checkBoundaries: index."
	
	newIndex := index + offset.
	^ super at: newIndex
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> at: index put: obj [
	| newIndex |
	
	self checkBoundaries: index.
	newIndex := index + offset.
	^ super at: newIndex put: obj
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> checkBoundaries: index [
	| newIndex |
	newIndex := index + offset.
	
	"expand boundaries if necessary. we insert 'newEntryBlock value' into newly created entries"
	[newIndex < firstIndex]
		whileTrue: [
			self addFirst: newEntryBlock value.
			"note: #addFirst modifies 'offset'."
			newIndex := index + offset. ].
	[newIndex > (lastIndex - firstIndex+1)] whileTrue: [ self add: newEntryBlock value. ].

]

{ #category : #enumerating }
VMDoubleEndedCollectionOld >> do: elementBlock separatedBy: separatorBlock [
	"required, because otherwise GTInspector would constantly poll on indices that don't exist,
	causing the collection to grow and grow."

	1 to: self size do:
		[:index |
		index = 1 ifFalse: [separatorBlock value].
		elementBlock value: (array at: index)]
]

{ #category : #enumerating }
VMDoubleEndedCollectionOld >> doWithIndex: elementAndIndexBlock [
	1 to: self size do: [ :index | elementAndIndexBlock value: (self at: index-offset) value: index-offset ]
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> initialize [
	super initialize.
	offset := 0.
	newEntryBlock := [ OrderedCollection new ].

]

{ #category : #private }
VMDoubleEndedCollectionOld >> makeRoomAtFirst [
	"Make some empty slots at the front of the array. If we have more than 50% free space, then just move the elements, so that the first 50% of the slots are free, otherwise add new free slots to the front by growing. Precondition: firstIndex = 1"
	
	| tally newFirstIndex newLastIndex |
	tally := self size.
	
	"if we are more than 50% full then we allocate more memory"
	tally * 2 >= array size ifTrue: [ Transcript show: 'growAtFirst'; cr. ^self growAtFirst ].
	
	"if we are empty we just adjust offset"
	tally = 0 ifTrue: [ Transcript show: 'resetTo';cr. ^self resetTo: array size + 1 ].
	
	"we have at least 50% free space, so we just move the entries"
	Transcript show: 'shift entries'; cr.
	newFirstIndex := array size // 2 + 1.
	"offset := offset + newFirstIndex - firstIndex."
	newLastIndex := newFirstIndex - firstIndex + lastIndex.
	0 to: tally - 1 do: [ :o |
		array at: newLastIndex - o put: (array at: lastIndex - o) ].
	array from: firstIndex to: newFirstIndex - 1 put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : #accessing }
VMDoubleEndedCollectionOld >> newEntryBlock: aBlock [
	Transcript show: 'setting newEntryBlock'; cr.
	newEntryBlock := aBlock.
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> offset [
	^ offset
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> offset: anInteger [
	offset := anInteger.
]

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionOld >> reset [
	super reset.
	offset ifNil: [ offset := 0. ].
]

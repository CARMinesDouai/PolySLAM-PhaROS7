Class {
	#name : #VMDoubleEndedCollectionTest,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #'as yet unclassified' }
VMDoubleEndedCollectionTest >> testAtPut [
	| collection data |
	collection := VMDoubleEndedCollection new.
	data := {
		{3.  'a'}.
		{0.  'b'}.
		{1.  'c'}.
		{-2.  'd'}.
		{-5.  'e'}.
		{1.  'f'}.
	}.
	data do: [ :pair |
		collection at: pair first put: pair second.
	].
	
	self assert: (collection at: (data at: 1) first) equals: ((data at: 1) second).
	self assert: (collection at: (data at: 2) first) equals: ((data at: 2) second).
	self assert: (collection at: (data at: 4) first) equals: ((data at: 4) second).
	self assert: (collection at: (data at: 5) first) equals: ((data at: 5) second).
	self assert: (collection at: (data at: 6) first) equals: ((data at: 6) second).

]

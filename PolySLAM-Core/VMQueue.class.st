Class {
	#name : #VMQueue,
	#superclass : #Object,
	#instVars : [
		'storage',
		'first',
		'size'
	],
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #private }
VMQueue >> checkSize [
	"increases the storage capacity if 'storage' is full"
	size >= storage size ifTrue: [
		self grow. ].
]

{ #category : #private }
VMQueue >> grow [
	"enlarges 'array' to twice the old size and copies the content.
	first is reset to 1, since the elements have been shifted"
	| newStorage |
	newStorage := Array new: (storage size * 2).
	1 to: storage size do: [ :i |
		newStorage at: i put: (storage atWrap: (i+first-1)).
	].
	first := 1.
	storage := newStorage.
]

{ #category : #initialization }
VMQueue >> initialize [
	storage := Array new: 10.
	first := 1.
	size := 0.
]

{ #category : #testing }
VMQueue >> isEmpty [
	^ size < 1
]

{ #category : #removing }
VMQueue >> peek [
	size < 1 ifTrue: [^ self error: 'pop failed: queue is empty'].
	^ storage atWrap: (first + size).

]

{ #category : #removing }
VMQueue >> pop [
	| result |
	size < 1 ifTrue: [^ self error: 'pop failed: queue is empty'].
	result := storage atWrap: first.
	first := first + 1.
	size := size - 1.
	^ result
]

{ #category : #adding }
VMQueue >> push: anObject [
	self checkSize.
	storage atWrap: first + size put: anObject.
	size := size + 1.
]

{ #category : #accessing }
VMQueue >> size [
	^ size
]

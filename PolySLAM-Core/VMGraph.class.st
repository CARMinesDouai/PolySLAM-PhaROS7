Class {
	#name : #VMGraph,
	#superclass : #Set,
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'rendering support' }
VMGraph class >> rendererClass [
	^VMGraphRenderer
]

{ #category : #converting }
VMGraph >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #accessing }
VMGraph >> atSector: aPolygon [
	| index start |
	index := start := aPolygon hash \\ array size + 1.
	[ 
		| element |
		((element := array at: index) == nil) ifTrue: [ self error: 'not found'. ^ nil ].
		(element enclosedSetElement sector = aPolygon) ifTrue: [ ^ array at: index ].
		(index := index \\ array size + 1) = start ] whileFalse.
	
	self errorNoFreeSpace
]

{ #category : #accessing }
VMGraph >> bounds [
	| rect anyOne |
	
	self ifEmpty: [ ^nil ].
	anyOne := self anyOne.
	rect := Rectangle origin: anyOne center corner: anyOne center.
	
	self do: [ :node |
		rect := rect encompass: node center.
	].

	^ rect

]

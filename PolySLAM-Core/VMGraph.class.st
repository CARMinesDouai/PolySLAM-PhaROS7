Class {
	#name : #VMGraph,
	#superclass : #Set,
	#category : #'PolySLAM-Core-Collections, Trees & Graphs'
}

{ #category : #'rendering support' }
VMGraph class >> rendererClass [
	^VMGraphRenderer
]

{ #category : #'as yet unclassified' }
VMGraph >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #'as yet unclassified' }
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

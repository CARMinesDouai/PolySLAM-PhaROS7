Class {
	#name : #VMBaseNode,
	#superclass : #Object,
	#instVars : [
		'node'
	],
	#category : #'PolySLAM-PhaROS-Examples-Nodes'
}

{ #category : #'as yet unclassified' }
VMBaseNode class >> node: aNode [
	^self new
		node: aNode;
		yourself.
]

{ #category : #'as yet unclassified' }
VMBaseNode >> convertMap: aMap toMsg: aMsg [
	
	aMap lineSegments do: [ :lineSeg |
		"add pointA"
		aMsg vertices add: ( Vector_mapsvm_vertex new
			x: lineSeg pointA x;
			y: lineSeg pointA y;
			type: lineSeg type asInteger;
			flags: 0).
		
		"add pointB"
		aMsg vertices add: ( Vector_mapsvm_vertex new
			x: lineSeg pointB x;
			y: lineSeg pointB y;
			type: lineSeg type asInteger;
			flags: 0).
	].
	
	^aMsg.

]

{ #category : #initialization }
VMBaseNode >> initialize [
	self logCr: 'executing: ', self class printString.
]

{ #category : #accessing }
VMBaseNode >> node [
	^node.
]

{ #category : #accessing }
VMBaseNode >> node: aNode [
	node := aNode.
]

{ #category : #accessing }
VMBaseNode >> robotPrefix [
	^VMROSOptions robotPrefix
]

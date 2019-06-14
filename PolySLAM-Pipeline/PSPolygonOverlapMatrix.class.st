Class {
	#name : #PSPolygonOverlapMatrix,
	#superclass : #PMMatrix,
	#instVars : [
		'zeros'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSPolygonOverlapMatrix class >> from: list [
	|matrix|
	matrix := self zerosRows: list size cols:list size.
	matrix from: list.
	^ matrix
]

{ #category : #checking }
PSPolygonOverlapMatrix >> checkContackOf:pA and: pB [
	|collection idx helper|
	idx := 1.
	collection := OrderedCollection new.
	pA asDoublyConnectedEdgeList linksDo:[:e| e id:idx. collection add:e. idx := idx +1.].
	pB asDoublyConnectedEdgeList linksDo:[:e| e id:idx. collection add:e. idx := idx +1].
	helper := PSInflateDecisionHelper from: collection.
	^(helper isDisjoint ) not
]

{ #category : #checking }
PSPolygonOverlapMatrix >> checkIntersetionOf: pA and: pB [
	|helper|
	helper := PSPolygonIntersectionHelper from: pA and: pB.
	helper perform.
	
	^(helper intersections isEmpty) not 
]

{ #category : #'instance creation' }
PSPolygonOverlapMatrix >> from: list [
	|len pA pB v|
	len := list size.
	zeros := true.
	1 to:len do:[:i|
		i to:len do:[:j|
			i = j ifFalse:[
				pA := list at: i.
				pB := list at: j.
				v := ( (self checkIntersetionOf: pA and:pB ) or: (self checkContackOf: pA and:pB ) ) ifTrue: [ 1 ] ifFalse: [ 0 ].
				v = 1 ifTrue:[zeros := false].
				self at: i at: j put: v
			]
		]
	]
]

{ #category : #accessing }
PSPolygonOverlapMatrix >> nextPair [
	|len|
	zeros ifTrue: [ ^ nil ].
	len := self numberOfRows.
	1 to: len do:[:i|
		i to: len do:[:j|
			(self at:i at:j) = 1
				ifTrue:[ ^ i@j ]]].
	^ nil
]

{ #category : #accessing }
PSPolygonOverlapMatrix >> zeros [
	^ zeros
]

{ #category : #accessing }
PSPolygonOverlapMatrix >> zeros: anObject [
	zeros := anObject
]

"
a normal Point, but with reference to the line segments it belongs to and type
"
Class {
	#name : #PSVertex,
	#superclass : #Point,
	#instVars : [
		'type',
		'segments'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'as yet unclassified' }
PSVertex class >> endOf: line [
	|o|

	o := line value pointB asPSVertex.
	o vertexType: 1.
	o segments removeAll.
	o segments add: line.
	line value pointB: o.
	^o
]

{ #category : #'as yet unclassified' }
PSVertex class >> intersectionOf: lineA and: lineB [
	|o intersection|
	
	(lineA isCollinearWith: lineB) ifTrue:[^nil].
	intersection := VMIntersection intersectLine: lineA value withLine: lineB value.
	
	(intersection insideLineASegment & intersection insideLineBSegment ) ifFalse: [ ^nil ].
	o := intersection intersectionPoint asPSVertex.
	o vertexType: -1.
	o segments add: lineA; add: lineB.
	"o intersectionAngle abs > 0.15 ifFalse:[^nil]."
	"(lineA value pointA = lineB value pointA) ifTrue: [ o inspect. self halt. ]."
	^o
]

{ #category : #'as yet unclassified' }
PSVertex class >> startOf: line [
	|o|
	o := line value pointA asPSVertex.
	o vertexType: 0.
	o segments removeAll.
	o segments add: line.
	line value pointA: o.
	^o
]

{ #category : #comparing }
PSVertex >> = anotherPoint [
	|vertex|
	vertex := anotherPoint asPSVertex.
	^(vertex asPoint = self asPoint) & (type = vertex vertexType ) & (segments = vertex segments)
]

{ #category : #converting }
PSVertex >> asPSVertex [
	^ self
]

{ #category : #converting }
PSVertex >> asPoint [
	^ (self x) @ (self y)
]

{ #category : #converting }
PSVertex >> fromPoint: p [
	self setX: p x setY: p y
]

{ #category : #utilities }
PSVertex >> getInnerPivotLine [
	^ self getPivotLine: true 
]

{ #category : #utilities }
PSVertex >> getOuterPivotLine [
	^ self getPivotLine: false
]

{ #category : #utilities }
PSVertex >> getPivotLine [
	^ self getInnerPivotLine
]

{ #category : #utilities }
PSVertex >> getPivotLine: isInner [
	|pivot line|
	self vertexType = -1 ifFalse:[^self segments first ].
	pivot := self segments first.
	line := self segments second.
	"mixte type return red"
	pivot value type asInteger  = line value type asInteger ifFalse: [ 
		^ self pivotLineByType
	].
	"red line, obstacle"
	pivot value type asInteger = 1 ifTrue:[
		^ self selectPivot: isInner
	].
	"green line, frontier, select outer"
	^self selectPivot: isInner not.
]

{ #category : #initialization }
PSVertex >> initialize [
	super initialize.
	type := 0.
	segments  := OrderedCollection new
]

{ #category : #utilities }
PSVertex >> intersectionAngle [
	self vertexType = -1 ifFalse:[^0].
	^((self segments first angle) - (self segments second angle))
]

{ #category : #testing }
PSVertex >> isEnd [
	^ type = 1
]

{ #category : #testing }
PSVertex >> isEndPoint [
	|t|
	t := 0.002.
	segments do:[:e|
		((self inrangeOf: e value pointA radius:t  ) | (self inrangeOf: e value pointB radius:t  ))	ifTrue:[^ true]].
	^ false
]

{ #category : #testing }
PSVertex >> isIntersection [
	^ type = -1
]

{ #category : #testing }
PSVertex >> isIntersectionAtEnd [
	type = -1 ifFalse:[^ false].
	self isEndPoint ifFalse:[^ false].
	(self inrangeOf: segments first value pointB ) ifTrue:[^true].
	^(self inrangeOf: segments second value pointB)
]

{ #category : #testing }
PSVertex >> isIntersectionAtStart [
	type = -1 ifFalse:[^ false].
	self isEndPoint ifFalse:[^ false].
	(self inrangeOf: segments first value pointA ) ifTrue:[^true].
	^ (self inrangeOf: segments second value pointA).
]

{ #category : #testing }
PSVertex >> isStart [
	^ (type = 0) 
]

{ #category : #utilities }
PSVertex >> pivotLineByType [
|pivot line|
pivot := self segments first.
line := self segments second.
pivot value type asInteger > line value type asInteger ifTrue:[
	pivot := line	
].
^ pivot
]

{ #category : #accessing }
PSVertex >> segments [
	^ segments
]

{ #category : #accessing }
PSVertex >> segments: anObject [
	segments := anObject
]

{ #category : #utilities }
PSVertex >> selectPivot:isInner [
|pivot line|
pivot := self segments first.
line := self segments second.


self isEndPoint ifTrue:[
	"intersection at start"
	(self isIntersectionAtStart) ifTrue:[
		(pivot value isPointOnRightSide: line value pointB)
			ifTrue:[ isInner ifTrue:[^pivot] ifFalse:[ ^line]]
			ifFalse:[ isInner ifTrue:[^line] ifFalse:[ ^pivot]	]
	].
	"intersection at end"
	(pivot value isPointOnRightSide: line value pointA)
			ifTrue:[isInner ifTrue:[^pivot] ifFalse:[^line]]
			ifFalse:[isInner ifTrue:[^line] ifFalse:[^pivot]].
].

(pivot value isPointOnRightSide: line value pointA)
	ifTrue:[
		isInner ifTrue: [ ^line ] ifFalse: [ ^pivot ] 
	] ifFalse:[
		isInner ifTrue: [ ^pivot ] ifFalse: [ ^line ] 
	].
]

{ #category : #accessing }
PSVertex >> vertexType [
	^ type
]

{ #category : #accessing }
PSVertex >> vertexType: anObject [
	type := anObject
]

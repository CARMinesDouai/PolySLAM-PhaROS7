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
	o := self new.
	o setX: line value pointB x setY: line value pointB y.
	o vertexType: 1.
	o segments add: line.
	^o
]

{ #category : #'as yet unclassified' }
PSVertex class >> intersectionOf: lineA and: lineB [
	|o p intersection|
	o := self new.
	
	(lineA isCollinearWith: lineB) ifTrue:[^nil].
	intersection := VMIntersection intersectLine: lineA value withLine: lineB value.
	
	(intersection insideLineASegment & intersection insideLineBSegment ) ifFalse: [ ^nil ].
	p := intersection intersectionPoint.

	o vertexType: -1.
	o setX: p x setY: p y.
	o segments add: lineA; add: lineB.
	"(lineA value pointA = lineB value pointA) ifTrue: [ o inspect. self halt. ]."
	^o
]

{ #category : #'as yet unclassified' }
PSVertex class >> startOf: line [
	|o|
	o := self new.
	o setX: line value pointA x setY: line value pointA y.
	o vertexType: 0.
	o segments add: line.
	^o
]

{ #category : #converting }
PSVertex >> asPoint [
	^ (self x) @ (self y)
]

{ #category : #initialization }
PSVertex >> getPivotLine [
	self segmentsDo: [ :p :l|
		p ifNotNil: [ ^ p ].
		^l	
	]
]

{ #category : #initialization }
PSVertex >> initialize [
	super initialize.
	type := 0.
	segments  := OrderedCollection new
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
PSVertex >> isStart [
	^ (type = 0) 
]

{ #category : #accessing }
PSVertex >> segments [
	^ segments
]

{ #category : #accessing }
PSVertex >> segments: anObject [
	segments := anObject
]

{ #category : #initialization }
PSVertex >> segmentsDo: aBlock [
	|pivot line|
	self vertexType = -1 ifFalse:[^aBlock value: nil value: self segments first ].
	pivot := self segments first.
	line := self segments second.
	"check for co linear first"
	self isEndPoint ifTrue:[
		(pivot value isPointOnRightSide: line value pointB)
			ifTrue:[
				^aBlock value: line value: pivot]
			ifFalse:[
				^aBlock value: pivot value: line]
	].
	(pivot value isPointOnRightSide: line value pointA)
	ifFalse:[
		^aBlock value: line value: pivot 
	].
	^ aBlock value: pivot value:line
]

{ #category : #accessing }
PSVertex >> vertexType [
	^ type
]

{ #category : #accessing }
PSVertex >> vertexType: anObject [
	type := anObject
]
